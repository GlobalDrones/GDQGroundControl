#include "telemetry/GDTelemetry.h"
#include "Vehicle.h"

using GDTelemetry::namedValueIs;

// GD25: nomes NAMED_VALUE_FLOAT enviados pelo firmware deste produto.
//   Temp1, TempICE  temperatura do motor a combustão -> gd60_Sensor1
//   RC_SCORE        qualidade do rádio (%), barra superior -> gd60_Sensor2
//   NET_SCORE       qualidade da rede (%), barra superior -> gd60_Sensor3
// Temp2 e Temp3 não alimentam nenhum fato, como no app anterior.
void gdHandleNamedValueFloat(Vehicle* vehicle, const mavlink_named_value_float_t& namedValueFloat)
{
    const float value = namedValueFloat.value;

    if (namedValueIs(namedValueFloat, "Temp1") || namedValueIs(namedValueFloat, "TempICE")) {
        vehicle->gd60_Sensor1()->setRawValue(value);
    } else if (namedValueIs(namedValueFloat, "RC_SCORE")) {
        vehicle->gd60_Sensor2()->setRawValue(value);
    } else if (namedValueIs(namedValueFloat, "NET_SCORE")) {
        vehicle->gd60_Sensor3()->setRawValue(value);
    }
}
