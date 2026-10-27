# GD25: somente o que é deste produto. O resto está em custom/.

GD_PRODUCT         = GD25
GD_TARGET          = GD25_QGC_DEV
GD_APP_NAME        = "GD25 QGC"
GD_SETTINGS_NAME   = QGroundControl
GD_ANDROID_PACKAGE = gd25dev.mavlink.qgroundcontrol
GD_ANDROID_LABEL   = "GD 25 QGC DEV"
GD_VERSION         = 2.3.4
GD_BUILD           = 0

# rc_override:           RC Override pela GCS (UniRC7 via SDK SiYi)
# second_stream_thermal: trata o 2º stream anunciado pela câmera MAVLink como térmico
GD_FEATURES        = rc_override second_stream_thermal checklist

# Mapeamento NAMED_VALUE_FLOAT -> fatos do veículo deste produto
SOURCES += $$PWD/telemetry.cc
