/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

// Global Drones GD25: painel inferior do FlyView comum (import GD.Variant 1.0).
// Da esquerda para a direita: gasolina, motor a combustão (temperatura e RPM do
// gerador), RPM dos 6 rotores, grade de dados, instrumento de atitude/bússola
// e heading do gimbal.
//
// Interface usada pelo FlyView comum:
//   toolsMargin     margem das ferramentas do FlyView
//   _androidBuild   true em Android/iOS (exigido pela instância; não usado aqui)
// A telemetria vem do veículo ativo. Por escopo dinâmico só se lê
// toolbar._mainStatusBGColor (MainRootWindow): a cor de status da barra
// superior, usada no degradê do fundo.
//
// Instâncias de bateria (posição na lista do veículo): 0 bateria, 1 gasolina,
// 2 gerador.

import QtQuick              2.12
import QtQuick.Layouts      1.12
import QtGraphicalEffects   1.0

import QGroundControl           1.0
import QGroundControl.Controls  1.0
import QGroundControl.Palette   1.0

Item {
    id: bottomDataArea

    property real toolsMargin
    property bool _androidBuild

    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    property int _batteryIndex:     0
    property int _gasolineIndex:    1
    property int _generatorIndex:   2

    property bool _selected_rotor_1
    property bool _selected_rotor_2
    property bool _selected_rotor_3
    property bool _selected_rotor_4
    property bool _selected_rotor_5
    property bool _selected_rotor_6

    property bool motorTempInfoVisible: false

    //-- Telemetria

    property real _gasolina: (activeVehicle && activeVehicle.batteries.count > _gasolineIndex)
                             ? activeVehicle.batteries.get(_gasolineIndex).percentRemaining.value
                             : 0

    // Temperatura do motor a combustão (TempICE)
    property real _motor_temp: (activeVehicle && activeVehicle.batteries.count > 0)
                               ? Number(activeVehicle.gd60_Sensor1.rawValue.toFixed(0))
                               : 0

    property real _GD_GeneratorRPM: (activeVehicle && activeVehicle._GD_GeneratorRPM)
                                    ? Number(activeVehicle._GD_GeneratorRPM.rawValue.toFixed(0))
                                    : 0

    property real _heading: activeVehicle ? activeVehicle.heading.value : 0

    // Yaw do gimbal relativo ao heading. Um 0 logo depois de um valor diferente
    // de 0 é tratado como zero espúrio e mantém o valor anterior; um segundo 0
    // seguido passa.
    property real _gimbal_yaw:      0
    property real _old_gimbal_yaw:  0

    function _updateGimbalYaw() {
        if (!activeVehicle) {
            _gimbal_yaw = 0
            return
        }
        var yaw = Number(activeVehicle._GD_GimbalYaw.rawValue.toFixed(2))
        if (_old_gimbal_yaw !== 0 && yaw === 0) {
            _old_gimbal_yaw = 0
            return
        }
        _old_gimbal_yaw = yaw
        _gimbal_yaw = yaw
    }

    onActiveVehicleChanged: _updateGimbalYaw()
    Component.onCompleted:  _updateGimbalYaw()

    Connections {
        target: activeVehicle ? activeVehicle._GD_GimbalYaw : null

        function onRawValueChanged() {
            _updateGimbalYaw()
        }
    }

    property string batteryVoltageText: {
        if (!activeVehicle || activeVehicle.batteries.count <= _batteryIndex)
            return "Battery Voltage: "
        return "Battery Voltage: " +
               activeVehicle.batteries.get(_batteryIndex).voltage.rawValue.toFixed(1) + "V"
    }

    property string batteryCurrentText: {
        if (!activeVehicle || activeVehicle.batteries.count <= _batteryIndex)
            return "Battery Current:"
        return "Battery Current: " +
               activeVehicle.batteries.get(_batteryIndex).current.rawValue.toFixed(1) + "A"
    }

    property string generatorCurrentText: {
        if (!activeVehicle || activeVehicle.batteries.count <= _generatorIndex)
            return "Generator Current:"
        return "Generator Current: " +
               activeVehicle.batteries.get(_generatorIndex).current.rawValue.toFixed(1) + "A"
    }

    property string groundSpeedText: {
        if (!activeVehicle || activeVehicle.batteries.count <= 0)
            return "Ground Speed:"
        return "Ground Speed: " + activeVehicle.groundSpeed.value.toFixed(1) + "m/s"
    }

    property string altLIDARText: {
        if (!activeVehicle || activeVehicle.batteries.count <= 0)
            return "Altitude LIDAR:"
        return "Altitude LIDAR: " + activeVehicle.rangeFinderDist.value.toFixed(1) + "m"
    }

    // Tempo no ar (flightTimeCustom, zera ao armar), em hh:mm:ss
    property string flightTimeText: {
        if (!activeVehicle || activeVehicle.batteries.count <= 0)
            return "Flighttime:"

        var totalSeconds = activeVehicle.flightTimeCustom.rawValue
        var hours = Math.floor(totalSeconds / 3600)
        var minutes = Math.floor((totalSeconds % 3600) / 60)
        var seconds = Math.floor(totalSeconds % 60)

        return "Flighttime: " + (hours > 0 ? (hours < 10 ? "0" + hours : hours) + ":" : "00:") +
               (minutes < 10 ? "0" + minutes : minutes) + ":" +
               (seconds < 10 ? "0" + seconds : seconds)
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    //**************************************************************************************************
    // FUNDO
    //**************************************************************************************************

    Rectangle {
        id: gradientBar
        anchors.fill: parent

        gradient: Gradient {
            GradientStop { position: 0.7; color: qgcPal.toolbarBackground }
            GradientStop { position: 1.0; color: toolbar._mainStatusBGColor }
        }
    }

    //**************************************************************************************************
    // GASOLINA
    //**************************************************************************************************

    Loader {
        id: gasolineIconLoader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: toolsMargin * 2
        anchors.topMargin: toolsMargin

        asynchronous: false
        width: height
        height: parent.height * 2 / 3
        active: true
        visible: true

        sourceComponent: Component {
            QGCColoredImage {
                anchors.fill: parent
                source: "/qmlimages/GasCan.svg"
                fillMode: Image.PreserveAspectFit
                color: _gasolina > 50 ? "green" : (_gasolina > 20 ? "orange" : "red")
            }
        }
    }

    DropShadow {
        anchors.fill: gasolineIconLoader
        source: gasolineIconLoader.item
        color: "#80000000"
        radius: 8
        samples: 17
        verticalOffset: 5
        horizontalOffset: 5
    }

    Rectangle {
        id: textBoxGasolinePercentage
        anchors.centerIn: gasolineIconLoader
        height: gasolineIconLoader.height / 3
        width: gasolineIconLoader.width

        color: "black"
        border.width: 1
        border.color: "lightgray"
    }

    Text {
        anchors.fill: textBoxGasolinePercentage
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: _gasolina + "%"
        font.bold: true
        color: "white"
    }

    //**************************************************************************************************
    // TEMPERATURA MOTOR
    //**************************************************************************************************

    // Vermelho com o gerador parado (RPM <= 0)
    QGCColoredImage {
        id: motorTemperatureInformationIcon
        anchors.top: parent.top
        anchors.left: textBoxGasolinePercentage.right
        anchors.leftMargin: toolsMargin * 0.5
        anchors.topMargin: toolsMargin * 2

        width: height
        height: parent.height * 2 / 3

        source: "/qmlimages/MotorTemp.svg"
        fillMode: Image.PreserveAspectFit
        color: (_GD_GeneratorRPM <= 0) ? "red" : "white"
    }

    QGCColoredImage {
        id: motorTemperatureInformationIcon2
        anchors.fill: motorTemperatureInformationIcon
        source: "/qmlimages/MotorTermometer.png"
        fillMode: Image.PreserveAspectFit

        color: _motor_temp > 110 ?
                   (_motor_temp > 150 ?
                        (_motor_temp >= 200 ? "red" : "orange")
                      : "yellow")
                 : "white"
    }

    Rectangle {
        id: textBoxMotorTempInfo
        anchors.centerIn: motorTemperatureInformationIcon
        height: motorTemperatureInformationIcon.height * 1.2
        width: motorTemperatureInformationIcon.width

        visible: motorTempInfoVisible
        color: "black"
        border.width: 1
        border.color: "lightgray"
    }

    // A caixa de temperatura/RPM abre e fecha a cada 2 cliques (toques no
    // tablet), como no app anterior.
    MouseArea {
        id: motorTempMouseArea
        anchors.fill: motorTemperatureInformationIcon
        hoverEnabled: true

        property int press_count: 0

        onClicked: {
            press_count = press_count + 1
            if (press_count % 2 === 0) {
                motorTempInfoVisible = !motorTempInfoVisible
            }
        }
    }

    ColumnLayout {
        anchors.fill: textBoxMotorTempInfo
        visible: textBoxMotorTempInfo.visible

        Text {
            Layout.alignment: Qt.AlignHCenter
            color: "white"
            text: _motor_temp.toString() + "°C"
            font.bold: true
            font.pixelSize: 20
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            color: "white"
            text: "RPM: "
            font.bold: true
            font.pixelSize: 20
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            color: "white"
            text: activeVehicle ? activeVehicle._GD_GeneratorRPM.rawValue.toFixed(0) : ""
            font.bold: true
            font.pixelSize: 20
        }
    }

    //**************************************************************************************************
    // ROTORES (RPM / 3850)
    //**************************************************************************************************

    Rectangle {
        id: rotorsTempArea
        anchors.top: parent.top
        anchors.left: motorTemperatureInformationIcon.right
        anchors.margins: toolsMargin * 1

        width: height * 2
        height: parent.height * 2 / 3
        color: "black"

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: 2
            border.color: "lightgray"
            z: parent.z + 1000
        }

        ListModel { id: accellRotorModel }

        Component.onCompleted: {
            for (var i = 0; i < 6; i++)
                accellRotorModel.append({ aceleracao: 0 })
        }

        Timer {
            interval: 100
            running: true
            repeat: true

            onTriggered: {
                if (!activeVehicle) return

                accellRotorModel.set(0, { aceleracao: activeVehicle._GD_RPM1.rawValue / 3850 })
                accellRotorModel.set(1, { aceleracao: activeVehicle._GD_RPM2.rawValue / 3850 })
                accellRotorModel.set(2, { aceleracao: activeVehicle._GD_RPM3.rawValue / 3850 })
                accellRotorModel.set(3, { aceleracao: activeVehicle._GD_RPM4.rawValue / 3850 })
                accellRotorModel.set(4, { aceleracao: activeVehicle._GD_RPM5.rawValue / 3850 })
                accellRotorModel.set(5, { aceleracao: activeVehicle._GD_RPM6.rawValue / 3850 })
            }
        }

        Repeater {
            model: accellRotorModel

            Rectangle {
                width: parent.width / 6
                height: model.aceleracao * parent.height
                x: index * parent.width / 6
                anchors.bottom: parent.bottom

                color: "green"
                border.width: 3

                border.color: {
                    if (index === 0 && _selected_rotor_1) return "yellow"
                    if (index === 1 && _selected_rotor_2) return "yellow"
                    if (index === 2 && _selected_rotor_3) return "yellow"
                    if (index === 3 && _selected_rotor_4) return "yellow"
                    if (index === 4 && _selected_rotor_5) return "yellow"
                    if (index === 5 && _selected_rotor_6) return "yellow"
                    return "black"
                }

                // Destaca a barra enquanto o cursor/dedo está sobre ela
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onContainsMouseChanged: {
                        if (index === 0) _selected_rotor_1 = !_selected_rotor_1
                        else if (index === 1) _selected_rotor_2 = !_selected_rotor_2
                        else if (index === 2) _selected_rotor_3 = !_selected_rotor_3
                        else if (index === 3) _selected_rotor_4 = !_selected_rotor_4
                        else if (index === 4) _selected_rotor_5 = !_selected_rotor_5
                        else if (index === 5) _selected_rotor_6 = !_selected_rotor_6
                    }
                }
            }
        }
    }

    //**************************************************************************************************
    // GRADE DE DADOS
    //**************************************************************************************************

    Item {
        id: _dataBox
        height: parent.height * 2 / 3
        width: parent.width * 0.45
        anchors.top: parent.top
        anchors.left: rotorsTempArea.right
        anchors.margins: toolsMargin

        // 1 px: o 2 do app anterior nunca chegava às células (ReferenceError);
        // mantida a espessura que aparece em campo.
        property int _borderWidth: 1
        property int _fontSize: 10

        Column {
            width: parent.width
            height: parent.height

            Row {
                width: parent.width
                height: parent.height / 2

                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    color: "transparent"
                    border.width: _dataBox._borderWidth
                    border.color: "white"

                    // Tensão: amarelo até 47 V, vermelho abaixo de 42 V
                    Text {
                        anchors.centerIn: parent
                        text: batteryVoltageText
                        font.bold: true
                        font.pointSize: _dataBox._fontSize
                        color: (!activeVehicle
                                || activeVehicle.batteries.count <= _batteryIndex
                                || isNaN(activeVehicle.batteries.get(_batteryIndex).voltage.rawValue))
                               ? "white"
                               : (activeVehicle.batteries.get(_batteryIndex).voltage.rawValue < 42
                                  ? "red"
                                  : activeVehicle.batteries.get(_batteryIndex).voltage.rawValue <= 47
                                    ? "yellow"
                                    : "white")
                    }
                }

                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    color: "transparent"
                    border.width: _dataBox._borderWidth
                    border.color: "white"

                    Text {
                        anchors.centerIn: parent
                        text: generatorCurrentText
                        font.bold: true
                        font.pointSize: _dataBox._fontSize
                        color: "white"
                    }
                }

                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    color: "transparent"
                    border.width: _dataBox._borderWidth
                    border.color: "white"

                    Text {
                        anchors.centerIn: parent
                        text: flightTimeText
                        font.bold: true
                        font.pointSize: _dataBox._fontSize
                        color: "white"
                    }
                }
            }

            Row {
                width: parent.width
                height: parent.height / 2

                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    color: "transparent"
                    border.width: _dataBox._borderWidth
                    border.color: "white"

                    Text {
                        anchors.centerIn: parent
                        text: batteryCurrentText
                        font.bold: true
                        font.pointSize: _dataBox._fontSize
                        color: "white"
                    }
                }

                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    color: "transparent"
                    border.width: _dataBox._borderWidth
                    border.color: "white"

                    Text {
                        anchors.centerIn: parent
                        text: groundSpeedText
                        font.bold: true
                        font.pointSize: _dataBox._fontSize
                        color: "white"
                    }
                }

                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    color: "transparent"
                    border.width: _dataBox._borderWidth
                    border.color: "white"

                    // Vermelho acima de 120 m
                    Text {
                        anchors.centerIn: parent
                        text: altLIDARText
                        font.bold: true
                        font.pointSize: _dataBox._fontSize
                        color: activeVehicle ? (activeVehicle.rangeFinderDist.value.toFixed(1) > 120 ? "red" : "white") : "white"
                    }
                }
            }
        }
    }

    //**************************************************************************************************
    // INSTRUMENTO DE ATITUDE/BÚSSOLA
    //**************************************************************************************************

    Item {
        width: parent.width * 0.35
        anchors.top: parent.top
        anchors.left: _dataBox.right

        Loader {
            width: parent.width / 2
            source: "qrc:/qml/QGCInstrumentWidget.qml"
        }
    }

    //**************************************************************************************************
    // HEADING DO GIMBAL
    //**************************************************************************************************

    Item {
        id: gimbalHeadingDial
        width: height
        height: parent.height * 0.85
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: toolsMargin

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: qgcPal.window
            border.color: qgcPal.text
            border.width: 1
        }

        Item {
            id: instrument
            anchors.fill: parent
            visible: false

            // Ícone da câmera apontando para heading do veículo + yaw do gimbal
            Image {
                id: cameraIcon
                width: parent.width * 0.4
                source: "/qmlimages/camera_video.svg"
                mipmap: true
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                sourceSize.width: width

                transform: Rotation {
                    origin.x: cameraIcon.width / 2
                    origin.y: cameraIcon.height / 2
                    angle: -90 + Number(_heading) + _gimbal_yaw
                }
            }

            QGCColoredImage {
                id: compassDial
                source: "/qmlimages/compassInstrumentDial.svg"
                mipmap: true
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                sourceSize.height: parent.height
                color: qgcPal.text
            }

            // Yaw do gimbal em graus
            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.35
                height: parent.width * 0.2
                border.color: qgcPal.text
                color: qgcPal.window
                opacity: 0.65
                z: 10

                QGCLabel {
                    text: _headingString
                    anchors.centerIn: parent
                    color: qgcPal.text
                    font.pointSize: 12

                    property string _headingString: activeVehicle ? String(_gimbal_yaw % 360) : "OFF"
                }
            }
        }

        // Máscara circular
        Rectangle {
            id: mask
            anchors.fill: instrument
            radius: width / 2
            color: "black"
            visible: false
        }

        OpacityMask {
            anchors.fill: instrument
            source: instrument
            maskSource: mask
        }
    }
}
