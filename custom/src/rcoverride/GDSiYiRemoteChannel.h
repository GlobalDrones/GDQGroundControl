#pragma once

#include <QByteArray>
#include <cstdint>

/// Comando 0x42 do SDK SiYi ("remote control channel data") usado com o UniRC7.
///
/// Antes ficava como acréscimo GD no src/SiYi/SiYiCrcApi; aqui o src/SiYi
/// volta a ser o da SiYi.
///
/// Quadro: 0x55 0x66 | ctrl | tamanho (LE) | seq (LE) | cmd | dados | CRC16 (LE)
namespace GDSiYiRemoteChannel
{
    constexpr int       ChannelCount    = 16;
    constexpr int       FrameLength     = 42;   // cabeçalho (8) + 16 canais (32) + CRC (2)
    constexpr uint8_t   CmdId           = 0x42;

    /// CRC16-CCITT (polinômio 0x1021, valor inicial 0), o do SDK SiYi
    uint16_t crc16(const uint8_t* data, int length);

    /// Pede ao UniRC7 o envio periódico dos canais. frequency 0x05 = 20 Hz;
    /// 0 pede o fim do envio (o mesmo quadro, só muda o byte de dados).
    QByteArray requestCommand(uint8_t frequency, uint16_t seq);

    /// Procura no datagrama o primeiro quadro 0x42 com CRC válido e copia os 16
    /// canais (us) para channels. Falso se não houver quadro válido.
    bool parseChannels(const uint8_t* data, int length, uint16_t channels[ChannelCount]);
}
