# GD25: somente o que é deste produto. O resto está em custom/.

GD_PRODUCT         = GD25
GD_TARGET          = GDGCS_25
GD_APP_NAME        = "GDGCS 25"
GD_SETTINGS_NAME   = QGroundControl
GD_ANDROID_PACKAGE = gd25dev.mavlink.qgroundcontrol
GD_ANDROID_LABEL   = "GDGCS 25"
GD_VERSION         = 2.4.0
GD_BUILD           = 0

# rc_override:           RC Override pela GCS (UniRC7 via SDK SiYi)
# second_stream_thermal: trata o 2º stream anunciado pela câmera MAVLink como térmico
GD_FEATURES        = rc_override second_stream_thermal checklist

# Mapeamento NAMED_VALUE_FLOAT -> fatos do veículo deste produto
SOURCES += $$PWD/telemetry.cc
