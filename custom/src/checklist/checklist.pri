# Checklist pré-operacional externo. Compilado em todos os produtos para o módulo
# QML PreFlightChecklist.Object sempre existir; quem liga é a configuração
# gdSettings.externalChecklistEnabled. O código JNI só entra no Android, e o
# QT += androidextras já vem do android.pri da base.
HEADERS += $$PWD/PreFlightChecklistBridge.h
SOURCES += $$PWD/PreFlightChecklistBridge.cc
