#include "GDRcOverride.h"
#include "GDRcOverrideWorker.h"

#include "QGCApplication.h"
#include "QGCToolbox.h"
#include "MAVLinkProtocol.h"
#include "MultiVehicleManager.h"
#include "Vehicle.h"
#include "VehicleLinkManager.h"

#include <QCoreApplication>
#include <QQmlEngine>
#include <QThread>

namespace {

// Perda de comunicação seguida com o veículo que desliga o override
constexpr int kCommLostStopMs = 30 * 1000;

}

GDRcOverride* GDRcOverride::instance()
{
    // Filho do app: vive mais que o motor QML que o usa
    static GDRcOverride* rcOverride = new GDRcOverride(qgcApp());
    return rcOverride;
}

void GDRcOverride::registerQmlTypes()
{
    qmlRegisterSingletonType<GDRcOverride>("GD.RcOverride", 1, 0, "GDRcOverride", [](QQmlEngine*, QJSEngine*) -> QObject* {
        GDRcOverride* rcOverride = instance();
        QQmlEngine::setObjectOwnership(rcOverride, QQmlEngine::CppOwnership);
        return rcOverride;
    });
}

GDRcOverride::GDRcOverride(QObject* parent)
    : QObject(parent)
{
    if (!available()) {
        return;
    }

    // Timer preciso: com 30 s o padrão (CoarseTimer) passa a ter resolução de
    // 1 s e pode disparar antes dos 30 s
    _commLostTimer.setSingleShot(true);
    _commLostTimer.setTimerType(Qt::PreciseTimer);
    _commLostTimer.setInterval(kCommLostStopMs);
    connect(&_commLostTimer, &QTimer::timeout, this, &GDRcOverride::_commLostTimeout);

    MultiVehicleManager* multiVehicleManager = qgcApp()->toolbox()->multiVehicleManager();
    connect(multiVehicleManager, &MultiVehicleManager::activeVehicleChanged, this, &GDRcOverride::_activeVehicleChanged);
    connect(multiVehicleManager, &MultiVehicleManager::vehicleRemoved,       this, &GDRcOverride::_vehicleRemoved);

    // Ao fechar o app o veículo ainda existe: devolve os canais, pede ao UniRC7
    // o fim do envio e espera a thread
    connect(qApp, &QCoreApplication::aboutToQuit, this, [this]() {
        _setRunning(false);
        _stopWorker(true, true);
    });
}

GDRcOverride::~GDRcOverride()
{
    // Normalmente a thread já terminou no aboutToQuit. Aqui o veículo pode não
    // existir mais: sem liberação, mas o pedido de fim ao UniRC7 sai.
    _stopWorker(false, true);
}

bool GDRcOverride::available() const
{
#ifdef GD_FEATURE_RC_OVERRIDE
    return true;
#else
    return false;
#endif
}

bool GDRcOverride::start()
{
    if (!available()) {
        _setLastError(tr("RC Override não disponível neste produto"));
        return false;
    }
    if (_running) {
        return true;
    }

    Vehicle* vehicle = qgcApp()->toolbox()->multiVehicleManager()->activeVehicle();
    if (!vehicle) {
        _setLastError(tr("Nenhum veículo conectado"));
        return false;
    }

    // Um stop() logo antes pode ainda estar enviando o pedido de fim ao UniRC7
    // e a liberação (até 80 ms)
    _stopWorker(true, true);

    MAVLinkProtocol*    mavlink = qgcApp()->toolbox()->mavlinkProtocol();
    GDRcOverrideWorker* worker  = new GDRcOverrideWorker(vehicle,
                                                         static_cast<uint8_t>(mavlink->getSystemId()),
                                                         static_cast<uint8_t>(mavlink->getComponentId()));
    worker->setLink(vehicle->vehicleLinkManager()->primaryLink());

    QThread* thread = new QThread();
    thread->setObjectName(QStringLiteral("GDRcOverride"));
    worker->moveToThread(thread);
    thread->start();

    // O socket é aberto na thread onde vai viver. O bind é imediato; esperar o
    // resultado evita mostrar o override ligado com a porta fechada.
    bool    opened = false;
    QString error;
    QMetaObject::invokeMethod(worker, [worker, &opened, &error]() { opened = worker->open(&error); }, Qt::BlockingQueuedConnection);
    if (!opened) {
        thread->quit();
        thread->wait();
        delete worker;
        delete thread;
        _setLastError(error);
        return false;
    }

    _thread     = thread;
    _worker     = worker;
    _vehicle    = vehicle;

    // Fim normal da thread depois de um stop() sem espera
    const quint32 generation = ++_workerGeneration;
    connect(thread, &QThread::finished, this, [this, generation]() {
        if (_thread && generation == _workerGeneration) {
            _thread->wait();
            _deleteWorker();
        }
    });

    VehicleLinkManager* vehicleLinkManager = vehicle->vehicleLinkManager();
    _linkConnection = connect(vehicleLinkManager, &VehicleLinkManager::primaryLinkChanged, this, &GDRcOverride::_primaryLinkChanged);

    // Desliga sozinho após 30 s seguidos sem comunicação com este veículo
    // (vale também se a comunicação já estava perdida ao ligar)
    _commLostConnection = connect(vehicleLinkManager, &VehicleLinkManager::communicationLostChanged, this, &GDRcOverride::_communicationLostChanged);
    _communicationLostChanged(vehicleLinkManager->communicationLost());

    // Como antes: o joystick do QGC disputaria os canais com o override. A
    // escolha fica salva no veículo e não é religada no stop().
    vehicle->setJoystickEnabled(false);

    // Como antes: RC_CHANNELS_RAW (id 35) a cada 20 ms, sem desfazer no stop()
    vehicle->sendMavCommand(MAV_COMP_ID_AUTOPILOT1,
                            MAV_CMD_SET_MESSAGE_INTERVAL,
                            true,                                               // mostra erros
                            static_cast<float>(MAVLINK_MSG_ID_RC_CHANNELS_RAW),
                            20000.0f);                                          // us

    _setLastError(QString());
    _setRunning(true);
    return true;
}

void GDRcOverride::stop()
{
    if (!_running) {
        return;
    }

    _setRunning(false);

    // Sem esperar: o pedido de fim ao UniRC7 e a liberação seguem na thread do worker
    _stopWorker(true, false);
}

void GDRcOverride::_activeVehicleChanged(Vehicle* vehicle)
{
    // A liberação vai para o veículo que estava em override, que continua existindo
    if (_running && vehicle != _vehicle) {
        stop();
    }
}

void GDRcOverride::_vehicleRemoved(Vehicle* vehicle)
{
    if (!_worker || vehicle != _vehicle) {
        return;
    }

    // O veículo é apagado logo depois deste sinal e a thread usa o ponteiro dele:
    // espera ela terminar (cerca de 40 ms do pedido de fim ao UniRC7). Sem
    // liberação, pois o veículo já perdeu os links.
    _setRunning(false);
    _stopWorker(false, true);
}

void GDRcOverride::_primaryLinkChanged()
{
    if (_worker && _vehicle) {
        _worker->setLink(_vehicle->vehicleLinkManager()->primaryLink());
    }
}

/// Conta a perda de comunicação seguida: começa na perda, cancela na volta
void GDRcOverride::_communicationLostChanged(bool communicationLost)
{
    if (!communicationLost) {
        _commLostTimer.stop();
    } else if (!_commLostTimer.isActive()) {
        _commLostTimer.start();
    }
}

void GDRcOverride::_commLostTimeout()
{
    // Confere de novo: a volta da comunicação pode ter chegado junto com o fim do tempo
    if (!_running || !_vehicle || !_vehicle->vehicleLinkManager()->communicationLost()) {
        return;
    }

    const QString reason = tr("RC Override desligado: sem comunicação com o veículo por %1 s").arg(kCommLostStopMs / 1000);
    _setLastError(reason);
    stop();
    qgcApp()->showAppMessage(reason);
}

/// Pede o fim da thread do worker, que antes pede ao UniRC7 o fim do envio dos
/// canais. sendRelease: devolve os canais ao rádio antes de terminar. wait:
/// espera a thread acabar (veículo saindo, app fechando): até 80 ms com
/// liberação, 40 ms sem.
void GDRcOverride::_stopWorker(bool sendRelease, bool wait)
{
    if (!_worker) {
        return;
    }

    _worker->halt();
    if (!sendRelease) {
        _worker->skipRelease();
    }

    if (!_workerFinishing) {
        _workerFinishing = true;
        disconnect(_linkConnection);
        disconnect(_commLostConnection);
        _commLostTimer.stop();
        GDRcOverrideWorker* worker = _worker;
        QMetaObject::invokeMethod(worker, [worker]() { worker->finish(); }, Qt::QueuedConnection);
    }

    if (wait) {
        _thread->wait();
        _deleteWorker();
    }
}

/// Só com a thread já terminada
void GDRcOverride::_deleteWorker()
{
    delete _worker;
    delete _thread;
    _worker             = nullptr;
    _thread             = nullptr;
    _vehicle            = nullptr;
    _workerFinishing    = false;
}

void GDRcOverride::_setRunning(bool running)
{
    if (_running != running) {
        _running = running;
        emit runningChanged(_running);
    }
}

void GDRcOverride::_setLastError(const QString& error)
{
    if (_lastError != error) {
        _lastError = error;
        emit lastErrorChanged();
    }
}
