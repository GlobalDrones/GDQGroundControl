import QtQuick              2.12
import QtQuick.Layouts      1.12
import QtGraphicalEffects   1.0

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

// GD30: painel inferior do Fly View. Da esquerda para a direita: bateria,
// gasolina, gerador, GPS, enlace RC, motor DLE (T1/T2/RPM) e RPM dos rotores.
//
// Calcula a própria telemetria a partir de activeVehicle (o FlyView passa o
// veículo ativo). Instâncias BATTERY_STATUS do GD30, na ordem do app anterior:
//   0 gerador, 1 gasolina, 2 bateria
// Lê por escopo dinâmico só toolbar._mainStatusBGColor (MainRootWindow).
Item {
    id: _root

    property real toolsMargin:      ScreenTools.defaultFontPixelWidth * 0.75
    property var  activeVehicle:    QGroundControl.multiVehicleManager.activeVehicle

    property var _generator:    _batteryAt(0)
    property var _gasoline:     _batteryAt(1)
    property var _battery:      _batteryAt(2)

    // Bateria: % linear entre 42 V e 50,2 V; textos com 2 casas decimais
    property string _batteryPct:        _battery ? ((_battery.voltage.rawValue.toFixed(2) - 42) / 8.2 * 100).toFixed(2) : "0"
    property string _batteryVoltage:    _battery ? _battery.voltage.rawValue.toFixed(2) : "0"
    property string _batteryCurrent:    _battery ? _battery.current.rawValue.toFixed(2) : "0"
    // Gasolina em litros: o firmware manda os litros no campo voltage (2ac60ba)
    property real   _gasolineL:         _gasoline ? _gasoline.voltage.value : 0
    property string _generatorCurrent:  _generator ? _generator.current.rawValue.toFixed(2) : "0"
    // GPS: satélites e tipo de fix (gps.lock), exibido como "PDOP"
    property int    _satCount:          activeVehicle ? activeVehicle.gps.count.rawValue : 0
    property int    _satPDOP:           activeVehicle ? activeVehicle.gps.lock.rawValue : 0

    // RPM que enche a barra de um rotor
    readonly property real _maxRotorRpm: 3500

    function _batteryAt(index) {
        return activeVehicle && activeVehicle.batteries.count > index ? activeVehicle.batteries.get(index) : null
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            GradientStop { position: 0.7; color: qgcPal.toolbarBackground }
            GradientStop { position: 1.0; color: toolbar._mainStatusBGColor }
        }
    }

    //-- Bateria
    QGCColoredImage {
        id:                 batteryIcon
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.margins:    toolsMargin
        width:              height
        height:             parent.height * 2 / 3
        source:             "/qmlimages/Battery.svg"
        fillMode:           Image.PreserveAspectFit
        color:              "white"
    }

    // Nível desenhado dentro do ícone (máscara invertida)
    Rectangle {
        id:             batteryLevel
        anchors.top:    batteryIcon.top
        anchors.left:   batteryIcon.left
        width:          batteryIcon.width
        height:         batteryIcon.height
        color:          "transparent"
        visible:        false

        Rectangle {
            y:                          parent.height * 0.1
            anchors.horizontalCenter:   parent.horizontalCenter
            width:                      parent.width / 2
            height:                     parent.height * 0.85
            color:                      _batteryPct > 50 ? "green" : (_batteryPct > 30 ? "orange" : "red")
        }

        // Parte vazia: altura proporcional a 1 - % da bateria
        Rectangle {
            anchors.horizontalCenter:   parent.horizontalCenter
            width:                      parent.width / 2
            height:                     parent.height * (0.15 + 0.85 * (1 - _batteryPct / 100))
            color:                      qgcPal.toolbarBackground
        }
    }

    OpacityMask {
        anchors.fill:   batteryLevel
        source:         batteryLevel
        maskSource:     batteryIcon
        invert:         true
    }

    Rectangle {
        id:                     batteryInfo
        anchors.verticalCenter: batteryIcon.verticalCenter
        anchors.left:           batteryIcon.right
        anchors.rightMargin:    toolsMargin
        height:                 batteryIcon.height * 0.7
        width:                  batteryIcon.width * 0.7
        color:                  "transparent"
        border.width:           0
        border.color:           "transparent"

        ColumnLayout {
            anchors.fill:   parent
            spacing:        0

            Text {
                Layout.alignment:   Text.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
                color:              "White"
                text:               _batteryPct > 9 ? _batteryPct + "%" : "0" + _batteryPct + "%"
                font.pointSize:     14
                font.bold:          true
            }
            Text {
                Layout.alignment:   Text.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
                color:              "White"
                text:               _batteryVoltage + " V"
                font.pointSize:     14
                font.bold:          true
            }
            Text {
                Layout.alignment:   Text.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
                color:              "White"
                text:               _batteryCurrent + " A"
                font.pointSize:     14
                font.bold:          true
            }
        }
    }

    //-- Gasolina (litros)
    QGCColoredImage {
        id:                 gasolineIcon
        anchors.top:        parent.top
        anchors.left:       batteryInfo.right
        anchors.leftMargin: toolsMargin * 4
        anchors.topMargin:  toolsMargin
        width:              height
        height:             parent.height * 2 / 3
        source:             "/qmlimages/GasCan.svg"
        fillMode:           Image.PreserveAspectFit
        color:              "white"
    }

    DropShadow {
        anchors.fill:       gasolineIcon
        source:             gasolineIcon
        color:              "#80000000"
        radius:             8
        samples:            17
        spread:             0
        verticalOffset:     5
        horizontalOffset:   5
    }

    Rectangle {
        id:                         gasolineInfo
        anchors.verticalCenter:     gasolineIcon.verticalCenter
        anchors.horizontalCenter:   gasolineIcon.horizontalCenter
        height:                     gasolineIcon.height / 3
        width:                      gasolineIcon.width
        color:                      "black"
        border.width:               1
        border.color:               "lightgray"
    }

    Text {
        anchors.fill:           gasolineInfo
        horizontalAlignment:    Text.AlignHCenter
        verticalAlignment:      Text.AlignVCenter
        text:                   _gasolineL.toString() + "L"
        font.bold:              true
        color:                  "white"
    }

    //-- Gerador (corrente)
    QGCColoredImage {
        id:                 generatorIcon
        anchors.top:        parent.top
        anchors.left:       gasolineIcon.right
        anchors.leftMargin: toolsMargin * 2
        anchors.topMargin:  toolsMargin * 2
        width:              height
        height:             parent.height * 2 / 3
        source:             "/qmlimages/Generator.svg"
        fillMode:           Image.PreserveAspectFit
        color:              "white"
    }

    DropShadow {
        anchors.fill:       generatorIcon
        source:             generatorIcon
        color:              "#80000000"
        radius:             8
        samples:            17
        spread:             0
        verticalOffset:     5
        horizontalOffset:   5
    }

    OpacityMask {
        anchors.fill:   generatorIcon
        source:         generatorIcon
        maskSource:     generatorIcon
    }

    Rectangle {
        id:                         generatorInfo
        anchors.verticalCenter:     generatorIcon.verticalCenter
        anchors.horizontalCenter:   generatorIcon.horizontalCenter
        height:                     generatorIcon.height / 2
        width:                      generatorIcon.width
        color:                      "black"
        border.width:               1
        border.color:               "lightgray"
    }

    ColumnLayout {
        anchors.fill:   generatorInfo
        spacing:        0

        Text {
            Layout.alignment:   Text.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            color:              "White"
            text:               _generatorCurrent + "A"
            font.pointSize:     12
            font.bold:          true
        }
    }

    //-- GPS
    QGCColoredImage {
        id:                 gpsIcon
        anchors.top:        parent.top
        anchors.left:       generatorIcon.right
        anchors.leftMargin: toolsMargin
        anchors.topMargin:  toolsMargin * 2
        width:              height
        height:             parent.height * 2 / 3
        source:             "/qmlimages/Gps.svg"
        fillMode:           Image.PreserveAspectFit
        color:              _satPDOP >= 2 && _satCount >= 6 ? "green" : "orange"
    }

    DropShadow {
        anchors.fill:       gpsIcon
        source:             gpsIcon
        color:              "#80000000"
        radius:             8
        samples:            17
        spread:             0
        verticalOffset:     5
        horizontalOffset:   5
    }

    OpacityMask {
        anchors.fill:   gpsIcon
        source:         gpsIcon
        maskSource:     gpsIcon
    }

    Rectangle {
        id:                     gpsInfo
        anchors.verticalCenter: gpsIcon.verticalCenter
        anchors.left:           gpsIcon.right
        anchors.leftMargin:     toolsMargin
        anchors.rightMargin:    toolsMargin
        height:                 gpsIcon.height * 0.7
        width:                  gpsIcon.width
        color:                  "transparent"
        border.width:           0
        border.color:           "transparent"
    }

    ColumnLayout {
        anchors.fill:   gpsInfo
        spacing:        0

        Text {
            Layout.alignment:   Text.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            color:              "White"
            text:               "Count: " + _satCount
            font.bold:          true
            font.pointSize:     15
        }
        Text {
            Layout.alignment:   Text.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            color:              "White"
            text:               "PDOP: " + _satPDOP
            font.bold:          true
            font.pointSize:     15
        }
    }

    //-- Enlace RC
    QGCColoredImage {
        id:                 rcIcon
        anchors.top:        parent.top
        anchors.left:       gpsInfo.right
        anchors.leftMargin: toolsMargin * 3
        anchors.topMargin:  toolsMargin * 2
        width:              height
        height:             parent.height * 2 / 3
        source:             "/qmlimages/RC.svg"
        fillMode:           Image.PreserveAspectFit
        color: {
            if (!activeVehicle) {
                return "white"
            }
            var rssi = activeVehicle.rcRSSI
            return rssi >= 60 ? "green" : (rssi >= 30 ? "yellow" : (rssi >= 20 ? "orange" : "red"))
        }

        MouseArea {
            id:             rcMouseArea
            anchors.fill:   parent
            hoverEnabled:   true
        }
    }

    // RSSI do RC com o ícone sob o cursor; no tablet aparece com o toque e fica
    // até tocar em outro lugar (comportamento atual do GD30)
    Rectangle {
        id:                         rcInfo
        anchors.verticalCenter:     rcIcon.verticalCenter
        anchors.horizontalCenter:   rcIcon.horizontalCenter
        height:                     gpsIcon.height * 0.7
        width:                      gpsIcon.width * 0.8
        visible:                    rcMouseArea.containsMouse
        color:                      "black"
        border.width:               1
        border.color:               "lightgray"
    }

    ColumnLayout {
        anchors.fill:   rcInfo
        spacing:        0
        visible:        rcInfo.visible

        Text {
            Layout.alignment:   Text.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            color:              "White"
            text:               activeVehicle ? activeVehicle.rcRSSI.toString() + "%" : ""
            font.bold:          true
        }
    }

    //-- Motor DLE: temperatura dos cilindros (T1/T2) e RPM
    QGCColoredImage {
        id:                 motorTempIcon
        anchors.top:        parent.top
        anchors.left:       rcIcon.right
        anchors.leftMargin: toolsMargin * 2
        anchors.topMargin:  toolsMargin * 2
        width:              height
        height:             parent.height * 2 / 3
        source:             "/qmlimages/MotorTemp.svg"
        fillMode:           Image.PreserveAspectFit
        color:              "white"
    }

    QGCColoredImage {
        anchors.fill:   motorTempIcon
        source:         "/qmlimages/MotorTermometer.png"
        fillMode:       Image.PreserveAspectFit
        color:          "white"
    }

    Rectangle {
        id:                     motorInfo
        anchors.verticalCenter: motorTempIcon.verticalCenter
        anchors.left:           motorTempIcon.right
        anchors.leftMargin:     10
        height:                 motorTempIcon.height * 1.2
        width:                  motorTempIcon.width * 1.5
        color:                  "black"
        border.width:           1
        border.color:           "lightgray"

        Column {
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin:     toolsMargin
            spacing:                6

            Text {
                color:          "white"
                font.bold:      true
                font.pixelSize: 22
                text:           activeVehicle ? "T1: " + activeVehicle.gd60_Sensor2.rawValue.toString() + "°C" : ""
            }
            Text {
                color:          "white"
                font.bold:      true
                font.pixelSize: 22
                text:           activeVehicle ? "T2: " + activeVehicle.gd60_Sensor3.rawValue.toString() + "°C" : ""
            }
            Text {
                color:          "white"
                font.bold:      true
                font.pixelSize: 22
                text:           activeVehicle ? "RPM: " + Math.max(0, activeVehicle.gd60_Sensor1.rawValue).toString() : ""
            }
        }
    }

    //-- RPM dos 6 rotores (ESC_TELEMETRY), barras de 0 a _maxRotorRpm
    QGCColoredImage {
        id:                 rotorsIcon
        anchors.top:        parent.top
        anchors.left:       motorInfo.right
        anchors.leftMargin: toolsMargin
        anchors.topMargin:  toolsMargin * 2
        width:              height
        height:             parent.height * 2 / 3
        source:             "/qmlimages/rotorsAccell.png"
        fillMode:           Image.PreserveAspectFit
        color:              "white"
    }

    Rectangle {
        id:                 rotorsArea
        anchors.top:        parent.top
        anchors.left:       rotorsIcon.right
        anchors.margins:    toolsMargin * 1.4
        width:              height * 2
        height:             rotorsIcon.height
        color:              "black"

        // Borda
        Rectangle {
            anchors.fill:   parent
            color:          "transparent"
            border.width:   2
            z:              parent.z + 13
            border.color:   "lightgray"
        }

        // Sombra
        Rectangle {
            anchors.fill:   parent
            z:              -1
            color:          "black"
            opacity:        0.3
            scale:          1.05
        }

        Repeater {
            model: 6

            Rectangle {
                property var _rpmFact: activeVehicle ? activeVehicle["_GD_RPM" + (index + 1)] : null

                width:          parent.width / 6
                height:         (_rpmFact ? _rpmFact.rawValue.toFixed(0) / _maxRotorRpm : 0) * parent.height
                x:              index * parent.width / 6
                anchors.bottom: parent.bottom
                z:              parent.z + 10
                color:          "green"
                border.color:   rotorMouseArea.containsMouse ? "yellow" : "black"
                border.width:   3

                MouseArea {
                    id:             rotorMouseArea
                    anchors.fill:   parent
                    hoverEnabled:   true
                }
            }
        }
    }
}
