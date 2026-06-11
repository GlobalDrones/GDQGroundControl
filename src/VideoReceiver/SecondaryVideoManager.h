#ifndef SECONDARYVIDEOMANAGER_H
#define SECONDARYVIDEOMANAGER_H
#pragma once
#include <QObject>
class QQuickItem;
class VideoReceiver;

class SecondaryVideoManager : public QObject
{
    Q_OBJECT

public:
    explicit SecondaryVideoManager(QObject* parent = nullptr);
    ~SecondaryVideoManager();

    Q_INVOKABLE void start(const QString& url, QQuickItem* widget);
    Q_INVOKABLE void stop();

private:
    VideoReceiver* _receiver = nullptr;
    void*          _sink     = nullptr;
};
#endif // SECONDARYVIDEOMANAGER_H
