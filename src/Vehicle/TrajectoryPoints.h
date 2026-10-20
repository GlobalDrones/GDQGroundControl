/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include "QmlObjectListModel.h"

#include <QGeoCoordinate>

class Vehicle;

class TrajectoryPoints : public QObject
{
    Q_OBJECT

public:
    TrajectoryPoints(Vehicle* vehicle, QObject* parent = nullptr);

    Q_INVOKABLE QVariantList list(void) const { return _points; }

    void start  (void);
    void stop   (void);

public slots:
    void clear  (void);

signals:
    void pointAdded     (QGeoCoordinate coordinate);
    void updateLastPoint(QGeoCoordinate coordinate);
    void pointRemoved   (QGeoCoordinate coordinate);    ///< Global Drones: ponto mais antigo saiu da trilha
    void pointsCleared  (void);

private slots:
    void _vehicleCoordinateChanged(QGeoCoordinate coordinate);

private:
    void _trimTrail(void);

    Vehicle*        _vehicle;
    QVariantList    _points;
    QGeoCoordinate  _lastPoint;
    double          _lastAzimuth;

    static constexpr double _distanceTolerance = 2.0;
    static constexpr double _azimuthTolerance = 1.5;

    // Global Drones: a trilha no mapa guarda só os pontos mais recentes, senão
    // cresce durante o voo inteiro e polui a tela do piloto (e59a89e, GD60)
    static constexpr int _maxTrailPoints = 500;
};
