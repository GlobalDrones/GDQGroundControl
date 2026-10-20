#include "telemetry/GDTelemetry.h"
#include "Vehicle.h"

using GDTelemetry::namedValueIs;

// GD150: nomes NAMED_VALUE_FLOAT enviados pelo firmware deste produto.
//   VazaoGMin  vazão, exibida como "GPM" -> gd60_Sensor1
//   TempICE    grava no mesmo fato da vazão, como no app anterior
//   RC_SCORE   qualidade do rádio (%), barra superior -> gd60_Sensor2
//   NET_SCORE  qualidade da rede (%), barra superior -> gd60_Sensor3
// Temp1 é ignorado de propósito: foi desligado quando a vazão passou a ocupar
// esse fato (fc2205a).
void gdHandleNamedValueFloat(Vehicle* vehicle, const mavlink_named_value_float_t& namedValueFloat)
{
    const float value = namedValueFloat.value;

    if (namedValueIs(namedValueFloat, "TempICE") || namedValueIs(namedValueFloat, "VazaoGMin")) {
        vehicle->gd60_Sensor1()->setRawValue(value);
    } else if (namedValueIs(namedValueFloat, "RC_SCORE")) {
        vehicle->gd60_Sensor2()->setRawValue(value);
    } else if (namedValueIs(namedValueFloat, "NET_SCORE")) {
        vehicle->gd60_Sensor3()->setRawValue(value);
    }
}
