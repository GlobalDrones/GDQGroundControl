"""Veículo ArduPilot simulado para o teste de fumaça: envia por UDP para a porta
14550 (autoconexão do QGC) as mensagens que os painéis GD leem.

Uso: python fake-vehicle.py [segundos] [porta UDP do QGC]
"""
import math
import os
import sys
import time

os.environ["MAVLINK20"] = "1"
from pymavlink import mavutil

mavutil.set_dialect("ardupilotmega")

duration = float(sys.argv[1]) if len(sys.argv) > 1 else 60.0
port = int(sys.argv[2]) if len(sys.argv) > 2 else 14550

mav = mavutil.mavlink_connection(f"udpout:127.0.0.1:{port}", source_system=1, source_component=1, dialect="ardupilotmega")
m = mav.mav

NVF_NAMES = [
    ("TempICE", 95.0), ("Temp1", 90.0), ("T_Motor", 88.0),
    ("RC_SCORE", 80.0), ("NET_SCORE", 60.0),
    ("DLE_C1", 9050.0), ("DLE_C2", 9120.0), ("DLE_RPM", 6200.0), ("REMAIN_SEC", 3600.0),
    ("ECU1_CTP1", 1100.0), ("ECU1_CTP2", 1080.0), ("ECU2_CTP1", 1050.0), ("ECU2_CTP2", 1020.0),
    ("ECU1_RPM", 5400.0), ("ECU2_RPM", 5300.0), ("VazaoGMin", 12.5),
]

start = time.time()
tick = 0
received = {}
lat, lon = -22.9123, -43.1731  # Rio de Janeiro (hemisférios S/W)
while time.time() - start < duration:
    t = time.time() - start
    boot_ms = int(t * 1000)
    m.heartbeat_send(mavutil.mavlink.MAV_TYPE_HEXAROTOR, mavutil.mavlink.MAV_AUTOPILOT_ARDUPILOTMEGA,
                     mavutil.mavlink.MAV_MODE_FLAG_CUSTOM_MODE_ENABLED, 5, mavutil.mavlink.MAV_STATE_STANDBY)
    m.sys_status_send(0, 0, 0, 500, 48000, 1200, 80, 0, 0, 0, 0, 0, 0)
    m.gps_raw_int_send(boot_ms * 1000, 3, int(lat * 1e7), int(lon * 1e7), 10000, 80, 90, 0, 0, 14)
    m.global_position_int_send(boot_ms, int(lat * 1e7), int(lon * 1e7), 10000, 5000, 0, 0, 0, 9000)
    m.attitude_send(boot_ms, 0.05 * math.sin(t), 0.03 * math.cos(t), 1.5, 0, 0, 0)
    m.vfr_hud_send(3.0, 3.2, 90, 40, 10.0, 0.1)
    for battery_id, (mv, pct) in enumerate([(48500, 80), (12000, 65), (50200, 90), (12100, 55)]):
        voltages = [mv] + [65535] * 9
        m.battery_status_send(battery_id, 0, 0, 2500, voltages, 1500, -1, -1, pct)
    for name, value in NVF_NAMES:
        m.named_value_float_send(boot_ms, name.encode(), value + math.sin(t))
    m.esc_telemetry_1_to_4_send([45, 46, 47, 48], [0] * 4, [0] * 4, [3000, 3100, 3200, 3300], [0] * 4, [0] * 4)
    m.esc_telemetry_5_to_8_send([45, 46, 47, 48], [0] * 4, [0] * 4, [3400, 3500, 0, 0], [0] * 4, [0] * 4)
    m.rpm_send(5200.0, 0.0)
    m.rangefinder_send(12.3, 3.3)
    m.nav_controller_output_send(0, 0, 90, 90, 150, 0, 0, 0)
    m.extended_sys_state_send(0, mavutil.mavlink.MAV_LANDED_STATE_ON_GROUND)
    try:
        m.gimbal_device_attitude_status_send(0, 0, boot_ms, 0, [0.966, 0.0, -0.259, 0.0], 0.0, 0.0, 0.0, 0)
    except Exception:
        pass
    # Responde ao pedido de parâmetros com um parâmetro só, para o QGC seguir adiante
    while True:
        try:
            msg = mav.recv_match(blocking=False)
        except ConnectionResetError:
            # Windows: ninguém escutando ainda na porta do QGC (ICMP port unreachable)
            msg = None
        if msg is None:
            break
        received[msg.get_type()] = received.get(msg.get_type(), 0) + 1
        # Sem resposta a PARAM_REQUEST_LIST: o QGC fica esperando os parâmetros e
        # não troca para a tela de configuração durante o teste.
        if msg.get_type() == "MISSION_REQUEST_LIST":
            m.mission_count_send(msg.get_srcSystem(), msg.get_srcComponent(), 0, getattr(msg, "mission_type", 0))
    tick += 1
    time.sleep(0.2)

print("Recebido da GCS:", received, flush=True)
