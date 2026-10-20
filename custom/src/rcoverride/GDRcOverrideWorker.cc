#include "GDRcOverrideWorker.h"
#include "Vehicle.h"

#include <QHostAddress>
#include <QThread>
#include <QTimer>
#include <QUdpSocket>

#include <algorithm>
#include <limits>

namespace {

// UniRC7 (SDK SiYi): mesmos endereço e portas das versões anteriores
const char* const       kUniRcAddress       = "192.168.144.20";
constexpr quint16       kUniRcPort          = 19856;
constexpr quint16       kLocalPort          = 19857;
constexpr uint8_t       kChannelRate20Hz    = 0x05;
constexpr uint8_t       kChannelRateOff     = 0x00;     // frequência 0: o UniRC7 para de enviar
constexpr uint16_t      kRequestSeq         = 0;
constexpr uint16_t      kStopSeq            = 1;        // seq seguinte, como o contador do SiYiCrcApi antigo

// No máximo um RC_CHANNELS_OVERRIDE a cada 50 ms (20 Hz), como antes
constexpr qint64        kMinSendIntervalMs  = 50;

constexpr int           kRequestRepeats     = 3;
constexpr int           kStopRepeats        = 3;
constexpr int           kReleaseRepeats     = 5;
constexpr int           kFinishRepeats      = kReleaseRepeats > kStopRepeats ? kReleaseRepeats : kStopRepeats;
constexpr unsigned long kRepeatIntervalMs   = 20;

// MAVLink: UINT16_MAX ignora o canal; UINT16_MAX - 1 devolve os canais 9-18 ao rádio
constexpr uint16_t      kChannelIgnore      = std::numeric_limits<uint16_t>::max();
constexpr uint16_t      kChannelRelease     = std::numeric_limits<uint16_t>::max() - 1;

}

GDRcOverrideWorker::GDRcOverrideWorker(Vehicle* vehicle, uint8_t gcsSystemId, uint8_t gcsComponentId)
    : _vehicle          (vehicle)
    , _vehicleId        (static_cast<uint8_t>(vehicle->id()))
    , _gcsSystemId      (gcsSystemId)
    , _gcsComponentId   (gcsComponentId)
{
}

bool GDRcOverrideWorker::open(QString* errorString)
{
    _socket = new QUdpSocket(this);

    // DontShareAddress: com a porta ocupada (outra instância do app) o bind
    // falha, em vez de dividir os pacotes do UniRC7 em silêncio
    if (!_socket->bind(QHostAddress::AnyIPv4, kLocalPort, QAbstractSocket::DontShareAddress)) {
        *errorString = tr("Não foi possível abrir a porta UDP %1: %2").arg(kLocalPort).arg(_socket->errorString());
        delete _socket;
        _socket = nullptr;
        return false;
    }

    connect(_socket, &QUdpSocket::readyRead, this, &GDRcOverrideWorker::_readDatagrams);

    _sendTimer = new QTimer(this);
    _sendTimer->setSingleShot(true);
    _sendTimer->setTimerType(Qt::PreciseTimer);
    connect(_sendTimer, &QTimer::timeout, this, &GDRcOverrideWorker::_sendOverride);

    // Fora desta chamada: quem chamou open() está esperando a resposta
    QMetaObject::invokeMethod(this, [this]() { _sendRequest(); }, Qt::QueuedConnection);
    return true;
}

void GDRcOverrideWorker::finish()
{
    _forwarding = false;

    delete _sendTimer;
    _sendTimer = nullptr;

    // O socket fecha só depois do pedido de fim ao UniRC7. Os quadros que
    // chegarem até lá ficam no buffer e são descartados com ele.
    _sendStopAndRelease();

    delete _socket;
    _socket = nullptr;

    QThread::currentThread()->quit();
}

void GDRcOverrideWorker::setLink(const WeakLinkInterfacePtr& link)
{
    QMutexLocker locker(&_linkMutex);
    _link = link;
}

void GDRcOverrideWorker::halt()
{
    _forwarding = false;
}

void GDRcOverrideWorker::skipRelease()
{
    _releaseOnFinish = false;
}

SharedLinkInterfacePtr GDRcOverrideWorker::_lockLink()
{
    QMutexLocker locker(&_linkMutex);
    return _link.lock();
}

void GDRcOverrideWorker::_sendRequest()
{
    // Mesmo pedido das versões anteriores: seq 0, repetido 3 vezes a cada 20 ms
    const QByteArray    request = GDSiYiRemoteChannel::requestCommand(kChannelRate20Hz, kRequestSeq);
    const QHostAddress  uniRc(QString::fromLatin1(kUniRcAddress));

    for (int i = 0; i < kRequestRepeats && _socket; i++) {
        _socket->writeDatagram(request, uniRc, kUniRcPort);
        QThread::msleep(kRepeatIntervalMs);
    }
}

void GDRcOverrideWorker::_readDatagrams()
{
    // Datagrama maior que o buffer é truncado, como no recvfrom anterior
    uint8_t buffer[256];

    while (_socket && _socket->hasPendingDatagrams()) {
        const qint64 length = _socket->readDatagram(reinterpret_cast<char*>(buffer), sizeof(buffer));
        if (length < 0) {
            break;
        }

        uint16_t channels[GDSiYiRemoteChannel::ChannelCount];
        if (GDSiYiRemoteChannel::parseChannels(buffer, static_cast<int>(length), channels)) {
            _queueOverride(channels);
        }
    }
}

void GDRcOverrideWorker::_queueOverride(const uint16_t* channels)
{
    if (!_forwarding) {
        return;
    }

    // No máximo um envio a cada 50 ms, sempre com o pacote mais recente do
    // rádio. Pacote que chega antes da hora espera o fim da janela, em vez de
    // ser descartado. Sem pacote do rádio não há envio: o ArduPilot solta o
    // override pelo RC_OVERRIDE_TIME.
    std::copy(channels, channels + GDSiYiRemoteChannel::ChannelCount, _pendingChannels);
    _pending = true;

    if (_sendTimer->isActive()) {
        return;
    }
    const qint64 wait = _lastSend.isValid() ? kMinSendIntervalMs - _lastSend.elapsed() : 0;
    if (wait > 0) {
        _sendTimer->start(static_cast<int>(wait));
    } else {
        _sendOverride();
    }
}

void GDRcOverrideWorker::_sendOverride()
{
    if (!_forwarding || !_pending) {
        return;
    }
    _pending = false;

    mavlink_rc_channels_override_t rc;
    rc.target_system    = _vehicleId;
    rc.target_component = MAV_COMP_ID_AUTOPILOT1;
    rc.chan1_raw        = _pendingChannels[0];
    rc.chan2_raw        = _pendingChannels[1];
    rc.chan3_raw        = _pendingChannels[2];
    rc.chan4_raw        = _pendingChannels[3];
    rc.chan5_raw        = _pendingChannels[4];
    rc.chan6_raw        = _pendingChannels[5];
    rc.chan7_raw        = _pendingChannels[6];
    rc.chan8_raw        = _pendingChannels[7];
    rc.chan9_raw        = _pendingChannels[8];
    rc.chan10_raw       = _pendingChannels[9];
    rc.chan11_raw       = _pendingChannels[10];
    rc.chan12_raw       = _pendingChannels[11];
    rc.chan13_raw       = _pendingChannels[12];
    rc.chan14_raw       = _pendingChannels[13];
    rc.chan15_raw       = _pendingChannels[14];
    rc.chan16_raw       = _pendingChannels[15];
    // O UniRC7 manda 16 canais: 17 e 18 ficam ignorados
    rc.chan17_raw       = kChannelIgnore;
    rc.chan18_raw       = kChannelIgnore;

    if (_send(rc)) {
        _lastSend.start();
    }
}

/// Pede ao UniRC7 o fim do envio dos canais (o mesmo 0x42 da abertura, com
/// frequência 0) e devolve os canais ao rádio. Sem o pedido de fim o UniRC7
/// segue mandando 20 quadros/s ao tablet, para uma porta fechada.
///
/// A liberação (0 nos canais 1-8, kChannelRelease nos 9-18) devolve os canais
/// na hora; sem ela o ArduPilot mantém os últimos valores até o
/// RC_OVERRIDE_TIME. Os dois são repetidos para garantir a entrega,
/// intercalados a cada 20 ms: até 80 ms com liberação, 40 ms sem.
void GDRcOverrideWorker::_sendStopAndRelease()
{
    const QByteArray    stopRequest = GDSiYiRemoteChannel::requestCommand(kChannelRateOff, kStopSeq);
    const QHostAddress  uniRc(QString::fromLatin1(kUniRcAddress));

    mavlink_rc_channels_override_t release {};
    release.target_system       = _vehicleId;
    release.target_component    = MAV_COMP_ID_AUTOPILOT1;
    release.chan9_raw   = kChannelRelease;
    release.chan10_raw  = kChannelRelease;
    release.chan11_raw  = kChannelRelease;
    release.chan12_raw  = kChannelRelease;
    release.chan13_raw  = kChannelRelease;
    release.chan14_raw  = kChannelRelease;
    release.chan15_raw  = kChannelRelease;
    release.chan16_raw  = kChannelRelease;
    release.chan17_raw  = kChannelRelease;
    release.chan18_raw  = kChannelRelease;

    bool releasing = true;
    for (int i = 0; i < kFinishRepeats; i++) {
        if (i > 0) {
            QThread::msleep(kRepeatIntervalMs);
        }
        if (i < kStopRepeats && _socket) {
            _socket->writeDatagram(stopRequest, uniRc, kUniRcPort);
        }
        if (releasing && i < kReleaseRepeats) {
            // skipRelease() interrompe; sem link não há a quem devolver
            releasing = _releaseOnFinish && _send(release);
        }
        if (!releasing && i + 1 >= kStopRepeats) {
            break;
        }
    }
}

/// Codifica no canal MAVLink do link primário, como o joystick do QGC. Falso
/// se não há link conectado.
bool GDRcOverrideWorker::_send(const mavlink_rc_channels_override_t& rc)
{
    // Pega o link a cada envio: segurar a referência durante as esperas da
    // liberação pode fazer o link desconectado ser destruído nesta thread
    SharedLinkInterfacePtr link = _lockLink();
    if (!link || !link->mavlinkChannelIsSet()) {
        return false;
    }

    // Ao desconectar, o LinkManager libera o canal (vira 255) antes de o
    // VehicleLinkManager trocar o link primário. Codificar com esse valor
    // escreveria fora do vetor de status MAVLink.
    const uint8_t channel = link->mavlinkChannel();
    if (channel >= MAVLINK_COMM_NUM_BUFFERS) {
        return false;
    }

    mavlink_message_t message;
    mavlink_msg_rc_channels_override_encode_chan(_gcsSystemId, _gcsComponentId, channel, &message, &rc);
    return _vehicle->sendMessageOnLinkThreadSafe(link.get(), message);
}
