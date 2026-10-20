#include "GDUrlInterceptor.h"

#include <QFile>

static const QString kVariantPrefix = QStringLiteral("/gdv");
static const QString kCommonPrefix  = QStringLiteral("/gdc");

QUrl GDUrlInterceptor::intercept(const QUrl& url, DataType type)
{
    if (type == QmldirFile || url.scheme() != QLatin1String("qrc")) {
        return url;
    }

    QString logicalPath = url.path();
    if (logicalPath.startsWith(kVariantPrefix + QLatin1Char('/'))) {
        logicalPath.remove(0, kVariantPrefix.length());
    } else if (logicalPath.startsWith(kCommonPrefix + QLatin1Char('/'))) {
        logicalPath.remove(0, kCommonPrefix.length());
    }

    const QString resolved = _resolve(logicalPath);
    if (resolved == url.path()) {
        return url;
    }
    QUrl result(url);
    result.setPath(resolved);
    return result;
}

QString GDUrlInterceptor::_resolve(const QString& logicalPath)
{
    auto it = _cache.constFind(logicalPath);
    if (it != _cache.constEnd()) {
        return it.value();
    }

    QString resolved = logicalPath;
    if (QFile::exists(QLatin1Char(':') + kVariantPrefix + logicalPath)) {
        resolved = kVariantPrefix + logicalPath;
    } else if (QFile::exists(QLatin1Char(':') + kCommonPrefix + logicalPath)) {
        resolved = kCommonPrefix + logicalPath;
    }
    _cache.insert(logicalPath, resolved);
    return resolved;
}
