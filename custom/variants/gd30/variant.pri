# GD30: somente o que é deste produto. O resto está em custom/.

GD_PRODUCT         = GD30
GD_TARGET          = GD30_QGC_DEV
GD_APP_NAME        = "GD30 QGC"
GD_SETTINGS_NAME   = QGroundControl
GD_ANDROID_PACKAGE = gd30g.mavlink.qgroundcontrol
GD_ANDROID_LABEL   = "GD 30 QGC DEV"
GD_VERSION         = 1.0.1
GD_BUILD           = 0

# rc_override:           RC Override pela GCS (UniRC7 via SDK SiYi)
# second_stream_thermal: trata o 2º stream anunciado pela câmera MAVLink como térmico
GD_FEATURES        = rc_override

# Mapeamento NAMED_VALUE_FLOAT -> fatos do veículo deste produto
SOURCES += $$PWD/telemetry.cc
