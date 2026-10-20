/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "VehicleEscStatusFactGroup.h"
#include "Vehicle.h"

const char* VehicleEscStatusFactGroup::_indexFactName =                             "index";

const char* VehicleEscStatusFactGroup::_rpmFirstFactName =                          "rpm1";
const char* VehicleEscStatusFactGroup::_rpmSecondFactName =                         "rpm2";
const char* VehicleEscStatusFactGroup::_rpmThirdFactName =                          "rpm3";
const char* VehicleEscStatusFactGroup::_rpmFourthFactName =                         "rpm4";

const char* VehicleEscStatusFactGroup::_currentFirstFactName =                      "current1";
const char* VehicleEscStatusFactGroup::_currentSecondFactName =                     "current2";
const char* VehicleEscStatusFactGroup::_currentThirdFactName =                      "current3";
const char* VehicleEscStatusFactGroup::_currentFourthFactName =                     "current4";

const char* VehicleEscStatusFactGroup::_voltageFirstFactName =                      "voltage1";
const char* VehicleEscStatusFactGroup::_voltageSecondFactName =                     "voltage2";
const char* VehicleEscStatusFactGroup::_voltageThirdFactName =                      "voltage3";
const char* VehicleEscStatusFactGroup::_voltageFourthFactName =                     "voltage4";

const char* VehicleEscStatusFactGroup::_temperatureFirstFactName =                  "temperature1";
const char* VehicleEscStatusFactGroup::_temperatureSecondFactName =                 "temperature2";
const char* VehicleEscStatusFactGroup::_temperatureThirdFactName =                  "temperature3";
const char* VehicleEscStatusFactGroup::_temperatureFourthFactName =                 "temperature4";

VehicleEscStatusFactGroup::VehicleEscStatusFactGroup(QObject* parent)
    : FactGroup                         (1000, ":/json/Vehicle/EscStatusFactGroup.json", parent)
    , _indexFact                        (0, _indexFactName,                         FactMetaData::valueTypeUint8)

    , _rpmFirstFact                     (0, _rpmFirstFactName,                      FactMetaData::valueTypeFloat)
    , _rpmSecondFact                    (0, _rpmSecondFactName,                     FactMetaData::valueTypeFloat)
    , _rpmThirdFact                     (0, _rpmThirdFactName,                      FactMetaData::valueTypeFloat)
    , _rpmFourthFact                    (0, _rpmFourthFactName,                     FactMetaData::valueTypeFloat)

    , _currentFirstFact                 (0, _currentFirstFactName,                  FactMetaData::valueTypeFloat)
    , _currentSecondFact                (0, _currentSecondFactName,                 FactMetaData::valueTypeFloat)
    , _currentThirdFact                 (0, _currentThirdFactName,                  FactMetaData::valueTypeFloat)
    , _currentFourthFact                (0, _currentFourthFactName,                 FactMetaData::valueTypeFloat)

    , _voltageFirstFact                 (0, _voltageFirstFactName,                  FactMetaData::valueTypeFloat)
    , _voltageSecondFact                (0, _voltageSecondFactName,                 FactMetaData::valueTypeFloat)
    , _voltageThirdFact                 (0, _voltageThirdFactName,                  FactMetaData::valueTypeFloat)
    , _voltageFourthFact                (0, _voltageFourthFactName,                 FactMetaData::valueTypeFloat)

    , _temperatureFirstFact             (0, _temperatureFirstFactName,              FactMetaData::valueTypeFloat)
    , _temperatureSecondFact            (0, _temperatureSecondFactName,             FactMetaData::valueTypeFloat)
    , _temperatureThirdFact             (0, _temperatureThirdFactName,              FactMetaData::valueTypeFloat)
    , _temperatureFourthFact            (0, _temperatureFourthFactName,             FactMetaData::valueTypeFloat)
{
    _addFact(&_indexFact,                       _indexFactName);

    _addFact(&_rpmFirstFact,                    _rpmFirstFactName);
    _addFact(&_rpmSecondFact,                   _rpmSecondFactName);
    _addFact(&_rpmThirdFact,                    _rpmThirdFactName);
    _addFact(&_rpmFourthFact,                   _rpmFourthFactName);

    _addFact(&_currentFirstFact,                _currentFirstFactName);
    _addFact(&_currentSecondFact,               _currentSecondFactName);
    _addFact(&_currentThirdFact,                _currentThirdFactName);
    _addFact(&_currentFourthFact,               _currentFourthFactName);

    _addFact(&_voltageFirstFact,                _voltageFirstFactName);
    _addFact(&_voltageSecondFact,               _voltageSecondFactName);
    _addFact(&_voltageThirdFact,                _voltageThirdFactName);
    _addFact(&_voltageFourthFact,               _voltageFourthFactName);

    _addFact(&_temperatureFirstFact,            _temperatureFirstFactName);
    _addFact(&_temperatureSecondFact,           _temperatureSecondFactName);
    _addFact(&_temperatureThirdFact,            _temperatureThirdFactName);
    _addFact(&_temperatureFourthFact,           _temperatureFourthFactName);
}

void VehicleEscStatusFactGroup::handleMessage(Vehicle* /* vehicle */, mavlink_message_t& message)
{
#if !defined(NO_ARDUPILOT_DIALECT)
    // Global Drones: o ArduPilot não envia ESC_STATUS; RPM e temperatura dos
    // ESCs chegam por ESC_TELEMETRY_1_TO_4.
    if (message.msgid == MAVLINK_MSG_ID_ESC_TELEMETRY_1_TO_4) {
        mavlink_esc_telemetry_1_to_4_t escTelemetry;
        mavlink_msg_esc_telemetry_1_to_4_decode(&message, &escTelemetry);

        rpmFirst()->setRawValue                 (escTelemetry.rpm[0]);
        rpmSecond()->setRawValue                (escTelemetry.rpm[1]);
        rpmThird()->setRawValue                 (escTelemetry.rpm[2]);
        rpmFourth()->setRawValue                (escTelemetry.rpm[3]);

        temperatureFirst()->setRawValue         (escTelemetry.temperature[0]);
        temperatureSecond()->setRawValue        (escTelemetry.temperature[1]);
        temperatureThird()->setRawValue         (escTelemetry.temperature[2]);
        temperatureFourth()->setRawValue        (escTelemetry.temperature[3]);
        return;
    }
#endif

    if (message.msgid != MAVLINK_MSG_ID_ESC_STATUS) {
        return;
    }

    mavlink_esc_status_t content;
    mavlink_msg_esc_status_decode(&message, &content);

    index()->setRawValue                        (content.index);

    rpmFirst()->setRawValue                     (content.rpm[0]);
    rpmSecond()->setRawValue                    (content.rpm[1]);
    rpmThird()->setRawValue                     (content.rpm[2]);
    rpmFourth()->setRawValue                    (content.rpm[3]);

    currentFirst()->setRawValue                 (content.current[0]);
    currentSecond()->setRawValue                (content.current[1]);
    currentThird()->setRawValue                 (content.current[2]);
    currentFourth()->setRawValue                (content.current[3]);

    voltageFirst()->setRawValue                 (content.voltage[0]);
    voltageSecond()->setRawValue                (content.voltage[1]);
    voltageThird()->setRawValue                 (content.voltage[2]);
    voltageFourth()->setRawValue                (content.voltage[3]);
}
