#pragma once

#include <QObject>
#include <QString>

/// Zonas de voo a partir de KML/SHP com margem. Disponível no QML como o
/// singleton GDFence (import GD.Fence 1.0).
///
/// Usa só a API pública do QGCMapPolygon, assim o src/MissionManager fica igual
/// à base.
class GDFence : public QObject
{
    Q_OBJECT

public:
    explicit GDFence(QObject* parent = nullptr);

    static void registerQmlTypes();

    /// Carrega o polígono do arquivo KML/SHP em mapPolygon (QGCMapPolygon),
    /// contraído spacing metros em direção ao centróide, com 50 pontos por aresta.
    /// @return true: polígono carregado
    Q_INVOKABLE bool loadKMLwithSpacing(QObject* mapPolygon, const QString& file, double spacing);
};
