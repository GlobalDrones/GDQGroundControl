/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                              2.11

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0
import QGroundControl.Vehicle               1.0

// GD150: o toque no nome do link principal passa direto para o próximo link
// do veículo (57ca673), em vez de abrir o menu de escolha da base.
Item {
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          primaryLinkSelector.width

    property bool showIndicator: _rgLinkNames.length > 1

    property var _activeVehicle:    QGroundControl.multiVehicleManager.activeVehicle
    property var _rgLinkNames:      _activeVehicle ? _activeVehicle.vehicleLinkManager.linkNames : [ ]

    QGCLabel {
        id:                     primaryLinkSelector
        anchors.verticalCenter: parent.verticalCenter
        text:                   _activeVehicle ? _activeVehicle.vehicleLinkManager.primaryLinkName : ""
        font.pointSize:         ScreenTools.mediumFontPointSize
        color:                  qgcPal.buttonText

        MouseArea {
            anchors.fill: parent

            onClicked: {
                if (!_activeVehicle || _rgLinkNames.length < 2)
                    return

                var current = _activeVehicle.vehicleLinkManager.primaryLinkName
                var nextIndex = 0

                // Encontra o link atual
                for (var i = 0; i < _rgLinkNames.length; i++) {
                    if (_rgLinkNames[i] === current) {
                        nextIndex = (i + 1) % _rgLinkNames.length
                        break
                    }
                }

                _activeVehicle.vehicleLinkManager.primaryLinkName = _rgLinkNames[nextIndex]
            }
        }
    }
}
