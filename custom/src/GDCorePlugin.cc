#include "GDCorePlugin.h"
#include "GDSettings.h"
#include "QGCApplication.h"
#include "QGCPalette.h"
#include "AppSettings.h"
#include "SettingsManager.h"
#include "FlyViewSettings.h"

#include "telemetry/GDTelemetry.h"
#include "checklist/PreFlightChecklistBridge.h"
#include "fence/GDFence.h"
#include "rcoverride/GDRcOverride.h"

#include <QQmlApplicationEngine>

GDCorePlugin::GDCorePlugin(QGCApplication* app, QGCToolbox* toolbox)
    : QGCCorePlugin(app, toolbox)
{
}

bool GDCorePlugin::gdRcOverride() const
{
#ifdef GD_FEATURE_RC_OVERRIDE
    return true;
#else
    return false;
#endif
}

bool GDCorePlugin::gdAndroid() const
{
#ifdef Q_OS_ANDROID
    return true;
#else
    return false;
#endif
}

void GDCorePlugin::setToolbox(QGCToolbox* toolbox)
{
    QGCCorePlugin::setToolbox(toolbox);
    _gdSettings = new GDSettings(this);

    // Todos os produtos usam só o tema escuro; o seletor de tema fica oculto.
    QGCPalette::setGlobalTheme(QGCPalette::Dark);

    // A opção do joystick virtual fica oculta (ver adjustSettingMetaData); um
    // valor ligado salvo antes continuaria valendo, então é desligado aqui.
    toolbox->settingsManager()->appSettings()->virtualJoystick()->setRawValue(false);
}

QQmlApplicationEngine* GDCorePlugin::createQmlApplicationEngine(QObject* parent)
{
    QQmlApplicationEngine* qmlEngine = QGCCorePlugin::createQmlApplicationEngine(parent);
    qmlEngine->setUrlInterceptor(&_urlInterceptor);

    PreFlightChecklistBridge::registerQmlTypes();
    GDFence::registerQmlTypes();
    GDRcOverride::registerQmlTypes();

    return qmlEngine;
}

bool GDCorePlugin::adjustSettingMetaData(const QString& settingsGroup, FactMetaData& metaData)
{
    const bool visible = QGCCorePlugin::adjustSettingMetaData(settingsGroup, metaData);

    if (settingsGroup == AppSettings::settingsGroup) {
        if (metaData.name() == AppSettings::indoorPaletteName) {
            metaData.setRawDefaultValue(1); // escuro
            return false;
        }
        if (metaData.name() == AppSettings::virtualJoystickName) {
            // Os manches virtuais ficam ocultos em todos os produtos. Com a opção
            // ligada o QGC mandaria MANUAL_CONTROL centrado, brigando com o RC Override.
            metaData.setRawDefaultValue(false);
            return false;
        }
        if (metaData.name() == AppSettings::telemetrySaveName) {
            metaData.setRawDefaultValue(true);
            return true;
        }
    } else if (settingsGroup == FlyViewSettings::settingsGroup) {
        if (metaData.name() == FlyViewSettings::keepMapCenteredOnVehicleName) {
            metaData.setRawDefaultValue(true);
            return true;
        }
    }

    return visible;
}

bool GDCorePlugin::mavlinkMessage(Vehicle* vehicle, LinkInterface* link, mavlink_message_t message)
{
    GDTelemetry::handleMessage(vehicle, message);
    return QGCCorePlugin::mavlinkMessage(vehicle, link, message);
}

bool GDCorePlugin::armingAllowed(Vehicle* vehicle, QString& reason)
{
#ifdef Q_OS_ANDROID
    if (_gdSettings && _gdSettings->externalChecklistEnabled()->rawValue().toBool()) {
        return PreFlightChecklistBridge::instance()->armingAllowed(vehicle, reason);
    }
#else
    Q_UNUSED(vehicle)
    Q_UNUSED(reason)
#endif
    return true;
}
