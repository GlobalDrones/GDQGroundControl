#include "telemetry/GDTelemetry.h"
#include "Vehicle.h"

using GDTelemetry::namedValueIs;

// GD60: nomes NAMED_VALUE_FLOAT enviados pela placa IFSC (dois motores, ECU1 e ECU2).
//   ECUn_CTP1, ECUn_CTP2  temperatura dos cilindros, em décimos de °C -> gd60_ECUn_CTPm
//   ECU1_RPM, ECU2_RPM    RPM dos motores -> gd60_RPM_M1/M2
//   Temp1..Temp3, TempICE -> gd60_Sensor1..3, sem uso no QML deste produto
// 32767 é o valor nulo da placa e vale para todos os nomes.
static constexpr float kNullValue = 32767;

void gdHandleNamedValueFloat(Vehicle* vehicle, const mavlink_named_value_float_t& namedValueFloat)
{
    const float value = namedValueFloat.value == kNullValue ? 0 : namedValueFloat.value;

    if (namedValueIs(namedValueFloat, "Temp1") || namedValueIs(namedValueFloat, "TempICE")) {
        vehicle->gd60_Sensor1()->setRawValue(value);
    } else if (namedValueIs(namedValueFloat, "Temp2")) {
        vehicle->gd60_Sensor2()->setRawValue(value);
    } else if (namedValueIs(namedValueFloat, "Temp3")) {
        vehicle->gd60_Sensor3()->setRawValue(value);
    } else if (namedValueIs(namedValueFloat, "ECU1_CTP1")) {
        vehicle->gd60_ECU1_CTP1()->setRawValue(value / 10);
    } else if (namedValueIs(namedValueFloat, "ECU1_CTP2")) {
        vehicle->gd60_ECU1_CTP2()->setRawValue(value / 10);
    } else if (namedValueIs(namedValueFloat, "ECU2_CTP1")) {
        vehicle->gd60_ECU2_CTP1()->setRawValue(value / 10);
    } else if (namedValueIs(namedValueFloat, "ECU2_CTP2")) {
        vehicle->gd60_ECU2_CTP2()->setRawValue(value / 10);
    } else if (namedValueIs(namedValueFloat, "ECU1_RPM")) {
        vehicle->gd60_RPM_M1()->setRawValue(value);
    } else if (namedValueIs(namedValueFloat, "ECU2_RPM")) {
        vehicle->gd60_RPM_M2()->setRawValue(value);
    }
}
