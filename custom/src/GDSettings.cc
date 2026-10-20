#include "GDSettings.h"

#include <QQmlEngine>
#include <QtQml>

DECLARE_SETTINGGROUP(GD, "GD")
{
    qmlRegisterUncreatableType<GDSettings>("GD.Settings", 1, 0, "GDSettings", "Reference only");
}

DECLARE_SETTINGSFACT(GDSettings, externalChecklistEnabled)
