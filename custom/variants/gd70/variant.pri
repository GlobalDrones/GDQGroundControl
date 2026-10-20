# GD70: somente o que é deste produto. O resto está em custom/.

GD_PRODUCT         = GD70
GD_TARGET          = GD70_QGC_DEV
GD_APP_NAME        = "GD70 QGC"
GD_SETTINGS_NAME   = QGroundControl
GD_ANDROID_PACKAGE = gd70dev.mavlink.qgroundcontrol
GD_ANDROID_LABEL   = "GD 70 QGC DEV"
GD_VERSION         = 0.1.1
GD_BUILD           = 0

# rc_override:           RC Override pela GCS (UniRC7 via SDK SiYi)
# second_stream_thermal: trata o 2º stream anunciado pela câmera MAVLink como térmico
GD_FEATURES        = second_stream_thermal

# O GD70 lê os parâmetros com uma única nova tentativa por parâmetro (1d7a2c3)
DEFINES += GD_PARAM_LOAD_RETRIES=1

# Mapeamento NAMED_VALUE_FLOAT -> fatos do veículo deste produto
SOURCES += $$PWD/telemetry.cc
