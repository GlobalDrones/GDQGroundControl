import QtQuick              2.12
import QtQuick.Layouts      1.12
import QtGraphicalEffects   1.0

import QGroundControl           1.0
import QGroundControl.Controls  1.0

// GD150: painel inferior do Fly View (bateria, consumo, vazão, GPS, RC e RPM
// dos rotores). Instanciado pelo FlyView comum. qgcPal e
// toolbar._mainStatusBGColor vêm do MainRootWindow.
Item {
    id: bottomDataArea

    // Interface do FlyView comum
    property real toolsMargin
    // Recebido do FlyView, mas sem uso: a caixa de RC aparece com o ponteiro
    // sobre o ícone (containsMouse), como no app anterior, onde este valor
    // chegava sempre false. Abrir por toque no tablet é decisão de produto.
    property bool _androidBuild

    property var  _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    // Bateria
    property real _pct_bateria_1: 0
    property real _tensao_bateria_1: 0
    property real _current_bateria_1: 0
    property int  _bat1Index: 0
    property int  _bat3Index: 2
    property real _current_generator: 0

    // GPS
    property real _satCount: 0
    property real _satPDOP: 0

    // Vazão (GPM)
    property real _gpm: 0

    // Média de RPM por rotor: valor fixo, como no FlyView anterior. Só posiciona
    // os marcadores de média, que estão ocultos.
    property real medAceleracaoRotor1: 1500
    property real medAceleracaoRotor2: 1500
    property real medAceleracaoRotor3: 1500
    property real medAceleracaoRotor4: 1500
    property real medAceleracaoRotor5: 1500
    property real medAceleracaoRotor6: 1500

    readonly property var _medAceleracaoRotor: [ medAceleracaoRotor1, medAceleracaoRotor2, medAceleracaoRotor3,
                                                 medAceleracaoRotor4, medAceleracaoRotor5, medAceleracaoRotor6 ]

    // RPM dos rotores (ESC)
    readonly property var _rotorRpm: _activeVehicle ?
                                         [ _activeVehicle._GD_RPM1.rawValue, _activeVehicle._GD_RPM2.rawValue, _activeVehicle._GD_RPM3.rawValue,
                                           _activeVehicle._GD_RPM4.rawValue, _activeVehicle._GD_RPM5.rawValue, _activeVehicle._GD_RPM6.rawValue ] :
                                         [ 0, 0, 0, 0, 0, 0 ]

    // Os Binding abaixo convertem o texto (toFixed/valueString) para número ao
    // gravar nas propriedades real; não trocar por binding direto.

    // =========================================================
    // BATERIA 1
    // =========================================================

    Binding {
        target: bottomDataArea
        property: "_tensao_bateria_1"
        value: {
            if (!bottomDataArea._activeVehicle)
                return 0

            if (bottomDataArea._activeVehicle.batteries.count <= 0)
                return 0

            return bottomDataArea._activeVehicle.batteries.get(_bat1Index).voltage.value.toFixed(1)
        }
    }

    Binding {
        target: bottomDataArea
        property: "_current_bateria_1"
        value: {
            if (!bottomDataArea._activeVehicle)
                return 0

            if (bottomDataArea._activeVehicle.batteries.count <= 0)
                return 0

            return bottomDataArea._activeVehicle.batteries.get(_bat1Index).current.value
        }
    }

    Binding {
        target: bottomDataArea
        property: "_current_generator"
        value: {
            if (!bottomDataArea._activeVehicle)
                return 0

            if (bottomDataArea._activeVehicle.batteries.count <= 0)
                return 0

            return bottomDataArea._activeVehicle.batteries.get(_bat3Index).current.value
        }
    }

    Binding {
        target: bottomDataArea
        property: "_pct_bateria_1"
        value: {
            if (!bottomDataArea._activeVehicle)
                return 0

            if (bottomDataArea._activeVehicle.batteries.count <= 0)
                return 0

            return bottomDataArea._activeVehicle.batteries.get(_bat1Index).percentRemaining.value
        }
    }

    // =========================================================
    // GPS
    // =========================================================

    Binding {
        target: bottomDataArea
        property: "_satCount"
        value: {
            if (!bottomDataArea._activeVehicle)
                return 0

            return bottomDataArea._activeVehicle.gps ?
                   bottomDataArea._activeVehicle.gps.count.valueString : 0
        }
    }

    // Rótulo "PDOP", mas o valor é o tipo de fix (gps.lock)
    Binding {
        target: bottomDataArea
        property: "_satPDOP"
        value: {
            if (!bottomDataArea._activeVehicle)
                return 0

            return bottomDataArea._activeVehicle.gps ?
                   bottomDataArea._activeVehicle.gps.lock.valueString : 0
        }
    }

    // =========================================================
    // VAZÃO - GPM
    // =========================================================

    Binding {
        target: bottomDataArea
        property: "_gpm"
        value: {
            if (!bottomDataArea._activeVehicle)
                return 0

            if (!bottomDataArea._activeVehicle.gd60_Sensor1)
                return 0

            return bottomDataArea._activeVehicle.gd60_Sensor1.rawValue
        }
    }

    Rectangle {
        id: gradientBar
        anchors.fill: parent

        gradient: Gradient {
            GradientStop { position: 0.7; color: qgcPal.toolbarBackground }
            GradientStop { position: 1.0; color: toolbar._mainStatusBGColor }
        }
    }

    // =========================================================
    // BATERIA: ícone com nível, %, tensão e corrente
    // =========================================================

    QGCColoredImage {
        id:                 batteryPercentageIcon_1
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.margins:    toolsMargin
        width:              height
        height:             parent.height*2/3
        source:             "/qmlimages/Battery.svg"
        fillMode:           Image.PreserveAspectFit
        color:              "white"
    }

    // Nível da bateria desenhado dentro do ícone (pela OpacityMask abaixo)
    Rectangle {
        id:             batteryPercentageBar_1
        anchors.top:    batteryPercentageIcon_1.top
        anchors.left:   batteryPercentageIcon_1.left
        width:          batteryPercentageIcon_1.width
        height:         batteryPercentageIcon_1.height
        color:          "transparent"
        visible:        false

        Rectangle {
            y:                          parent.height*0.1
            anchors.horizontalCenter:   parent.horizontalCenter
            width:                      parent.width/2
            height:                     parent.height*0.85
            color:                      _pct_bateria_1 > 50 ? "green" : (_pct_bateria_1 > 30 ? "orange" : "red")
        }

        // Cobre a parte vazia: altura = 1 - nível
        Rectangle {
            anchors.horizontalCenter:   parent.horizontalCenter
            width:                      parent.width/2
            height:                     parent.height*(0.15 + 0.85*(1-_pct_bateria_1/100))
            color:                      qgcPal.toolbarBackground
        }
    }

    OpacityMask {
        anchors.fill:   batteryPercentageBar_1
        source:         batteryPercentageBar_1
        maskSource:     batteryPercentageIcon_1
        invert:         true
    }

    Rectangle {
        id:                     textBoxBatteryInfo_1
        anchors.verticalCenter: batteryPercentageIcon_1.verticalCenter
        anchors.left:           batteryPercentageIcon_1.right
        height:                 batteryPercentageIcon_1.height*0.7
        width:                  batteryPercentageIcon_1.width*0.7
        color:                  "transparent"
        border.width:           0

        ColumnLayout {
            id:             batteryInfoColumn_1
            anchors.fill:   parent
            spacing:        0

            Text {
                Layout.alignment:   Qt.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
                color:              "White"
                text:               _pct_bateria_1 > 9 ? _pct_bateria_1 + "%" : "0" + _pct_bateria_1 + "%"
                font.pointSize:     14
                font.bold:          true
            }
            Text {
                Layout.alignment:   Qt.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
                color:              "White"
                text:               _tensao_bateria_1 + " V"
                font.pointSize:     14
                font.bold:          true
            }
            Text {
                Layout.alignment:   Qt.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
                color:              "White"
                text:               _current_bateria_1 + " A"
                font.pointSize:     14
                font.bold:          true
            }
        }
    }

    // =========================================================
    // CONSUMO
    // =========================================================

    QGCColoredImage {
        id:                 powerComIcon
        anchors.top:        parent.top
        anchors.left:       textBoxBatteryInfo_1.right
        anchors.leftMargin: toolsMargin*2.5
        anchors.topMargin:  toolsMargin*2
        width:              height
        height:             parent.height*3/5
        source:             "/qmlimages/power_consumo.svg"
        fillMode:           Image.PreserveAspectFit
        color:              "White"
    }
    DropShadow {
        anchors.fill:       powerComIcon
        source:             powerComIcon
        color:              "#80000000"
        radius:             8
        samples:            17
        spread:             0
        verticalOffset:     5
        horizontalOffset:   5
    }

    Rectangle {
        id:                     textBoxpowerComIcon
        anchors.verticalCenter: powerComIcon.verticalCenter
        anchors.left:           powerComIcon.right
        anchors.leftMargin:     toolsMargin
        height:                 powerComIcon.height*0.7
        width:                  powerComIcon.width
        color:                  "transparent"
        border.width:           0
    }
    ColumnLayout {
        id:             powerComIconInfoColumn
        anchors.fill:   textBoxpowerComIcon
        spacing:        0

        // Valor fixo: o produto ainda não recebe telemetria de consumo
        Text {
            Layout.alignment:   Qt.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            color:              "White"
            text:               _current_generator + " A"
            font.bold:          true
            font.pointSize:     15
        }
    }

    // =========================================================
    // VAZÃO
    // =========================================================

    QGCColoredImage {
        id:                 pressureGaugeIcon
        anchors.top:        parent.top
        anchors.left:       textBoxpowerComIcon.right
        anchors.leftMargin: toolsMargin*2.5
        anchors.topMargin:  toolsMargin*2
        width:              height
        height:             parent.height*3/4
        source:             "/qmlimages/pressure_gauge.svg"
        fillMode:           Image.PreserveAspectFit
        color:              "White"
    }
    DropShadow {
        anchors.fill:       pressureGaugeIcon
        source:             pressureGaugeIcon
        color:              "#80000000"
        radius:             8
        samples:            17
        spread:             0
        verticalOffset:     5
        horizontalOffset:   5
    }

    Rectangle {
        id:                     textBoxpressureGaugeIcon
        anchors.verticalCenter: pressureGaugeIcon.verticalCenter
        anchors.left:           pressureGaugeIcon.right
        anchors.leftMargin:     toolsMargin
        height:                 pressureGaugeIcon.height*0.7
        width:                  pressureGaugeIcon.width
        color:                  "transparent"
        border.width:           0
    }
    ColumnLayout {
        id:             pressureGaugeInfoColumn
        anchors.fill:   textBoxpressureGaugeIcon
        spacing:        0

        Text {
            Layout.alignment:   Qt.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            color:              "White"
            text:               _gpm.toFixed(1).toString() + " GPM"
            font.bold:          true
            font.pointSize:     15
        }
    }

    // =========================================================
    // GPS: satélites e fix
    // =========================================================

    QGCColoredImage {
        id:                 satteliteInformationIcon
        anchors.top:        parent.top
        anchors.left:       pressureGaugeInfoColumn.right
        anchors.leftMargin: toolsMargin*1.5
        anchors.topMargin:  toolsMargin*2
        width:              height
        height:             parent.height*2/3
        source:             "/qmlimages/Gps.svg"
        fillMode:           Image.PreserveAspectFit
        color:              _satPDOP >= 2 && _satCount >= 6 ? "green" : "orange"
    }
    DropShadow {
        anchors.fill:       satteliteInformationIcon
        source:             satteliteInformationIcon
        color:              "#80000000"
        radius:             8
        samples:            17
        spread:             0
        verticalOffset:     5
        horizontalOffset:   5
    }
    OpacityMask {
        anchors.fill:   satteliteInformationIcon
        source:         satteliteInformationIcon
        maskSource:     satteliteInformationIcon
    }

    Rectangle {
        id:                     textBoxSatteliteInfo
        anchors.verticalCenter: satteliteInformationIcon.verticalCenter
        anchors.left:           satteliteInformationIcon.right
        anchors.leftMargin:     toolsMargin
        height:                 satteliteInformationIcon.height*0.7
        width:                  satteliteInformationIcon.width
        color:                  "transparent"
        border.width:           0
    }
    ColumnLayout {
        id:             satteliteInfoColumn
        anchors.fill:   textBoxSatteliteInfo
        spacing:        0

        Text {
            Layout.alignment:   Qt.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            color:              "White"
            text:               "Count: " + _satCount
            font.bold:          true
            font.pointSize:     15
        }
        Text {
            Layout.alignment:   Qt.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            color:              "White"
            text:               "PDOP: " + _satPDOP
            font.bold:          true
            font.pointSize:     15
        }
    }

    // =========================================================
    // ENLACE RC: cor pelo RSSI; o valor aparece no hover
    // =========================================================

    QGCColoredImage {
        id:                 rcInformationIcon
        anchors.top:        parent.top
        anchors.left:       textBoxSatteliteInfo.right
        anchors.leftMargin: toolsMargin*3
        anchors.topMargin:  toolsMargin*2
        width:              height
        height:             parent.height*2/3
        source:             "/qmlimages/RC.svg"
        fillMode:           Image.PreserveAspectFit
        color:              !_activeVehicle ? "white" :
                            (_activeVehicle.rcRSSI >= 60 ? "green" :
                            (_activeVehicle.rcRSSI >= 30 ? "yellow" :
                            (_activeVehicle.rcRSSI >= 20 ? "orange" : "red")))

        MouseArea {
            id:             rcMouseArea
            anchors.fill:   parent
            hoverEnabled:   true
        }
    }

    Rectangle {
        id:                         textBoxRCInfo
        anchors.verticalCenter:     rcInformationIcon.verticalCenter
        anchors.horizontalCenter:   rcInformationIcon.horizontalCenter
        height:                     satteliteInformationIcon.height*0.7
        width:                      satteliteInformationIcon.width*0.8
        visible:                    rcMouseArea.containsMouse
        color:                      "black"
        border.width:               1
        border.color:               "lightgray"
    }
    ColumnLayout {
        id:             rcInfoColumn
        anchors.fill:   textBoxRCInfo
        spacing:        0
        visible:        textBoxRCInfo.visible

        Text {
            Layout.alignment:   Qt.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            color:              "White"
            text:               _activeVehicle ? _activeVehicle.rcRSSI + "%" : ""
            font.bold:          true
        }
    }

    // =========================================================
    // RPM DOS ROTORES: uma barra por rotor (escala 3500 rpm)
    // =========================================================

    Rectangle {
        id:                 rotorsTempArea
        anchors.top:        parent.top
        anchors.left:       rcInformationIcon.right
        anchors.margins:    toolsMargin * 1.4
        width:              height * 2
        height:             parent.height*2/3
        color:              "black"

        // Borda
        Rectangle {
            anchors.fill:   parent
            color:          "transparent"
            border.width:   2
            z:              parent.z+13
            border.color:   "lightgray"
        }
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
                // Destaque amarelo enquanto o ponteiro está sobre a barra
                property bool selected: false

                width:          parent.width / 6
                height:         parent.height * _rotorRpm[index] / 3500
                x:              index * parent.width / 6
                anchors.bottom: parent.bottom
                z:              parent.z + 10
                color:          "green"
                border.color:   selected ? "yellow" : "black"
                border.width:   3

                MouseArea {
                    anchors.fill:           parent
                    hoverEnabled:           true
                    onContainsMouseChanged: parent.selected = !parent.selected
                }
            }
        }

        // Marcadores da média por rotor (ocultos no produto)
        Repeater {
            model: 6

            Rectangle {
                width:          parent.width/6
                height:         parent.height/20
                x:              index*parent.width/6
                y:              parent.height * _medAceleracaoRotor[index] / 4000
                z:              1000
                color:          "white"
                border.color:   "black"
                border.width:   0.5
                visible:        false
            }
        }
    }
}
