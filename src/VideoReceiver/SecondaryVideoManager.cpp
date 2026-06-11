#include "SecondaryVideoManager.h"
#include "GStreamer.h"
#include "VideoReceiver.h"
#include <QDebug>

SecondaryVideoManager::SecondaryVideoManager(QObject* parent)
    : QObject(parent) {}

SecondaryVideoManager::~SecondaryVideoManager() { stop(); }

void SecondaryVideoManager::start(const QString& url, QQuickItem* widget)
{
    stop();

    if (!widget) {
        qWarning() << "SecondaryVideo: widget is null";
        return;
    }

    if (!widget->window()) {
        qWarning() << "SecondaryVideo: widget has no window yet, retrying in 2s";
        QTimer::singleShot(2000, this, [this, url, widget](){
            start(url, widget);
        });
        return;
    }

    qWarning() << "SecondaryVideo: widget window OK, creating sink";

    _sink = GStreamer::createVideoSink(this, widget);
    if (!_sink) {
        qWarning() << "SecondaryVideo: createVideoSink failed";
        return;
    }

    _receiver = GStreamer::createVideoReceiver(this);

    connect(_receiver, &VideoReceiver::onStartComplete, this, [](VideoReceiver::STATUS s){
        qWarning() << "SecondaryVideo onStartComplete:" << s;
    });
    connect(_receiver, &VideoReceiver::onStartDecodingComplete, this, [](VideoReceiver::STATUS s){
        qWarning() << "SecondaryVideo onStartDecodingComplete:" << s;
    });

    _receiver->startDecoding(_sink);
    _receiver->start(url, 5, -1);
}

void SecondaryVideoManager::stop()
{
    if (_receiver) {
        _receiver->stopDecoding();
        _receiver->stop();
        _receiver->deleteLater();
        _receiver = nullptr;
    }
    if (_sink) {
        GStreamer::releaseVideoSink(_sink);
        _sink = nullptr;
    }
}
