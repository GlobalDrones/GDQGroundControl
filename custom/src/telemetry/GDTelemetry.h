#pragma once

#include "QGCMAVLink.h"

#include <cstring>

class Vehicle;

/// Telemetria específica da Global Drones: preenche os fatos GD do Vehicle
/// (gd60_Sensor*, _GD_*, rangeFinderDist...) a partir das mensagens MAVLink.
/// Chamado pelo GDCorePlugin para toda mensagem do veículo.
namespace GDTelemetry {
    void handleMessage(Vehicle* vehicle, const mavlink_message_t& message);

    /// Compara o nome de um NAMED_VALUE_FLOAT como os apps anteriores: strncmp
    /// nos 10 caracteres do campo, que vem sem terminador quando está cheio.
    inline bool namedValueIs(const mavlink_named_value_float_t& namedValueFloat, const char* name)
    {
        return strncmp(namedValueFloat.name, name, MAVLINK_MSG_NAMED_VALUE_FLOAT_FIELD_NAME_LEN) == 0;
    }
}

/// Mapeamento NAMED_VALUE_FLOAT -> fatos, um por produto.
/// Implementado em custom/variants/<variante>/telemetry.cc
void gdHandleNamedValueFloat(Vehicle* vehicle, const mavlink_named_value_float_t& namedValueFloat);
