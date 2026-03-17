import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.12

import QtLocation 5.3
import QtPositioning 5.3
import QtQuick.Window 2.2
import QtQml.Models 2.1

import QGroundControl 1.0
import QGroundControl.Airspace 1.0
import QGroundControl.Airmap 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.Controls 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.FactSystem 1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Vehicle 1.0

import QtGraphicalEffects 1.0

import SiYi.Object 1.0
import "qrc:/qml/QGroundControl/Controls"
import "qrc:/qml/QGroundControl/FlightDisplay"

Item {
    id: lateralDataArea

    // ================================
    // INPUTS
    // ================================
    property real toolsMargin
    property bool _androidBuild
    property var  _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    property real sectionHeight: height / 7

    function safeValue(fact, unit) {
        if (!_activeVehicle || !fact || fact.value === undefined || isNaN(fact.value))
            return "--"
        return fact.value.toFixed(2) + unit
    }

    function safeNumber(fact) {
        if (!_activeVehicle || !fact || fact.value === undefined || isNaN(fact.value))
            return NaN
        return fact.value
    }

    Rectangle {
        anchors.fill: parent
        color:qgcPal.toolbarBackground
    }
    Item{
        id: flightTimeArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: sectionHeight

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing:                0
            height: sectionHeight


            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "White"
                text:                   "Est. Time"
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "White"
                text:                   horas_restantes_string+":"+minutos_restantes_string+":"+segundos_restantes_string
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
        }
    }
    Item{
        id: dist2HomeArea
        anchors.top: flightTimeArea.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: sectionHeight

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing:                0
            height: sectionHeight


            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "White"
                text:                   "Dist. Home"
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "White"
                text:                   safeValue(_activeVehicle.distanceToHome, " m")
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
        }
    }

    Item{
        id: dist2WaypointArea
        anchors.top: dist2HomeArea.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: sectionHeight

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing:                0
            height: sectionHeight


            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "White"
                text:                   "Dist. WP"
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "White"
                text: safeValue(_activeVehicle.distanceToNextWP, " m")                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
        }
    }
    Item{
        id: altitudeRelativeArea
        anchors.top: dist2WaypointArea.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: sectionHeight

        ColumnLayout {

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing:                0
            height: sectionHeight


            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  _activeVehicle.rangeFinderDist.value.toFixed(2) >120 ? "red": "white"
                text:                   "Alt. LIDAR"
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  _activeVehicle.rangeFinderDist.value.toFixed(2) >120 ? "red": "white"
                text: safeValue(_activeVehicle.rangeFinderDist, " m")
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
        }
    }
    Item{
        id: altitudeBarometricArea
        anchors.top: altitudeRelativeArea.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: sectionHeight

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing:                0
            height: sectionHeight


            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "white"
                text:                   "Alt. AMSL"
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "white"
                //text:                   Math.round(_activeVehicle.altitudeAMSL.value*10)/10 + "m"
                text: safeValue(_activeVehicle.altitudeAMSL, " m")
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
        }
    }
    Item{
        id: horSpeedArea
        anchors.top: altitudeBarometricArea.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: sectionHeight

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing:                0
            height: sectionHeight


            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "White"
                text:                   "Hor. speed"
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  Math.round(_activeVehicle.airSpeed.value*10)/10 < 17? "White" : "Red"
                text:                   Math.round(_activeVehicle.airSpeed.value*10)/10 +"m/s"
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
        }
    }
    Item{
        id: vertSpeedArea
        anchors.top: horSpeedArea.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: sectionHeight

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing:                0
            height: sectionHeight


            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "White"
                text:                   "Vert. speed"
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
            Text {

                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "White"
                text:                   Math.round(_activeVehicle.climbRate.value*10)/10+"m/s"
                //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                font.bold: true
            }
        }
    }

    Text {
        id: minSpeedText
        text: "Min Speed: 0km/h"
        anchors.left: parent.left
        anchors.bottom: maxSpeedText.top
        anchors.margins: _toolsMargin // Adiciona um pequeno espaço do canto
        font.bold: true
        font.pixelSize:         _androidBuild ?  7 : 12
        color: qgcPal.toolbarBackground
        z:1000
    }
    Text {
        id: maxSpeedText
        text: "Max Speed: 61,2km/h"
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: _toolsMargin // Adiciona um pequeno espaço do canto
        font.bold: true
        font.pixelSize:         _androidBuild ?  7 : 12
        color: qgcPal.toolbarBackground
        z:1000
        Component.onCompleted: aircraftAndRotorsLoader.active = true
    }



}

