#pragma once

#include <QObject>
#include <QPointer>
#include <QTimer>

class QThread;
class Vehicle;
class GDRcOverrideWorker;

/// RC Override pela GCS: os canais do rádio UniRC7 (SDK SiYi, UDP) vão para o
/// veículo ativo como RC_CHANNELS_OVERRIDE.
///
/// Singleton QML "GDRcOverride" (import GD.RcOverride 1.0), registrado em todos
/// os produtos para o QML comum carregar sempre. Só os produtos com rc_override
/// em GD_FEATURES conseguem ligar.
///
/// Para sozinho quando o veículo ativo muda, quando o veículo é removido e após
/// 30 s seguidos sem comunicação com o veículo. Ao parar (por qualquer motivo,
/// inclusive ao fechar o app) pede ao UniRC7 o fim do envio dos canais.
class GDRcOverride : public QObject
{
    Q_OBJECT

public:
    ~GDRcOverride() override;

    /// O produto tem RC Override (GD_FEATURE_RC_OVERRIDE)
    Q_PROPERTY(bool     available   READ available  CONSTANT)
    /// Esta GCS está reenviando os canais do rádio ao veículo
    Q_PROPERTY(bool     running     READ running    NOTIFY runningChanged)
    /// Motivo da última falha de start() ou do último desligamento automático
    /// (perda de comunicação). Vazio depois de um start() que ligou.
    Q_PROPERTY(QString  lastError   READ lastError  NOTIFY lastErrorChanged)

    static GDRcOverride*    instance        ();
    static void             registerQmlTypes();

    bool    available   () const;
    bool    running     () const { return _running; }
    QString lastError   () const { return _lastError; }

    /// Liga o override no veículo ativo. Falso, com lastError, se não ligou.
    Q_INVOKABLE bool start  ();
    /// Para o override e devolve os canais ao rádio
    Q_INVOKABLE void stop   ();

signals:
    void runningChanged     (bool running);
    void lastErrorChanged   ();

private:
    explicit GDRcOverride(QObject* parent);

    void _activeVehicleChanged      (Vehicle* vehicle);
    void _vehicleRemoved            (Vehicle* vehicle);
    void _primaryLinkChanged        ();
    void _communicationLostChanged  (bool communicationLost);
    void _commLostTimeout           ();
    void _stopWorker                (bool sendRelease, bool wait);
    void _deleteWorker              ();
    void _setRunning                (bool running);
    void _setLastError              (const QString& error);

    QThread*                _thread             = nullptr;
    GDRcOverrideWorker*     _worker             = nullptr;
    bool                    _workerFinishing    = false;
    quint32                 _workerGeneration   = 0;
    QPointer<Vehicle>       _vehicle;               ///< veículo em override (até a thread terminar)
    QMetaObject::Connection _linkConnection;
    QMetaObject::Connection _commLostConnection;
    QTimer                  _commLostTimer;         ///< perda de comunicação seguida até o desligamento
    bool                    _running            = false;
    QString                 _lastError;
};
