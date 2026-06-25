#include "SecondaryVideoManager.h"
#include "GStreamer.h"
#include "VideoReceiver.h"
#include <QDebug>
#include <QTimer>
#include <QPointer>

SecondaryVideoManager::SecondaryVideoManager(QObject* parent)
    : QObject(parent) {}

SecondaryVideoManager::~SecondaryVideoManager() { stop(); }

void SecondaryVideoManager::start(const QString& url, QQuickItem* widget)
{
    stop();

    if (!widget) {
        qWarning() << "SecondaryVideo: widget is null";
        connect(widget, &QObject::destroyed,
                this,
                [this]() {
                    qWarning() << "Secondary video widget destroyed";
                    stop();
                });
    }

    if (!widget->window()) {
        qWarning() << "SecondaryVideo: widget has no window yet, retrying in 2s";

        // FIX: guard the QQuickItem* with QPointer so the retry doesn't
        // dereference a destroyed item if the QML page/window changes
        // before the 2s timer fires.
        QPointer<QQuickItem> guardedWidget(widget);
        QTimer::singleShot(2000, this, [this, url, guardedWidget]() {
            if (guardedWidget) {
                start(url, guardedWidget);
            } else {
                qWarning() << "SecondaryVideo: widget destroyed before retry, aborting";
            }
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
    if (!_receiver) {
        // FIX: bail out if receiver creation failed, otherwise the
        // connect()/startDecoding()/start() calls below would run on
        // a null pointer.
        qWarning() << "SecondaryVideo: createVideoReceiver failed";
        GStreamer::releaseVideoSink(_sink);
        _sink = nullptr;
        return;
    }

    connect(_receiver, &VideoReceiver::onStartDecodingComplete, this, [](VideoReceiver::STATUS s) {
        qWarning() << "SecondaryVideo onStartDecodingComplete:" << s;
    });

    // FIX: this was the main crash cause. startDecoding() was being called
    // immediately, before the source pipeline (start()) had even been
    // created/negotiated. As soon as the transmitter went live and buffers
    // started flowing, they hit a sink attached to a pipeline that wasn't
    // ready yet, crashing before the first frame ever displayed.
    //
    // Correct order: start() the source first, wait for onStartComplete,
    // and only then attach the sink via startDecoding().
    connect(_receiver, &VideoReceiver::onStartComplete, this, [this](VideoReceiver::STATUS s) {
        qWarning() << "SecondaryVideo onStartComplete:" << s;

        if (!_receiver || !_sink) {
            // stop() may have run in the meantime (e.g. user navigated away).
            return;
        }

        if (s == VideoReceiver::STATUS_OK) {
            _receiver->startDecoding(_sink);
        } else {
            qWarning() << "SecondaryVideo: start() failed with status" << s << "- not starting decoding";
        }
    });

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
