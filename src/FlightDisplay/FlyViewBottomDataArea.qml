import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.Vehicle 1.0

/*
    UI do GD30 também foi fragmentada em arquivos menores para organizar melhor.
    -Russi  17/03/2026
*/
Item {
    id: bottomDataArea

    property real toolsMargin
    property bool _androidBuild
    property var  _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    property real battery1Pct: 0
    property real battery1Voltage: 0
    property real battery1Current: 0

    property real gasolinePct: 0
    property real generatorCurrent: 0

    property real satCount: 0
    property real satPDOP: 0

    property real motorTemp: 0

    property bool flagAlertaGerador: false
    property bool _GD60: false

    // rotores
    property bool _selected_rotor_1
    property bool _selected_rotor_2
    property bool _selected_rotor_3
    property bool _selected_rotor_4
    property bool _selected_rotor_5
    property bool _selected_rotor_6

    Rectangle {
        id: gradientBar
        anchors.fill: parent

        gradient: Gradient {
            GradientStop { position: 0.7; color:  qgcPal.toolbarBackground} // Top color
            GradientStop { position: 1.0; color:  toolbar._mainStatusBGColor} // Bottom color
        }
    }

    QGCColoredImage {
        id: batteryPercentageIcon_1
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.margins:    _toolsMargin
        width:              height
        height:             parent.height*2/3
        source:             "/qmlimages/Battery.svg"
        fillMode:           Image.PreserveAspectFit
        color:              "white"
        visible: true
    }

    Rectangle{
        id: batteryPercentageBar_1
        anchors.top: batteryPercentageIcon_1.top
        anchors.left: batteryPercentageIcon_1.left
        //anchors.margins: _toolsMargin
        width: batteryPercentageIcon_1.width
        height: batteryPercentageIcon_1.height
        color: "transparent"//batMouseArea.containsMouse? "green": "red"
        visible: false
        Rectangle{
            y: parent.height*0.1
            anchors.horizontalCenter: parent.horizontalCenter
            //anchors.left: parent.left
            width: parent.width/2
            height: parent.height*0.85 //fixo pra não ultrapassar o desenho
            color: (_pct_bateria_1) > 50 ? "green" : ((_pct_bateria_1) > 30 ? "orange" : "red") //cor dinamica de acordo com o _pct_bateria_1
        }
        Rectangle{ //BARRA DE ALTURA DINAMICA PRA INDICAR O NÍVEL DE bateria -> HEIGHT = 1-bateria%

            anchors.horizontalCenter: parent.horizontalCenter
            //anchors.left: parent.left
            width: parent.width/2
            height: parent.height*(0.15 + 0.85*(1-_pct_bateria_1/100) )// bateria | dinamico de acordo com 1-(% bateria). cor há de ser dinamica também
            color: qgcPal.toolbarBackground
        }

    }

    OpacityMask{
        anchors.fill: batteryPercentageBar_1
        source: batteryPercentageBar_1
        maskSource: batteryPercentageIcon_1
        invert: true
        MouseArea{
            id: batMouseArea_1
            anchors.fill: parent
            hoverEnabled : true

        }
    }
    Rectangle{
        id: textBoxBatteryInfo_1
        anchors.verticalCenter: batteryPercentageIcon_1 .verticalCenter
        //anchors.horizontalCenter: batteryPercentageIcon_1.horizontalCenter
        anchors.left: batteryPercentageIcon_1.right
        anchors.rightMargin: _toolsMargin
        height: batteryPercentageIcon_1.height*0.7
        width: batteryPercentageIcon_1.width*0.7
        visible: true//batMouseArea_1.containsMouse? true: false
        color: "transparent"// desktop version "black"
        border.width: 0
        border.color: "transparent"// desktop version "lightgray"
        Component.onCompleted: gasolineIconLoader.active = true


        ColumnLayout {
            id:                     batteryInfoColumn_1
            //anchors.top: textBoxBatteryInfo_1.top
            //anchors.horizontalCenter: textBoxBatteryInfo_1.horizontalCenter
            anchors.fill:parent
            spacing:                0
            visible: true//textBoxBatteryInfo_1.visible

            Text {
                id: textBoxBatteryInfo_1PCT
                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "White"
                text:                   _pct_bateria_1 > 9? _pct_bateria_1+"%": "0"+_pct_bateria_1+"%"
                //font.pixelSize:       _androidBuild ?  21 : 21//ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                visible: textBoxBatteryInfo_1.visible
                font.bold: true
            }
            Text {
                id: textBoxBatteryInfo_1TENSION
                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "White"
                text:                   _tensao_bateria_1 + " V"
                //font.pixelSize:         _androidBuild ?  21 : 21///ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                visible: textBoxBatteryInfo_1.visible
                font.bold: true
            }
            Text {
                id: textBoxBatteryInfo_1CURRENT
                Layout.alignment:       Text.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  "White"
                text:                   _current_bateria_1 + " A"
                //font.pixelSize:         _androidBuild ?  21 : 21///ScreenTools.smallFontPixelHeight
                font.pointSize: 14
                visible: textBoxBatteryInfo_1.visible
                font.bold: true
            }

        }
    }


    //gasolina
    Loader {
        id: gasolineIconLoader
        anchors.top: parent.top
        anchors.left: textBoxBatteryInfo_1.right
        anchors.rightMargin: _toolsMargin
        anchors.leftMargin: _toolsMargin*4
        anchors.topMargin: _toolsMargin
        asynchronous: false
        width: height
        height: parent.height * 2 / 3
        active: false  // set true when you want to load it
        visible: true


        sourceComponent: Component {
            QGCColoredImage {
                id: gasolinePercentageIcon
                anchors.fill: parent
                anchors.margins: 0
                source: "/qmlimages/GasCan.svg"
                fillMode: Image.PreserveAspectFit
                color:  _gasolina > 50 ? "green" : (_gasolina > 20 ? "orange" : "red")
                visible: true
            }
        }
    }

    DropShadow {
        anchors.fill: gasolineIconLoader
        source: gasolineIconLoader.item
        color: "#80000000" // Semi-transparent black shadow
        radius: 8
        samples:17
        spread: 0
        verticalOffset: 5
        horizontalOffset: 5
    }

    Rectangle{
        id: textBoxGasolinePercentage
        anchors.verticalCenter: gasolineIconLoader.verticalCenter
        anchors.horizontalCenter: gasolineIconLoader.horizontalCenter
        height: gasolineIconLoader.height/3
        width: gasolineIconLoader.width
        visible: visible//gasMouseArea.containsMouse? true: false
        color: "black"
        border.width: 1
        border.color: "lightgray"

    }
    Text{
        anchors.fill: textBoxGasolinePercentage
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: _gasolina + "%"
        font.bold: true
        color: "white"
        visible: textBoxGasolinePercentage.visible
    }




    //operação do gerador (pode ser pop-up por que é fudido de importante?) incluir pop-up/cor dinamica/etc
    QGCColoredImage {
        id: generatorFunctionalityIcon
        anchors.top:        parent.top
        anchors.left:       gasolineIconLoader.right
        anchors.leftMargin: _toolsMargin*2
        anchors.topMargin:  _toolsMargin*2
        width:              height
        height:             parent.height*2/3
        source:             "/qmlimages/Generator.svg"
        fillMode:           Image.PreserveAspectFit
        color:              !flagAlertaGerador ? "white" : "orange" //vai receber o retorno da função. Ou vai estar verde ou vai estar vermelho/laranja. Sem rolo

    }
    DropShadow {
        anchors.fill: generatorFunctionalityIcon
        source: generatorFunctionalityIcon
        color: "#80000000" // Semi-transparent black shadow
        radius: 8
        samples:17
        spread: 0
        verticalOffset: 5
        horizontalOffset: 5
    }

    OpacityMask{
        anchors.fill: generatorFunctionalityIcon
        source: generatorFunctionalityIcon
        maskSource: generatorFunctionalityIcon
        MouseArea{
            id: generatorMouseArea
            anchors.fill: parent
            hoverEnabled : true

        }
    }


    Rectangle{
        id: textBoxGeneratorInfo
        anchors.verticalCenter: generatorFunctionalityIcon.verticalCenter
        anchors.horizontalCenter: generatorFunctionalityIcon.horizontalCenter
        height: generatorFunctionalityIcon.height/2
        width: generatorFunctionalityIcon.width
        visible: true//generatorMouseArea.containsMouse? true: false
        color: "black"
        border.width: 1
        border.color: "lightgray"
    }
    ColumnLayout {
        id:                     generatorInfoColumn
        anchors.fill: textBoxGeneratorInfo
        spacing:                0
        visible: textBoxGeneratorInfo.visible


        Text {
            Layout.alignment:       Text.AlignHCenter
            verticalAlignment:      Text.AlignVCenter
            color:                  "White"
            text:                   _current_generator + "A"
            font.pointSize: 12
            font.bold: true
            //font.pointSize:         ScreenTools.mediumFontPixelHeight
        }

    }



    //satelite https://forest-gis.com/2018/01/acuracia-gps-o-que-sao-pdop-hdop-gdop-multi-caminho-e-outros.html/?srsltid=AfmBOorX7DD9JggA1vLTP2DuhOK44T28jHasCbLA0nv5nSnLX7irYLlW
    //activeVehicle.gps.count.rawValue (NUM SATELITES); _activeVehicle.gps.hdop.rawValue (HDOP); globals.activeVehicle.gps.lock.rawValue (PDOP)
    QGCColoredImage {
        id: satteliteInformationIcon
        anchors.top:        parent.top
        anchors.left:       _GD60? generatorFunctionalityIcon.right :generatorFunctionalityIcon.right
        anchors.leftMargin: _toolsMargin
        anchors.topMargin:  _toolsMargin*2
        width:              height
        height:             parent.height*2/3
        source:             "/qmlimages/Gps.svg"
        fillMode:           Image.PreserveAspectFit
        color:              _satPDOP >= 2 && _satCount >=6 ? "green": "orange"
    }
    DropShadow {
        anchors.fill: satteliteInformationIcon
        source: satteliteInformationIcon
        color: "#80000000" // Semi-transparent black shadow
        radius: 8
        samples:17
        spread: 0
        verticalOffset: 5
        horizontalOffset: 5
    }
    OpacityMask{
        anchors.fill: satteliteInformationIcon
        source: satteliteInformationIcon
        maskSource: satteliteInformationIcon
        MouseArea{
            id: satMouseArea
            anchors.fill: parent
            hoverEnabled : true

        }
    }
    Rectangle{
        id: textBoxSatteliteInfo
        anchors.verticalCenter: satteliteInformationIcon.verticalCenter
        //anchors.horizontalCenter: satteliteInformationIcon.horizontalCenter
        anchors.left: satteliteInformationIcon.right
        anchors.leftMargin: _toolsMargin
        anchors.rightMargin: _toolsMargin
        height: satteliteInformationIcon.height*0.7
        width: satteliteInformationIcon.width
        visible: true//satMouseArea.containsMouse? true: false
        color: "transparent" // desktop "black"
        border.width: 0// 1
        border.color: "transparent"// desktop "lightgray"
    }
    ColumnLayout {
        id:                     satteliteInfoColumn
        anchors.fill: textBoxSatteliteInfo
        spacing:                0
        visible: textBoxSatteliteInfo.visible


        Text {
            Layout.alignment:       Text.AlignHCenter
            verticalAlignment:      Text.AlignVCenter
            color:                  "White"
            text:                   "Count: " + _satCount
            font.bold: true
            //font.pixelSize:         _androidBuild ?  26 : 24
            font.pointSize: 15
        }
        Text {
            Layout.alignment:       Text.AlignHCenter
            verticalAlignment:      Text.AlignVCenter
            color:                  "White"
            text:                   "PDOP: "+ _satPDOP
            font.bold: true
            //font.pixelSize:         _androidBuild ?  26 : 24
            font.pointSize: 15
            //font.pointSize:         ScreenTools.mediumFontPixelHeight
        }

    }

    //enlace
    QGCColoredImage {
        id: rcInformationIcon
        anchors.top:        parent.top
        anchors.left:       textBoxSatteliteInfo.right
        anchors.leftMargin: _toolsMargin*3
        anchors.topMargin:  _toolsMargin*2
        width:              height
        height:             parent.height*2/3
        source:             "/qmlimages/RC.svg"
        fillMode:           Image.PreserveAspectFit
        color:           _activeVehicle.rcRSSI.valueOf() >= 60 ? "green" : (_activeVehicle.rcRSSI.valueOf()>=30? "yellow": (_activeVehicle.rcRSSI.valueOf() >= 20 ? "orange":"red"))
        visible: true

        MouseArea{
            id: rcMouseArea
            anchors.fill: parent
            hoverEnabled : true
            onClicked: {
                if (_androidBuild) {
                    textBoxRCInfo.visible = !textBoxRCInfo.visible;
                }
            }
        }
    }


    Rectangle{
        id: textBoxRCInfo
        anchors.verticalCenter: rcInformationIcon.verticalCenter
        anchors.horizontalCenter: rcInformationIcon.horizontalCenter
        height: satteliteInformationIcon.height*0.7
        width: satteliteInformationIcon.width*0.8
        visible: _androidBuild ? false : rcMouseArea.containsMouse
        color: "black"
        border.width: 1
        border.color: "lightgray"
    }
    ColumnLayout {
        id:                     rcInfoColumn
        anchors.fill: textBoxRCInfo
        //anchors.rightMargin: _toolsMargin*2
        spacing:                0
        visible: textBoxRCInfo.visible

        Text {
            Layout.alignment:       Text.AlignHCenter
            verticalAlignment:      Text.AlignVCenter
            color:                  "White"
            text:                   _activeVehicle.rcRSSI.toString()+"%" /*_activeVehicle.rcRSSI.toString() +"%"*/ /*_rcQuality + "%"*/
            font.bold: true
            //font.pointSize:         ScreenTools.mediumFontPixelHeight
        }
    }


    //Temperatura Gerador
    QGCColoredImage {
        id: motorTemperatureInformationIcon
        anchors.top: parent.top
        anchors.left: rcInformationIcon.right
        anchors.leftMargin: _toolsMargin * 2   // Adjust this for desired spacing
        anchors.topMargin: _toolsMargin * 2
        width: height
        height: parent.height * 2/3
        source: "/qmlimages/MotorTemp.svg"
        fillMode: Image.PreserveAspectFit
        color: "white"
    }
    QGCColoredImage {
        id: motorTemperatureInformationIcon2
        anchors.top: parent.top
        anchors.left: rcInformationIcon.right
        anchors.leftMargin: _toolsMargin * 2  // Slight spacing between both temp icons
        anchors.topMargin: _toolsMargin * 2
        width: height
        height: parent.height * 2/3
        source: "/qmlimages/MotorTermometer.png"
        fillMode: Image.PreserveAspectFit
        color: _motor_temp > 110 ? (_motor_temp > 150 ? (_motor_temp >= 200 ? "red" : "orange") : "yellow") : "white"
    }
    Rectangle {
        id: textBoxMotorTempInfo

        anchors.verticalCenter: motorTemperatureInformationIcon.verticalCenter
        anchors.left: motorTemperatureInformationIcon.right   // 🔥 MUITO IMPORTANTE
        anchors.leftMargin: 10

        height: motorTemperatureInformationIcon.height*1.2
        width: motorTemperatureInformationIcon.width*1.5

        visible: true
        color: "black"
        border.width: 1
        border.color: "lightgray"

        Column {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: _toolsMargin
                spacing: 6

                Text {
                    color: "white"
                    font.bold: true
                    font.pixelSize: 15
                    text: (_activeVehicle && _activeVehicle._gd60_Sensor2Fact)
                          ? "T1: " + _activeVehicle._gd60_Sensor2Fact.rawValue + "°C"
                          : "T1: --"
                }

                Text {
                    color: "white"
                    font.bold: true
                    font.pixelSize: 15
                    text: (_activeVehicle && _activeVehicle._gd60_Sensor3Fact)
                          ? "T2: " + _activeVehicle._gd60_Sensor3Fact.rawValue + "°C"
                          : "T2: --"
                }

                Text {
                    color: "white"
                    font.bold: true
                    font.pixelSize: 15
                    text: (_activeVehicle && _activeVehicle._gd60_Sensor1Fact)
                          ? "RPM: " + _activeVehicle._gd60_Sensor1Fact.rawValue
                          : "RPM: --"
                }
            }
    }



    //Temperatura Rotores
    QGCColoredImage {
        id: rotorAccelerationInformationIcon
        anchors.top:        parent.top
        anchors.left:       textBoxMotorTempInfo.right
        anchors.leftMargin: _toolsMargin
        anchors.topMargin:  _toolsMargin*2
        width:              height
        height:             parent.height*2/3
        source:             "/qmlimages/rotorsAccell.png"
        fillMode:           Image.PreserveAspectFit
        color:              "white"
        visible: !_GD60? true:false

    }
    Rectangle {
        id: rotorsTempArea
        anchors.top: parent.top
        anchors.left: _GD60? motorTempInfoColumn.right : rotorAccelerationInformationIcon.right
        anchors.margins: _toolsMargin * 1.4
        width: height * 2
        height: rotorAccelerationInformationIcon.height
        color: "black" // Background color

        // Borda com aparência de aço
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: 2
            z: parent.z+13
            border.color: "lightgray" // Cor base da borda
        }
        Rectangle {
            anchors.fill: parent
            z: -1
            color: "black"
            opacity: 0.3
            scale: 1.05
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Modelo dinâmico com tensões das células
        ListModel {
            id: accellRotorModel
        }

        // Popula o modelo com valores dinamicamente
        Component.onCompleted: {
            accellRotorModel.append({ aceleracao: 0 });
            accellRotorModel.append({ aceleracao: 0 });
            accellRotorModel.append({ aceleracao: 0 });
            accellRotorModel.append({ aceleracao: 0 });
            accellRotorModel.append({ aceleracao: 0 });
            accellRotorModel.append({ aceleracao: 0 });

        }

        Timer{//Atualiza os valores periodicamente [TODO: mudar interval depois]
            interval: 100; running: true; repeat: true
            onTriggered: {
                accellRotorModel.set(0, { aceleracao: _activeVehicle._GD_RPM1.rawValue.toFixed(0)/3500 });
                accellRotorModel.set(1, { aceleracao: _activeVehicle._GD_RPM2.rawValue.toFixed(0)/3500 });
                accellRotorModel.set(2, { aceleracao: _activeVehicle._GD_RPM3.rawValue.toFixed(0)/3500 });
                accellRotorModel.set(3, { aceleracao: _activeVehicle._GD_RPM4.rawValue.toFixed(0)/3500 });
                accellRotorModel.set(4, { aceleracao: _activeVehicle._GD_RPM5.rawValue.toFixed(0)/3500 });
                accellRotorModel.set(5, { aceleracao: _activeVehicle._GD_RPM6.rawValue.toFixed(0)/3500 });
            }
        }

        Repeater {
            model: accellRotorModel

            Rectangle {
                width: _GD60? parent.width /4 : parent.width / 6
                height: model.aceleracao* parent.height // Altura proporcional à aceleracao
                x: _GD60? index * parent.width / 4 : index * parent.width / 6 // Posiciona horizontalmente
                anchors.bottom: parent.bottom
                z: parent.z + 10
                color: "green"
                border.color: {
                    if(index == 0 && _selected_rotor_1) return "yellow"
                    else if (index == 1 && _selected_rotor_2) return "yellow"
                    else if (index == 2 && _selected_rotor_3) return "yellow"
                    else if (index == 3 && _selected_rotor_4) return "yellow"
                    else if (index == 4 && _selected_rotor_5) return "yellow"
                    else if (index == 5 && _selected_rotor_6) return "yellow"
                    else return "black"
                }
                border.width: 3//index === 0 && motor1_selected ? 3 : 1
                MouseArea { // Torna a barra interativa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        console.log("Célula", index + 1, "tensão:", model.tensao);
                        console.log(_activeVehicle)
                        console.log(_activeVehicle.batteries.count)
                        console.log(_activeVehicle.batteries.get(0).percentRemaining.valueString)

                    }

                    onContainsMouseChanged: {
                        if(!_GD60){
                            if(index == 0){_selected_rotor_1 = !_selected_rotor_1 }
                            else if(index == 1){_selected_rotor_2 = !_selected_rotor_2 }
                            else if(index == 2){_selected_rotor_3 = !_selected_rotor_3 }
                            else if(index == 3){_selected_rotor_4 = !_selected_rotor_4 }
                            else if(index == 4){_selected_rotor_5 = !_selected_rotor_5 }
                            else if(index == 5){_selected_rotor_6 = !_selected_rotor_6 }
                        }
                    }
                }

            }



        }

        Repeater{
            model: accellRotorModel
            Rectangle{
                width: parent.width/6
                height: parent.height/20
                y: {
                    if(index == 0) return parent.height*((medAceleracaoRotor1)/4000)
                    else if (index == 1) return parent.height*((medAceleracaoRotor2)/4000)
                    else if (index == 2) return parent.height*((medAceleracaoRotor3)/4000)
                    else if (index == 3) return parent.height*((medAceleracaoRotor4)/4000)
                    else if (index == 4) return parent.height*((medAceleracaoRotor5)/4000)
                    else if (index == 5) return parent.height*((medAceleracaoRotor6)/4000)
                }
                x: index*parent.width/6
                z:1000
                color: "white"
                border.color:"black"
                border.width:0.5
                visible: false
            }
        }

    }
}

