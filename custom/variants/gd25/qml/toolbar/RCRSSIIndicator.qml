/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

// Global Drones GD25: substitui src/ui/toolbar/RCRSSIIndicator.qml (ver custom/README.md)
// Diferença: no lugar das barras de sinal, a barra mostra o RSSI do RC em %
// e a qualidade da rede (NET_SCORE, gd60_Sensor3) e do rádio (RC_SCORE,
// gd60_Sensor2) enviadas pelo firmware do GD25 (ver telemetry.cc).

import QtQuick          2.11
import QtQuick.Layouts  1.11

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- RC RSSI Indicator
Item {
    id:             _root
    width:          rssiRow.width * 1.1
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property bool showIndicator: _activeVehicle.supportsRadio

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _rcRSSIAvailable:   _activeVehicle ? _activeVehicle.rcRSSI > 0 && _activeVehicle.rcRSSI <= 100 : false

    Component {
        id: rcRSSIInfo

        Rectangle {
            width:  rcrssiCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: rcrssiCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text

            Column {
                id:                 rcrssiCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(rcrssiGrid.width, rssiLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                QGCLabel {
                    id:             rssiLabel
                    text:           _activeVehicle ? (_activeVehicle.rcRSSI !== 255 ? qsTr("RC RSSI Status") : qsTr("RC RSSI Data Unavailable")) : qsTr("N/A", "No data available")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                GridLayout {
                    id:                 rcrssiGrid
                    visible:            _rcRSSIAvailable
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter

                    QGCLabel { text: qsTr("RSSI:") }
                    QGCLabel { text: _activeVehicle ? (_activeVehicle.rcRSSI + "%") : 0 }
                }
            }
        }
    }

    Row {
        id:             rssiRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth

        QGCColoredImage {
            width:              height
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            sourceSize.height:  height
            source:             "/qmlimages/RC.svg"
            fillMode:           Image.PreserveAspectFit
            opacity:            _rcRSSIAvailable ? 1 : 0.5
            color:              qgcPal.buttonText
        }

        QGCLabel {
            font.bold:              true
            anchors.verticalCenter: parent.verticalCenter
            text:                   _activeVehicle ? (_activeVehicle.rcRSSI + "%") : 0
        }

        // GD: qualidade da rede (NET_SCORE)
        QGCColoredImage {
            width:              height
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            sourceSize.height:  height
            source:             "/qmlimages/wifi.svg"
            fillMode:           Image.PreserveAspectFit
            opacity:            _rcRSSIAvailable ? 1 : 0.5
            color:              qgcPal.buttonText
        }

        QGCLabel {
            font.bold:              true
            anchors.verticalCenter: parent.verticalCenter
            text:                   _activeVehicle ? (_activeVehicle.gd60_Sensor3.rawValue.toFixed(0) + "%") : "NaN"
        }

        // GD: qualidade do rádio (RC_SCORE)
        QGCColoredImage {
            width:              height
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            sourceSize.height:  height
            source:             "/qmlimages/SensorsComponentIcon.png"
            fillMode:           Image.PreserveAspectFit
            opacity:            _rcRSSIAvailable ? 1 : 0.5
            color:              qgcPal.buttonText
        }

        QGCLabel {
            font.bold:              true
            anchors.verticalCenter: parent.verticalCenter
            text:                   _activeVehicle ? (_activeVehicle.gd60_Sensor2.rawValue.toFixed(0) + "%") : "NaN"
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showIndicatorPopup(_root, rcRSSIInfo)
        }
    }
}
