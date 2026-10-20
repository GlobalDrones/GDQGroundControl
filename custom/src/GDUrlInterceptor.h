#pragma once

#include <QHash>
#include <QQmlAbstractUrlInterceptor>

/// Substitui arquivos da base (QML e imagens) pelas versões Global Drones.
///
/// Um recurso qrc:/<caminho> é procurado primeiro em qrc:/gdv/<caminho>
/// (variante), depois em qrc:/gdc/<caminho> (comum a todos os produtos) e, se
/// não houver substituto, fica o original da base SiYi.
///
/// Arquivos já redirecionados que referenciam vizinhos por caminho relativo
/// (qrc:/gdc/qml/X.qml -> qrc:/gdc/qml/Y.qml) voltam a ser resolvidos pelo
/// caminho lógico, então Y pode estar na variante, no comum ou na base.
class GDUrlInterceptor : public QQmlAbstractUrlInterceptor
{
public:
    QUrl intercept(const QUrl& url, DataType type) override;

private:
    QString _resolve(const QString& logicalPath);

    QHash<QString, QString> _cache;
};
