import QtQuick          2.12
import QtGraphicalEffects 1.0

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

// GD60: painel lateral do Fly View (à direita da área principal).
//   - RPM dos 4 rotores (ESC_TELEMETRY, escStatus.rpmFirst..Fourth), com o
//     contorno do GD60 entre os mostradores;
//   - os 2 motores horizontais: RPM (gd60_RPM_M1/M2) e temperatura dos
//     cilindros das ECUs (gd60_ECUn_CTP1/2);
//   - matriz 2x2 com a temperatura dos 4 ESCs.
// A troca de câmera e o botão de Override ficam por cima, no FlyView.
Item {
    id: _root

    property var    activeVehicle
    property bool   androidBuild:   false
    property real   toolsMargin:    ScreenTools.defaultFontPixelWidth * 0.75
    /// Lado do contorno do GD60 entre os rotores (o FlyView passa 2/3 do
    /// mostrador de rumo do HUD)
    property real   iconSize:       0

    property var    _escStatus: activeVehicle ? activeVehicle.escStatus : null
    property real   _rpmRotor1: _escStatus ? _escStatus.rpmFirst.value  : 0
    property real   _rpmRotor2: _escStatus ? _escStatus.rpmSecond.value : 0
    property real   _rpmRotor3: _escStatus ? _escStatus.rpmThird.value  : 0
    property real   _rpmRotor4: _escStatus ? _escStatus.rpmFourth.value : 0

    function _escTemperatureText(fact, label) {
        return fact.value.toString() + "° \n " + label
    }

    function _ecuTemperatureText(fact) {
        return fact.rawValue.toFixed(0).toString() + "°C"
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    Rectangle {
        anchors.fill:   parent
        color:          qgcPal.toolbarBackground
    }

    //-- Rotores: valor ao lado de cada mostrador

    Text {
        id:                     textRpm1
        width:                  1
        height:                 1
        anchors.left:           parent.left
        anchors.top:            parent.top
        anchors.topMargin:      androidBuild ? toolsMargin : 0
        anchors.leftMargin:     androidBuild ? toolsMargin : toolsMargin * 5
        text:                   _rpmRotor1
        color:                  "green"
        font.bold:              true
    }

    RpmDial {
        id:                     dialRpm1
        anchors.left:           textRpm1.right
        anchors.top:            textRpm1.bottom
        anchors.topMargin:      androidBuild ? toolsMargin : toolsMargin * 2
        anchors.leftMargin:     androidBuild ? toolsMargin * 4 : toolsMargin * 2
        height:                 parent.height / 6
        width:                  height
        value:                  _rpmRotor1
        startAngle:             Math.PI
        endAngle:               Math.PI * 1.5
    }

    Text {
        id:                     textRpm2
        width:                  1
        height:                 1
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.topMargin:      androidBuild ? toolsMargin : 0
        anchors.rightMargin:    toolsMargin * 8
        text:                   _rpmRotor2
        color:                  "green"
        font.bold:              true
    }

    RpmDial {
        id:                     dialRpm2
        anchors.right:          textRpm2.left
        anchors.top:            textRpm2.bottom
        anchors.topMargin:      androidBuild ? toolsMargin : toolsMargin * 2
        anchors.rightMargin:    androidBuild ? -toolsMargin * 2 : toolsMargin * 2
        height:                 parent.height / 6
        width:                  height
        value:                  _rpmRotor2
        startAngle:             Math.PI * 2
        endAngle:               Math.PI * 1.5
        anticlockwise:          true
    }

    Text {
        id:                     textRpm3
        width:                  1
        height:                 1
        anchors.left:           parent.left
        anchors.bottom:         dialRpm3.bottom
        anchors.leftMargin:     androidBuild ? toolsMargin : toolsMargin * 5
        text:                   _rpmRotor3
        color:                  "green"
        font.bold:              true
    }

    RpmDial {
        id:                     dialRpm3
        anchors.left:           dialRpm1.left
        anchors.top:            dialRpm1.bottom
        anchors.topMargin:      androidBuild ? -toolsMargin * 14 : -toolsMargin * 25
        height:                 parent.height / 6
        width:                  height
        value:                  _rpmRotor3
        startAngle:             Math.PI
        endAngle:               Math.PI * 0.5
        anticlockwise:          true
    }

    Text {
        id:                     textRpm4
        width:                  1
        height:                 1
        anchors.right:          parent.right
        anchors.bottom:         dialRpm4.bottom
        anchors.rightMargin:    toolsMargin * 8
        text:                   _rpmRotor4
        color:                  "green"
        font.bold:              true
    }

    RpmDial {
        id:                     dialRpm4
        anchors.left:           dialRpm2.left
        anchors.top:            dialRpm2.bottom
        anchors.topMargin:      androidBuild ? -toolsMargin * 14 : -toolsMargin * 25
        height:                 parent.height / 6
        width:                  height
        value:                  _rpmRotor4
        startAngle:             0
        endAngle:               Math.PI * 0.5
    }

    // Contorno do GD60 entre os 4 mostradores
    QGCColoredImage {
        width:                          iconSize
        height:                         iconSize
        anchors.horizontalCenter:       parent.horizontalCenter
        anchors.horizontalCenterOffset: -parent.width * 0.022
        anchors.verticalCenter:         dialRpm1.verticalCenter
        anchors.verticalCenterOffset:   parent.height * 0.01
        source:                         "/qmlimages/GD60_lowres.png"
        color:                          "white"
        rotation:                       180
        opacity:                        0.2
        layer.enabled:                  true
        layer.smooth:                   true
        layer.effect: DropShadow {
            color:              "black"
            horizontalOffset:   0
            verticalOffset:     0
            radius:             1
            smooth:             true
            samples:            32
            spread:             0.5
        }
    }

    //-- Motores horizontais: RPM no mostrador, temperatura dos cilindros embaixo

    RpmDial {
        id:                 dialMotor1
        anchors.left:       parent.left
        anchors.top:        textRpm3.bottom
        anchors.topMargin:  toolsMargin * 2
        height:             parent.width
        width:              height
        value:              activeVehicle ? activeVehicle.gd60_RPM_M1.rawValue : 0
        minValue:           1900
        maxValue:           6500
        startAngle:         Math.PI
        endAngle:           Math.PI * 2
    }

    Row {
        id:                         textMotor1
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.top:                dialMotor1.bottom
        anchors.topMargin:          -parent.width * 0.45
        spacing:                    0

        Text {
            width:                  40
            horizontalAlignment:    Text.AlignRight
            font.pixelSize:         androidBuild ? 20 : 18
            font.bold:              true
            color:                  "white"
            text:                   activeVehicle ? _ecuTemperatureText(activeVehicle.gd60_ECU1_CTP1) : ""
        }

        Text {
            width:                  60
            horizontalAlignment:    Text.AlignHCenter
            font.pixelSize:         androidBuild ? 20 : 18
            font.bold:              true
            color:                  "green"
            text:                   activeVehicle ? activeVehicle.gd60_RPM_M1.rawValue : ""
        }

        Text {
            width:                  40
            horizontalAlignment:    Text.AlignLeft
            font.pixelSize:         androidBuild ? 20 : 18
            font.bold:              true
            color:                  "white"
            text:                   activeVehicle ? _ecuTemperatureText(activeVehicle.gd60_ECU1_CTP2) : ""
        }
    }

    RpmDial {
        id:                 dialMotor2
        anchors.left:       parent.left
        anchors.top:        textMotor1.bottom
        anchors.topMargin:  toolsMargin * 2
        height:             parent.width
        width:              height
        value:              activeVehicle ? activeVehicle.gd60_RPM_M2.rawValue : 0
        minValue:           1900
        maxValue:           6500
        startAngle:         Math.PI
        endAngle:           Math.PI * 2
    }

    Row {
        id:                         textMotor2
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.top:                dialMotor2.bottom
        anchors.topMargin:          -parent.width * 0.45
        spacing:                    0

        Text {
            width:                  40
            horizontalAlignment:    Text.AlignRight
            font.pixelSize:         androidBuild ? 20 : 18
            font.bold:              true
            color:                  "white"
            text:                   activeVehicle ? _ecuTemperatureText(activeVehicle.gd60_ECU2_CTP1) : ""
        }

        Text {
            width:                  60
            horizontalAlignment:    Text.AlignHCenter
            font.pixelSize:         androidBuild ? 20 : 18
            font.bold:              true
            color:                  "green"
            text:                   activeVehicle ? activeVehicle.gd60_RPM_M2.rawValue : ""
        }

        Text {
            width:                  40
            horizontalAlignment:    Text.AlignLeft
            font.pixelSize:         androidBuild ? 20 : 18
            font.bold:              true
            color:                  "white"
            text:                   activeVehicle ? _ecuTemperatureText(activeVehicle.gd60_ECU2_CTP2) : ""
        }
    }

    //-- Temperatura dos ESCs

    Grid {
        id:                         escMatrix
        anchors.top:                textMotor2.bottom
        anchors.topMargin:          toolsMargin
        anchors.horizontalCenter:   parent.horizontalCenter
        width:                      parent.width - toolsMargin * (androidBuild ? 4 : 8)
        height:                     width / 2
        columns:                    2

        Repeater {
            model: [
                { fact: "temperatureFirst",  label: "ESC 1" },
                { fact: "temperatureSecond", label: "ESC 2" },
                { fact: "temperatureThird",  label: "ESC 3" },
                { fact: "temperatureFourth", label: "ESC 4" }
            ]

            Rectangle {
                implicitWidth:  (escMatrix.width - escMatrix.spacing) / 2
                implicitHeight: (escMatrix.height - escMatrix.spacing) / 2
                color:          "transparent"
                border.color:   "white"
                border.width:   2

                Text {
                    anchors.centerIn:       parent
                    text:                   _escStatus ? _escTemperatureText(_escStatus[modelData.fact], modelData.label) : ""
                    color:                  "white"
                    font.bold:              true
                    font.pixelSize:         androidBuild ? 14 : 18
                    horizontalAlignment:    Text.AlignHCenter
                }
            }
        }
    }
}
