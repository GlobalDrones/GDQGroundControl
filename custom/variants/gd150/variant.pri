# GD150: somente o que é deste produto. O resto está em custom/.

GD_PRODUCT         = GD150
GD_TARGET          = GD150_QGC_DEV
GD_APP_NAME        = "GD150 QGC"
GD_SETTINGS_NAME   = QGroundControl
GD_ANDROID_PACKAGE = gd150dev.mavlink.qgroundcontrol
GD_ANDROID_LABEL   = "GD150 QGC DEV"
GD_VERSION         = 0.1.1
GD_BUILD           = 0

# rc_override:           RC Override pela GCS (UniRC7 via SDK SiYi)
# second_stream_thermal: trata o 2º stream anunciado pela câmera MAVLink como térmico
GD_FEATURES        = second_stream_thermal

# Mapeamento NAMED_VALUE_FLOAT -> fatos do veículo deste produto
SOURCES += $$PWD/telemetry.cc
