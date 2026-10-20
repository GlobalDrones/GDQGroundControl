#include "telemetry/GDTelemetry.h"
#include "Vehicle.h"

using GDTelemetry::namedValueIs;

// GD30: nomes NAMED_VALUE_FLOAT enviados pelo firmware deste produto (motor DLE).
//   DLE_C1, DLE_C2  temperatura dos cilindros, em centésimos de °C -> gd60_Sensor2/3 ("T1"/"T2")
//   DLE_RPM         RPM do motor -> gd60_Sensor1 ("RPM")
//   Temp1           grava no mesmo fato do RPM, como no app anterior
//   REMAIN_SEC      tempo restante estimado em segundos -> gd30_remainsecs ("Est. Time")
// Temp2, Temp3 e TempICE não alimentam nenhum fato neste produto.
void gdHandleNamedValueFloat(Vehicle* vehicle, const mavlink_named_value_float_t& namedValueFloat)
{
    const float value = namedValueFloat.value;

    if (namedValueIs(namedValueFloat, "Temp1") || namedValueIs(namedValueFloat, "DLE_RPM")) {
        vehicle->gd60_Sensor1()->setRawValue(value);
    } else if (namedValueIs(namedValueFloat, "DLE_C1")) {
        vehicle->gd60_Sensor2()->setRawValue(value / 100);
    } else if (namedValueIs(namedValueFloat, "DLE_C2")) {
        vehicle->gd60_Sensor3()->setRawValue(value / 100);
    } else if (namedValueIs(namedValueFloat, "REMAIN_SEC") || namedValueIs(namedValueFloat, "REMAIN_SE")) {
        // O campo tem 10 caracteres: "REMAIN_SEC" também cobre "REMAIN_SECS"
        // truncado, e "REMAIN_SE" é a variante de 9 caracteres
        vehicle->gd30_remainsecs()->setRawValue(value);
    }
}
