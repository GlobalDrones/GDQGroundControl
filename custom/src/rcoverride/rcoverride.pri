# RC Override pela GCS (UniRC7 via SDK SiYi -> RC_CHANNELS_OVERRIDE).
# Compilado em todos os produtos para o módulo QML GD.RcOverride sempre existir.
# Só os produtos com "rc_override" em GD_FEATURES conseguem ligar o override.
HEADERS += \
    $$PWD/GDRcOverride.h \
    $$PWD/GDRcOverrideWorker.h \
    $$PWD/GDSiYiRemoteChannel.h

SOURCES += \
    $$PWD/GDRcOverride.cc \
    $$PWD/GDRcOverrideWorker.cc \
    $$PWD/GDSiYiRemoteChannel.cc
