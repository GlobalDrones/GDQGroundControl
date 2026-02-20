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

/*
Depois de anos com flyview monolítico, finalmente separei algumas coisas em componentes menores. Se isso ajudar quem for mexer no código futuramente,
amém. - Russi 19/02/26
*/
Item {
    id: bottomDataArea

    property real _gasolina
    property real _motor_temp

    property var activeVehicle:QGroundControl.multiVehicleManager.activeVehicle
    property real   toolsMargin
    property bool _androidBuild

    property int _battery1Index: 0
    property int _battery2Index: 0
    property int _gasolineIndex: 1
    property int _generatorIndex: 2

    property bool _selected_rotor_1
    property bool _selected_rotor_2
    property bool _selected_rotor_3
    property bool _selected_rotor_4
    property bool _selected_rotor_5
    property bool _selected_rotor_6

    property real medAceleracaoRotor1
    property real medAceleracaoRotor2
    property real medAceleracaoRotor3
    property real medAceleracaoRotor4
    property real medAceleracaoRotor5
    property real medAceleracaoRotor6

    Binding{
        target: bottomDataArea
        property: "_gasolina"
        value: {
            if (!activeVehicle) return 0
            if (activeVehicle.batteries.count <= 0) return 0
            return activeVehicle.batteries.get(_gasolineIndex).percentRemaining.value
        }
    }

    Binding{
        target: bottomDataArea
        property: "_motor_temp"
        value:{
        if (!activeVehicle) return 0
        if (activeVehicle.batteries.count <= 0) return 0
        return activeVehicle.gd60_Sensor1.rawValue.toFixed(0)
        }
    }

    property string batteryVoltageText: ""
    Binding {
        target: bottomDataArea
        property: "batteryVoltageText"
        value: {
            if (!activeVehicle) return "Battery Voltage: "
            if (activeVehicle.batteries.count <= 0) return "Battery Voltage: "

            return "Battery Voltage: " +
                   activeVehicle.batteries.get(0).voltage.rawValue.toFixed(1) + "V"
        }
    }

    property string batteryCurrentText: ""
    Binding {
        target: bottomDataArea
        property: "batteryCurrentText"
        value: {
            if (!activeVehicle) return "Battery Current:"
            if (activeVehicle.batteries.count <= 0) return "Battery Current:"

            return "Battery Current: " +
                   activeVehicle.batteries.get(0).current.rawValue.toFixed(1) + "A"
        }
    }

    property string generatorCurrentText: ""
    Binding {
        target: bottomDataArea
        property: "generatorCurrentText"
        value: {
            if (!activeVehicle) return "Generator Current:"
            if (activeVehicle.batteries.count <= 0) return "Generator Current:"

            return "Generator Current: " +
                   activeVehicle.batteries.get(2).current.rawValue.toFixed(1) + "A"
        }
    }

    property string groundSpeedText:""
    Binding {
        target: bottomDataArea
        property: "groundSpeedText"
        value: {
            if (!activeVehicle) return "Ground Speed:"
            if (activeVehicle.batteries.count <= 0) return "Ground Speed:"

            return "Ground Speed: " +
                        activeVehicle.groundSpeed.value.toFixed(1)+"m/s"
        }
    }

    property string altAMSLText: ""
    Binding {
        target: bottomDataArea
        property: "altAMSLText"
        value: {
            if (!activeVehicle) return "Altitude AMSL:"
            if (activeVehicle.batteries.count <= 0) return "Altitude AMSL:"

            return "Altitude AMSL: " +
                       activeVehicle.altitudeAMSL.value.toFixed(1)+"m"
        }
    }

    property string flightTimeText: ""
    Binding {
        target: bottomDataArea
        property: "flightTimeText"
        value: {
            if (!activeVehicle) return "Flighttime:"
            if (activeVehicle.batteries.count <= 0) return "Altitude AMSL:"

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


    //**************************************************************************************************
    // BACKGROUND
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

    QGCColoredImage {
        id: motorTemperatureInformationIcon
        anchors.top: parent.top
        anchors.left: textBoxGasolinePercentage.right
        anchors.leftMargin: toolsMargin * 2
        anchors.topMargin: toolsMargin * 2

        width: height
        height: parent.height * 2/3

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

        visible: _androidBuild ? false : motorTempMouseArea.containsMouse
        color: "black"
        border.width: 1
        border.color: "lightgray"
    }

    MouseArea {
        id: motorTempMouseArea
        anchors.fill: motorTemperatureInformationIcon
        hoverEnabled: true
        property bool tapped: false

        onPressed: {
                if (_androidBuild) {
                    tapped = !tapped
                    textBoxMotorTempInfo.visible = tapped
                }
            }

            onContainsMouseChanged: {
                if (!_androidBuild) {
                    textBoxMotorTempInfo.visible = containsMouse
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
            text: activeVehicle ?
                  activeVehicle._GD_GeneratorRPM.rawValue.toFixed(0)
                  : ""
            font.bold: true
            font.pixelSize: 20
        }
    }


    //**************************************************************************************************
    // ROTORS AREA
    //**************************************************************************************************

    Rectangle {
        id: rotorsTempArea
        anchors.top: parent.top
        anchors.left: motorTemperatureInformationIcon.right
        anchors.margins: toolsMargin * 1.5

        width: height * 2
        height: parent.height * 2 / 3
        color: "black"

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: 2
            border.color: "lightgray"
            z: parent.z+1000
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
                    if(index === 0 && _selected_rotor_1) return "yellow"
                    if(index === 1 && _selected_rotor_2) return "yellow"
                    if(index === 2 && _selected_rotor_3) return "yellow"
                    if(index === 3 && _selected_rotor_4) return "yellow"
                    if(index === 4 && _selected_rotor_5) return "yellow"
                    if(index === 5 && _selected_rotor_6) return "yellow"
                    return "black"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onContainsMouseChanged: {
                        if(index === 0) _selected_rotor_1 = !_selected_rotor_1
                        else if(index === 1) _selected_rotor_2 = !_selected_rotor_2
                        else if(index === 2) _selected_rotor_3 = !_selected_rotor_3
                        else if(index === 3) _selected_rotor_4 = !_selected_rotor_4
                        else if(index === 4) _selected_rotor_5 = !_selected_rotor_5
                        else if(index === 5) _selected_rotor_6 = !_selected_rotor_6
                    }
                }
            }
        }
    }


    //**************************************************************************************************
    // DATA BOX
    //**************************************************************************************************

    Item {
                            id: _dataBox
                            height: parent.height * 2/3
                            width: parent.width*0.45
                            anchors.top: parent.top
                            anchors.left: rotorsTempArea.right
                            anchors.margins: toolsMargin * 1.5
                            property int _borderWidth: 2
                            property int _fontSize: 10//_androidBuild ?  15 : 20

                            // JavaScript function to format numbers with leading zeros
                            // (You can place this function elsewhere, like in a separate .js file, for reusability)
                            function formatNumber(value, desiredLength) {
                                if (!value)return "";
                                else return value.toString().padStart(desiredLength, '0');
                            }

                            Column {
                                width: parent.width
                                height: parent.height

                                Row {
                                    width: parent.width
                                    height: parent.height / 2

                                    // First row of rectangles
                                    Rectangle {
                                        width: parent.width/3
                                        height: parent.height
                                        color: "transparent"
                                        border.width: _borderWidth
                                        border.color:"white"
                                        Text {
                                            id: text1
                                            anchors.centerIn: parent
                                            // Assuming data is 1234, and you want 5 total digits (one leading zero)
                                            text: batteryVoltageText
                                            font.bold: true
                                            font.pointSize: _dataBox._fontSize
                                            color: "white"
                                        }
                                    }
                                    Rectangle {
                                        width: parent.width/3
                                        height: parent.height
                                        color: "transparent"
                                        border.width: _borderWidth
                                        border.color:"white"

                                        Text {
                                            anchors.centerIn: parent
                                            text: generatorCurrentText
                                            font.bold: true
                                            font.pointSize: _dataBox._fontSize
                                            color: "white"
                                        }

                                    }
                                    Rectangle {
                                        width: parent.width/3
                                        height: parent.height
                                        color: "transparent"
                                        border.width: _borderWidth
                                        border.color:"white"
                                        Text {
                                            anchors.centerIn: parent
                                            text: flightTimeText
                                            //text: "Flightime: " + _flightTime
                                            font.bold: true
                                            font.pointSize: _dataBox._fontSize
                                            color: "white"
                                        }
                                    }
                                }

                                Row {
                                    width: parent.width
                                    height: parent.height / 2

                                    // Second row of rectangles
                                    Rectangle {
                                        width: parent.width/3
                                        height: parent.height
                                        color: "transparent"
                                        border.width: _borderWidth
                                        border.color:"white"
                                        Text {
                                            anchors.centerIn: parent
                                            text: batteryCurrentText
                                            font.bold: true
                                            font.pointSize: _dataBox._fontSize
                                            color: "white"
                                        }
                                    }
                                    Rectangle {
                                        width: parent.width/3
                                        height: parent.height
                                        color: "transparent"
                                        border.width: _borderWidth
                                        border.color:"white"
                                        Text {
                                            anchors.centerIn: parent
                                            text: groundSpeedText
                                            font.bold: true
                                            font.pointSize: _dataBox._fontSize
                                            color: "white"
                                        }
                                    }
                                    Rectangle {
                                        width: parent.width/3
                                        height: parent.height
                                        color: "transparent"
                                        border.width: _borderWidth
                                        border.color:"white"
                                        Text {
                                            anchors.centerIn: parent
                                            text: altAMSLText
                                            font.bold: true
                                            font.pointSize: _dataBox._fontSize
                                            color: "white"
                                        }
                                    }
                                }
                            }
                        }


    //**************************************************************************************************
    // INSTRUMENT
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
}
