/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "QGCMapPolygon.h"
#include "QGCGeo.h"
#include "JsonHelper.h"
#include "QGCQGeoCoordinate.h"
#include "QGCApplication.h"
#include "ShapeFileHelper.h"
#include "QGCLoggingCategory.h"
#include <vector>
#include <cmath>
#include <numeric>


#include <QGeoRectangle>
#include <QDebug>
#include <QJsonArray>
#include <QLineF>
#include <QFile>
#include <QDomDocument>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

const char* QGCMapPolygon::jsonPolygonKey = "polygon";

QGCMapPolygon::QGCMapPolygon(QObject* parent)
    : QObject               (parent)
    , _dirty                (false)
    , _centerDrag           (false)
    , _ignoreCenterUpdates  (false)
    , _interactive          (false)
    , _resetActive          (false)
{
    _init();
}

QGCMapPolygon::QGCMapPolygon(const QGCMapPolygon& other, QObject* parent)
    : QObject               (parent)
    , _dirty                (false)
    , _centerDrag           (false)
    , _ignoreCenterUpdates  (false)
    , _interactive          (false)
    , _resetActive          (false)
{
    *this = other;

    _init();
}

void QGCMapPolygon::_init(void)
{
    connect(&_polygonModel, &QmlObjectListModel::dirtyChanged, this, &QGCMapPolygon::_polygonModelDirtyChanged);
    connect(&_polygonModel, &QmlObjectListModel::countChanged, this, &QGCMapPolygon::_polygonModelCountChanged);

    connect(this, &QGCMapPolygon::pathChanged,  this, &QGCMapPolygon::_updateCenter);
    connect(this, &QGCMapPolygon::countChanged, this, &QGCMapPolygon::isValidChanged);
    connect(this, &QGCMapPolygon::countChanged, this, &QGCMapPolygon::isEmptyChanged);
}

const QGCMapPolygon& QGCMapPolygon::operator=(const QGCMapPolygon& other)
{
    clear();

    QVariantList vertices = other.path();
    QList<QGeoCoordinate> rgCoord;
    for (const QVariant& vertexVar: vertices) {
        rgCoord.append(vertexVar.value<QGeoCoordinate>());
    }
    appendVertices(rgCoord);

    setDirty(true);

    return *this;
}

void QGCMapPolygon::clear(void)
{
    // Bug workaround, see below
    while (_polygonPath.count() > 1) {
        _polygonPath.takeLast();
    }
    emit pathChanged();

    // Although this code should remove the polygon from the map it doesn't. There appears
    // to be a bug in QGCMapPolygon which causes it to not be redrawn if the list is empty. So
    // we work around it by using the code above to remove all but the last point which in turn
    // will cause the polygon to go away.
    _polygonPath.clear();

    _polygonModel.clearAndDeleteContents();

    emit cleared();

    setDirty(true);
}

void QGCMapPolygon::adjustVertex(int vertexIndex, const QGeoCoordinate coordinate)
{
    _polygonPath[vertexIndex] = QVariant::fromValue(coordinate);
    _polygonModel.value<QGCQGeoCoordinate*>(vertexIndex)->setCoordinate(coordinate);
    if (!_centerDrag) {
        // When dragging center we don't signal path changed until all vertices are updated
        emit pathChanged();
    }
    setDirty(true);
}

void QGCMapPolygon::setDirty(bool dirty)
{
    if (_dirty != dirty) {
        _dirty = dirty;
        if (!dirty) {
            _polygonModel.setDirty(false);
        }
        emit dirtyChanged(dirty);
    }
}

QGeoCoordinate QGCMapPolygon::_coordFromPointF(const QPointF& point) const
{
    QGeoCoordinate coord;

    if (_polygonPath.count() > 0) {
        QGeoCoordinate tangentOrigin = _polygonPath[0].value<QGeoCoordinate>();
        convertNedToGeo(-point.y(), point.x(), 0, tangentOrigin, &coord);
    }

    return coord;
}

QPointF QGCMapPolygon::_pointFFromCoord(const QGeoCoordinate& coordinate) const
{
    if (_polygonPath.count() > 0) {
        double y, x, down;
        QGeoCoordinate tangentOrigin = _polygonPath[0].value<QGeoCoordinate>();

        convertGeoToNed(coordinate, tangentOrigin, &y, &x, &down);
        return QPointF(x, -y);
    }

    return QPointF();
}

QPolygonF QGCMapPolygon::_toPolygonF(void) const
{
    QPolygonF polygon;

    if (_polygonPath.count() > 2) {
        for (int i=0; i<_polygonPath.count(); i++) {
            polygon.append(_pointFFromCoord(_polygonPath[i].value<QGeoCoordinate>()));
        }
    }

    return polygon;
}

bool QGCMapPolygon::containsCoordinate(const QGeoCoordinate& coordinate) const
{
    if (_polygonPath.count() > 2) {
        return _toPolygonF().containsPoint(_pointFFromCoord(coordinate), Qt::OddEvenFill);
    } else {
        return false;
    }
}

void QGCMapPolygon::setPath(const QList<QGeoCoordinate>& path)
{
    _polygonPath.clear();
    _polygonModel.clearAndDeleteContents();
    for(const QGeoCoordinate& coord: path) {
        _polygonPath.append(QVariant::fromValue(coord));
        _polygonModel.append(new QGCQGeoCoordinate(coord, this));
    }

    setDirty(true);
    emit pathChanged();
}

void QGCMapPolygon::setPath(const QVariantList& path)
{
    _polygonPath = path;

    _polygonModel.clearAndDeleteContents();
    for (int i=0; i<_polygonPath.count(); i++) {
        _polygonModel.append(new QGCQGeoCoordinate(_polygonPath[i].value<QGeoCoordinate>(), this));
    }

    setDirty(true);
    emit pathChanged();
}

void QGCMapPolygon::saveToJson(QJsonObject& json)
{
    QJsonValue jsonValue;

    JsonHelper::saveGeoCoordinateArray(_polygonPath, false /* writeAltitude*/, jsonValue);
    json.insert(jsonPolygonKey, jsonValue);
    setDirty(false);
}

bool QGCMapPolygon::loadFromJson(const QJsonObject& json, bool required, QString& errorString)
{
    errorString.clear();
    clear();

    if (required) {
        if (!JsonHelper::validateRequiredKeys(json, QStringList(jsonPolygonKey), errorString)) {
            return false;
        }
    } else if (!json.contains(jsonPolygonKey)) {
        return true;
    }

    if (!JsonHelper::loadGeoCoordinateArray(json[jsonPolygonKey], false /* altitudeRequired */, _polygonPath, errorString)) {
        return false;
    }

    for (int i=0; i<_polygonPath.count(); i++) {
        _polygonModel.append(new QGCQGeoCoordinate(_polygonPath[i].value<QGeoCoordinate>(), this));
    }

    setDirty(false);
    emit pathChanged();

    return true;
}

QList<QGeoCoordinate> QGCMapPolygon::coordinateList(void) const
{
    QList<QGeoCoordinate> coords;

    for (int i=0; i<_polygonPath.count(); i++) {
        coords.append(_polygonPath[i].value<QGeoCoordinate>());
    }

    return coords;
}

void QGCMapPolygon::splitPolygonSegment(int vertexIndex)
{
    int nextIndex = vertexIndex + 1;
    if (nextIndex > _polygonPath.length() - 1) {
        nextIndex = 0;
    }

    QGeoCoordinate firstVertex = _polygonPath[vertexIndex].value<QGeoCoordinate>();
    QGeoCoordinate nextVertex = _polygonPath[nextIndex].value<QGeoCoordinate>();

    double distance = firstVertex.distanceTo(nextVertex);
    double azimuth = firstVertex.azimuthTo(nextVertex);
    QGeoCoordinate newVertex = firstVertex.atDistanceAndAzimuth(distance / 2, azimuth);

    if (nextIndex == 0) {
        appendVertex(newVertex);
    } else {
        _polygonModel.insert(nextIndex, new QGCQGeoCoordinate(newVertex, this));
        _polygonPath.insert(nextIndex, QVariant::fromValue(newVertex));
        emit pathChanged();
        if (0 <= _selectedVertexIndex && vertexIndex < _selectedVertexIndex) {
            selectVertex(_selectedVertexIndex+1);
        }
    }
}

void QGCMapPolygon::appendVertex(const QGeoCoordinate& coordinate)
{
    _polygonPath.append(QVariant::fromValue(coordinate));
    _polygonModel.append(new QGCQGeoCoordinate(coordinate, this));
    emit pathChanged();
}

void QGCMapPolygon::appendVertices(const QList<QGeoCoordinate>& coordinates)
{
    QList<QObject*> objects;

    _beginResetIfNotActive();
    for (const QGeoCoordinate& coordinate: coordinates) {
        objects.append(new QGCQGeoCoordinate(coordinate, this));
        _polygonPath.append(QVariant::fromValue(coordinate));
    }
    _polygonModel.append(objects);
    _endResetIfNotActive();

    emit pathChanged();
}

void QGCMapPolygon::appendVertices(const QVariantList& varCoords)
{
    QList<QGeoCoordinate> rgCoords;
    for (const QVariant& varCoord: varCoords) {
        rgCoords.append(varCoord.value<QGeoCoordinate>());
    }
    appendVertices(rgCoords);
}

void QGCMapPolygon::_polygonModelDirtyChanged(bool dirty)
{
    if (dirty) {
        setDirty(true);
    }
}

void QGCMapPolygon::removeVertex(int vertexIndex)
{
    if (vertexIndex < 0 && vertexIndex > _polygonPath.length() - 1) {
        qWarning() << "Call to removePolygonCoordinate with bad vertexIndex:count" << vertexIndex << _polygonPath.length();
        return;
    }

    if (_polygonPath.length() <= 3) {
        // Don't allow the user to trash the polygon
        return;
    }

    QObject* coordObj = _polygonModel.removeAt(vertexIndex);
    coordObj->deleteLater();
    if(vertexIndex == _selectedVertexIndex) {
        selectVertex(-1);
    } else if (vertexIndex < _selectedVertexIndex) {
        selectVertex(_selectedVertexIndex - 1);
    } // else do nothing - keep current selected vertex

    _polygonPath.removeAt(vertexIndex);
    emit pathChanged();
}

void QGCMapPolygon::_polygonModelCountChanged(int count)
{
    emit countChanged(count);
}

void QGCMapPolygon::_updateCenter(void)
{
    if (!_ignoreCenterUpdates) {
        QGeoCoordinate center;

        if (_polygonPath.count() > 2) {
            QPointF centroid(0, 0);
            QPolygonF polygonF = _toPolygonF();
            for (int i=0; i<polygonF.count(); i++) {
                centroid += polygonF[i];
            }
            center = _coordFromPointF(QPointF(centroid.x() / polygonF.count(), centroid.y() / polygonF.count()));
        }
        if (_center != center) {
            _center = center;
            emit centerChanged(center);
        }
    }
}

void QGCMapPolygon::setCenter(QGeoCoordinate newCenter)
{
    if (newCenter != _center) {
        _ignoreCenterUpdates = true;

        // Adjust polygon vertices to new center
        double distance = _center.distanceTo(newCenter);
        double azimuth = _center.azimuthTo(newCenter);

        for (int i=0; i<count(); i++) {
            QGeoCoordinate oldVertex = _polygonPath[i].value<QGeoCoordinate>();
            QGeoCoordinate newVertex = oldVertex.atDistanceAndAzimuth(distance, azimuth);
            adjustVertex(i, newVertex);
        }

        if (_centerDrag) {
            // When center dragging, signals from adjustVertext are not sent. So we need to signal here when all adjusting is complete.
            emit pathChanged();
        }

        _ignoreCenterUpdates = false;

        _center = newCenter;
        emit centerChanged(newCenter);
    }
}

void QGCMapPolygon::setCenterDrag(bool centerDrag)
{
    if (centerDrag != _centerDrag) {
        _centerDrag = centerDrag;
        emit centerDragChanged(centerDrag);
    }
}

void QGCMapPolygon::setInteractive(bool interactive)
{
    if (_interactive != interactive) {
        _interactive = interactive;
        emit interactiveChanged(interactive);
    }
}

QGeoCoordinate QGCMapPolygon::vertexCoordinate(int vertex) const
{
    if (vertex >= 0 && vertex < _polygonPath.count()) {
        return _polygonPath[vertex].value<QGeoCoordinate>();
    } else {
        qWarning() << "QGCMapPolygon::vertexCoordinate bad vertex requested:count" << vertex << _polygonPath.count();
        return QGeoCoordinate();
    }
}

QList<QPointF> QGCMapPolygon::nedPolygon(void) const
{
    QList<QPointF>  nedPolygon;

    if (count() > 0) {
        QGeoCoordinate  tangentOrigin = vertexCoordinate(0);

        for (int i=0; i<_polygonModel.count(); i++) {
            double y, x, down;
            QGeoCoordinate vertex = vertexCoordinate(i);
            if (i == 0) {
                // This avoids a nan calculation that comes out of convertGeoToNed
                x = y = 0;
            } else {
                convertGeoToNed(vertex, tangentOrigin, &y, &x, &down);
            }
            nedPolygon += QPointF(x, y);
        }
    }

    return nedPolygon;
}


void QGCMapPolygon::offset(double distance)
{
    QList<QGeoCoordinate> rgNewPolygon;

    // I'm sure there is some beautiful famous algorithm to do this, but here is a brute force method

    if (count() > 2) {
        // Convert the polygon to NED
        QList<QPointF> rgNedVertices = nedPolygon();

        // Walk the edges, offsetting by the specified distance
        QList<QLineF> rgOffsetEdges;
        for (int i=0; i<rgNedVertices.count(); i++) {
            int     lastIndex = i == rgNedVertices.count() - 1 ? 0 : i + 1;
            QLineF  offsetEdge;
            QLineF  originalEdge(rgNedVertices[i], rgNedVertices[lastIndex]);

            QLineF workerLine = originalEdge;
            workerLine.setLength(distance);
            workerLine.setAngle(workerLine.angle() - 90.0);
            offsetEdge.setP1(workerLine.p2());

            workerLine.setPoints(originalEdge.p2(), originalEdge.p1());
            workerLine.setLength(distance);
            workerLine.setAngle(workerLine.angle() + 90.0);
            offsetEdge.setP2(workerLine.p2());

            rgOffsetEdges.append(offsetEdge);
        }

        // Intersect the offset edges to generate new vertices
        QPointF         newVertex;
        QGeoCoordinate  tangentOrigin = vertexCoordinate(0);
        for (int i=0; i<rgOffsetEdges.count(); i++) {
            int prevIndex = i == 0 ? rgOffsetEdges.count() - 1 : i - 1;
            auto intersect = rgOffsetEdges[prevIndex].intersects(rgOffsetEdges[i], &newVertex);
            if (intersect == QLineF::NoIntersection) {
                // FIXME: Better error handling?
                qWarning("Intersection failed");
                return;
            }
            QGeoCoordinate coord;
            convertNedToGeo(newVertex.y(), newVertex.x(), 0, tangentOrigin, &coord);
            rgNewPolygon.append(coord);
        }
    }

    // Update internals
    _beginResetIfNotActive();
    clear();
    appendVertices(rgNewPolygon);
    _endResetIfNotActive();
}

bool QGCMapPolygon::loadKMLOrSHPFile(const QString& file)
{
    QString errorString;
    QList<QGeoCoordinate> rgCoords;
    if (!ShapeFileHelper::loadPolygonFromFile(file, rgCoords, errorString)) {
        qgcApp()->showAppMessage(errorString);
        return false;
    }

    _beginResetIfNotActive();
    clear();
    appendVertices(rgCoords);
    //Aqui é como se acessa rgCoords)
    //for(auto i: rgCoords)qWarning()<<(i.toString());
    _endResetIfNotActive();

    return true;
}
/*bool QGCMapPolygon::loadKMLwithSpacing(const QString& file, int intra_spacing) //v1
{
    //===================Parse polygons========================================
    QString errorString;
    QList<QGeoCoordinate> rgCoords; // Stores the original and final Lat/Lon coordinates

    if (!ShapeFileHelper::loadPolygonFromFile(file, rgCoords, errorString)) {
        qgcApp()->showAppMessage(errorString);
        return false;
    }

    _beginResetIfNotActive();
    clear();

    if (rgCoords.size() < 3 || intra_spacing == 0) {
        // Not a polygon or no spacing needed
        appendVertices(rgCoords);
        _endResetIfNotActive();
        return true;
    }

    //===================SETUP CONSTANTS AND REFERENCE POINT===================

    // R in METERS is crucial for scaling to be in meters.
    const double R_METERS = 6371000.0;
    const double DEG_TO_RAD = M_PI / 180.0;
    const double RAD_TO_DEG = 180.0 / M_PI;
    const int desiredPrecision = 9; // For debugging output

    // 1. CHOOSE LOCAL TANGENT PLANE (LTP) ORIGIN
    // Use the first vertex as the local origin (lat_0, lon_0)
    double lat_ref_deg = rgCoords.first().latitude();
    double lon_ref_deg = rgCoords.first().longitude();

    double lat_ref_rad = lat_ref_deg * DEG_TO_RAD;
    double lon_ref_rad = lon_ref_deg * DEG_TO_RAD;

    // Pre-calculate the scale factor for Longitude (R * cos(lat_ref))
    const double LON_SCALE_FACTOR = R_METERS * std::cos(lat_ref_rad);

    // Coordinate structure for local (meter) projection
    struct Coordinate {
        double x; // East (m)
        double y; // North (m)
    };

    //===================1. FORWARD PROJECTION (Lat/Lon -> X, Y Meters)===================

    std::vector<Coordinate> vertices; // Stores the local X, Y (meters) vertices
    for(const auto& geoCoord : rgCoords) {
        double lat_i_rad = geoCoord.latitude() * DEG_TO_RAD;
        double lon_i_rad = geoCoord.longitude() * DEG_TO_RAD;

        // X (East) = dLon * (R * cos(lat_ref))
        double dLon_rad = lon_i_rad - lon_ref_rad;
        double x = dLon_rad * LON_SCALE_FACTOR;

        // Y (North) = dLat * R
        double dLat_rad = lat_i_rad - lat_ref_rad;
        double y = dLat_rad * R_METERS;

        Coordinate curr_coord;
        curr_coord.x = x;
        curr_coord.y = y;
        vertices.push_back(curr_coord);
    }

    //===================2. CENTROID CALCULATION (on X, Y Meters)===================

    int n = vertices.size();
    double signedArea = 0.0;
    double centroidX = 0.0;
    double centroidY = 0.0;

    for (int i = 0; i < n; ++i) {
        const Coordinate& p_i = vertices[i];
        const Coordinate& p_i_plus_1 = vertices[(i + 1) % n];

        double crossProduct = (p_i.x * p_i_plus_1.y - p_i_plus_1.x * p_i.y);

        signedArea += crossProduct;
        centroidX += (p_i.x + p_i_plus_1.x) * crossProduct;
        centroidY += (p_i.y + p_i_plus_1.y) * crossProduct;
    }

    signedArea *= 0.5;

    // Handle zero area polygon (collinear points)
    if (std::abs(signedArea) < 1e-9) {
        qgcApp()->showAppMessage(QStringLiteral("KML/SHP polygon has zero area. Cannot calculate centroid or scale."));
        _endResetIfNotActive();
        return false;
    }

    // Final Centroid Calculation
    double scaleFactor = 1.0 / (6.0 * signedArea);
    Coordinate centroid;
    centroid.x = centroidX * scaleFactor;
    centroid.y = centroidY * scaleFactor;

    //===================3. SCALING THE POLYGON (towards Centroid)===================

    std::vector<Coordinate> newVertices;
    newVertices.reserve(vertices.size());
    double S = (double)intra_spacing; // Spacing to be reduced, now in meters

    for (const auto& v_i : vertices) {
        // Vector from Centroid to Vertex (V_i - C)
        double vector_x = v_i.x - centroid.x;
        double vector_y = v_i.y - centroid.y;

        // Distance (Magnitude D)
        double D = std::sqrt(vector_x * vector_x + vector_y * vector_y);

        double k; // Scaling factor

        if (D < 1e-9) {
            k = 0.0; // Point already at centroid
        } else {
            // New Distance D' = max(0, D - S)
            double D_prime = std::max(0.0, D - S);
            k = D_prime / D;
        }

        // New Position: C + (Vector * k)
        Coordinate v_prime;
        v_prime.x = centroid.x + vector_x * k;
        v_prime.y = centroid.y + vector_y * k;
        newVertices.push_back(v_prime);
    }

    //===================4. INVERSE PROJECTION (X, Y Meters -> Lat/Lon)===================

    // Reuse rgCoords to store the new Lat/Lon
    // NOTE: This loop relies on 'rgCoords' and 'newVertices' being the same size (n)
    for (int i = 0; i < n; ++i) {
        double l_x = newVertices[i].x; // X (East) in meters
        double l_y = newVertices[i].y; // Y (North) in meters

        // Inverse Y -> Latitude
        // dLat_rad = Y / R_METERS
        double dLat_rad_prime = l_y / R_METERS;
        double new_lat_deg = (lat_ref_rad + dLat_rad_prime) * RAD_TO_DEG;

        // Inverse X -> Longitude
        // dLon_rad = X / LON_SCALE_FACTOR
        double dLon_rad_prime = l_x / LON_SCALE_FACTOR;
        double new_lon_deg = (lon_ref_rad + dLon_rad_prime) * RAD_TO_DEG;

        // Set the new coordinate in the GeoCoordinate list
        rgCoords[i].setLongitude(new_lon_deg);
        rgCoords[i].setLatitude(new_lat_deg);

        // --- DEBUG PRINTING ---
        QString x_str = QString::number(l_x, 'f', desiredPrecision);
        QString y_str = QString::number(l_y, 'f', desiredPrecision);
        QString latStr = QString::number(new_lat_deg, 'f', desiredPrecision);
        QString lonStr = QString::number(new_lon_deg, 'f', desiredPrecision);

        qDebug() << "--- New Vertex Coords (i=" << i << ") ---";
        qDebug().noquote() << QString("Lat: %1, Lon: %2").arg(latStr).arg(lonStr);
        qDebug().noquote() << QString("X (East): %1, Y (North): %2").arg(x_str).arg(y_str);
        qDebug() << "---------------------------------------";
    }

    // Clean up temporary vectors (optional, but good practice)
    vertices.clear();
    newVertices.clear();

    appendVertices(rgCoords);
    _endResetIfNotActive();

    return true;
}
*/

/*bool QGCMapPolygon::loadKMLwithSpacing(const QString& file, int intra_spacing) //v2
{
    //===================Parse polygons========================================
    QString errorString;
    QList<QGeoCoordinate> rgCoords; // Stores the original and final Lat/Lon coordinates

    if (!ShapeFileHelper::loadPolygonFromFile(file, rgCoords, errorString)) {
        qgcApp()->showAppMessage(errorString);
        return false;
    }

    _beginResetIfNotActive();
    clear();

    if (rgCoords.size() < 3) {
        // Not a polygon or no spacing needed
        appendVertices(rgCoords);
        _endResetIfNotActive();
        return true;
    }

    //===================SETUP CONSTANTS AND REFERENCE POINT===================

    // R in METERS is crucial for scaling to be in meters.
    const double R_METERS = 6371000.0;
    const double DEG_TO_RAD = M_PI / 180.0;
    const double RAD_TO_DEG = 180.0 / M_PI;
    const int desiredPrecision = 9; // For debugging output

    // 1. CHOOSE LOCAL TANGENT PLANE (LTP) ORIGIN
    // Use the first vertex as the local origin (lat_0, lon_0)
    double lat_ref_deg = rgCoords.first().latitude();
    double lon_ref_deg = rgCoords.first().longitude();

    double lat_ref_rad = lat_ref_deg * DEG_TO_RAD;
    double lon_ref_rad = lon_ref_deg * DEG_TO_RAD;

    // Pre-calculate the scale factor for Longitude (R * cos(lat_ref))
    const double LON_SCALE_FACTOR = R_METERS * std::cos(lat_ref_rad);

    // Coordinate structure for local (meter) projection
    struct Coordinate {
        double x; // East (m)
        double y; // North (m)
    };

    //===================1. FORWARD PROJECTION (Lat/Lon -> X, Y Meters)===================

    std::vector<Coordinate> vertices; // Stores the local X, Y (meters) vertices
    vertices.reserve(static_cast<size_t>(rgCoords.size()));
    for(const auto& geoCoord : rgCoords) {
        double lat_i_rad = geoCoord.latitude() * DEG_TO_RAD;
        double lon_i_rad = geoCoord.longitude() * DEG_TO_RAD;

        // X (East) = dLon * (R * cos(lat_ref))
        double dLon_rad = lon_i_rad - lon_ref_rad;
        double x = dLon_rad * LON_SCALE_FACTOR;

        // Y (North) = dLat * R
        double dLat_rad = lat_i_rad - lat_ref_rad;
        double y = dLat_rad * R_METERS;

        Coordinate curr_coord;
        curr_coord.x = x;
        curr_coord.y = y;
        vertices.push_back(curr_coord);
    }

    //===================2. CENTROID CALCULATION (on X, Y Meters)===================

    int n = static_cast<int>(vertices.size());
    double signedArea = 0.0;
    double centroidX = 0.0;
    double centroidY = 0.0;

    for (int i = 0; i < n; ++i) {
        const Coordinate& p_i = vertices[i];
        const Coordinate& p_i_plus_1 = vertices[(i + 1) % n];

        double crossProduct = (p_i.x * p_i_plus_1.y - p_i_plus_1.x * p_i.y);

        signedArea += crossProduct;
        centroidX += (p_i.x + p_i_plus_1.x) * crossProduct;
        centroidY += (p_i.y + p_i_plus_1.y) * crossProduct;
    }

    signedArea *= 0.5;

    // Handle zero area polygon (collinear points)
    if (std::abs(signedArea) < 1e-9) {
        qgcApp()->showAppMessage(QStringLiteral("KML/SHP polygon has zero area. Cannot calculate centroid or scale."));
        _endResetIfNotActive();
        return false;
    }

    // Final Centroid Calculation
    double scaleFactor = 1.0 / (6.0 * signedArea);
    Coordinate centroid;
    centroid.x = centroidX * scaleFactor;
    centroid.y = centroidY * scaleFactor;

    //===================3. SCALING THE POLYGON (towards Centroid)===================

    std::vector<Coordinate> newVertices;
    newVertices.reserve(vertices.size());
    double S = static_cast<double>(intra_spacing); // Spacing to be reduced, in meters

    for (const auto& v_i : vertices) {
        // Vector from Centroid to Vertex (V_i - C)
        double vector_x = v_i.x - centroid.x;
        double vector_y = v_i.y - centroid.y;

        // Distance (Magnitude D)
        double D = std::sqrt(vector_x * vector_x + vector_y * vector_y);

        double k; // Scaling factor

        if (D < 1e-9) {
            k = 0.0; // Point already at centroid
        } else {
            // New Distance D' = max(0, D - S)
            double D_prime = std::max(0.0, D - S);
            k = D_prime / D;
        }

        // New Position: C + (Vector * k)
        Coordinate v_prime;
        v_prime.x = centroid.x + vector_x * k;
        v_prime.y = centroid.y + vector_y * k;
        newVertices.push_back(v_prime);
    }

    //===================3.5. DENSIFY EDGES (INSERT EXACTLY 5000 INTERMEDIATE POINTS)
    // and move each created point inward by intra_spacing (same shrink formula) ================

    const int numSegments = 50; // EXACT number requested
    // Pre-check: ensure we have at least 1 vertex in newVertices
    if (newVertices.empty()) {
        // Nothing to do (shouldn't happen because we already checked rgCoords.size() >= 3)
    } else {
        std::vector<Coordinate> densifiedVertices;
        // Reserve heuristic: each original vertex produces 1 + numSegments outputs.
        // This can be huge; be mindful of memory.
        size_t approxCount = static_cast<size_t>(newVertices.size()) * (static_cast<size_t>(numSegments) + 1ULL);
        const size_t maxReserve = 100000000ULL; // safety cap for reserve; adjust as needed
        if (approxCount > maxReserve) approxCount = maxReserve;
        densifiedVertices.reserve(approxCount);

        for (size_t i = 0; i < newVertices.size(); ++i) {
            const Coordinate& v1 = newVertices[i];
            const Coordinate& v2 = newVertices[(i + 1) % newVertices.size()]; // wrap-around for closing edge

            // 1) Add the starting vertex of the edge (already shrunk)
            densifiedVertices.push_back(v1);

            // 2) Compute direction vector (v1 -> v2)
            double dx = v2.x - v1.x;
            double dy = v2.y - v1.y;

            // 3) Generate exactly numSegments intermediate points between v1 and v2
            for (int j = 1; j <= numSegments; ++j) {
                double t = static_cast<double>(j) / (static_cast<double>(numSegments) + 1.0);

                // Interpolated point between v1 and v2 (in local meters)
                Coordinate interp;
                interp.x = v1.x + t * dx;
                interp.y = v1.y + t * dy;

                // Now move interp toward centroid by 'S' meters using correct vector (interp - centroid)
                double vec_x = interp.x - centroid.x; // vector FROM centroid TO interp
                double vec_y = interp.y - centroid.y;
                double distToCentroid = std::sqrt(vec_x * vec_x + vec_y * vec_y);

                if (distToCentroid > 1e-9) {
                    double Dp = std::max(0.0, distToCentroid - S); // new distance
                    double k = Dp / distToCentroid;               // scaling factor
                    interp.x = centroid.x + vec_x * k;
                    interp.y = centroid.y + vec_y * k;
                } else {
                    // interp is at centroid (degenerate) -> leave at centroid
                }

                densifiedVertices.push_back(interp);
            }

            // Do NOT push v2 here; the next iteration will push v2 as v1 (this preserves order without duplicates)
        }

        // Replace newVertices with densified version
        newVertices.swap(densifiedVertices);
    }

    //===================4. INVERSE PROJECTION (X, Y Meters -> Lat/Lon)===================

    // Make sure rgCoords has the same size as newVertices
    int newN = static_cast<int>(newVertices.size());
    //rgCoords.resize(newN); // preserve indexing
    while (rgCoords.size() < newN) {
        rgCoords.push_back(QGeoCoordinate()); // push a default QGeoCoordinate
    }

    for (int i = 0; i < newN; ++i) {
        double l_x = newVertices[i].x; // X (East) in meters
        double l_y = newVertices[i].y; // Y (North) in meters

        // Inverse Y -> Latitude
        // dLat_rad = Y / R_METERS
        double dLat_rad_prime = l_y / R_METERS;
        double new_lat_deg = (lat_ref_rad + dLat_rad_prime) * RAD_TO_DEG;

        // Inverse X -> Longitude
        // dLon_rad = X / LON_SCALE_FACTOR
        double dLon_rad_prime = l_x / LON_SCALE_FACTOR;
        double new_lon_deg = (lon_ref_rad + dLon_rad_prime) * RAD_TO_DEG;

        // Set the new coordinate in the GeoCoordinate list
        rgCoords[i].setLongitude(new_lon_deg);
        rgCoords[i].setLatitude(new_lat_deg);

        // --- DEBUG PRINTING ---
        QString x_str = QString::number(l_x, 'f', desiredPrecision);
        QString y_str = QString::number(l_y, 'f', desiredPrecision);
        QString latStr = QString::number(new_lat_deg, 'f', desiredPrecision);
        QString lonStr = QString::number(new_lon_deg, 'f', desiredPrecision);

        qDebug() << "--- New Vertex Coords (i=" << i << ") ---";
        qDebug().noquote() << QString("Lat: %1, Lon: %2").arg(latStr).arg(lonStr);
        qDebug().noquote() << QString("X (East): %1, Y (North): %2").arg(x_str).arg(y_str);
        qDebug() << "---------------------------------------";
    }

    // Clean up temporary vectors (optional, but good practice)
    vertices.clear();
    newVertices.clear();

    appendVertices(rgCoords);
    _endResetIfNotActive();

    return true;
}
*/


bool QGCMapPolygon::loadKMLwithSpacing(const QString& file, int intra_spacing) //v3
{
    //===================Parse polygons========================================
    QString errorString;
    QList<QGeoCoordinate> rgCoords; // original polygon

    if (!ShapeFileHelper::loadPolygonFromFile(file, rgCoords, errorString)) {
        qgcApp()->showAppMessage(errorString);
        return false;
    }

    _beginResetIfNotActive();
    clear();

    if (rgCoords.size() < 3) {
        appendVertices(rgCoords);
        _endResetIfNotActive();
        return true;
    }

    //===================Constants for projection=============================
    const double R_METERS = 6371000.0;
    const double DEG_TO_RAD = M_PI / 180.0;
    const double RAD_TO_DEG = 180.0 / M_PI;

    // Use first vertex as reference point for projection
    double lat_ref_deg = rgCoords.first().latitude();
    double lon_ref_deg = rgCoords.first().longitude();
    double lat_ref_rad = lat_ref_deg * DEG_TO_RAD;
    double lon_ref_rad = lon_ref_deg * DEG_TO_RAD;
    const double LON_SCALE = R_METERS * std::cos(lat_ref_rad);

    //===================Forward projection: Lat/Lon -> local meters=========
    struct Coord { double x, y; };
    std::vector<Coord> vertices;
    for (const auto& c : rgCoords) {
        double lat_rad = c.latitude() * DEG_TO_RAD;
        double lon_rad = c.longitude() * DEG_TO_RAD;
        double x = (lon_rad - lon_ref_rad) * LON_SCALE;
        double y = (lat_rad - lat_ref_rad) * R_METERS;
        vertices.push_back({x, y});
    }

    //===================Compute centroid====================================
    double signedArea = 0.0, cx = 0.0, cy = 0.0;
    int n = vertices.size();
    for (int i = 0; i < n; ++i) {
        const auto& p0 = vertices[i];
        const auto& p1 = vertices[(i+1)%n];
        double cross = p0.x*p1.y - p1.x*p0.y;
        signedArea += cross;
        cx += (p0.x + p1.x) * cross;
        cy += (p0.y + p1.y) * cross;
    }
    signedArea *= 0.5;
    if (std::abs(signedArea) < 1e-9) {
        qgcApp()->showAppMessage("Polygon has zero area.");
        _endResetIfNotActive();
        return false;
    }
    double scaleFactor = 1.0 / (6.0 * signedArea);
    Coord centroid = {cx * scaleFactor, cy * scaleFactor};

    //===================Shrink vertices toward centroid======================
    std::vector<Coord> shrunk;
    for (const auto& v : vertices) {
        double dx = v.x - centroid.x;
        double dy = v.y - centroid.y;
        double dist = std::sqrt(dx*dx + dy*dy);
        double k = dist < 1e-9 ? 0.0 : std::max(0.0, dist - intra_spacing)/dist;
        shrunk.push_back({ centroid.x + dx*k, centroid.y + dy*k });
    }

    //===================Densify edges only, exclude original vertices========
    const int numSegments = 50; // points per edge
    std::vector<Coord> densified;
    for (size_t i = 0; i < shrunk.size(); ++i) {
        const Coord& A = shrunk[i];
        const Coord& B = shrunk[(i+1)%shrunk.size()];

        // Generate exactly numSegments intermediate points
        for (int j = 1; j <= numSegments; ++j) {
            double t = static_cast<double>(j) / (numSegments + 1.0);
            double x = A.x + t*(B.x - A.x);
            double y = A.y + t*(B.y - A.y);

            // Shrink intermediate point toward centroid
            double dx = x - centroid.x;
            double dy = y - centroid.y;
            double dist = std::sqrt(dx*dx + dy*dy);
            if (dist > 1e-9) {
                double k = std::max(0.0, dist - intra_spacing)/dist;
                x = centroid.x + dx*k;
                y = centroid.y + dy*k;
            }

            densified.push_back({x, y});
        }
    }

    //===================Convert back to lat/lon=============================
    QList<QGeoCoordinate> finalCoords;
    for (const auto& v : densified) {
        double lat = (lat_ref_rad + v.y / R_METERS) * RAD_TO_DEG;
        double lon = (lon_ref_rad + v.x / LON_SCALE) * RAD_TO_DEG;
        finalCoords.push_back(QGeoCoordinate(lat, lon));
    }

    appendVertices(finalCoords);
    _endResetIfNotActive();
    return true;
}

double QGCMapPolygon::area(void) const
{
    // https://www.mathopenref.com/coordpolygonarea2.html

    if (_polygonPath.count() < 3) {
        return 0;
    }

    double coveredArea = 0.0;
    QList<QPointF> nedVertices = nedPolygon();
    for (int i=0; i<nedVertices.count(); i++) {
        if (i != 0) {
            coveredArea += nedVertices[i - 1].x() * nedVertices[i].y() - nedVertices[i].x() * nedVertices[i -1].y();
        } else {
            coveredArea += nedVertices.last().x() * nedVertices[i].y() - nedVertices[i].x() * nedVertices.last().y();
        }
    }
    return 0.5 * fabs(coveredArea);
}

void QGCMapPolygon::verifyClockwiseWinding(void)
{
    if (_polygonPath.count() <= 2) {
        return;
    }

    double sum = 0;
    for (int i=0; i<_polygonPath.count(); i++) {
        QGeoCoordinate coord1 = _polygonPath[i].value<QGeoCoordinate>();
        QGeoCoordinate coord2 = (i == _polygonPath.count() - 1) ? _polygonPath[0].value<QGeoCoordinate>() : _polygonPath[i+1].value<QGeoCoordinate>();

        sum += (coord2.longitude() - coord1.longitude()) * (coord2.latitude() + coord1.latitude());
    }

    if (sum < 0.0) {
        // Winding is counter-clockwise and needs reversal

        QList<QGeoCoordinate> rgReversed;
        for (const QVariant& varCoord: _polygonPath) {
            rgReversed.prepend(varCoord.value<QGeoCoordinate>());
        }

        _beginResetIfNotActive();
        clear();
        appendVertices(rgReversed);
        _endResetIfNotActive();
    }
}

void QGCMapPolygon::beginReset(void)
{
    _resetActive = true;
    _polygonModel.beginReset();
}

void QGCMapPolygon::endReset(void)
{
    _resetActive = false;
    _polygonModel.endReset();
    emit pathChanged();
    emit centerChanged(_center);
}

void QGCMapPolygon::_beginResetIfNotActive(void)
{
    if (!_resetActive) {
        beginReset();
    }
}

void QGCMapPolygon::_endResetIfNotActive(void)
{
    if (!_resetActive) {
        endReset();
    }
}

QDomElement QGCMapPolygon::kmlPolygonElement(KMLDomDocument& domDocument)
{
#if 0
    <Polygon id="ID">
      <!-- specific to Polygon -->
      <extrude>0</extrude>                       <!-- boolean -->
      <tessellate>0</tessellate>                 <!-- boolean -->
      <altitudeMode>clampToGround</altitudeMode>
            <!-- kml:altitudeModeEnum: clampToGround, relativeToGround, or absolute -->
            <!-- or, substitute gx:altitudeMode: clampToSeaFloor, relativeToSeaFloor -->
      <outerBoundaryIs>
        <LinearRing>
          <coordinates>...</coordinates>         <!-- lon,lat[,alt] -->
        </LinearRing>
      </outerBoundaryIs>
      <innerBoundaryIs>
        <LinearRing>
          <coordinates>...</coordinates>         <!-- lon,lat[,alt] -->
        </LinearRing>
      </innerBoundaryIs>
    </Polygon>
#endif

    QDomElement polygonElement = domDocument.createElement("Polygon");

    domDocument.addTextElement(polygonElement, "altitudeMode", "clampToGround");

    QDomElement outerBoundaryIsElement = domDocument.createElement("outerBoundaryIs");
    QDomElement linearRingElement = domDocument.createElement("LinearRing");

    outerBoundaryIsElement.appendChild(linearRingElement);
    polygonElement.appendChild(outerBoundaryIsElement);

    QString coordString;
    for (const QVariant& varCoord : _polygonPath) {
        coordString += QStringLiteral("%1\n").arg(domDocument.kmlCoordString(varCoord.value<QGeoCoordinate>()));
    }
    coordString += QStringLiteral("%1\n").arg(domDocument.kmlCoordString(_polygonPath.first().value<QGeoCoordinate>()));
    domDocument.addTextElement(linearRingElement, "coordinates", coordString);

    return polygonElement;
}

void QGCMapPolygon::setTraceMode(bool traceMode)
{
    if (traceMode != _traceMode) {
        _traceMode = traceMode;
        emit traceModeChanged(traceMode);
    }
}

void QGCMapPolygon::setShowAltColor(bool showAltColor){
    if (showAltColor != _showAltColor) {
        _showAltColor = showAltColor;
        emit showAltColorChanged(showAltColor);
    }
}

void QGCMapPolygon::selectVertex(int index)
{
    if(index == _selectedVertexIndex) return;   // do nothing

    if(-1 <= index && index < count()) {
        _selectedVertexIndex = index;
    } else {
        if (!qgcApp()->runningUnitTests()) {
            qCWarning(ParameterManagerLog)
            << QString("QGCMapPolygon: Selected vertex index (%1) is out of bounds! "
                       "Polygon vertices indexes range is [%2..%3].").arg(index).arg(0).arg(count()-1);
        }
        _selectedVertexIndex = -1;   // deselect vertex
    }

    emit selectedVertexChanged(_selectedVertexIndex);
}
