#include "PreFlightChecklistBridge.h"
#include "QGCApplication.h"
#include "QGCToolbox.h"
#include "QGCLoggingCategory.h"
#include "MultiVehicleManager.h"
#include "Vehicle.h"

#include <QQmlEngine>
#include <QtQml>

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#include <QAndroidJniEnvironment>
#endif

QGC_LOGGING_CATEGORY(PreFlightChecklistLog, "PreFlightChecklistLog")

#ifdef Q_OS_ANDROID
namespace {

// App de checklist (app Qt): package e Activity de entrada
const char kChecklistPackage[]  = "org.globaldrones.GDPreFlightChecklist";
const char kChecklistActivity[] = "org.qtproject.qt5.android.bindings.QtActivity";

const int kResultOk = -1; // Activity.RESULT_OK

QAndroidJniObject javaString(const char* text)
{
    return QAndroidJniObject::fromString(QString::fromLatin1(text));
}

/// Intent novo (ACTION_MAIN) com a Activity do app de checklist explícita. O Intent do launcher
/// (getLaunchIntentForPackage) vem com FLAG_ACTIVITY_NEW_TASK, que não devolve resultado ao
/// startActivityForResult.
QAndroidJniObject checklistIntent()
{
    QAndroidJniObject intent("android/content/Intent",
                             "(Ljava/lang/String;)V",
                             javaString("android.intent.action.MAIN").object<jstring>());
    QAndroidJniObject component("android/content/ComponentName",
                                "(Ljava/lang/String;Ljava/lang/String;)V",
                                javaString(kChecklistPackage).object<jstring>(),
                                javaString(kChecklistActivity).object<jstring>());
    if (!intent.isValid() || !component.isValid()) {
        qCWarning(PreFlightChecklistLog) << "Falha ao criar o Intent do app de checklist";
        return QAndroidJniObject();
    }
    intent.callObjectMethod("setComponent",
                            "(Landroid/content/ComponentName;)Landroid/content/Intent;",
                            component.object<jobject>());
    return intent;
}

void putExtra(const QAndroidJniObject& intent, const char* key, const QString& value)
{
    intent.callObjectMethod("putExtra",
                            "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;",
                            javaString(key).object<jstring>(),
                            QAndroidJniObject::fromString(value).object<jstring>());
}

void startChecklistActivity(const QAndroidJniObject& intent, int requestCode, QAndroidActivityResultReceiver* receiver)
{
    if (!QtAndroid::androidActivity().isValid()) {
        qCWarning(PreFlightChecklistLog) << "Activity Android inválida";
        return;
    }

    QtAndroid::startActivity(intent, requestCode, receiver);

    // App de checklist não instalado: startActivityForResult lança ActivityNotFoundException.
    // A exceção pendente derrubaria o app na próxima chamada JNI.
    QAndroidJniEnvironment env;
    if (env->ExceptionCheck()) {
        env->ExceptionDescribe();
        env->ExceptionClear();
        qCWarning(PreFlightChecklistLog) << "Não foi possível abrir o app de checklist" << kChecklistPackage;
    }
}

// Chaves e tipos dos extras têm que bater com o que o app de checklist envia
// (IntentBridge::finishWithChecklistResult no app).

QString stringExtra(const QAndroidJniObject& data, const char* key)
{
    const QAndroidJniObject value = data.callObjectMethod("getStringExtra",
                                                          "(Ljava/lang/String;)Ljava/lang/String;",
                                                          javaString(key).object<jstring>());
    return value.isValid() ? value.toString() : QString();
}

bool boolExtra(const QAndroidJniObject& data, const char* key)
{
    return data.callMethod<jboolean>("getBooleanExtra",
                                     "(Ljava/lang/String;Z)Z",
                                     javaString(key).object<jstring>(),
                                     jboolean(false)) != JNI_FALSE;
}

qint64 longExtra(const QAndroidJniObject& data, const char* key)
{
    return data.callMethod<jlong>("getLongExtra",
                                  "(Ljava/lang/String;J)J",
                                  javaString(key).object<jstring>(),
                                  jlong(0));
}

} // namespace
#endif // Q_OS_ANDROID

PreFlightChecklistBridge::PreFlightChecklistBridge(QObject* parent)
    : QObject(parent)
{
    // O checklist vale para a aeronave conectada: trocar ou perder o veículo ativo exige um novo.
    QGCToolbox* toolbox = qgcApp() ? qgcApp()->toolbox() : nullptr;
    MultiVehicleManager* multiVehicleManager = toolbox ? toolbox->multiVehicleManager() : nullptr;
    if (multiVehicleManager) {
        _activeVehicle = multiVehicleManager->activeVehicle();
        connect(multiVehicleManager, &MultiVehicleManager::activeVehicleChanged, this, &PreFlightChecklistBridge::_activeVehicleChanged);
    }
}

PreFlightChecklistBridge* PreFlightChecklistBridge::instance()
{
    static PreFlightChecklistBridge* bridge = new PreFlightChecklistBridge();
    return bridge;
}

void PreFlightChecklistBridge::registerQmlTypes()
{
    // A instância é usada também pela trava de armamento (C++): o motor QML não pode apagá-la.
    PreFlightChecklistBridge* bridge = instance();
    QQmlEngine::setObjectOwnership(bridge, QQmlEngine::CppOwnership);

    qmlRegisterSingletonType<PreFlightChecklistBridge>("PreFlightChecklist.Object", 1, 0, "PreFlightChecklist",
                                                       [](QQmlEngine*, QJSEngine*) -> QObject* {
                                                           return PreFlightChecklistBridge::instance();
                                                       });
}

bool PreFlightChecklistBridge::armingAllowed(Vehicle* /*vehicle*/, QString& reason)
{
    if (_checklistComplete) {
        return true;
    }
    reason = tr("Checklist pré-operacional não foi liberado. Complete o checklist antes de armar.");
    return false;
}

void PreFlightChecklistBridge::requestChecklist()
{
#ifdef Q_OS_ANDROID
    const QAndroidJniObject intent = checklistIntent();
    if (!intent.isValid()) {
        return;
    }
    qCDebug(PreFlightChecklistLog) << "Abrindo o app de checklist";
    startChecklistActivity(intent, kRequestCode, this);
#endif
}

void PreFlightChecklistBridge::finalizeOperation(const QString& checklistFile)
{
#ifdef Q_OS_ANDROID
    const QAndroidJniObject intent = checklistIntent();
    if (intent.isValid()) {
        // O app de checklist gera o relatório da operação a partir do arquivo do checklist
        putExtra(intent, "action", QStringLiteral("finalizar_operacao"));
        putExtra(intent, "checklist_file", checklistFile);
        qCDebug(PreFlightChecklistLog) << "Finalizando operação" << checklistFile;
        startChecklistActivity(intent, kFinalizeRequestCode, this);
    }
#else
    Q_UNUSED(checklistFile)
#endif

    // A operação terminou mesmo que o relatório não volte: o próximo armamento exige um novo checklist.
    _resetReport();
    _resetChecklist();
}

#ifdef Q_OS_ANDROID
void PreFlightChecklistBridge::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject& data)
{
    // Chamado na thread de UI do Android. O Intent só vale durante a chamada, então os extras são
    // lidos aqui e o estado é atualizado na thread do Qt (QML e trava de armamento).
    if (receiverRequestCode != kRequestCode && receiverRequestCode != kFinalizeRequestCode) {
        return;
    }

    // Cancelado ou sem dados: o estado não muda
    if (resultCode != kResultOk || !data.isValid()) {
        qCDebug(PreFlightChecklistLog) << "App de checklist voltou sem resultado" << receiverRequestCode << resultCode;
        return;
    }

    if (receiverRequestCode == kFinalizeRequestCode) {
        const bool      generated   = boolExtra(data, "report_generated");
        const QString   path        = stringExtra(data, "report_path");
        qCDebug(PreFlightChecklistLog) << "Relatório" << generated << path;
        QMetaObject::invokeMethod(this, [this, generated, path]() { _setReportResult(generated, path); }, Qt::QueuedConnection);
        return;
    }

    ChecklistResult result;
    result.complete         = boolExtra(data, "checklist_complete");
    result.aircraftName     = stringExtra(data, "aircraft_name");
    result.releasedBy       = stringExtra(data, "released_by");
    result.checklistFile    = stringExtra(data, "checklist_file");
    result.releasedAt       = longExtra(data, "released_at");
    qCDebug(PreFlightChecklistLog) << "Checklist" << result.complete << result.aircraftName << result.checklistFile;
    QMetaObject::invokeMethod(this, [this, result]() { _setChecklistResult(result); }, Qt::QueuedConnection);
}
#endif

void PreFlightChecklistBridge::_setChecklistResult(const ChecklistResult& result)
{
    _hasResult          = true;
    _checklistComplete  = result.complete;
    _aircraftName       = result.aircraftName;
    _releasedBy         = result.releasedBy;
    _checklistFile      = result.checklistFile;
    _releasedAt         = result.releasedAt;
    emit checklistResultChanged();
}

void PreFlightChecklistBridge::_setReportResult(bool generated, const QString& path)
{
    _hasReportResult    = true;
    _reportGenerated    = generated;
    _reportPath         = path;
    emit reportResultChanged();
}

void PreFlightChecklistBridge::_resetChecklist()
{
    if (!_hasResult && !_checklistComplete) {
        return;
    }
    _hasResult          = false;
    _checklistComplete  = false;
    _aircraftName.clear();
    _releasedBy.clear();
    _checklistFile.clear();
    _releasedAt         = 0;
    emit checklistResultChanged();
}

void PreFlightChecklistBridge::_resetReport()
{
    if (!_hasReportResult) {
        return;
    }
    _hasReportResult    = false;
    _reportGenerated    = false;
    _reportPath.clear();
    emit reportResultChanged();
}

void PreFlightChecklistBridge::_activeVehicleChanged(Vehicle* activeVehicle)
{
    // Um checklist feito antes de conectar vale para o primeiro veículo que conectar
    if (_activeVehicle && _activeVehicle != activeVehicle) {
        qCDebug(PreFlightChecklistLog) << "Veículo ativo mudou: checklist zerado";
        _resetChecklist();
    }
    _activeVehicle = activeVehicle;
}
