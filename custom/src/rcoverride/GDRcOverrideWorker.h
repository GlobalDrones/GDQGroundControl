#pragma once

#include "GDSiYiRemoteChannel.h"
#include "LinkInterface.h"

#include <QElapsedTimer>
#include <QMutex>
#include <QObject>
#include <atomic>

class QTimer;
class QUdpSocket;
class Vehicle;

/// Recebe os canais do UniRC7 pelo SDK SiYi (UDP) e os reenvia ao veículo como
/// RC_CHANNELS_OVERRIDE.
///
/// Vive numa thread própria para o atraso do override não depender da carga da
/// interface. O GDRcOverride garante que a thread termina antes de o veículo ser
/// apagado.
///
/// Ao terminar (finish), pede ao UniRC7 o fim do envio dos canais (0x42,
/// frequência 0) e devolve os canais ao rádio, salvo skipRelease().
class GDRcOverrideWorker : public QObject
{
    Q_OBJECT

public:
    GDRcOverrideWorker(Vehicle* vehicle, uint8_t gcsSystemId, uint8_t gcsComponentId);

    // Executados na thread do worker
    bool open       (QString* errorString);
    void finish     ();

    // Seguros a partir de qualquer thread
    void setLink    (const WeakLinkInterfacePtr& link);
    void halt       ();     ///< para de reenviar os canais na hora
    void skipRelease();     ///< finish() não envia a liberação (veículo saindo). O pedido de fim ao UniRC7 sai sempre.

private:
    void                    _sendRequest    ();
    void                    _readDatagrams  ();
    void                    _queueOverride  (const uint16_t* channels);
    void                    _sendOverride   ();
    void                    _sendStopAndRelease();
    bool                    _send           (const mavlink_rc_channels_override_t& rc);
    SharedLinkInterfacePtr  _lockLink       ();

    Vehicle*                _vehicle;
    const uint8_t           _vehicleId;
    const uint8_t           _gcsSystemId;
    const uint8_t           _gcsComponentId;
    QUdpSocket*             _socket         = nullptr;
    QTimer*                 _sendTimer      = nullptr;
    QElapsedTimer           _lastSend;
    uint16_t                _pendingChannels[GDSiYiRemoteChannel::ChannelCount];
    bool                    _pending        = false;
    QMutex                  _linkMutex;
    WeakLinkInterfacePtr    _link;
    std::atomic<bool>       _forwarding     {true};
    std::atomic<bool>       _releaseOnFinish{true};
};
