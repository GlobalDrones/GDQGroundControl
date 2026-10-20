#include "telemetry/GDTelemetry.h"
#include "Vehicle.h"

using GDTelemetry::namedValueIs;

// GD70: nomes NAMED_VALUE_FLOAT enviados pelo firmware deste produto.
//   T_Motor    temperatura do motor -> gd60_Sensor1
//   RC_SCORE   qualidade do rádio (%), barra superior -> gd60_Sensor2
//   NET_SCORE  qualidade da rede (%), barra superior -> gd60_Sensor3
// Temp1 e TempICE são ignorados de propósito: saíram quando o T_Motor entrou
// (cbbb676, "Motor Temperature fix") e gravavam no mesmo fato.
void gdHandleNamedValueFloat(Vehicle* vehicle, const mavlink_named_value_float_t& namedValueFloat)
{
    const float value = namedValueFloat.value;

    if (namedValueIs(namedValueFloat, "T_Motor")) {
        vehicle->gd60_Sensor1()->setRawValue(value);
    } else if (namedValueIs(namedValueFloat, "RC_SCORE")) {
        vehicle->gd60_Sensor2()->setRawValue(value);
    } else if (namedValueIs(namedValueFloat, "NET_SCORE")) {
        vehicle->gd60_Sensor3()->setRawValue(value);
    }
}
