#include "GDTelemetry.h"
#include "Vehicle.h"

#include <QtMath>

#include <cmath>

// Mensagens MAVLink padrão que alimentam os fatos GD. O tratamento é o mesmo
// em todos os produtos; o que muda por produto (NAMED_VALUE_FLOAT) fica em
// custom/variants/<variante>/telemetry.cc.

static void _handleGimbalDeviceAttitudeStatus(Vehicle* vehicle, const mavlink_message_t& message)
{
    mavlink_gimbal_device_attitude_status_t status;
    mavlink_msg_gimbal_device_attitude_status_decode(&message, &status);

    // Convenção MAVLink (ZYX). O QQuaternion::toEulerAngles usado antes decompõe
    // em Y-X-Z e acopla os ângulos: com o gimbal girado em yaw, o pitch exibido
    // saía errado (yaw 90° e pitch -45° apareciam como pitch 0° e roll 45°).
    float q[4] = { status.q[0], status.q[1], status.q[2], status.q[3] };
    const float norm = qSqrt(q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3]);
    if (norm > 0.0f) {
        for (float& component : q) {
            component /= norm;
        }
    }

    float dcm[3][3];
    mavlink_quaternion_to_dcm(q, dcm);

    // Não usa mavlink_dcm_to_euler: com a câmera apontada para baixo (pitch
    // -90°, pose comum) o arredondamento deixa |dcm[2][0]| acima de 1 e o
    // pitch dela sai NaN, e nesse gimbal lock a fórmula de yaw dela cancela
    // os termos e devolve ruído. NaN vindo na mensagem continua NaN (as
    // comparações abaixo são falsas).
    float sinPitch = -dcm[2][0];
    if (sinPitch > 1.0f) {
        sinPitch = 1.0f;
    } else if (sinPitch < -1.0f) {
        sinPitch = -1.0f;
    }
    const float pitch = std::asin(sinPitch);

    float roll, yaw;
    if (qAbs(qAbs(pitch) - static_cast<float>(M_PI_2)) < 1.0e-3f) {
        // Gimbal lock: roll e yaw giram no mesmo eixo, o giro todo fica no yaw
        roll = 0.0f;
        yaw  = std::atan2(-dcm[0][1], dcm[1][1]);
    } else {
        roll = std::atan2(dcm[2][1], dcm[2][2]);
        yaw  = std::atan2(dcm[1][0], dcm[0][0]);
    }

    vehicle->_GD_GimbalRoll()->setRawValue(qRadiansToDegrees(roll));
    vehicle->_GD_GimbalPitch()->setRawValue(qRadiansToDegrees(pitch));
    vehicle->_GD_GimbalYaw()->setRawValue(qRadiansToDegrees(yaw));
}

void GDTelemetry::handleMessage(Vehicle* vehicle, const mavlink_message_t& message)
{
    switch (message.msgid) {
    case MAVLINK_MSG_ID_NAMED_VALUE_FLOAT:
    {
        mavlink_named_value_float_t namedValueFloat;
        mavlink_msg_named_value_float_decode(&message, &namedValueFloat);
        gdHandleNamedValueFloat(vehicle, namedValueFloat);
        break;
    }
    case MAVLINK_MSG_ID_GIMBAL_DEVICE_ATTITUDE_STATUS:
        _handleGimbalDeviceAttitudeStatus(vehicle, message);
        break;
    case MAVLINK_MSG_ID_NAV_CONTROLLER_OUTPUT:
    {
        mavlink_nav_controller_output_t navControllerOutput;
        mavlink_msg_nav_controller_output_decode(&message, &navControllerOutput);
        vehicle->distanceToNextWP()->setRawValue(navControllerOutput.wp_dist);
        break;
    }
#if !defined(NO_ARDUPILOT_DIALECT)
    // RPM dos motores (ESC) e do gerador e telêmetro: mensagens do dialeto ArduPilot
    case MAVLINK_MSG_ID_ESC_TELEMETRY_1_TO_4:
    {
        mavlink_esc_telemetry_1_to_4_t escTelemetry;
        mavlink_msg_esc_telemetry_1_to_4_decode(&message, &escTelemetry);
        vehicle->_GD_RPM1()->setRawValue(escTelemetry.rpm[0]);
        vehicle->_GD_RPM2()->setRawValue(escTelemetry.rpm[1]);
        vehicle->_GD_RPM3()->setRawValue(escTelemetry.rpm[2]);
        vehicle->_GD_RPM4()->setRawValue(escTelemetry.rpm[3]);
        break;
    }
    case MAVLINK_MSG_ID_ESC_TELEMETRY_5_TO_8:
    {
        mavlink_esc_telemetry_5_to_8_t escTelemetry;
        mavlink_msg_esc_telemetry_5_to_8_decode(&message, &escTelemetry);
        vehicle->_GD_RPM5()->setRawValue(escTelemetry.rpm[0]);
        vehicle->_GD_RPM6()->setRawValue(escTelemetry.rpm[1]);
        break;
    }
    case MAVLINK_MSG_ID_RPM:
    {
        mavlink_rpm_t rpm;
        mavlink_msg_rpm_decode(&message, &rpm);
        vehicle->_GD_GeneratorRPM()->setRawValue(rpm.rpm1);
        break;
    }
    case MAVLINK_MSG_ID_RANGEFINDER:
    {
        mavlink_rangefinder_t rangefinder;
        mavlink_msg_rangefinder_decode(&message, &rangefinder);
        vehicle->rangeFinderDist()->setRawValue(qIsNaN(rangefinder.distance) ? 0 : rangefinder.distance);
        break;
    }
#endif
    default:
        break;
    }
}
