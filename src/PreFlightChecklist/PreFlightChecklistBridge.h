#ifndef PREFLIGHTCHECKLISTBRIDGE_H
#define PREFLIGHTCHECKLISTBRIDGE_H

#include <QObject>
#include <QString>

#if defined(Q_OS_ANDROID)
#include <QtAndroid>
#include <QAndroidActivityResultReceiver>
#include <QAndroidJniObject>
#endif

class PreFlightChecklistBridge : public QObject
#if defined(Q_OS_ANDROID)
    , public QAndroidActivityResultReceiver
#endif
{
    Q_OBJECT

    Q_PROPERTY(bool hasResult
                   READ hasResult
                       NOTIFY checklistResultChanged)

    Q_PROPERTY(bool checklistComplete
                   READ checklistComplete
                       NOTIFY checklistResultChanged)

    Q_PROPERTY(QString aircraftName
                   READ aircraftName
                       NOTIFY checklistResultChanged)

    Q_PROPERTY(QString releasedBy
                   READ releasedBy
                       NOTIFY checklistResultChanged)

    Q_PROPERTY(QString checklistFile
                   READ checklistFile
                       NOTIFY checklistResultChanged)

    Q_PROPERTY(qint64 releasedAt
                   READ releasedAt
                       NOTIFY checklistResultChanged)

public:
    static PreFlightChecklistBridge *instance();

    Q_INVOKABLE void requestChecklist();

    bool hasResult() const
    {
        return _hasResult;
    }

    bool checklistComplete() const
    {
        return _checklistComplete;
    }

    QString aircraftName() const
    {
        return _aircraftName;
    }

    QString releasedBy() const
    {
        return _releasedBy;
    }

    QString checklistFile() const
    {
        return _checklistFile;
    }

    qint64 releasedAt() const
    {
        return _releasedAt;
    }

#if defined(Q_OS_ANDROID)
    void handleActivityResult(
        int receiverRequestCode,
        int resultCode,
        const QAndroidJniObject &data
        ) override;
#endif

signals:
    void checklistResultChanged();

private:
    explicit PreFlightChecklistBridge(QObject *parent = nullptr);

    static constexpr int kRequestCode = 4200;

    static PreFlightChecklistBridge *_instance;

    bool _hasResult = false;
    bool _checklistComplete = false;

    QString _aircraftName;
    QString _releasedBy;
    QString _checklistFile;

    qint64 _releasedAt = 0;
};

#endif // PREFLIGHTCHECKLISTBRIDGE_H
