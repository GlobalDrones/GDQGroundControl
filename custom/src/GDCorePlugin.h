#pragma once

#include "QGCCorePlugin.h"
#include "GDUrlInterceptor.h"

class GDSettings;

/// Plugin da Global Drones. Disponível no QML como QGroundControl.corePlugin.
class GDCorePlugin : public QGCCorePlugin
{
    Q_OBJECT

public:
    GDCorePlugin(QGCApplication* app, QGCToolbox* toolbox);

    /// Nome do produto (GD25, GD30, GD60, GD70, GD150)
    Q_PROPERTY(QString      gdProduct           READ gdProduct          CONSTANT)
    /// Versão do produto, definida em custom/variants/<variante>/variant.pri
    Q_PROPERTY(QString      gdVersion           READ gdVersion          CONSTANT)
    /// O produto tem RC Override pela GCS
    Q_PROPERTY(bool         gdRcOverride        READ gdRcOverride       CONSTANT)
    /// Build Android (o checklist externo só existe no Android)
    Q_PROPERTY(bool         gdAndroid           READ gdAndroid          CONSTANT)
    Q_PROPERTY(GDSettings*  gdSettings          READ gdSettings         CONSTANT)

    QString     gdProduct   () const { return QStringLiteral(GD_PRODUCT_NAME); }
    QString     gdVersion   () const { return QStringLiteral(GD_VERSION_STR); }
    bool        gdRcOverride() const;
    bool        gdAndroid   () const;
    GDSettings* gdSettings  () { return _gdSettings; }

    // QGCCorePlugin overrides
    void                    setToolbox                  (QGCToolbox* toolbox) override;
    QQmlApplicationEngine*  createQmlApplicationEngine  (QObject* parent) override;
    void                    createRootWindow            (QQmlApplicationEngine* qmlEngine) override;
    bool                    adjustSettingMetaData       (const QString& settingsGroup, FactMetaData& metaData) override;
    bool                    mavlinkMessage              (Vehicle* vehicle, LinkInterface* link, mavlink_message_t message) override;
    bool                    armingAllowed               (Vehicle* vehicle, QString& reason);

private:
    GDSettings*         _gdSettings = nullptr;
    GDUrlInterceptor    _urlInterceptor;
};
