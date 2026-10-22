// GD70: painel inferior do FlyView comum (import GD.Variant 1.0).
// Origem: archive/gd70 src/FlightDisplay/FlyViewBottomViewArea.qml.
//
// Instâncias de BATTERY_STATUS no GD70 (f6ba286): 0 = gerador, 1 = bateria,
// 2 = gasolina. O painel lateral usa o mesmo índice de gasolina.

import QtQuick              2.12
import QtQuick.Layouts      1.12
import QtGraphicalEffects   1.0

import QGroundControl           1.0
import QGroundControl.Controls  1.0
import QGroundControl.Palette   1.0

Item {
    id: bottomDataArea

    // Interface com o FlyView comum
    property real   toolsMargin
    property bool   _androidBuild   // atribuído pelo FlyView; o GD70 não usa

    property var    activeVehicle:  QGroundControl.multiVehicleManager.activeVehicle

    property int    _generatorIndex:    0
    property int    _batteryIndex:      1
    property int    _gasolineIndex:     2

    property bool   motorTempInfoVisible: false

    property bool   _selected_rotor_1
    property bool   _selected_rotor_2
    property bool   _selected_rotor_3
    property bool   _selected_rotor_4
    property bool   _selected_rotor_5
    property bool   _selected_rotor_6

    property real   _heading:       activeVehicle ? activeVehicle.heading.value : 0
    property real   _gimbal_yaw:    0
    property real   _old_gimbal_yaw: 0

    property real _gasolina: {
        if (!activeVehicle) return 0
        if (activeVehicle.batteries.count <= _gasolineIndex) return 0
        return activeVehicle.batteries.get(_gasolineIndex).percentRemaining.rawValue
    }

    // gd60_Sensor1 = T_Motor (telemetry.cc do GD70)
    property real _motor_temp: {
        if (!activeVehicle) return 0
        if (activeVehicle.batteries.count <= 0) return 0
        return activeVehicle.gd60_Sensor1.rawValue.toFixed(0)
    }

    property string generatorVoltageText: {
        if (!activeVehicle) return "Bus Voltage: "
        if (activeVehicle.batteries.count <= _generatorIndex) return "Generator Voltage: "
        return "Generator Voltage: " + activeVehicle.batteries.get(_generatorIndex).voltage.rawValue.toFixed(1) + "V"
    }

    property string generatorCurrentText: {
        if (!activeVehicle) return "Bus Current:"
        if (activeVehicle.batteries.count <= _generatorIndex) return "Generator Current:"
        return "Generator Current: " + activeVehicle.batteries.get(_generatorIndex).current.rawValue.toFixed(1) + "A"
    }

    property string batteryVoltageText: {
        if (!activeVehicle) return "Battery Voltage: "
        if (activeVehicle.batteries.count <= _batteryIndex) return "Battery Voltage: "
        return "Battery Voltage: " + activeVehicle.batteries.get(_batteryIndex).voltage.rawValue.toFixed(1) + "V"
    }

    property string batteryCurrentText: {
        if (!activeVehicle) return "Battery Current:"
        if (activeVehicle.batteries.count <= _batteryIndex) return "Battery Current:"
        return "Battery Current: " + activeVehicle.batteries.get(_batteryIndex).current.rawValue.toFixed(1) + "A"
    }

    // Distância voada: zera ao armar (decisão de produto 3)
    property string flightDistanceText: {
        if (!activeVehicle) return "FlightDist:"
        return "FlightDist: " + activeVehicle.flightDistance.rawValue.toFixed(1) + "m"
    }

    property string groundSpeedText: {
        if (!activeVehicle) return "Ground Speed:"
        if (activeVehicle.batteries.count <= 0) return "Ground Speed:"
        return "Ground Speed: " + activeVehicle.groundSpeed.value.toFixed(1) + "m/s"
    }

    // Cor da tensão do gerador: vermelho < 42 V, amarelo <= 47 V
    property color generatorVoltageColor: {
        if (!activeVehicle || activeVehicle.batteries.count <= _generatorIndex) return "white"
        var volts = activeVehicle.batteries.get(_generatorIndex).voltage.rawValue
        if (isNaN(volts)) return "white"
        return volts < 42 ? "red" : (volts <= 47 ? "yellow" : "white")
    }



    property string altLIDARText: ""
    Binding {
        target: bottomDataArea
        property: "altLIDARText"
        value: {
            if (!activeVehicle) return "Altitude LIDAR:"
            if (activeVehicle.batteries.count <= 0) return "Altitude LIDAR:"

            /*return "Altitude LIDAR: " +
                       activeVehicle.rangeFinderDist.value.toFixed(1)+"m"*/
            return "Altitude LIDAR: " +
                       activeVehicle.rangeFinderDist.value.toFixed(1)+"m"
        }
    }

    property string flightTimeText: ""
    Binding {
        target: bottomDataArea
        property: "flightTimeText"
        value: {
            if (!activeVehicle) return "Flighttime:"
            if (activeVehicle.batteries.count <= 0) return "Flighttime:"

            //TODO: descobrir porque o systime do 25 começa em 8 minutos
            var totalSeconds = activeVehicle.flightTimeCustom.rawValue
            var hours = Math.floor(totalSeconds / 3600)
            var minutes = Math.floor((totalSeconds % 3600) / 60)
            var seconds = Math.floor(totalSeconds % 60)

            // Formata para garantir dois dígitos (00:00:00)
            return "Flighttime: " + (hours > 0 ? (hours < 10 ? "0" + hours : hours) + ":" : "00:") +
                   (minutes < 10 ? "0" + minutes : minutes) + ":" +
                   (seconds < 10 ? "0" + seconds : seconds)
        }
    }


    // Yaw do gimbal com filtro: um zero isolado depois de um valor diferente
    // de zero é tratado como leitura espúria e mantém o valor anterior.
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
        function onRawValueChanged() { _updateGimbalYaw() }
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
        text: _gasolina.toString() + "%"
        font.bold: true
        color: "white"
    }

    //**************************************************************************************************
    // TEMPERATURA DO MOTOR
    //**************************************************************************************************

    // Branco fixo: o vermelho com RPM do gerador <= 0 foi desligado no GD70 (6ea08a9)
    QGCColoredImage {
        id: motorTemperatureInformationIcon
        anchors.top: parent.top
        anchors.left: textBoxGasolinePercentage.right
        anchors.leftMargin: toolsMargin * 2
        anchors.topMargin: toolsMargin * 2

        width: height
        height: parent.height * 2 / 3

        source: "/qmlimages/MotorTemp.svg"
        fillMode: Image.PreserveAspectFit
        color: "white"
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

    // Abre/fecha a caixa de temperatura/RPM a cada 2 cliques, como hoje no
    // GD70 (41bd1ac), também no Android.
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
        anchors.margins: toolsMargin

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
    // GRADE DE DADOS (2 x 3)
    //**************************************************************************************************

    // Bordas das células com 1 px: é o que o GD70 mostra hoje (a largura 2
    // declarada no archive nunca era lida, ReferenceError por escopo).
    Item {
        id: _dataBox
        height: parent.height * 2 / 3
        width: parent.width * 0.45
        anchors.top: parent.top
        anchors.left: rotorsTempArea.right
        anchors.margins: toolsMargin

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
                    border.width: 1
                    border.color: "white"

                    Text {
                        anchors.centerIn: parent
                        text: generatorVoltageText
                        font.bold: true
                        font.pointSize: _dataBox._fontSize
                        color: generatorVoltageColor
                    }
                }

                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    color: "transparent"
                    border.width: 1
                    border.color: "white"

                    Text {
                        anchors.centerIn: parent
                        text: flightTimeText
                        font.bold: true
                        font.pointSize: _dataBox._fontSize
                        color: "white"
                    }
                }

                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    color: "transparent"
                    border.width: 1
                    border.color: "white"

                    Text {
                        anchors.centerIn: parent
                        text: flightDistanceText
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
                    border.width: 1
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
                    border.width: 1
                    border.color: "white"

                    Text {
                        anchors.centerIn: parent
                        text: altLIDARText
                        font.bold: true
                        font.pointSize: _dataBox._fontSize
                        color: "white"
                    }
                }

                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    color: "transparent"
                    border.width: 1
                    border.color: "white"

                    Text {
                        anchors.centerIn: parent
                        text: groundSpeedText
                        font.bold: true
                        font.pointSize: _dataBox._fontSize
                        color: "white"
                    }
                }
            }
        }
    }

    //**************************************************************************************************
    // INSTRUMENTO DE ATITUDE/BÚSSOLA (substituto comum do QGCInstrumentWidget)
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
        id: gimbalHeading
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

            // Câmera no lugar do ponteiro: heading do veículo + yaw relativo do gimbal
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

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.35
                height: parent.width * 0.2
                border.color: qgcPal.text
                color: qgcPal.window
                opacity: 0.65
                z: 10

                QGCLabel {
                    text: activeVehicle ? String(_gimbal_yaw % 360) : "OFF"
                    anchors.centerIn: parent
                    color: qgcPal.text
                    font.pointSize: 12
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
