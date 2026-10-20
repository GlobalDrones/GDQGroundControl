#include "GDFence.h"
#include "QGCApplication.h"
#include "QGCMapPolygon.h"
#include "ShapeFileHelper.h"

#include <QDebug>
#include <QGeoCoordinate>
#include <QQmlEngine>
#include <QtMath>

#include <algorithm>
#include <cmath>
#include <vector>

GDFence::GDFence(QObject* parent)
    : QObject(parent)
{
}

void GDFence::registerQmlTypes()
{
    qmlRegisterSingletonType<GDFence>("GD.Fence", 1, 0, "GDFence",
        [](QQmlEngine*, QJSEngine*) -> QObject* { return new GDFence(); });
}

// Algoritmo da v3 de QGCMapPolygon::loadKMLwithSpacing dos produtos (2025-10):
// projeta os vértices num plano local em metros (origem no 1º vértice), contrai
// cada ponto radialmente em direção ao centróide e devolve só os pontos
// intermediários das arestas. Não é um offset de borda: em polígonos alongados
// ou côncavos a distância até a borda original não é exatamente "spacing".
bool GDFence::loadKMLwithSpacing(QObject* mapPolygonObject, const QString& file, double spacing)
{
    QGCMapPolygon* mapPolygon = qobject_cast<QGCMapPolygon*>(mapPolygonObject);
    if (!mapPolygon) {
        qWarning() << "GDFence::loadKMLwithSpacing: object is not a QGCMapPolygon";
        return false;
    }

    QString errorString;
    QList<QGeoCoordinate> rgCoords;
    if (!ShapeFileHelper::loadPolygonFromFile(file, rgCoords, errorString)) {
        qgcApp()->showAppMessage(errorString);
        return false;
    }

    // Mesmo agrupamento que o QGCMapPolygonVisuals usa: uma única atualização no mapa
    mapPolygon->beginReset();
    mapPolygon->clear();

    if (rgCoords.count() < 3) {
        mapPolygon->appendVertices(rgCoords);
        mapPolygon->endReset();
        return true;
    }

    const double kEarthRadius   = 6371000.0;
    const double kDegToRad      = M_PI / 180.0;
    const double kRadToDeg      = 180.0 / M_PI;

    const double latRefRad  = rgCoords.first().latitude() * kDegToRad;
    const double lonRefRad  = rgCoords.first().longitude() * kDegToRad;
    const double lonScale   = kEarthRadius * std::cos(latRefRad);

    struct Point { double x, y; };

    std::vector<Point> vertices;
    vertices.reserve(static_cast<size_t>(rgCoords.count()));
    for (const QGeoCoordinate& coord : rgCoords) {
        const double x = (coord.longitude() * kDegToRad - lonRefRad) * lonScale;
        const double y = (coord.latitude() * kDegToRad - latRefRad) * kEarthRadius;
        vertices.push_back({ x, y });
    }

    // Centróide pela fórmula da área com sinal
    double signedArea = 0.0;
    double cx = 0.0;
    double cy = 0.0;
    const size_t n = vertices.size();
    for (size_t i = 0; i < n; ++i) {
        const Point& p0 = vertices[i];
        const Point& p1 = vertices[(i + 1) % n];
        const double cross = p0.x * p1.y - p1.x * p0.y;
        signedArea += cross;
        cx += (p0.x + p1.x) * cross;
        cy += (p0.y + p1.y) * cross;
    }
    signedArea *= 0.5;
    if (std::abs(signedArea) < 1e-9) {
        qgcApp()->showAppMessage(tr("Polygon has zero area."));
        mapPolygon->endReset();
        return false;
    }
    const double scaleFactor = 1.0 / (6.0 * signedArea);
    const Point centroid = { cx * scaleFactor, cy * scaleFactor };

    std::vector<Point> shrunk;
    shrunk.reserve(n);
    for (const Point& v : vertices) {
        const double dx = v.x - centroid.x;
        const double dy = v.y - centroid.y;
        const double dist = std::sqrt(dx * dx + dy * dy);
        const double k = dist < 1e-9 ? 0.0 : std::max(0.0, dist - spacing) / dist;
        shrunk.push_back({ centroid.x + dx * k, centroid.y + dy * k });
    }

    // 50 pontos por aresta, sem os vértices; cada ponto é contraído de novo
    const int kPointsPerEdge = 50;
    std::vector<Point> densified;
    densified.reserve(n * static_cast<size_t>(kPointsPerEdge));
    for (size_t i = 0; i < n; ++i) {
        const Point& a = shrunk[i];
        const Point& b = shrunk[(i + 1) % n];
        for (int j = 1; j <= kPointsPerEdge; ++j) {
            const double t = static_cast<double>(j) / (kPointsPerEdge + 1.0);
            double x = a.x + t * (b.x - a.x);
            double y = a.y + t * (b.y - a.y);

            const double dx = x - centroid.x;
            const double dy = y - centroid.y;
            const double dist = std::sqrt(dx * dx + dy * dy);
            if (dist > 1e-9) {
                const double k = std::max(0.0, dist - spacing) / dist;
                x = centroid.x + dx * k;
                y = centroid.y + dy * k;
            }
            densified.push_back({ x, y });
        }
    }

    QList<QGeoCoordinate> finalCoords;
    finalCoords.reserve(static_cast<int>(densified.size()));
    for (const Point& p : densified) {
        const double lat = (latRefRad + p.y / kEarthRadius) * kRadToDeg;
        const double lon = (lonRefRad + p.x / lonScale) * kRadToDeg;
        finalCoords.append(QGeoCoordinate(lat, lon));
    }

    mapPolygon->appendVertices(finalCoords);
    mapPolygon->endReset();
    return true;
}
