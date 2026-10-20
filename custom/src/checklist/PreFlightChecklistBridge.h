#pragma once

#include <QObject>
#include <QPointer>
#include <QString>

#ifdef Q_OS_ANDROID
#include <QAndroidActivityResultReceiver>
#include <QAndroidJniObject>
#endif

class Vehicle;

/// Integração com o app externo de checklist pré-operacional (org.globaldrones.GDPreFlightChecklist).
/// No QML: import PreFlightChecklist.Object 1.0, singleton PreFlightChecklist.
/// O app só existe no Android; nas outras plataformas a classe compila e não abre nada.
/// Quem decide se o checklist é usado é a configuração gdSettings.externalChecklistEnabled
/// (GDCorePlugin::armingAllowed e MainRootWindow.qml).
class PreFlightChecklistBridge : public QObject
#ifdef Q_OS_ANDROID
    , public QAndroidActivityResultReceiver
#endif
{
    Q_OBJECT

public:
    /// Algum resultado de checklist chegou (liberado ou não)
    Q_PROPERTY(bool     hasResult           READ hasResult          NOTIFY checklistResultChanged)
    /// Checklist liberado. Volta a falso em "Finalizar Operação" e quando o veículo ativo muda ou desconecta.
    Q_PROPERTY(bool     checklistComplete   READ checklistComplete  NOTIFY checklistResultChanged)
    Q_PROPERTY(QString  aircraftName        READ aircraftName       NOTIFY checklistResultChanged)
    Q_PROPERTY(QString  releasedBy          READ releasedBy         NOTIFY checklistResultChanged)
    /// Arquivo do checklist preenchido: é o que finalizeOperation() devolve ao app para gerar o relatório
    Q_PROPERTY(QString  checklistFile       READ checklistFile      NOTIFY checklistResultChanged)
    Q_PROPERTY(qint64   releasedAt          READ releasedAt         NOTIFY checklistResultChanged)
    Q_PROPERTY(bool     hasReportResult     READ hasReportResult    NOTIFY reportResultChanged)
    Q_PROPERTY(bool     reportGenerated     READ reportGenerated    NOTIFY reportResultChanged)
    Q_PROPERTY(QString  reportPath          READ reportPath         NOTIFY reportResultChanged)

    static PreFlightChecklistBridge* instance();
    static void registerQmlTypes();

    /// Abre o app de checklist. O resultado chega por checklistResultChanged.
    Q_INVOKABLE void requestChecklist();
    /// Encerra a operação: zera o checklist (o próximo armamento exige um novo) e pede ao app
    /// o relatório gerado a partir de checklistFile. O resultado chega por reportResultChanged.
    Q_INVOKABLE void finalizeOperation(const QString& checklistFile);

    /// Trava de armamento. Só é consultada com o checklist externo ligado (GDCorePlugin::armingAllowed).
    bool armingAllowed(Vehicle* vehicle, QString& reason);

    bool    hasResult           () const { return _hasResult; }
    bool    checklistComplete   () const { return _checklistComplete; }
    QString aircraftName        () const { return _aircraftName; }
    QString releasedBy          () const { return _releasedBy; }
    QString checklistFile       () const { return _checklistFile; }
    qint64  releasedAt          () const { return _releasedAt; }
    bool    hasReportResult     () const { return _hasReportResult; }
    bool    reportGenerated     () const { return _reportGenerated; }
    QString reportPath          () const { return _reportPath; }

#ifdef Q_OS_ANDROID
    void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject& data) override;
#endif

signals:
    void checklistResultChanged();
    void reportResultChanged();

private:
    explicit PreFlightChecklistBridge(QObject* parent = nullptr);

    struct ChecklistResult {
        bool    complete    = false;
        QString aircraftName;
        QString releasedBy;
        QString checklistFile;
        qint64  releasedAt  = 0;
    };

    void _setChecklistResult    (const ChecklistResult& result);
    void _setReportResult       (bool generated, const QString& path);
    void _resetChecklist        ();
    void _resetReport           ();
    void _activeVehicleChanged  (Vehicle* activeVehicle);

    // Códigos locais do QAndroidActivityResultReceiver
    static constexpr int kRequestCode           = 4200;
    static constexpr int kFinalizeRequestCode   = 77777;

    bool    _hasResult          = false;
    bool    _checklistComplete  = false;
    QString _aircraftName;
    QString _releasedBy;
    QString _checklistFile;
    qint64  _releasedAt         = 0;

    bool    _hasReportResult    = false;
    bool    _reportGenerated    = false;
    QString _reportPath;

    QPointer<Vehicle> _activeVehicle;
};
