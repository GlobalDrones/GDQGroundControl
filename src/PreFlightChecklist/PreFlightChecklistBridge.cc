#include "PreFlightChecklistBridge.h"
#include "qdebug.h"

#if defined(Q_OS_ANDROID)
#include <QAndroidJniObject>
#include <QtAndroid>
#endif

PreFlightChecklistBridge* PreFlightChecklistBridge::_instance = nullptr;

PreFlightChecklistBridge::PreFlightChecklistBridge(QObject* parent)
    : QObject(parent)
{
}

PreFlightChecklistBridge* PreFlightChecklistBridge::instance()
{
    if (!_instance) {
        _instance = new PreFlightChecklistBridge();
    }

    return _instance;
}

void PreFlightChecklistBridge::requestChecklist()
{
#if defined(Q_OS_ANDROID)

    QAndroidJniObject activity = QtAndroid::androidActivity();

    if (!activity.isValid()) {
        qWarning() << "PreFlightChecklist: Android activity is invalid";
        return;
    }

    QAndroidJniObject packageName =
        QAndroidJniObject::fromString(
            "org.globaldrones.GDPreFlightChecklist"
            );

    // Em vez de adivinhar o nome da Activity de entrada do app do checklist
    // (setClassName com Context+2 Strings nem existe no Android, e assumir
    // "QtActivity" genérica quebra se o app customizar a Activity, como o
    // próprio QGC faz com QGCActivity), pedimos pro PackageManager o launch
    // intent real do pacote — funciona independente de como a Activity foi
    // nomeada.
    QAndroidJniObject packageManager =
        activity.callObjectMethod(
            "getPackageManager",
            "()Landroid/content/pm/PackageManager;"
            );

    if (!packageManager.isValid()) {
        qWarning() << "PreFlightChecklist: failed to get PackageManager";
        return;
    }

    QAndroidJniObject launchIntent =
        packageManager.callObjectMethod(
            "getLaunchIntentForPackage",
            "(Ljava/lang/String;)Landroid/content/Intent;",
            packageName.object<jstring>()
            );

    if (!launchIntent.isValid()) {
        qWarning() << "PreFlightChecklist: app not installed or has no launcher activity";
        return;
    }

    qDebug() << "PreFlightChecklist: launching external app";

    QtAndroid::startActivity(
        launchIntent,
        kRequestCode,
        this
        );

#endif
}


// ============================================================================
// Android activity result
// ============================================================================

#if defined(Q_OS_ANDROID)

void PreFlightChecklistBridge::handleActivityResult(
    int receiverRequestCode,
    int resultCode,
    const QAndroidJniObject& data)
{
    // ------------------------------------------------------------------------
    // Ignora resultados de outras requisições
    // ------------------------------------------------------------------------

    if (receiverRequestCode != kRequestCode) {
        return;
    }


    // ------------------------------------------------------------------------
    // Android Activity.RESULT_OK == -1
    // ------------------------------------------------------------------------

    if (resultCode != -1) {
        return;
    }


    // ------------------------------------------------------------------------
    // Verifica se recebemos um Intent válido
    // ------------------------------------------------------------------------

    if (!data.isValid()) {
        return;
    }


    // ------------------------------------------------------------------------
    // checklist_complete (boolean — chave e tipo têm que bater com o que
    // IntentBridge::finishWithChecklistResult, no app do checklist, envia)
    // ------------------------------------------------------------------------

    _checklistComplete =
        data.callMethod<jboolean>(
            "getBooleanExtra",
            "(Ljava/lang/String;Z)Z",
            QAndroidJniObject::fromString("checklist_complete").object<jstring>(),
            jboolean(false)
            );


    // ------------------------------------------------------------------------
    // aircraft_name
    // ------------------------------------------------------------------------

    const QAndroidJniObject aircraftName =
        data.callObjectMethod(
            "getStringExtra",
            "(Ljava/lang/String;)Ljava/lang/String;",
            QAndroidJniObject::fromString(
                "aircraft_name"
                ).object<jstring>()
            );

    if (aircraftName.isValid()) {
        _aircraftName = aircraftName.toString();
    } else {
        _aircraftName.clear();
    }


    // ------------------------------------------------------------------------
    // released_by
    // ------------------------------------------------------------------------

    const QAndroidJniObject releasedBy =
        data.callObjectMethod(
            "getStringExtra",
            "(Ljava/lang/String;)Ljava/lang/String;",
            QAndroidJniObject::fromString(
                "released_by"
                ).object<jstring>()
            );

    if (releasedBy.isValid()) {
        _releasedBy = releasedBy.toString();
    } else {
        _releasedBy.clear();
    }


    // ------------------------------------------------------------------------
    // checklist_file
    // ------------------------------------------------------------------------

    const QAndroidJniObject checklistFile =
        data.callObjectMethod(
            "getStringExtra",
            "(Ljava/lang/String;)Ljava/lang/String;",
            QAndroidJniObject::fromString(
                "checklist_file"
                ).object<jstring>()
            );

    if (checklistFile.isValid()) {
        _checklistFile = checklistFile.toString();
    } else {
        _checklistFile.clear();
    }


    // ------------------------------------------------------------------------
    // released_at (long — chave e tipo têm que bater com o envio)
    // ------------------------------------------------------------------------

    _releasedAt =
        data.callMethod<jlong>(
            "getLongExtra",
            "(Ljava/lang/String;J)J",
            QAndroidJniObject::fromString("released_at").object<jstring>(),
            jlong(0)
            );


    // ------------------------------------------------------------------------
    // Resultado recebido
    // ------------------------------------------------------------------------

    _hasResult = true;

    emit checklistResultChanged();
}

#endif
