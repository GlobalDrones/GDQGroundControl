#include "GDAndroidStorage.h"
#include "QGCApplication.h"
#include "SettingsManager.h"
#include "AppSettings.h"

#include <QtAndroid>
#include <QAndroidJniEnvironment>
#include <QAndroidJniObject>
#include <QDir>
#include <QGuiApplication>

static constexpr int kAndroid11 = 30;

GDAndroidStorage::GDAndroidStorage(QObject* parent)
    : QObject(parent)
{
    connect(qGuiApp, &QGuiApplication::applicationStateChanged, this, &GDAndroidStorage::_applicationStateChanged);
}

void GDAndroidStorage::requestAllFilesAccessIfNeeded()
{
    if (_hasAllFilesAccess()) {
        return;
    }
    qgcApp()->showAppMessage(QObject::tr("Para salvar logs, missões e parâmetros, libere \"Acesso a todos os arquivos\" para este aplicativo na tela que vai abrir."));
    if (_openAllFilesAccessSettings()) {
        // Fica escutando a volta ao app para criar as pastas assim que liberado
        new GDAndroidStorage(qgcApp());
    }
}

void GDAndroidStorage::_applicationStateChanged(Qt::ApplicationState state)
{
    if (state != Qt::ApplicationActive || !_hasAllFilesAccess()) {
        return;
    }
    _createSaveDirectories();
    deleteLater();
}

bool GDAndroidStorage::_hasAllFilesAccess()
{
    if (QtAndroid::androidSdkVersion() < kAndroid11) {
        return true;
    }
    const jboolean granted = QAndroidJniObject::callStaticMethod<jboolean>("android/os/Environment", "isExternalStorageManager");
    QAndroidJniEnvironment env;
    if (env->ExceptionCheck()) {
        env->ExceptionClear();
        return true;
    }
    return granted;
}

bool GDAndroidStorage::_openAllFilesAccessSettings()
{
    QAndroidJniEnvironment env;
    QAndroidJniObject activity = QtAndroid::androidActivity();
    if (!activity.isValid()) {
        return false;
    }

    // Tela da permissão deste app; alguns aparelhos só têm a tela geral
    const char* actions[] = { "ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION", "ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION" };
    const QAndroidJniObject packageName = activity.callObjectMethod("getPackageName", "()Ljava/lang/String;");
    for (const char* actionName : actions) {
        const QAndroidJniObject action = QAndroidJniObject::getStaticObjectField("android/provider/Settings", actionName, "Ljava/lang/String;");
        if (env->ExceptionCheck() || !action.isValid()) {
            env->ExceptionClear();
            continue;
        }
        QAndroidJniObject intent("android/content/Intent", "(Ljava/lang/String;)V", action.object<jstring>());
        if (actionName == actions[0]) {
            const QAndroidJniObject uri = QAndroidJniObject::callStaticObjectMethod(
                "android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;",
                QAndroidJniObject::fromString(QStringLiteral("package:") + packageName.toString()).object<jstring>());
            intent.callObjectMethod("setData", "(Landroid/net/Uri;)Landroid/content/Intent;", uri.object());
        }
        QtAndroid::startActivity(intent, 0);
        if (env->ExceptionCheck()) {
            env->ExceptionClear();
            continue;
        }
        return true;
    }
    return false;
}

void GDAndroidStorage::_createSaveDirectories()
{
    AppSettings* appSettings = qgcApp()->toolbox()->settingsManager()->appSettings();
    const QStringList paths = {
        appSettings->missionSavePath(), appSettings->parameterSavePath(), appSettings->telemetrySavePath(),
        appSettings->logSavePath(), appSettings->videoSavePath(), appSettings->photoSavePath(), appSettings->crashSavePath(),
    };
    for (const QString& path : paths) {
        if (!path.isEmpty()) {
            QDir().mkpath(path);
        }
    }
}
