#include "GDSiYiRemoteChannel.h"

namespace GDSiYiRemoteChannel
{

uint16_t crc16(const uint8_t* data, int length)
{
    uint16_t crc = 0;
    for (int i = 0; i < length; i++) {
        crc ^= static_cast<uint16_t>(data[i] << 8);
        for (int bit = 0; bit < 8; bit++) {
            crc = (crc & 0x8000) ? static_cast<uint16_t>((crc << 1) ^ 0x1021) : static_cast<uint16_t>(crc << 1);
        }
    }
    return crc;
}

QByteArray requestCommand(uint8_t frequency, uint16_t seq)
{
    const uint16_t dataLength = 1;

    QByteArray frame;
    frame.append(char(0x55));
    frame.append(char(0x66));
    frame.append(char(0x01));               // ctrl, como no exemplo Python do SDK
    frame.append(char(dataLength & 0xFF));
    frame.append(char(dataLength >> 8));
    frame.append(char(seq & 0xFF));
    frame.append(char(seq >> 8));
    frame.append(char(CmdId));
    frame.append(char(frequency));

    const uint16_t crc = crc16(reinterpret_cast<const uint8_t*>(frame.constData()), frame.size());
    frame.append(char(crc & 0xFF));
    frame.append(char(crc >> 8));
    return frame;
}

bool parseChannels(const uint8_t* data, int length, uint16_t channels[ChannelCount])
{
    // Como antes: o datagrama precisa começar com cabeçalho e ter um quadro inteiro
    if (length < FrameLength || data[0] != 0x55 || data[1] != 0x66) {
        return false;
    }

    int i = 0;
    while (i + FrameLength <= length) {
        if (data[i] != 0x55 || data[i + 1] != 0x66) {
            i++;
            continue;
        }

        // Comando e canais vêm do quadro cujo CRC bateu. As versões anteriores
        // liam sempre do início do datagrama, mesmo quando o quadro válido era
        // um posterior.
        const uint8_t*  frame       = data + i;
        const uint16_t  receivedCrc = static_cast<uint16_t>(frame[FrameLength - 2] | (frame[FrameLength - 1] << 8));
        if (receivedCrc != crc16(frame, FrameLength - 2) || frame[7] != CmdId) {
            i += FrameLength;
            continue;
        }

        for (int ch = 0; ch < ChannelCount; ch++) {
            channels[ch] = static_cast<uint16_t>(frame[8 + ch * 2] | (frame[9 + ch * 2] << 8));
        }
        return true;
    }

    return false;
}

} // namespace GDSiYiRemoteChannel
