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

    // Cria um Intent novo, em vez de usar o Intent do launcher.
    QAndroidJniObject intent(
        "android/content/Intent",
        "(Ljava/lang/String;)V",
        QAndroidJniObject::fromString(
            "android.intent.action.MAIN"
            ).object<jstring>()
        );

    if (!intent.isValid()) {
        qWarning() << "PreFlightChecklist: failed to create Intent";
        return;
    }

    // Aponta diretamente para a Activity do aplicativo de checklist.
    QAndroidJniObject componentName(
        "android/content/ComponentName",
        "(Ljava/lang/String;Ljava/lang/String;)V",
        QAndroidJniObject::fromString(
            "org.globaldrones.GDPreFlightChecklist"
            ).object<jstring>(),
        QAndroidJniObject::fromString(
            "org.qtproject.qt5.android.bindings.QtActivity"
            ).object<jstring>()
        );

    if (!componentName.isValid()) {
        qWarning() << "PreFlightChecklist: failed to create ComponentName";
        return;
    }

    intent.callObjectMethod(
        "setComponent",
        "(Landroid/content/ComponentName;)Landroid/content/Intent;",
        componentName.object<jobject>()
        );

    const jint flags =
        intent.callMethod<jint>(
            "getFlags",
            "()I"
            );

    qDebug() << "PreFlightChecklist: flags do Intent novo ="
             << Qt::hex
             << flags;

    qDebug() << "PreFlightChecklist: launching external app";

    QtAndroid::startActivity(
        intent,
        kRequestCode,
        this
        );

#endif
}


void PreFlightChecklistBridge::finalizeOperation(
    const QString &checklistFile)
{
#if defined(Q_OS_ANDROID)

    QAndroidJniObject activity = QtAndroid::androidActivity();

    if (!activity.isValid()) {
        qWarning() << "PreFlightChecklist: Android activity is invalid";
        return;
    }

    // Cria um Intent novo, em vez de usar o Intent do launcher.
    QAndroidJniObject intent(
        "android/content/Intent",
        "(Ljava/lang/String;)V",
        QAndroidJniObject::fromString(
            "android.intent.action.MAIN"
            ).object<jstring>()
        );

    if (!intent.isValid()) {
        qWarning() << "PreFlightChecklist: failed to create Intent";
        return;
    }

    // Aponta diretamente para a Activity do aplicativo de checklist.
    QAndroidJniObject componentName(
        "android/content/ComponentName",
        "(Ljava/lang/String;Ljava/lang/String;)V",
        QAndroidJniObject::fromString(
            "org.globaldrones.GDPreFlightChecklist"
            ).object<jstring>(),
        QAndroidJniObject::fromString(
            "org.qtproject.qt5.android.bindings.QtActivity"
            ).object<jstring>()
        );

    if (!componentName.isValid()) {
        qWarning() << "PreFlightChecklist: failed to create ComponentName";
        return;
    }

    intent.callObjectMethod(
        "setComponent",
        "(Landroid/content/ComponentName;)Landroid/content/Intent;",
        componentName.object<jobject>()
        );

    // Indica ao aplicativo do checklist que esta abertura
    // corresponde à finalização da operação.
    intent.callObjectMethod(
        "putExtra",
        "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;",
        QAndroidJniObject::fromString(
            "action"
            ).object<jstring>(),
        QAndroidJniObject::fromString(
            "finalizar_operacao"
            ).object<jstring>()
        );

    // Passa o arquivo da checklist que deve ser utilizado
    // para gerar o relatório da operação.
    intent.callObjectMethod(
        "putExtra",
        "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;",
        QAndroidJniObject::fromString(
            "checklist_file"
            ).object<jstring>(),
        QAndroidJniObject::fromString(
            checklistFile
            ).object<jstring>()
        );

    const jint flags =
        intent.callMethod<jint>(
            "getFlags",
            "()I"
            );

    qDebug() << "PreFlightChecklist: flags do Intent novo ="
             << Qt::hex
             << flags;

    qDebug() << "PreFlightChecklist: requesting operation finalize for"
             << checklistFile;

    QtAndroid::startActivity(
        intent,
        kFinalizeRequestCode,
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
    qDebug() << "PreFlightChecklistBridge::handleActivityResult chamado —"
             << "requestCode:" << receiverRequestCode
             << "resultCode:" << resultCode
             << "data válida:" << data.isValid();

    if (receiverRequestCode != kRequestCode && receiverRequestCode != kFinalizeRequestCode) {
        return; // não é nenhum dos dois Intents que a gente dispara
    }

    if (resultCode != -1) {
        return;
    }

    if (!data.isValid()) {
        return;
    }

    if (receiverRequestCode == kFinalizeRequestCode) {

        _reportGenerated =
            data.callMethod<jboolean>(
                "getBooleanExtra",
                "(Ljava/lang/String;Z)Z",
                QAndroidJniObject::fromString(
                    "report_generated"
                    ).object<jstring>(),
                jboolean(false)
                );

        const QAndroidJniObject reportPath =
            data.callObjectMethod(
                "getStringExtra",
                "(Ljava/lang/String;)Ljava/lang/String;",
                QAndroidJniObject::fromString(
                    "report_path"
                    ).object<jstring>()
                );

        _reportPath =
            reportPath.isValid()
                ? reportPath.toString()
                : QString();

        qDebug() << "PreFlightChecklist: ===== RESULTADO FINALIZACAO =====";
        qDebug() << "PreFlightChecklist: report_generated ="
                 << _reportGenerated;
        qDebug() << "PreFlightChecklist: report_path ="
                 << _reportPath;
        qDebug() << "PreFlightChecklist: report_path valido ="
                 << reportPath.isValid();
        qDebug() << "PreFlightChecklist: =================================";

        _hasReportResult = true;
        emit reportResultChanged();

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

    qDebug() << "PreFlightChecklistBridge: checklistFile recebido =" << _checklistFile;


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
