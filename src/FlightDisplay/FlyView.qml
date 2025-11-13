/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

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


//GD25/60
/*Item {
    id: _root

    property bool _GD60: true

    // These should only be used by MainRootWindow
    property var planController:    _planController
    property var guidedController:  _guidedController

    // Properties of UTM adapter
    property bool utmspSendActTrigger: false

    PlanMasterController {
        id:                     _planController
        flyView:                true
        Component.onCompleted:  start()
    }

    property bool   _mainWindowIsMap:       mapControl.pipState.state === mapControl.pipState.fullState
    property bool   _isFullWindowItemDark:  _mainWindowIsMap ? mapControl.isSatelliteMap : true
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _missionController:     _planController.missionController
    property var    _geoFenceController:    _planController.geoFenceController
    property var    _rallyPointController:  _planController.rallyPointController
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property var    _guidedController:      guidedActionsController
    property var    _guidedActionList:      guidedActionList
    property var    _guidedValueSlider:     guidedValueSlider
    property var    _widgetLayer:           widgetLayer
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property var    _mapControl:            mapControl

    property real  mainViewHeight: _GD60? parent.height*0.845:parent.height*5/6
    property real  mainViewWidth : parent.width - (parent.height - mainViewHeight) //garantir simetria
    property bool _cameraExchangeActive : false
    property var _pct_bateria_1: 0//_activeVehicle.batteries.get(0).percentRemaining.valueString + "%"
    property var _tensao_bateria_1:  0 //modificado em MainWindow
    property var _current_bateria_1:  0

    property var _pct_bateria_2: 0//_activeVehicle.batteries.get(0).percentRemaining.valueString + "%"
    property var _tensao_bateria_2:  0 //modificado em MainWindow
    property var _current_bateria_2:  0

    property var _current_generator: 0
    property var _temperature_generator: 0
    property real _gasolina: 50//_activeVehicle.batteries.get(1).voltage (P/ GD25)

    property int _battery1Index: _GD60? 0:0
    property int _battery2Index: _GD60? 1:0
    property int _gasolineIndex: _GD60? 0:1
    property int _generatorIndex: _GD60? 0:2


    property int _satCount: 0
    property int _satPDOP: 0
    property var _rcQuality: 0
    property var _rcQuality_ARRAY: []
    property var _rcQuality_mean: 0
    property real rollingRCQualitySum: 0
    property var _current_battery_ARRAY: []
    property var _current_generator_ARRAY: []
    property var _returnFunctionArray: []
    property bool flagAlertaGerador: false
    property real oldGeneratorMediamValue: 0
    property int  maxGeneratorCurrent: 120
    property var  _distanceToHome:     _activeVehicle.distanceToHome.rawValue.toFixed(2)
    property var  _distanceToWP: _activeVehicle.distanceToNextWP.rawValue.toFixed(2)
    property var _mavlinkLossPercent: _activeVehicle.mavlinkLossPercent.rawValue
    property real _groundSpeed: 0
    property real _altitudeAMSL: 0
    property int _flightTime:0

    property real _aceleracao_rotor_1: 0    //PLACEHOLDER
    property var  aceleracao_rotor_1_ARRAY: []
    property real _aceleracao_rotor_2: 0 //PLACEHOLDER
    property var  aceleracao_rotor_2_ARRAY: []
    property real _aceleracao_rotor_3: 0 //PLACEHOLDER
    property var  aceleracao_rotor_3_ARRAY: []
    property real _aceleracao_rotor_4: 0 //PLACEHOLDER
    property var  aceleracao_rotor_4_ARRAY: []
    property real _aceleracao_rotor_5: 0 //PLACEHOLDER
    property var  aceleracao_rotor_5_ARRAY: []
    property real _aceleracao_rotor_6: 0 //PLACEHOLDER
    property var  aceleracao_rotor_6_ARRAY: []


    property real medAceleracaoRotor1: 1500
    property real medAceleracaoRotor2: 1500
    property real medAceleracaoRotor3: 1500
    property real medAceleracaoRotor4: 1500
    property real medAceleracaoRotor5: 1500
    property real medAceleracaoRotor6: 1500

    property bool _selected_rotor_1: false
    property bool _selected_rotor_2: false
    property bool _selected_rotor_3: false
    property bool _selected_rotor_4: false
    property bool _selected_rotor_5: false
    property bool _selected_rotor_6: false

    property real _motor_temp: 30
    property real _motor_rpm: 3000

    property int _rpm_horizontal1: 0
    property int _rpm_horizontal2: 0

    property int horas_restantes:0
    property int minutos_restantes:0
    property int segundos_restantes:0

    property string horas_restantes_string:"00"
    property string minutos_restantes_string:"00"
    property string segundos_restantes_string:"00"

    property bool _androidBuild: (Qt.platform.os === "ios" || Qt.platform.os === "android")

    //property real _maxVel: _activeVehicle.parameterManager.


    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    property var res_x: parent.width
    property var res_y: parent.height
    property real radianPI: Math.PI/180

    property string popUp_breachAlert
    property string _breachAlertColor

    property bool canShowBreachAlert: true

    property string requestedAlerts
    property int alertCounts: 0;

    function makeAlerts() {
        var alertas = ""
        var count = 0
        if (_activeVehicle && _activeVehicle.flying) {
            if (Math.abs(_current_generator) <= 5){
                alertas += "POSSÍVEL PROBLEMA NO GERADOR\n"
                count++
            }
            if (_motor_temp >= 110){
                alertas += "POSSÍVEL SOBREAQUECIMENTO NO GERADOR\n"
                count++
            }
        }
        console.log(alertas)
        return [count,alertas]
    }



    Timer {
        id: breachCooldownTimer
        interval: 10000 // cooldown de 10 segundos
        running: true
        repeat: true
        onTriggered: {
            console.log("Temperatura: ", _motor_temp.toString())
            console.log("Gasolina: ",_gasolina)
            var result = makeAlerts();
            alertCounts = result[0];
            requestedAlerts = result[1];
            if(alertCounts > 0) generatorAlertPopup.open();
        }
    }

    function _calcCenterViewPort() {
        var newToolInset = Qt.rect(0, 0, width, height)
        toolstrip.adjustToolInset(newToolInset)
    }

    function dropMessageIndicatorTool() {
        toolbar.dropMessageIndicatorTool();
    }

    function dmsStringToRadians(input) {
        //console.log(input);
        input=input.toString()

        // Step 1: Split by commas (to separate latitude and longitude)
        const parts = input.split(',');
        //console.log(parts)
        if (parts.length < 2) {
            throw new Error("Invalid DMS input format");
        }

        // Step 2: Process each part (latitude and longitude)
        function dmsToDecimal(dmsStr) {
            // Remove extra spaces and split by the degree symbol '°', then by the minute and second symbols
            const [degMinSec, direction] = dmsStr.trim().split('  ').filter(part => part !== '');

            // Split the degree, minutes, and seconds
            const [degrees, minutes, seconds] = degMinSec.split(/°|'|"/).map(Number);

            // Calculate the decimal degrees
            let decimalDegrees = degrees + minutes / 60 + seconds / 3600;

            // Apply the sign based on direction (N/S/E/W)
            if (direction === 'S' || direction === 'W') {
                decimalDegrees *= -1;
            }

            return decimalDegrees;
        }

        // Step 3: Convert both latitude and longitude to decimal degrees
        const latDeg = dmsToDecimal(parts[0]);
        const lonDeg = dmsToDecimal(parts[1]);

        // Step 4: Convert decimal degrees to radians
        const toRadians = (deg) => deg * Math.PI / 180;

        return {
            latRadians: toRadians(latDeg),
            lonRadians: toRadians(lonDeg)
        };
    }

    function radianCoordsToCartesian(lat,lon){
        const R = 6371; //Raio arredondado da terra
        const x = R * Math.cos(lat)* Math.cos(lon);
        const y = R * Math.cos(lat)* Math.sin(lon);
        const z = R * Math.sin(lat);
        return {
            x:x,
            y:y,
            z:z
        };
    }

    function breachDetection() {
        const vehicle_lat = _activeVehicle.coordinate.latitude.valueOf()*radianPI;
        const vehicle_lon = _activeVehicle.coordinate.longitude.valueOf()*radianPI;
        var coords = radianCoordsToCartesian(vehicle_lat,vehicle_lon);

        const v_x = coords.x;
        const v_y = coords.y;
        //até aqui convertemos as coordenadas geograficas do veículo em coordenadas cartesianas
        var inside = false;
        var level_breach = -1
        //para cada poligono
        for(let i = 0; i<_geoFenceController.polygons.count.valueOf();i++){
            let polygon = _geoFenceController.polygons.get(i).path;
            let p1 = dmsStringToRadians(polygon[0]);
            p1 = radianCoordsToCartesian(p1.latRadians, p1.lonRadians)
            let p2;
            //para cada vértice
            let num_vertices = _geoFenceController.polygons.get(i).path.length;
            for(let j = 1; j<=num_vertices;j++){
                p2 = dmsStringToRadians(polygon[j % num_vertices]);
                p2 = radianCoordsToCartesian(p2.latRadians, p2.lonRadians);

                if(v_y > Math.min(p1.y,p2.y)){
                    if(v_y <= Math.max(p1.y,p2.y)){
                        if(v_x <= Math.max(p1.x,p2.x)){
                            const x_intersection = ((v_y - p1.y) * (p2.x - p1.x)) / (p2.y - p1.y) + p1.x;
                            if (p1.x === p2.x || v_x <= x_intersection) {
                                inside = !inside;
                            }
                        }
                    }
                }
                p1=p2;
            }
            if(!inside){
                level_breach = i;
            }
            else{inside = false;}
        }
        return {breach:!inside, level:level_breach};
    }

    function generatorAlert(batValues, gerValues, oldGerMed){ //TODO: incluir condicional tensão da bateria < 44V
        var medBat = 0;
        var medGer = 0;
        var flagAlert = false;
        for (var i = 0; i<20; i++){
            medBat = medBat + batValues[i];
            medGer = medGer + gerValues[i];
        }
        medBat = medBat;
        medGer = medGer;

        //Se a média da corrente do gerador esta próxima de 0, levanta flag
        if (Math.abs(medGer)<20){
            flagAlert = true;
        }
        //Se a media da corrente da bateria é maior que do gerador E a média do gerador está caindo, levanta flag
        else if (medBat > medGer && oldGerMed > medGer) {
            flagAlert = true;
            //console.log(medBat,medGer, oldGerMed)
        }

        return [flagAlert, medGer];
    }

    function accelerationPercentageToRadius(percentage){
        return percentage*0.015

    }

    Timer{
        id: propertyValuesUpdater
        interval: 100
        running: true
        repeat: true

        onTriggered:{


            if(_GD60){

                _pct_bateria_1 = ((((_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2) - 20)/5.2)*100).toFixed(2)//(((_activeVehicle.batteries.get(0).voltage.rawValue/100)/50)*10000).toFixed(2)//_activeVehicle.batteries.get(0).percentRemaining.rawValue
                _tensao_bateria_1 = (_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2)
                _current_bateria_1 = (_activeVehicle.batteries.get(_battery1Index).current.rawValue).toFixed(2)

                _pct_bateria_2 = ((((_activeVehicle.batteries.get(_battery2Index).voltage.rawValue).toFixed(2) - 47.6)/13.3)*100).toFixed(2)//(((_activeVehicle.batteries.get(0).voltage.rawValue/100)/50)*10000).toFixed(2)//_activeVehicle.batteries.get(0).percentRemaining.rawValue
                _tensao_bateria_2 = (_activeVehicle.batteries.get(_battery2Index).voltage.rawValue).toFixed(2)
                _current_bateria_2 = (_activeVehicle.batteries.get(_battery2Index).current.rawValue).toFixed(2)


            }
            else{
                _pct_bateria_1 = ((((_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2) - 42)/8.2)*100).toFixed(2)//(((_activeVehicle.batteries.get(0).voltage.rawValue/100)/50)*10000).toFixed(2)//_activeVehicle.batteries.get(0).percentRemaining.rawValue
                _tensao_bateria_1 = (_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2)
                _current_bateria_1 = (_activeVehicle.batteries.get(_battery1Index).current.rawValue).toFixed(2)
            }



            _satCount = _activeVehicle.gps.count.rawValue
            _satPDOP = _activeVehicle.gps.lock.rawValue



            // console.log(_activeVehicle.rcRSSI.valueOf())
            _gasolina = _activeVehicle.batteries.get(_gasolineIndex).percentRemaining.rawValue//_activeVehicle.batteries.index(0,1).voltage.rawValue


            _rcQuality = _activeVehicle.rcRSSI//(100 - _activeVehicle.mavlinkLossPercent.valueOf().toFixed(1)).toFixed(1)
            _rcQuality_ARRAY.push(_rcQuality)
            rollingRCQualitySum += _rcQuality
            if(_rcQuality_ARRAY.length === 10){
                _rcQuality_mean = (rollingRCQualitySum / 10).toFixed(0)
                rollingRCQualitySum -= _rcQuality_ARRAY.shift()
            }

            horas_restantes = Math.floor((7200*(_gasolina/100))/3600)
            minutos_restantes = Math.floor(((7200*(_gasolina/100))%3600)/60)
            segundos_restantes = (7200 * (_gasolina/100))%60

            _groundSpeed = _activeVehicle.groundSpeed.value.toFixed(1)
            _altitudeAMSL = _activeVehicle.altitudeAMSL.value
            _flightTime = (_activeVehicle.flightTimeCustom.value).toFixed(0)





            if(horas_restantes<10) {horas_restantes_string = "0"+horas_restantes.toString()}
            else {horas_restantes_string = horas_restantes.toString()}
            if(minutos_restantes < 10){ minutos_restantes_string = "0" +minutos_restantes.toString()}
            else {minutos_restantes_string = minutos_restantes.toString()}
            if(segundos_restantes <10) {segundos_restantes_string = "0" + segundos_restantes.toString()}
            else {segundos_restantes_string = segundos_restantes.toString()}


            var breach_val = breachDetection()
            if (breach_val.level > -1 && canShowBreachAlert) {
                console.log("VIOLACAO DE ESPAÇO AEREO NÍVEL ", breach_val.level + 1)

                if (breach_val.level === 0) {
                    popUp_breachAlert = "Invasão do Volume de Contingência!"
                    _breachAlertColor = "Yellow"
                }
                if (breach_val.level === 1) {
                    popUp_breachAlert = "Invasão do Volume de Ground Risk Buffer!"
                    _breachAlertColor = "Orange"
                }

                // breachAlertPopup.open()
                generatorAlertPopup.open()
                canShowBreachAlert = false
                breachCooldownTimer.start()
            }


            _motor_temp = _motor_temp
            if(_GD60){
                _aceleracao_rotor_1 = _aceleracao_rotor_1
                _aceleracao_rotor_2 = _aceleracao_rotor_2
                _aceleracao_rotor_3 = _aceleracao_rotor_3
                _aceleracao_rotor_4 = _aceleracao_rotor_4
            }
            else{
                aceleracao_rotor_1_ARRAY.push(_aceleracao_rotor_1)
                aceleracao_rotor_2_ARRAY.push(_aceleracao_rotor_2)
                aceleracao_rotor_3_ARRAY.push(_aceleracao_rotor_3)
                aceleracao_rotor_4_ARRAY.push(_aceleracao_rotor_4)
                aceleracao_rotor_5_ARRAY.push(_aceleracao_rotor_5)
                aceleracao_rotor_6_ARRAY.push(_aceleracao_rotor_6)
            }

            _current_generator_ARRAY.push(_current_generator)
            _current_generator = _activeVehicle.batteries.get(_generatorIndex).current.rawValue.toFixed(2)
            _current_bateria_1 = _activeVehicle.batteries.get(_battery1Index).current.rawValue.toFixed(2)


            _temperature_generator = _activeVehicle.batteries.get(_generatorIndex).temperature.rawValue.toFixed(2)


            if(_current_generator_ARRAY.length === 20){ //sabendo que recebemos um dado novo a cada 0.1 segundos
                _returnFunctionArray = generatorAlert(_current_battery_ARRAY, _current_generator_ARRAY, oldGeneratorMediamValue);//executa função
                flagAlertaGerador = _returnFunctionArray[0]; //atualiza flag geral com valor booleano retornado da função
                oldGeneratorMediamValue = _returnFunctionArray[1]; //atualiza valor de média
                _current_battery_ARRAY.shift();
                _current_generator_ARRAY.shift();
            }
            if(aceleracao_rotor_1_ARRAY.length ===20){
                var temp1 = 0;
                var temp2 = 0;
                var temp3 = 0;
                var temp4 = 0;
                var temp5 = 0;
                var temp6 = 0;
                for (var c = 0; c<20; c++){
                    temp1 = temp1 + aceleracao_rotor_1_ARRAY[c];
                    temp2 = temp2 + aceleracao_rotor_2_ARRAY[c];
                    temp3 = temp3 + aceleracao_rotor_3_ARRAY[c];
                    temp4 = temp4 + aceleracao_rotor_4_ARRAY[c];
                    temp5 = temp5 + aceleracao_rotor_5_ARRAY[c];
                    temp6 = temp6 + aceleracao_rotor_6_ARRAY[c];
                }
                medAceleracaoRotor1 = temp1/20
                medAceleracaoRotor2 = temp2/20
                medAceleracaoRotor3 = temp3/20
                medAceleracaoRotor4 = temp4/20
                medAceleracaoRotor5 = temp5/20
                medAceleracaoRotor6 = temp6/20
                //   console.log("medAccell1", medAceleracaoRotor1)

                aceleracao_rotor_1_ARRAY.shift();
                aceleracao_rotor_2_ARRAY.shift();
                aceleracao_rotor_3_ARRAY.shift();
                aceleracao_rotor_4_ARRAY.shift();
                aceleracao_rotor_5_ARRAY.shift();
                aceleracao_rotor_6_ARRAY.shift();

            }
        }
    }


    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                          BOTTOM VIEW AREA                                                        //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    Loader{
        id: bottomDataLoader
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: parent.width
        height: parent.height - mainViewHeight
        active: true  // or false if you want to delay loading
        asynchronous: true
        onLoaded: {let now = new Date();
            console.log("bottomDataArea LOADED at " + now.toLocaleTimeString());}

        sourceComponent: Component {
            id: bottomDataComponent
            Item {
                id: bottomDataArea
                anchors.bottom : parent.bottom
                anchors.left : parent.left
                width : parent.width
                height: parent.height





                Rectangle {
                    id: gradientBar
                    anchors.fill: parent

                    gradient: Gradient {
                        GradientStop { position: 0.7; color:  qgcPal.toolbarBackground} // Top color
                        GradientStop { position: 1.0; color:  toolbar._mainStatusBGColor} // Bottom color
                    }
                }


                Rectangle{
                    id: textBoxBatteryInfo_2
                    anchors.verticalCenter: batteryPercentageIcon_2 .verticalCenter
                    //anchors.horizontalCenter: batteryPercentageIcon_1.horizontalCenter
                    anchors.left: batteryPercentageIcon_2.right
                    anchors.rightMargin: _toolsMargin
                    height: batteryPercentageIcon_2.height*0.7
                    width: batteryPercentageIcon_2.width*0.7
                    visible: false//true//batMouseArea_1.containsMouse? true: false
                    color: "transparent"// desktop version "black"
                    border.width: 0
                    border.color: "transparent"// desktop version "lightgray"
                    Component.onCompleted: gasolineIconLoader.active = true


                    ColumnLayout {
                        id:                     batteryInfoColumn_2
                        anchors.top: textBoxBatteryInfo_2.top
                        anchors.horizontalCenter: textBoxBatteryInfo_2.horizontalCenter
                        spacing:                0
                        visible: _GD60//true//textBoxBatteryInfo_1.visible

                        Text {
                            id: textBoxBatteryInfo_2PCT
                            Layout.alignment:       Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _pct_bateria_2 > 9? _pct_bateria_2+"%": "0"+_pct_bateria_2+"%"
                            font.pixelSize:       _androidBuild ?  13 : 21//ScreenTools.smallFontPixelHeight
                            visible: _GD60//textBoxBatteryInfo_1.visible
                            font.bold: true
                        }
                        Text {
                            id: textBoxBatteryInfo_2TENSION
                            Layout.alignment:       Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _tensao_bateria_2 + " V"
                            font.pixelSize:         _androidBuild ?  13 : 21///ScreenTools.smallFontPixelHeight
                            visible: _GD60//textBoxBatteryInfo_1.visible
                            font.bold: true
                        }
                        Text {
                            id: textBoxBatteryInfo_2CURRENT
                            Layout.alignment:       Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _current_bateria_2 + " A"
                            font.pixelSize:         _androidBuild ?  13 : 21///ScreenTools.smallFontPixelHeight
                            visible: _GD60//textBoxBatteryInfo_1.visible
                            font.bold: true
                        }

                    }
                }

                //gasolina
                Loader {
                    id: gasolineIconLoader
                    anchors.top: parent.top
                    anchors.left:parent.left
                    anchors.rightMargin: _toolsMargin
                    anchors.leftMargin: _toolsMargin*2
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


                //Temperatura Gerador
                QGCColoredImage {
                    id: motorTemperatureInformationIcon
                    anchors.top: parent.top
                    anchors.left: textBoxGasolinePercentage.right
                    anchors.leftMargin: _toolsMargin * 2   // Adjust this for desired spacing
                    anchors.topMargin: _toolsMargin * 2
                    width: height
                    height: parent.height * 2/3
                    source: "/qmlimages/MotorTemp.svg"
                    fillMode: Image.PreserveAspectFit
                    color: "white"
                    visible: _GD60? false:true
                }
                QGCColoredImage {
                    id: motorTemperatureInformationIcon2
                    anchors.top: parent.top
                    anchors.left: textBoxGasolinePercentage.right
                    anchors.leftMargin: _toolsMargin * 2  // Slight spacing between both temp icons
                    anchors.topMargin: _toolsMargin * 2
                    width: height
                    height: parent.height * 2/3
                    source: "/qmlimages/MotorTermometer.png"
                    fillMode: Image.PreserveAspectFit
                    color: _motor_temp > 110 ? (_motor_temp > 150 ? (_motor_temp >= 200 ? "red" : "orange") : "yellow") : "white"
                    visible: motorTemperatureInformationIcon.visible
                }

                Rectangle{
                    id: textBoxMotorTempInfo
                    anchors.verticalCenter: motorTemperatureInformationIcon.verticalCenter
                    anchors.horizontalCenter: motorTemperatureInformationIcon.horizontalCenter
                    height: motorTemperatureInformationIcon.height*1.2
                    width: motorTemperatureInformationIcon.width
                    visible:  _androidBuild || motorTemperatureInformationIcon.visible ? false : motorTempMouseArea.containsMouse//motorTempMouseArea.containsMouse? true: false
                    color: "black"
                    border.width: 1
                    border.color: "lightgray"
                }
                MouseArea{
                    id:motorTempMouseArea
                    anchors.fill: motorTemperatureInformationIcon
                    hoverEnabled: !_GD60
                    onClicked: {
                        if (_androidBuild) {
                            textBoxMotorTempInfo.visible = !textBoxMotorTempInfo.visible;
                        }
                    }
                }
                ColumnLayout {
                    id: motorTempInfoColumn
                    anchors.fill: textBoxMotorTempInfo
                    spacing:                0
                    visible: textBoxMotorTempInfo.visible


                    Text {
                        Layout.alignment:       Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   _motor_temp.toString()+"°C"
                        font.bold: true
                        font.pixelSize:         (_GD60? 15:20)
                    }
                    Text {
                        Layout.alignment:       Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   "RPM: "
                        font.bold: true
                        font.pixelSize:         (_GD60? 15:20)
                    }
                    Text {
                        Layout.alignment:       Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   _motor_rpm.toFixed(0)
                        font.bold: true
                        font.pixelSize:         (_GD60? 15:20)
                    }
                    Text {
                        Layout.alignment:       Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   _motor_temp.toString()+"°C"
                        font.bold: true
                        font.pixelSize:         (_GD60? 15:20)
                        visible: _GD60? true:false
                    }

                    Text {
                        Layout.alignment:       Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   "RPM: "+_motor_rpm.toFixed(0)
                        font.bold: true
                        font.pixelSize:         (_GD60? 15:20)
                        visible: _GD60? true:false
                    }
                }



                Rectangle {
                    id: rotorsTempArea
                    anchors.top: parent.top
                    anchors.left: _GD60? textBoxGasolinePercentage.right : motorTempInfoColumn.right
                    anchors.margins: _toolsMargin * 1.5
                    width: height * 2
                    height: parent.height*2/3
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
                        if (_GD60){
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_1)/5000 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_2)/5000 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_3)/5000 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_4)/5000 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_5)/5000 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_6)/5000 });
                        }
                        else{
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_1)/3850 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_2)/3850 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_3)/3850 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_4)/3850 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_5)/3850 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_6)/3850 });
                        }

                    }

                    Timer{//Atualiza os valores periodicamente [TODO: mudar interval depois]
                        interval: 100; running: true; repeat: true
                        onTriggered: {

                            if (!_GD60){
                                accellRotorModel.set(0, { aceleracao: _aceleracao_rotor_1/3850 });
                                accellRotorModel.set(1, { aceleracao: _aceleracao_rotor_2/3850 });
                                accellRotorModel.set(2, { aceleracao: _aceleracao_rotor_3/3850 });
                                accellRotorModel.set(3, { aceleracao: _aceleracao_rotor_4/3850 });
                                accellRotorModel.set(4, { aceleracao: _aceleracao_rotor_5/3850 });
                                accellRotorModel.set(5, { aceleracao: _aceleracao_rotor_6/3850 });}
                            else{
                                accellRotorModel.set(0, { aceleracao: _aceleracao_rotor_1/5000 });
                                accellRotorModel.set(1, { aceleracao: _aceleracao_rotor_2/5000 });
                                accellRotorModel.set(2, { aceleracao: _aceleracao_rotor_3/5000 });
                                accellRotorModel.set(3, { aceleracao: _aceleracao_rotor_4/5000 });;
                            }
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

                Item{
                    id: centralRotor_1_Accell
                    anchors.left: rotorsTempArea.right
                    anchors.top: parent.top
                    anchors.margins:    _toolsMargin*2
                    height: parent.height*2/3
                    width: height
                    visible: _GD60? true:false
                    Canvas { //border of
                        anchors.fill: parent
                        id: rotor1Arc
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.strokeStyle = "gray" // Arc color
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            var radius = Math.min(width, height) / 2.5
                            ctx.arc(width / 2, height / 2, radius,  Math.PI * 0.75, Math.PI * 0.25, false) // ctx.arc(width,height,radius,start,end,anticlockwise)
                            //ctx.arc(width / 2, height / 2, 100, Math.PI * 0.75, Math.PI * 0.25, false) // Arc from 135° to 45°
                            ctx.stroke()
                            ctx.strokeStyle = "green"//"gray" // Arc color
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, radius,  Math.PI * 0.75, Math.PI * (0.75 + accelerationPercentageToRadius(_rpm_horizontal1/4000)) , false) // ctx.arc(width,height,radius,start,end,anticlockwise)
                            //ctx.arc(width / 2, height / 2, 100, Math.PI * 0.75, Math.PI * 0.25, false) // Arc from 135° to 45°
                            ctx.stroke()
                        }
                    }

                    DropShadow {
                        anchors.fill: parent
                        source: rotor1Arc
                        color: "yellow" // Semi-transparent black shadow
                        radius: 8
                        samples:17
                        spread: 0.4
                        verticalOffset: 0
                        horizontalOffset: 0
                        visible: _selected_rotor_1
                    }
                    //Component.onCompleted: requestPaint()
                    Text{
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: _rpm_horizontal1
                        color:"green"
                        font.bold: true
                    }
                }

                Item{
                    id: centralRotor_2_Accell
                    anchors.left: centralRotor_1_Accell.right
                    anchors.top: parent.top
                    anchors.margins:    _toolsMargin*2
                    height: parent.height*2/3
                    width: height
                    visible: _GD60? true:false
                    Canvas { //border of
                        anchors.fill: parent
                        id: rotor2Arc
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.strokeStyle = "gray" // Arc color
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            var radius = Math.min(width, height) / 2.5
                            ctx.arc(width / 2, height / 2, radius,  Math.PI * 0.75, Math.PI * 0.25, false) // ctx.arc(width,height,radius,start,end,anticlockwise)
                            //ctx.arc(width / 2, height / 2, 100, Math.PI * 0.75, Math.PI * 0.25, false) // Arc from 135° to 45°
                            ctx.stroke()
                            ctx.strokeStyle = "green"//"gray" // Arc color
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, radius,  Math.PI * 0.75, Math.PI * (0.75 + accelerationPercentageToRadius(_rpm_horizontal2/4000)) , false) // ctx.arc(width,height,radius,start,end,anticlockwise)
                            //ctx.arc(width / 2, height / 2, 100, Math.PI * 0.75, Math.PI * 0.25, false) // Arc from 135° to 45°
                            ctx.stroke()
                        }
                    }

                    DropShadow {
                        anchors.fill: parent
                        source: rotor2Arc
                        color: "yellow" // Semi-transparent black shadow
                        radius: 8
                        samples:17
                        spread: 0.4
                        verticalOffset: 0
                        horizontalOffset: 0
                        visible: _selected_rotor_1
                    }
                    //Component.onCompleted: requestPaint()
                    Text{
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: _rpm_horizontal2
                        color:"green"
                        font.bold: true
                    }
                }




                Item {
                    id: _dataBox
                    height: parent.height * 2/3
                    width: parent.width*0.45
                    anchors.top: parent.top
                    anchors.left: _GD60? centralRotor_2_Accell.right : rotorsTempArea.right
                    anchors.margins: _toolsMargin * 1.5
                    property int _borderWidth: 2
                    property int _fontSize: _androidBuild ?  15 : 20

                    // JavaScript function to format numbers with leading zeros
                    // (You can place this function elsewhere, like in a separate .js file, for reusability)
                    function formatNumber(value, desiredLength) {
                        return value.toString().padStart(desiredLength, '0');
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
                                    text: "Battery Voltage: " + _dataBox.formatNumber(_tensao_bateria_1, 2)+"V"
                                    font.bold: true
                                    font.pixelSize: _dataBox._fontSize
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
                                    text: "Generator Current " + _dataBox.formatNumber(_current_generator, 2)+"A"
                                    font.bold: true
                                    font.pixelSize: _dataBox._fontSize
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
                                    // Converter _flightTime (segundos) para milissegundos
                                    property var date: new Date(0, 0, 1, 0, 0, _flightTime)
                                    // Formatar e exibir o texto
                                    text: "Flightime: " + Qt.formatTime(date, "hh:mm:ss")
                                    //text: "Flightime: " + _flightTime
                                    font.bold: true
                                    font.pixelSize: _dataBox._fontSize
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
                                    text: "Battery Current " + _dataBox.formatNumber(_current_bateria_1, 2)
                                    font.bold: true
                                    font.pixelSize: _dataBox._fontSize
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
                                    text: "Ground Speed: " + _dataBox.formatNumber(_groundSpeed, 2)+"m/s"
                                    font.bold: true
                                    font.pixelSize: _dataBox._fontSize
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
                                    text: "Altitude AMSL: " + _dataBox.formatNumber(_altitudeAMSL, 2)+"m"
                                    font.bold: true
                                    font.pixelSize: _dataBox._fontSize
                                    color: "white"
                                }
                            }
                        }
                    }
                }

                Item{
                    width: parent.width*0.3
                    //height: parent.height *2/3
                    anchors.top: parent.top
                    //anchors.bottom: parent.bottom
                    anchors.left: _dataBox.right


                    Loader {
                        width:  parent.width/2
                        source: "qrc:/qml/QGCInstrumentWidget.qml"

                    }
                }

                //ESSES PRÓXIMOS 2 ITENS SÃO DO GD60. PARA COMPILAR PARA O GD60, PEGUE A VERSÃO MAIN DA BRANCH E COLOQUE _GD60: TRUE NO COMEÇO DO ARQUIVO
                // Dial Accelerometer

            }

        }
    }


    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                          LATERAL VIEW AREA                                                       //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    Loader{
        id: lateralDataLoader
        anchors.right : parent.right
        anchors.bottom : bottomDataLoader.top
        anchors.top:toolbarsize.bottom
        width : parent.width - mainViewWidth
        height: mainViewHeight
        active: active  // or false if you want to delay loading
        asynchronous: true
        onLoaded:{
            let now = new Date();
            console.log("lateralDataArea LOADED at " + now.toLocaleTimeString());
            //bottomDataLoader.active = true;
        }

        sourceComponent: Component {
            id: lateralDataComponent
            Item {
                id: lateralDataArea
                anchors.fill: parent
                property real sectionHeight: (parent.height - bottomDataLoader.height) / 6
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
                            font.pixelSize:         _androidBuild ?  15 : 24//ScreenTools.smallFontPixelHeight
                            font.bold: true
                        }
                        Text {

                            Layout.alignment:       Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   horas_restantes_string+":"+minutos_restantes_string+":"+segundos_restantes_string
                            font.pixelSize:         _androidBuild ?  15 : 24//ScreenTools.smallFontPixelHeight
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
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                        Text {

                            Layout.alignment:       Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _activeVehicle.distanceToHome.value === "NaN"? 0 : _activeVehicle.distanceToHome.value.toFixed(2)+"m"
                            font.pixelSize:         _androidBuild ?  15 : 24
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
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                        Text {

                            Layout.alignment:       Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _activeVehicle.distanceToNextWP.value == "NaN"? 0 : _activeVehicle.distanceToNextWP.value+"m"
                            font.pixelSize:         _androidBuild ?  15 : 24
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
                            color:                  "White"
                            text:                   "Alt. LIDAR"
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                        Text {

                            Layout.alignment:       Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _activeVehicle.rangeFinderDist.value.toFixed(2) + "m" //altitudeRelative.value*10)/10 + "m"
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                    }
                }

                Item{
                    id: horSpeedArea
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
                            color:                  "White"
                            text:                   "Hor. speed"
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                        Text {

                            Layout.alignment:       Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  Math.round(_activeVehicle.airSpeed.value*10)/10 < 17? "White" : "Red"
                            text:                   Math.round(_activeVehicle.airSpeed.value*10)/10 +"m/s"
                            font.pixelSize:         _androidBuild ?  15 : 24
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
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                        Text {

                            Layout.alignment:       Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   Math.round(_activeVehicle.climbRate.value*10)/10+"m/s"
                            font.pixelSize:         _androidBuild ?  15 : 24
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


                Loader {
                    id: aircraftAndRotorsLoader
                    active: false
                    asynchronous: true

                    anchors.top: parent.bottom
                    anchors.left: parent.left
                    width: parent.width
                    height: width

                    sourceComponent: Component {
                        Item {
                            width: parent.width
                            height: width

                            QGCColoredImage {
                                id: aircraftIcon
                                anchors.fill: parent
                                source: _GD60 ? "/qmlimages/GD60_lowres.png" : "/qmlimages/GD25_lowres.png"
                                fillMode: Image.PreserveAspectFit
                                color: "white"
                            }

                            QGCColoredImage {
                                id: rotor1Mask
                                anchors.fill: parent
                                source: "/qmlimages/rotor1mask_lowres.png"
                                visible:  !_GD60
                                color: "white"
                            }
                            DropShadow {
                                anchors.fill: rotor1Mask
                                source: rotor1Mask
                                color: "yellow"
                                radius: 8
                                samples: 17
                                spread: 0.4
                                verticalOffset: 0
                                horizontalOffset: 0
                                visible: _selected_rotor_1
                            }

                            QGCColoredImage {
                                id: rotor2Mask
                                anchors.fill: parent
                                source: "/qmlimages/rotor2mask_lowres.png"
                                color: "white"
                                visible:  !_GD60
                            }
                            DropShadow {
                                anchors.fill: rotor2Mask
                                source: rotor2Mask
                                color: "yellow"
                                radius: 8
                                samples: 17
                                spread: 0.4
                                verticalOffset: 0
                                horizontalOffset: 0
                                visible: _selected_rotor_2
                            }

                            QGCColoredImage {
                                id: rotor3Mask
                                anchors.fill: parent
                                source: "/qmlimages/rotor3mask_lowres.png"
                                color: "white"
                                visible:  !_GD60
                            }
                            DropShadow {
                                anchors.fill: rotor3Mask
                                source: rotor3Mask
                                color: "yellow"
                                radius: 8
                                samples: 17
                                spread: 0.4
                                verticalOffset: 0
                                horizontalOffset: 0
                                visible: _selected_rotor_3
                            }

                            QGCColoredImage {
                                id: rotor4Mask
                                anchors.fill: parent
                                source: "/qmlimages/rotor4mask_lowres.png"
                                color: "white"
                                visible:  !_GD60
                            }
                            DropShadow {
                                anchors.fill: rotor4Mask
                                source: rotor4Mask
                                color: "yellow"
                                radius: 8
                                samples: 17
                                spread: 0.4
                                verticalOffset: 0
                                horizontalOffset: 0
                                visible: _selected_rotor_4
                            }

                            QGCColoredImage {
                                id: rotor5Mask
                                anchors.fill: parent
                                source: "/qmlimages/rotor5mask_lowres.png"
                                color: "white"
                                visible:  !_GD60
                            }
                            DropShadow {
                                anchors.fill: rotor5Mask
                                source: rotor5Mask
                                color: "yellow"
                                radius: 8
                                samples: 17
                                spread: 0.4
                                verticalOffset: 0
                                horizontalOffset: 0
                                visible: _selected_rotor_5
                            }

                            QGCColoredImage {
                                id: rotor6Mask
                                anchors.fill: parent
                                source: "/qmlimages/rotor6mask_lowres.png"
                                color: "white"
                                visible:  !_GD60
                            }
                            DropShadow {
                                anchors.fill: rotor6Mask
                                source: rotor6Mask
                                color: "yellow"
                                radius: 8
                                samples: 17
                                spread: 0.4
                                verticalOffset: 0
                                horizontalOffset: 0
                                visible: _selected_rotor_6
                            }
                        }
                    }
                }

            }
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                          MAIN VIEW AREA                                                          //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    Item {
        id: mainViewArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: lateralDataLoader.left
        anchors.bottom: bottomDataLoader.top

        Component.onCompleted:{
            let now = new Date();
            console.log("mainViewArea LOADED at " + now.toLocaleTimeString());lateralDataLoader.active = true; bottomDataLoader.active = true;}

        QGCToolInsets {
            id: _toolInsets
            leftEdgeBottomInset: _pipOverlay.visible ? _pipOverlay.x + _pipOverlay.width : 0
            bottomEdgeLeftInset: _pipOverlay.visible ? parent.height - _pipOverlay.y : 0
        }

        FlyViewWidgetLayer {
            id: widgetLayer
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: guidedAltSlider.visible ? guidedAltSlider.left : parent.right
            z: _fullItemZorder + 1
            parentToolInsets: _toolInsets
            mapControl: _mapControl
            visible: !QGroundControl.videoManager.fullScreen
        }

        FlyViewCustomLayer {
            id: customOverlay
            anchors.fill: widgetLayer
            z: _fullItemZorder + 2
            parentToolInsets: widgetLayer.totalToolInsets
            mapControl: _mapControl
            visible: !QGroundControl.videoManager.fullScreen
        }

        GuidedActionsController {
            id: guidedActionsController
            missionController: _missionController
            actionList: _guidedActionList
            altitudeSlider: _guidedAltSlider
        }



        GuidedActionList {
            id: guidedActionList
            anchors.margins: _margins
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            z: QGroundControl.zOrderTopMost
            guidedController: _guidedController
        }

        //-- Altitude slider
        GuidedAltitudeSlider {
            id: guidedAltSlider
            anchors.margins: _toolsMargin
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            z: QGroundControl.zOrderTopMost
            radius: ScreenTools.defaultFontPixelWidth / 2
            width: ScreenTools.defaultFontPixelWidth * 10
            color: qgcPal.window
            visible: false
        }

        FlyViewMap {
            id: mapControl
            planMasterController: _planController
            rightPanelWidth: ScreenTools.defaultFontPixelHeight * 9
            pipMode: !_mainWindowIsMap
            toolInsets: customOverlay.totalToolInsets
            mapName: "FlightDisplayView"
        }

        FlyViewVideo {
            id: videoControl
            iconLeftMargin: widgetLayer.iconLeftMargin
        }

        QGCPipOverlay {
            id: _pipOverlay
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: _toolsMargin
            item1IsFullSettingsKey: "MainFlyWindowIsMap"
            item1: mapControl
            item2: QGroundControl.videoManager.hasVideo ? videoControl : null
            fullZOrder: _fullItemZorder
            pipZOrder: _pipItemZorder
            show: !QGroundControl.videoManager.fullScreen
                  && (videoControl.pipState.state === videoControl.pipState.pipState
                      || mapControl.pipState.state === mapControl.pipState.pipState)
        }

        Popup {
            id: breachAlertPopup
            x: (parent.width - width) / 2
            y: 10  // optional: vertical position
            width: parent.width/4
            height: 100
            modal: false
            focus: false
            background: null
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            visible: false

            Rectangle {
                anchors.fill: parent
                color: _breachAlertColor
                border.color: "black"
                visible: false

                Text {
                    anchors.centerIn: parent
                    text: popUp_breachAlert
                    font.bold: true
                    visible: false
                    // font.pixelSize: _androidBuild? 8 : 14
                }
            }
        }

        Popup {



            id: generatorAlertPopup
            x: (parent.width - width) / 2
            y: 10  // optional: vertical position
            width: parent.width/4
            height: 100
            modal: false
            focus: false
            background: null
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            visible: alertCounts>0

            Rectangle {
                anchors.fill: parent
                color: "red"
                border.color: "black"
                visible: true
                Text {
                    anchors.centerIn: parent
                    text: requestedAlerts
                    font.bold: false
                    visible: true

                     font.pixelSize: _androidBuild? 12 : 14
                }
            }
        }


        Item {
            id: cameraControlOverlay
            z: QGroundControl.zOrderTopMost
            visible: QGroundControl.videoManager.hasVideo

            property int cameraIndex: 0

            states: [
                State {
                    name: "full"
                    when: !((videoControl.pipState.state === videoControl.pipState.pipState) && (!_pipOverlay._isExpanded))
                    PropertyChanges {
                        target: cameraControlOverlay
                        anchors.top: parent.top
                        anchors.bottom: null
                        anchors.right: parent.right
                        anchors.margins: 25
                    }
                },
                State {
                    name: "hidden"
                    when: ((videoControl.pipState.state === videoControl.pipState.pipState) && (!_pipOverlay._isExpanded))
                    PropertyChanges {
                        target: cameraControlOverlay
                        visible: false
                    }
                }
            ]

            Row {
                spacing: ScreenTools.defaultFontPixelWidth
                anchors.right: parent.right
                anchors.top: parent.top

                Rectangle {
                    id: cameraTextBackground
                    color: "#80000000"
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth / 2
                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth / 2
                    height: cameraText.implicitHeight + ScreenTools.defaultFontPixelHeight
                    width: cameraText.implicitWidth + ScreenTools.defaultFontPixelWidth * 2

                    Text {
                        id: cameraText
                        anchors.centerIn: parent
                        text: {
                            if (QGroundControl.videoManager.streams.length > 0 && cameraControlOverlay.cameraIndex < QGroundControl.videoManager.streams.length) {
                                var element = QGroundControl.videoManager.streams[cameraControlOverlay.cameraIndex]
                                return element.alias ? element.alias : element.url
                            } else {
                                return "Sem câmeras"
                            }
                        }
                        color: "white"
                        font.bold: true
                    }
                }


                QGCColoredImage {
                    id: cameraButton
                    source: "/qmlimages/camera"
                    width: ScreenTools.defaultFontPixelHeight * 2
                    height: width
                    fillMode: Image.PreserveAspectFit
                    color: "white"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            _activeVehicle.overwriteRC();
                            if (QGroundControl.videoManager.streams.length > 0) {
                                cameraControlOverlay.cameraIndex = (cameraControlOverlay.cameraIndex + 1) % QGroundControl.videoManager.streams.length

                                var element = QGroundControl.videoManager.streams[cameraControlOverlay.cameraIndex]
                                if (element.ip) {
                                    QGroundControl.settingsManager.videoSettings.rtspUrl.rawValue = element.ip
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
*/

//
Item {
    id: _root

    property bool _GD60: true

    // These should only be used by MainRootWindow
    property var planController:    _planController
    property var guidedController:  _guidedController

    // Properties of UTM adapter
    property bool utmspSendActTrigger: false

    PlanMasterController {
        id:                     _planController
        flyView:                true
        Component.onCompleted:  start()
    }

    property bool   _mainWindowIsMap:       mapControl.pipState.state === mapControl.pipState.fullState
    property bool   _isFullWindowItemDark:  _mainWindowIsMap ? mapControl.isSatelliteMap : true
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _missionController:     _planController.missionController
    property var    _geoFenceController:    _planController.geoFenceController
    property var    _rallyPointController:  _planController.rallyPointController
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property var    _guidedController:      guidedActionsController
    property var    _guidedActionList:      guidedActionList
    property var    _guidedValueSlider:     guidedValueSlider
    property var    _widgetLayer:           widgetLayer
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property var    _mapControl:            mapControl

    property real  mainViewHeight: _GD60? parent.height*0.7:parent.height*5/6
    property real  mainViewWidth : parent.width - (parent.height - mainViewHeight) //garantir simetria
    property bool _cameraExchangeActive : false
    property var _pct_bateria_1: 0//_activeVehicle.batteries.get(0).percentRemaining.valueString + "%"
    property var _tensao_bateria_1:  0 //modificado em MainWindow
    property var _current_bateria_1:  0

    property var _pct_bateria_2: 0//_activeVehicle.batteries.get(0).percentRemaining.valueString + "%"
    property var _tensao_bateria_2:  0 //modificado em MainWindow
    property var _current_bateria_2:  0

    property var _current_generator: 0
    property var _temperature_generator: 0
    property real _gasolina: 50//_activeVehicle.batteries.get(1).voltage (P/ GD25)

    property int _battery1Index: _GD60? 0:0
    property int _battery2Index: _GD60? 1:0
    property int _gasolineIndex: _GD60? 0:1
    property int _generatorIndex: _GD60? 0:2


    property int _satCount: 0
    property int _satPDOP: 0
    property var _rcQuality: 0
    property var _rcQuality_ARRAY: []
    property var _rcQuality_mean: 0
    property real rollingRCQualitySum: 0
    property var _current_battery_ARRAY: []
    property var _current_generator_ARRAY: []
    property var _returnFunctionArray: []
    property bool flagAlertaGerador: false
    property real oldGeneratorMediamValue: 0
    property int  maxGeneratorCurrent: 120
    //property var  _distanceToHome:     _activeVehicle.distanceToHome.rawValue.toFixed(2)
    //property var  _distanceToWP: _activeVehicle.distanceToNextWP.rawValue.toFixed(2)
    //property var _mavlinkLossPercent: _activeVehicle.mavlinkLossPercent.rawValue
    property real _groundSpeed: 0
    property real _altitudeAMSL: 0
    property int _flightTime:0

    property real _aceleracao_rotor_1: 0    //PLACEHOLDER
    property var  aceleracao_rotor_1_ARRAY: []
    property real _aceleracao_rotor_2: 0 //PLACEHOLDER
    property var  aceleracao_rotor_2_ARRAY: []
    property real _aceleracao_rotor_3: 0 //PLACEHOLDER
    property var  aceleracao_rotor_3_ARRAY: []
    property real _aceleracao_rotor_4: 0 //PLACEHOLDER
    property var  aceleracao_rotor_4_ARRAY: []
    property real _aceleracao_rotor_5: 0 //PLACEHOLDER
    property var  aceleracao_rotor_5_ARRAY: []
    property real _aceleracao_rotor_6: 0 //PLACEHOLDER
    property var  aceleracao_rotor_6_ARRAY: []


    property real medAceleracaoRotor1: 1500
    property real medAceleracaoRotor2: 1500
    property real medAceleracaoRotor3: 1500
    property real medAceleracaoRotor4: 1500
    property real medAceleracaoRotor5: 1500
    property real medAceleracaoRotor6: 1500

    property bool _selected_rotor_1: false
    property bool _selected_rotor_2: false
    property bool _selected_rotor_3: false
    property bool _selected_rotor_4: false
    property bool _selected_rotor_5: false
    property bool _selected_rotor_6: false

    property real _motor_temp: 30
    property real _motor_rpm: 3000

    property int _rpm_horizontal1: 0
    property int _rpm_horizontal2: 0

    property int horas_restantes:0
    property int minutos_restantes:0
    property int segundos_restantes:0

    property string horas_restantes_string:"00"
    property string minutos_restantes_string:"00"
    property string segundos_restantes_string:"00"

    property bool _androidBuild: (Qt.platform.os === "ios" || Qt.platform.os === "android")

    //property real _maxVel: _activeVehicle.parameterManager.


    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    property var res_x: parent.width
    property var res_y: parent.height
    property real radianPI: Math.PI/180

    property string popUp_breachAlert
    property string _breachAlertColor

    property bool canShowBreachAlert: true

    property string requestedAlerts
    property int alertCounts: 0;
    property color hudGrey: "#33333366"

    function makeAlerts() {
        var alertas = ""
        var count = 0
        if (_activeVehicle && _activeVehicle.flying) {
            if (Math.abs(_current_generator) <= 5){
                alertas += "POSSÍVEL PROBLEMA NO GERADOR\n"
                count++
            }
            if (_motor_temp >= 110){
                alertas += "POSSÍVEL SOBREAQUECIMENTO NO GERADOR\n"
                count++
            }
        }
        console.log(alertas)
        return [count,alertas]
    }



    Timer {
        id: breachCooldownTimer
        interval: 10000 // cooldown de 10 segundos
        running: true
        repeat: true
        onTriggered: {
            console.log("Temperatura: ", _motor_temp.toString())
            console.log("Gasolina: ",_gasolina)
            var result = makeAlerts();
            alertCounts = result[0];
            requestedAlerts = result[1];
            if(alertCounts > 0) generatorAlertPopup.open();
        }
    }

    function _calcCenterViewPort() {
        var newToolInset = Qt.rect(0, 0, width, height)
        toolstrip.adjustToolInset(newToolInset)
    }

    function dropMessageIndicatorTool() {
        toolbar.dropMessageIndicatorTool();
    }

    function dmsStringToRadians(input) {
        //console.log(input);
        input=input.toString()

        // Step 1: Split by commas (to separate latitude and longitude)
        const parts = input.split(',');
        //console.log(parts)
        if (parts.length < 2) {
            throw new Error("Invalid DMS input format");
        }

        // Step 2: Process each part (latitude and longitude)
        function dmsToDecimal(dmsStr) {
            // Remove extra spaces and split by the degree symbol '°', then by the minute and second symbols
            const [degMinSec, direction] = dmsStr.trim().split('  ').filter(part => part !== '');

            // Split the degree, minutes, and seconds
            const [degrees, minutes, seconds] = degMinSec.split(/°|'|"/).map(Number);

            // Calculate the decimal degrees
            let decimalDegrees = degrees + minutes / 60 + seconds / 3600;

            // Apply the sign based on direction (N/S/E/W)
            if (direction === 'S' || direction === 'W') {
                decimalDegrees *= -1;
            }

            return decimalDegrees;
        }

        // Step 3: Convert both latitude and longitude to decimal degrees
        const latDeg = dmsToDecimal(parts[0]);
        const lonDeg = dmsToDecimal(parts[1]);

        // Step 4: Convert decimal degrees to radians
        const toRadians = (deg) => deg * Math.PI / 180;

        return {
            latRadians: toRadians(latDeg),
            lonRadians: toRadians(lonDeg)
        };
    }

    function radianCoordsToCartesian(lat,lon){
        const R = 6371; //Raio arredondado da terra
        const x = R * Math.cos(lat)* Math.cos(lon);
        const y = R * Math.cos(lat)* Math.sin(lon);
        const z = R * Math.sin(lat);
        return {
            x:x,
            y:y,
            z:z
        };
    }

    function breachDetection() {
        const vehicle_lat = _activeVehicle.coordinate.latitude.valueOf()*radianPI;
        const vehicle_lon = _activeVehicle.coordinate.longitude.valueOf()*radianPI;
        var coords = radianCoordsToCartesian(vehicle_lat,vehicle_lon);

        const v_x = coords.x;
        const v_y = coords.y;
        //até aqui convertemos as coordenadas geograficas do veículo em coordenadas cartesianas
        var inside = false;
        var level_breach = -1
        //para cada poligono
        for(let i = 0; i<_geoFenceController.polygons.count.valueOf();i++){
            let polygon = _geoFenceController.polygons.get(i).path;
            let p1 = dmsStringToRadians(polygon[0]);
            p1 = radianCoordsToCartesian(p1.latRadians, p1.lonRadians)
            let p2;
            //para cada vértice
            let num_vertices = _geoFenceController.polygons.get(i).path.length;
            for(let j = 1; j<=num_vertices;j++){
                p2 = dmsStringToRadians(polygon[j % num_vertices]);
                p2 = radianCoordsToCartesian(p2.latRadians, p2.lonRadians);

                if(v_y > Math.min(p1.y,p2.y)){
                    if(v_y <= Math.max(p1.y,p2.y)){
                        if(v_x <= Math.max(p1.x,p2.x)){
                            const x_intersection = ((v_y - p1.y) * (p2.x - p1.x)) / (p2.y - p1.y) + p1.x;
                            if (p1.x === p2.x || v_x <= x_intersection) {
                                inside = !inside;
                            }
                        }
                    }
                }
                p1=p2;
            }
            if(!inside){
                level_breach = i;
            }
            else{inside = false;}
        }
        return {breach:!inside, level:level_breach};
    }

    function generatorAlert(batValues, gerValues, oldGerMed){ //TODO: incluir condicional tensão da bateria < 44V
        var medBat = 0;
        var medGer = 0;
        var flagAlert = false;
        for (var i = 0; i<20; i++){
            medBat = medBat + batValues[i];
            medGer = medGer + gerValues[i];
        }
        medBat = medBat;
        medGer = medGer;

        //Se a média da corrente do gerador esta próxima de 0, levanta flag
        if (Math.abs(medGer)<20){
            flagAlert = true;
        }
        //Se a media da corrente da bateria é maior que do gerador E a média do gerador está caindo, levanta flag
        else if (medBat > medGer && oldGerMed > medGer) {
            flagAlert = true;
            //console.log(medBat,medGer, oldGerMed)
        }

        return [flagAlert, medGer];
    }

    function accelerationPercentageToRadius(percentage){
        return percentage*0.015

    }

    function mapValueToRadians(value, minInput, maxInput, startAngleRad, endAngleRad) {
        // 1. Garante que o valor esteja dentro dos limites da entrada
        var clampedValue = Math.min(Math.max(value, minInput), maxInput);

        // 2. Calcula a Proporção (0 a 1) do valor na escala de entrada
        var inputRange = maxInput - minInput;
        var ratio = (clampedValue - minInput) / inputRange;

        // 3. Mapeia a proporção para o intervalo de Radianos
        var arcRange = endAngleRad - startAngleRad;
        var mappedRad = startAngleRad + (ratio * arcRange);

        return mappedRad;
    }

    Timer{
        id: propertyValuesUpdater
        interval: 100
        running: true
        repeat: true

        onTriggered:{


            if(_GD60){

                _pct_bateria_1 = ((((_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2) - 20)/5.2)*100).toFixed(2)//(((_activeVehicle.batteries.get(0).voltage.rawValue/100)/50)*10000).toFixed(2)//_activeVehicle.batteries.get(0).percentRemaining.rawValue
                _tensao_bateria_1 = (_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2)
                _current_bateria_1 = (_activeVehicle.batteries.get(_battery1Index).current.rawValue).toFixed(2)

                _pct_bateria_2 = ((((_activeVehicle.batteries.get(_battery2Index).voltage.rawValue).toFixed(2) - 47.6)/13.3)*100).toFixed(2)//(((_activeVehicle.batteries.get(0).voltage.rawValue/100)/50)*10000).toFixed(2)//_activeVehicle.batteries.get(0).percentRemaining.rawValue
                _tensao_bateria_2 = (_activeVehicle.batteries.get(_battery2Index).voltage.rawValue).toFixed(2)
                _current_bateria_2 = (_activeVehicle.batteries.get(_battery2Index).current.rawValue).toFixed(2)


            }
            else{
                _pct_bateria_1 = ((((_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2) - 42)/8.2)*100).toFixed(2)//(((_activeVehicle.batteries.get(0).voltage.rawValue/100)/50)*10000).toFixed(2)//_activeVehicle.batteries.get(0).percentRemaining.rawValue
                _tensao_bateria_1 = (_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2)
                _current_bateria_1 = (_activeVehicle.batteries.get(_battery1Index).current.rawValue).toFixed(2)
            }



            _satCount = _activeVehicle.gps.count.rawValue
            _satPDOP = _activeVehicle.gps.lock.rawValue



            // console.log(_activeVehicle.rcRSSI.valueOf())
            _gasolina = _activeVehicle.batteries.get(_gasolineIndex).percentRemaining.rawValue//_activeVehicle.batteries.index(0,1).voltage.rawValue


            _rcQuality = _activeVehicle.rcRSSI//(100 - _activeVehicle.mavlinkLossPercent.valueOf().toFixed(1)).toFixed(1)
            _rcQuality_ARRAY.push(_rcQuality)
            rollingRCQualitySum += _rcQuality
            if(_rcQuality_ARRAY.length === 10){
                _rcQuality_mean = (rollingRCQualitySum / 10).toFixed(0)
                rollingRCQualitySum -= _rcQuality_ARRAY.shift()
            }

            horas_restantes = Math.floor((7200*(_gasolina/100))/3600)
            minutos_restantes = Math.floor(((7200*(_gasolina/100))%3600)/60)
            segundos_restantes = (7200 * (_gasolina/100))%60

            _groundSpeed = _activeVehicle.groundSpeed.value.toFixed(1)
            _altitudeAMSL = _activeVehicle.altitudeAMSL.value
            _flightTime = (_activeVehicle.flightTimeCustom.value).toFixed(0)





            if(horas_restantes<10) {horas_restantes_string = "0"+horas_restantes.toString()}
            else {horas_restantes_string = horas_restantes.toString()}
            if(minutos_restantes < 10){ minutos_restantes_string = "0" +minutos_restantes.toString()}
            else {minutos_restantes_string = minutos_restantes.toString()}
            if(segundos_restantes <10) {segundos_restantes_string = "0" + segundos_restantes.toString()}
            else {segundos_restantes_string = segundos_restantes.toString()}


            var breach_val = breachDetection()
            if (breach_val.level > -1 && canShowBreachAlert) {
                console.log("VIOLACAO DE ESPAÇO AEREO NÍVEL ", breach_val.level + 1)

                if (breach_val.level === 0) {
                    popUp_breachAlert = "Invasão do Volume de Contingência!"
                    _breachAlertColor = "Yellow"
                }
                if (breach_val.level === 1) {
                    popUp_breachAlert = "Invasão do Volume de Ground Risk Buffer!"
                    _breachAlertColor = "Orange"
                }

                // breachAlertPopup.open()
                generatorAlertPopup.open()
                canShowBreachAlert = false
                breachCooldownTimer.start()
            }


            _motor_temp = _motor_temp
            if(_GD60){
                _aceleracao_rotor_1 = _aceleracao_rotor_1
                _aceleracao_rotor_2 = _aceleracao_rotor_2
                _aceleracao_rotor_3 = _aceleracao_rotor_3
                _aceleracao_rotor_4 = _aceleracao_rotor_4
            }
            else{
                aceleracao_rotor_1_ARRAY.push(_aceleracao_rotor_1)
                aceleracao_rotor_2_ARRAY.push(_aceleracao_rotor_2)
                aceleracao_rotor_3_ARRAY.push(_aceleracao_rotor_3)
                aceleracao_rotor_4_ARRAY.push(_aceleracao_rotor_4)
                aceleracao_rotor_5_ARRAY.push(_aceleracao_rotor_5)
                aceleracao_rotor_6_ARRAY.push(_aceleracao_rotor_6)
            }

            _current_generator_ARRAY.push(_current_generator)
            _current_generator = _activeVehicle.batteries.get(_generatorIndex).current.rawValue.toFixed(2)
            _current_bateria_1 = _activeVehicle.batteries.get(_battery1Index).current.rawValue.toFixed(2)


            _temperature_generator = _activeVehicle.batteries.get(_generatorIndex).temperature.rawValue.toFixed(2)


            if(_current_generator_ARRAY.length === 20){ //sabendo que recebemos um dado novo a cada 0.1 segundos
                _returnFunctionArray = generatorAlert(_current_battery_ARRAY, _current_generator_ARRAY, oldGeneratorMediamValue);//executa função
                flagAlertaGerador = _returnFunctionArray[0]; //atualiza flag geral com valor booleano retornado da função
                oldGeneratorMediamValue = _returnFunctionArray[1]; //atualiza valor de média
                _current_battery_ARRAY.shift();
                _current_generator_ARRAY.shift();
            }
            if(aceleracao_rotor_1_ARRAY.length ===20){
                var temp1 = 0;
                var temp2 = 0;
                var temp3 = 0;
                var temp4 = 0;
                var temp5 = 0;
                var temp6 = 0;
                for (var c = 0; c<20; c++){
                    temp1 = temp1 + aceleracao_rotor_1_ARRAY[c];
                    temp2 = temp2 + aceleracao_rotor_2_ARRAY[c];
                    temp3 = temp3 + aceleracao_rotor_3_ARRAY[c];
                    temp4 = temp4 + aceleracao_rotor_4_ARRAY[c];
                    temp5 = temp5 + aceleracao_rotor_5_ARRAY[c];
                    temp6 = temp6 + aceleracao_rotor_6_ARRAY[c];
                }
                medAceleracaoRotor1 = temp1/20
                medAceleracaoRotor2 = temp2/20
                medAceleracaoRotor3 = temp3/20
                medAceleracaoRotor4 = temp4/20
                medAceleracaoRotor5 = temp5/20
                medAceleracaoRotor6 = temp6/20
                //   console.log("medAccell1", medAceleracaoRotor1)

                aceleracao_rotor_1_ARRAY.shift();
                aceleracao_rotor_2_ARRAY.shift();
                aceleracao_rotor_3_ARRAY.shift();
                aceleracao_rotor_4_ARRAY.shift();
                aceleracao_rotor_5_ARRAY.shift();
                aceleracao_rotor_6_ARRAY.shift();

            }
        }
    }





    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    //                          LATERAL VIEW AREA                                                       //
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    Loader{
        id: lateralDataLoader
        anchors.right : parent.right
        anchors.bottom : parent.bottom
        anchors.top:parent.top
        width : parent.width - mainViewWidth
        height: mainViewHeight
        active: active  // or false if you want to delay loading
        asynchronous: true
        onLoaded:{
            let now = new Date();
            console.log("lateralDataArea LOADED at " + now.toLocaleTimeString());
            //bottomDataLoader.active = true;
        }

        sourceComponent: Component {
            id: lateralDataComponent
            Item {
                id: lateralDataArea
                anchors.fill: parent
                Rectangle {
                    anchors.fill: parent
                    color:qgcPal.toolbarBackground
                }
                Text{
                    id: text_rpm1
                    width: 1
                    height: 1
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: _androidBuild ? _toolsMargin: 0
                    anchors.leftMargin: _androidBuild ? _toolsMargin: _toolsMargin*5
                    text: _aceleracao_rotor_1
                    color:"green"
                    font.bold: true
                }
                //RPM1
                Item{
                    id: dialRPM1
                    anchors.left: text_rpm1.right
                    anchors.top: text_rpm1.bottom
                    anchors.topMargin: _androidBuild ? _toolsMargin: _toolsMargin*2
                    anchors.leftMargin:    _androidBuild ? _toolsMargin*4 : _toolsMargin*2
                    anchors.bottomMargin: _androidBuild ? 0: _toolsMargin*2
                    height: parent.height/6
                    width: height
                    Canvas {
                        anchors.fill: parent
                        id: rotor1Arc
                        renderTarget: Canvas.Image
                        renderStrategy: Canvas.Cooperative
                        property real angleRPM1: 0//accelerationPercentageToRadius(_aceleracao_rotor_1/5000)*100
                        Behavior on angleRPM1 {
                                NumberAnimation { duration: 100; easing.type: Easing.OutQuad } // suavizador de animação
                            }
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.clearRect(0, 0, width, height)
                            var radius = Math.min(width, height) / 2.5
                            var startAngle = Math.PI; // 180 graus
                            var endAngle = Math.PI*1.5;          // 270 graus

                            // Arco de Fundo (cinza)
                            ctx.strokeStyle = "gray" // Cor do arco de fundo
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            // ctx.arc(centro_x, centro_y, raio, ângulo_inicial, ângulo_final, sentido_antihorario)
                            ctx.arc(width / 2, height / 2, radius, startAngle, endAngle, false)
                            ctx.stroke()

                            // Arco de Preenchimento (verde), usando a variável de ângulo 'angleRPM1'
                            ctx.strokeStyle = "green"
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, radius, startAngle, angleRPM1 , false)
                            ctx.stroke()

                            // Define o ponto central (origem da linha)
                            var centerX = width / 2;
                            var centerY = height / 2;

                            // Calcula as coordenadas X e Y da ponta do ponteiro usando o ângulo atual (angleRPM1)
                            // Nota: O raio do ponteiro será o mesmo do arco (radius)
                            var pointerX = centerX + radius * Math.cos(angleRPM1);
                            var pointerY = centerY + radius * Math.sin(angleRPM1);

                            ctx.strokeStyle = "red" // Cor do ponteiro
                            ctx.lineWidth = 2       // Espessura do ponteiro

                            ctx.beginPath()
                            ctx.moveTo(centerX, centerY) // Inicia no centro
                            ctx.lineTo(pointerX, pointerY) // Desenha até a borda do arco
                            ctx.stroke()
                        }
                        Timer {interval: 33;running: true;repeat: true;onTriggered: {parent.requestPaint();parent.angleRPM1= mapValueToRadians(_aceleracao_rotor_1, 0, 5000, Math.PI, Math.PI*1.5);}}

                    }

                }//fim RPM1

                //RPM2
                Text{
                    id: text_rpm2
                    width: 1
                    height: 1
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: _androidBuild ? _toolsMargin: 0
                    anchors.rightMargin: _toolsMargin*8
                    text: _aceleracao_rotor_2
                    color:"green"
                    font.bold: true
                }

                Item{
                    id: dialRPM2
                    anchors.right: text_rpm2.left
                    anchors.top: text_rpm2.bottom
                    anchors.topMargin: _androidBuild ? _toolsMargin: _toolsMargin*2
                    anchors.rightMargin:    _androidBuild ? -_toolsMargin*2 : _toolsMargin*2
                    anchors.bottomMargin: _androidBuild ? 0: _toolsMargin*2
                    height: parent.height/6
                    width: height
                    Canvas {
                        anchors.fill: parent
                        id: rotor2Arc
                        renderTarget: Canvas.Image
                        renderStrategy: Canvas.Cooperative
                        property real angleRPM2: 0//accelerationPercentageToRadius(_aceleracao_rotor_1/5000)*100
                        Behavior on angleRPM2 {
                                NumberAnimation { duration: 100; easing.type: Easing.OutQuad } // suavizador de animação
                            }
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.clearRect(0, 0, width, height)
                            var radius = Math.min(width, height) / 2.5
                            var startAngle = Math.PI*2; // 270 graus
                            var endAngle = Math.PI*1.5;          // 360 graus

                            // Arco de Fundo (cinza)
                            ctx.strokeStyle = "gray" // Cor do arco de fundo
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            // ctx.arc(centro_x, centro_y, raio, ângulo_inicial, ângulo_final, sentido_antihorario)
                            ctx.arc(width / 2, height / 2, radius, startAngle, endAngle, true)
                            ctx.stroke()

                            // Arco de Preenchimento (verde), usando a variável de ângulo 'angleRPM2'
                            ctx.strokeStyle = "green"
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, radius, startAngle, angleRPM2 , true)
                            ctx.stroke()

                            // Define o ponto central (origem da linha)
                            var centerX = width / 2;
                            var centerY = height / 2;

                            // Calcula as coordenadas X e Y da ponta do ponteiro usando o ângulo atual (angleRPM2)
                            // Nota: O raio do ponteiro será o mesmo do arco (radius)
                            var pointerX = centerX + radius * Math.cos(angleRPM2);
                            var pointerY = centerY + radius * Math.sin(angleRPM2);

                            ctx.strokeStyle = "red" // Cor do ponteiro
                            ctx.lineWidth = 2       // Espessura do ponteiro

                            ctx.beginPath()
                            ctx.moveTo(centerX, centerY) // Inicia no centro
                            ctx.lineTo(pointerX, pointerY) // Desenha até a borda do arco
                            ctx.stroke()
                        }
                        Timer {interval: 33;running: true;repeat: true;onTriggered: {parent.requestPaint();parent.angleRPM2= mapValueToRadians(_aceleracao_rotor_2, 0, 5000, Math.PI*2, Math.PI*1.5)}}

                    }

                }//fim RPM2

                Text{
                    id: text_rpm3
                    width: 1
                    height: 1
                    anchors.left: parent.left
                    anchors.bottom: dialRPM3.bottom
                    anchors.leftMargin: _androidBuild ? _toolsMargin: _toolsMargin*5
                    text: _aceleracao_rotor_3
                    color:"green"
                    font.bold: true
                }
                //RPM3
                Item{
                    id: dialRPM3
                    anchors.left: dialRPM1.left
                    anchors.top: dialRPM1.bottom
                    //anchors.leftMargin:    _toolsMargin*7
                    anchors.topMargin: _androidBuild ? -_toolsMargin*14 : -_toolsMargin*25
                    height: parent.height/6
                    width: height
                    Canvas {
                        anchors.fill: parent
                        id: rotor3Arc
                        renderTarget: Canvas.Image
                        renderStrategy: Canvas.Cooperative
                        property real angleRPM3: 0//accelerationPercentageToRadius(_aceleracao_rotor_1/5000)*100
                        Behavior on angleRPM3 {
                                NumberAnimation { duration: 100; easing.type: Easing.OutQuad } // suavizador de animação
                            }
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.clearRect(0, 0, width, height)
                            var radius = Math.min(width, height) / 2.5
                            var startAngle = Math.PI; // 180 graus
                            var endAngle = Math.PI*0.5;          // 90 graus

                            // Arco de Fundo (cinza)
                            ctx.strokeStyle = "gray" // Cor do arco de fundo
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            // ctx.arc(centro_x, centro_y, raio, ângulo_inicial, ângulo_final, sentido_antihorario)
                            ctx.arc(width / 2, height / 2, radius, startAngle, endAngle, true)
                            ctx.stroke()

                            // Arco de Preenchimento (verde), usando a variável de ângulo 'angleRPM3'
                            ctx.strokeStyle = "green"
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, radius, startAngle, angleRPM3 , true)
                            ctx.stroke()

                            // Define o ponto central (origem da linha)
                            var centerX = width / 2;
                            var centerY = height / 2;

                            // Calcula as coordenadas X e Y da ponta do ponteiro usando o ângulo atual (angleRPM3)
                            // Nota: O raio do ponteiro será o mesmo do arco (radius)
                            var pointerX = centerX + radius * Math.cos(angleRPM3);
                            var pointerY = centerY + radius * Math.sin(angleRPM3);

                            ctx.strokeStyle = "red" // Cor do ponteiro
                            ctx.lineWidth = 2       // Espessura do ponteiro

                            ctx.beginPath()
                            ctx.moveTo(centerX, centerY) // Inicia no centro
                            ctx.lineTo(pointerX, pointerY) // Desenha até a borda do arco
                            ctx.stroke()
                        }
                        Timer {interval: 33;running: true;repeat: true;onTriggered: {parent.requestPaint();parent.angleRPM3= mapValueToRadians(_aceleracao_rotor_3, 0, 5000, Math.PI, Math.PI*0.5);}}

                    }

                }//fim RPM3

                Text{
                    id: text_rpm4
                    width: 1
                    height: 1
                    anchors.right: parent.right
                    anchors.bottom: dialRPM4.bottom
                    anchors.rightMargin:  _toolsMargin*8
                    text: _aceleracao_rotor_4
                    color:"green"
                    font.bold: true
                }
                //RPM4
                Item{
                    id: dialRPM4
                    anchors.left: dialRPM2.left
                    anchors.top: dialRPM2.bottom
                    //anchors.leftMargin:    _toolsMargin*7
                    anchors.topMargin: _androidBuild ? -_toolsMargin*14 : -_toolsMargin*25

                    height: parent.height/6
                    width: height
                    Canvas {
                        anchors.fill: parent
                        id: rotor4Arc
                        renderTarget: Canvas.Image
                        renderStrategy: Canvas.Cooperative
                        property real angleRPM4: 0//accelerationPercentageToRadius(_aceleracao_rotor_1/5000)*100
                        Behavior on angleRPM4 {
                                NumberAnimation { duration: 100; easing.type: Easing.OutQuad } // suavizador de animação
                            }
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.clearRect(0, 0, width, height)
                            var radius = Math.min(width, height) / 2.5
                            var startAngle = 0; // 360 graus
                            var endAngle = Math.PI*0.5;          // 90 graus

                            // Arco de Fundo (cinza)
                            ctx.strokeStyle = "gray" // Cor do arco de fundo
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            // ctx.arc(centro_x, centro_y, raio, ângulo_inicial, ângulo_final, sentido_antihorario)
                            ctx.arc(width / 2, height / 2, radius, startAngle, endAngle, false)
                            ctx.stroke()

                            // Arco de Preenchimento (verde), usando a variável de ângulo 'angleRPM4'
                            ctx.strokeStyle = "green"
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, radius, startAngle, angleRPM4 , false)
                            ctx.stroke()

                            // Define o ponto central (origem da linha)
                            var centerX = width / 2;
                            var centerY = height / 2;

                            // Calcula as coordenadas X e Y da ponta do ponteiro usando o ângulo atual (angleRPM4)
                            // Nota: O raio do ponteiro será o mesmo do arco (radius)
                            var pointerX = centerX + radius * Math.cos(angleRPM4);
                            var pointerY = centerY + radius * Math.sin(angleRPM4);

                            ctx.strokeStyle = "red" // Cor do ponteiro
                            ctx.lineWidth = 2       // Espessura do ponteiro

                            ctx.beginPath()
                            ctx.moveTo(centerX, centerY) // Inicia no centro
                            ctx.lineTo(pointerX, pointerY) // Desenha até a borda do arco
                            ctx.stroke()
                        }
                        Timer {interval: 33;running: true;repeat: true;onTriggered: {parent.requestPaint();parent.angleRPM4= mapValueToRadians(_aceleracao_rotor_4, 0, 5000, 0, Math.PI*0.5);}}

                    }

                }//fim RPM4

                //RPM GERADOR TODO: RPM DO GERADOR NÃO EXISTE COMO INFO AINDA
                Item{
                    id: dialRPMGerador
                    anchors.left: parent.left
                    anchors.top: text_rpm3.bottom
                    anchors.topMargin:    _toolsMargin*2
                    height: parent.width
                    width: height
                    Canvas {
                        anchors.fill: parent
                        id: rotorGeradorArc
                        renderTarget: Canvas.Image
                        renderStrategy: Canvas.Cooperative
                        property real angleRPMGerador: 0//accelerationPercentageToRadius(_aceleracao_rotor_1/5000)*100
                        Behavior on angleRPMGerador {
                                NumberAnimation { duration: 100; easing.type: Easing.OutQuad } // suavizador de animação
                            }
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.clearRect(0, 0, width, height)
                            var radius = Math.min(width, height) / 2.5
                            var startAngle = Math.PI; // 180 graus
                            var endAngle = Math.PI*2;          // 360

                            // Arco de Fundo (cinza)
                            ctx.strokeStyle = "gray" // Cor do arco de fundo
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            // ctx.arc(centro_x, centro_y, raio, ângulo_inicial, ângulo_final, sentido_antihorario)
                            ctx.arc(width / 2, height / 2, radius, startAngle, endAngle, false)
                            ctx.stroke()

                            // Arco de Preenchimento (verde), usando a variável de ângulo 'angleRPMGerador'
                            ctx.strokeStyle = "green"
                            ctx.lineWidth = 8
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, radius, startAngle, angleRPMGerador , false)
                            ctx.stroke()

                            // Define o ponto central (origem da linha)
                            var centerX = width / 2;
                            var centerY = height / 2;

                            // Calcula as coordenadas X e Y da ponta do ponteiro usando o ângulo atual (angleRPMGerador)
                            // Nota: O raio do ponteiro será o mesmo do arco (radius)
                            var pointerX = centerX + radius * Math.cos(angleRPMGerador);
                            var pointerY = centerY + radius * Math.sin(angleRPMGerador);

                            ctx.strokeStyle = "red" // Cor do ponteiro
                            ctx.lineWidth = 2       // Espessura do ponteiro

                            ctx.beginPath()
                            ctx.moveTo(centerX, centerY) // Inicia no centro
                            ctx.lineTo(pointerX, pointerY) // Desenha até a borda do arco
                            ctx.stroke()
                        }
                        Timer {interval: 33;running: true;repeat: true;onTriggered: {parent.requestPaint();parent.angleRPMGerador= mapValueToRadians(_aceleracao_rotor_1, 0, 5000, Math.PI, Math.PI*2);}}
                    }


                }//fim RPM GERADOR

                Text{
                    id: text_rpmGerador
                    width: 1
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: dialRPMGerador.bottom
                    anchors.topMargin: -parent.width*0.45 // um pouco menos da metade para não ficar colado
                    font.pixelSize: _androidBuild? 20 : 18
                    text: _aceleracao_rotor_1 //TODO: TROCAR PRA INFO DE RPM DO MOTOR CENTRAL
                    color:"green"
                    font.bold: true
                    horizontalAlignment: parent.width
                }



            }

        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    //                          MAIN VIEW AREA                                                          //
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    Item {
        id: mainViewArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: lateralDataLoader.left
        anchors.bottom: parent.bottom

        Component.onCompleted:{
            let now = new Date();
            console.log("mainViewArea LOADED at " + now.toLocaleTimeString());lateralDataLoader.active = true; bottomDataLoader.active = true;}

        QGCToolInsets {
            id: _toolInsets
            leftEdgeBottomInset: _pipOverlay.visible ? _pipOverlay.x + _pipOverlay.width : 0
            bottomEdgeLeftInset: _pipOverlay.visible ? parent.height - _pipOverlay.y : 0
        }

        FlyViewWidgetLayer {
            id: widgetLayer
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: guidedAltSlider.visible ? guidedAltSlider.left : parent.right
            z: _fullItemZorder + 1
            parentToolInsets: _toolInsets
            mapControl: _mapControl
            visible: !QGroundControl.videoManager.fullScreen
        }

        FlyViewCustomLayer {
            id: customOverlay
            anchors.fill: widgetLayer
            z: _fullItemZorder + 2
            parentToolInsets: widgetLayer.totalToolInsets
            mapControl: _mapControl
            visible: !QGroundControl.videoManager.fullScreen
        }

        GuidedActionsController {
            id: guidedActionsController
            missionController: _missionController
            actionList: _guidedActionList
            altitudeSlider: _guidedAltSlider
        }



        GuidedActionList {
            id: guidedActionList
            anchors.margins: _margins
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            z: QGroundControl.zOrderTopMost
            guidedController: _guidedController
        }

        //-- Altitude slider
        GuidedAltitudeSlider {
            id: guidedAltSlider
            anchors.margins: _toolsMargin
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            z: QGroundControl.zOrderTopMost
            radius: ScreenTools.defaultFontPixelWidth / 2
            width: ScreenTools.defaultFontPixelWidth * 10
            color: qgcPal.window
            visible: false
        }

        FlyViewMap {
            id: mapControl
            planMasterController: _planController
            rightPanelWidth: ScreenTools.defaultFontPixelHeight * 9
            pipMode: !_mainWindowIsMap
            toolInsets: customOverlay.totalToolInsets
            mapName: "FlightDisplayView"
        }

        FlyViewVideo {
            id: videoControl
            iconLeftMargin: widgetLayer.iconLeftMargin
        }

        QGCPipOverlay {
            id: _pipOverlay
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: _toolsMargin
            item1IsFullSettingsKey: "MainFlyWindowIsMap"
            item1: mapControl
            item2: QGroundControl.videoManager.hasVideo ? videoControl : null
            fullZOrder: _fullItemZorder
            pipZOrder: _pipItemZorder
            show: !QGroundControl.videoManager.fullScreen
                  && (videoControl.pipState.state === videoControl.pipState.pipState
                      || mapControl.pipState.state === mapControl.pipState.pipState)
        }

        Rectangle{
            id: borda_video
            anchors.fill: videoControl
            color: "transparent"
            //border.width: _mainWindowIsMap ? 1 : 5
            //border.color: black
            z: videoControl.z+5
        }

        Item{
            id: pilotHUD
            anchors.verticalCenter: borda_video.verticalCenter
            anchors.horizontalCenter: borda_video.horizontalCenter
            width: borda_video.width*0.65
            height: borda_video.height*0.95
            z: videoControl.z
            visible: !_mainWindowIsMap

            Rectangle{ //delimitador de área só pra ver os limites. Apagar quando completo
                anchors.fill: parent
                color:"red"
                visible: false
            }

            /////COMEÇO DO PITCH
            Item {
                id: pitchArea
                width: parent.width / 3
                height: parent.width / 3
                anchors.centerIn: parent
                clip: true

                property real pitch: _activeVehicle.pitch.rawValue.toFixed(2)
                property real lineSpacing: height / 5
                readonly property int totalLines: 37 // -90 a 90 a cada 5 graus

                // Calcula o deslocamento vertical para ajustar o movimento conforme pitch
                property real pitchOffsetY: (pitch+80) / 5 * lineSpacing //+80 pra dar offset inicial, se não o valor 0 do indicador é -80

                Repeater {
                    model: pitchArea.totalLines
                    delegate: Item {
                        width: parent.width
                        height: pitchArea.lineSpacing

                        property int angle: 90 - index * 5

                        y: index * pitchArea.lineSpacing + pitchArea.pitchOffsetY * -1

                        // Exeste visibilidade para limitar desenho (opcional)
                        visible: y + height >= 0 && y <= pitchArea.height

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            x: 0
                            height: 4
                            width: angle % 10 === 0 ? parent.width * 0.5 : parent.width * 0.25
                            color: "white"//"#00FF00"
                            border.width: 1
                            border.color:"black"
                        }

                        Text {
                            visible: angle % 10 === 0
                            text: angle + "°"
                            color: "white"//"#00FF00"
                            font.pixelSize: _androidBuild? 12 : ScreenTools.defaultFontPixelWidth*2
                            anchors.verticalCenter: parent.verticalCenter
                            font.bold: true
                            anchors.left: parent.left
                            anchors.leftMargin: width * 0.55
                            z: parent.z + 20 // esse +20 é porquice, mas deixa assim por enquanto
                            layer.enabled: true
                            layer.smooth: true
                            layer.effect: DropShadow {
                                color: "black"
                                horizontalOffset: 0
                                verticalOffset: 0
                                radius: 3
                                smooth: true
                                samples: 32
                                spread: 0.8 // Ajuste para tornar a borda mais definida (menos difusa)
                            }
                        }
                    }
                }
            }

            QGCColoredImage { // crosshair no centro da camera
                id: crosshair_central
                width: parent.width / 3
                height: parent.width / 5
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                source: "/qmlimages/crossHair.svg"
                layer.enabled: true
                layer.smooth: true
                layer.effect: DropShadow {
                    color: "black"
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 2
                    smooth: true
                    samples: 32
                    spread: 0.8 // Ajuste para tornar a borda mais definida (menos difusa)
                }

            }
            /////FIM DO PITCH


            /////COMEÇO DO ROLL
            Item {
                id: dialRoll
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 0
                width: parent.width
                height: parent.width / 2

                Canvas {
                    anchors.fill: parent
                    id: rollArc
                    renderTarget: Canvas.Image
                    renderStrategy: Canvas.Cooperative
                    visible: true
                    property real angleRoll: 0
                    Behavior on angleRoll {
                        NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                    }
                    layer.enabled: true
                    layer.smooth: true
                    layer.effect: DropShadow {
                        color: "black"
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 2
                        smooth: true
                        samples: 32
                        spread: 0.8 // Ajuste para tornar a borda mais definida (menos difusa)
                    }
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.clearRect(0, 0, width, height)
                        var centerX = width / 2
                        var centerY = height / 2
                        var radius = Math.min(width, height) / 2.5


                        // Desenha o arco branco
                        ctx.strokeStyle = "white"
                        ctx.lineWidth = 5
                        ctx.beginPath()
                        ctx.arc(centerX, centerY, radius - 10, Math.PI * 1.08, Math.PI * 1.92, false)
                        ctx.stroke()

                        // Riscos picotados a cada 15 graus
                        ctx.strokeStyle = "white"
                        ctx.lineWidth = 5
                        for (var deg = 195; deg <= 345; deg += 15) {
                            var rad = deg * Math.PI / 180
                            var innerRadius = radius - 10
                            var outerRadius = radius
                            if (deg % 5 === 0) {
                                outerRadius = radius + 10
                            }

                            var xStart = centerX + innerRadius * Math.cos(rad)
                            var yStart = centerY + innerRadius * Math.sin(rad)

                            var xEnd = centerX + outerRadius * Math.cos(rad)
                            var yEnd = centerY + outerRadius * Math.sin(rad)

                            ctx.beginPath()
                            ctx.moveTo(xStart, yStart)
                            ctx.lineTo(xEnd, yEnd)
                            ctx.stroke()
                        }
                        // É uma boa prática resetar as propriedades da sombra se você for desenhar
                        // outros elementos que não devam ter sombra depois.
                        // ctx.shadowColor = "transparent";
                        // ctx.shadowBlur = 0;
                        // ctx.shadowOffsetX = 0;
                        // ctx.shadowOffsetY = 0;
                    }
                    Timer {
                        interval: 33; running: true; repeat: true
                        onTriggered: {
                            parent.requestPaint()
                            parent.angleRoll = mapValueToRadians(_activeVehicle.roll.rawValue.toFixed(2), -150, 150, Math.PI * 1.08, Math.PI * 1.92)
                            //console.log("airspeed:", _activeVehicle.airSpeed.rawValue.toFixed(2))
                        }
                    }
                }

                QGCColoredImage {
                    id: pointerRoll
                    width: dialRoll.width / 10
                    height: dialRoll.height / 2
                    anchors.horizontalCenter: rollArc.horizontalCenter
                    anchors.verticalCenter: rollArc.verticalCenter
                    anchors.verticalCenterOffset: -dialRoll.height/4
                    color: "white"
                    source: "/qmlimages/rollPointer.svg"
                    transformOrigin: Item.Bottom
                    rotation: (rollArc.angleRoll - 1.5 * Math.PI) * (180 / Math.PI)
                    smooth: true
                    layer.enabled: true
                    layer.smooth: true
                    layer.effect: DropShadow {
                        color: "black"
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 2
                        smooth: true
                        samples: 32
                        spread: 0.8 // Ajuste para tornar a borda mais definida (menos difusa)
                    }
                }
            }
            ///// FIM DO ROLL

            /////COMEÇO DO HEADING
            QGCColoredImage {
                id: headingIndicator
                width: parent.width *0.25
                height: parent.width *0.25
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: pitchArea.bottom
                anchors.margins: _toolsMargin*0.5
                source: "/qmlimages/compassInstrumentDial.svg"
                color: "white"
                rotation: _activeVehicle.heading.rawValue.toFixed(2)
                layer.enabled: true
                layer.smooth: true
                layer.effect: DropShadow {
                    color: "black"
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 1
                    smooth: true
                    samples: 32
                    spread: 0.5 // Ajuste para tornar a borda mais definida (menos difusa)
                }
            }
            QGCColoredImage {
                id: vehicleHeadingIcon
                width: headingIndicator.width/2
                height: headingIndicator.height/2
                anchors.horizontalCenter: headingIndicator.horizontalCenter
                anchors.verticalCenter: headingIndicator.verticalCenter
                source: "/qmlimages/GD60_lowres.png"
                color: "white"
                rotation: 180
                layer.enabled: true
                layer.smooth: true
                layer.effect: DropShadow {
                    color: "black"
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 1
                    smooth: true
                    samples: 32
                    spread: 0.5 // Ajuste para tornar a borda mais definida (menos difusa)
                }

            }
            QGCColoredImage {
                id: pointerHeading
                width: headingIndicator.width/5
                height: width
                anchors.horizontalCenter: headingIndicator.horizontalCenter
                anchors.bottom: headingIndicator.top
                anchors.bottomMargin: -_toolsMargin*0.5
                color: "white"
                source: "/qmlimages/rollPointer.svg"
                rotation: 180
                smooth: true
                layer.enabled: true
                layer.smooth: true
                layer.effect: DropShadow {
                    color: "black"
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 1
                    smooth: true
                    samples: 32
                    spread: 0.5 // Ajuste para tornar a borda mais definida (menos difusa)
                }
            }
            Item {
                id: headingTextBox
                width: ScreenTools.defaultFontPixelWidth * 6 // Mantém a largura original
                height: ScreenTools.defaultFontPixelHeight
                anchors.horizontalCenter: pointerHeading.horizontalCenter
                anchors.verticalCenter:  pointerHeading.verticalCenter

                Rectangle {
                    id: headingValuetextBox
                    anchors.fill: parent
                    color: "black"
                    border.color: "white"
                    border.width: 1
                }

                Text {
                    text: _activeVehicle.heading.rawValue.toFixed(0).padStart(3, '0') + "°"
                    color: "white"
                    font.pixelSize: ScreenTools.defaultFontPixelWidth * 2
                    font.bold: true
                    anchors.centerIn: headingValuetextBox // Centraliza horizontal e verticalmente
                    z: parent.z + 20
                }
            }
            ///// FIM DO HEADING

            ///// COMEÇO BARRA LATERAL / VELOCIDADES HORIZONTAIS

            Item{
                id: barraLateralEsquerda
                width: parent.width/10
                height: parent.height*2/3
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: crosshair_central.left
                anchors.rightMargin: _toolsMargin*10
                clip: true
                property real current_value: -_activeVehicle.airSpeed.rawValue.toFixed(2) // Usando o rawValue para cálculo
                property real lineSpacing: height / 6
                readonly property int totalLines: 40 // De -190 a 200 (se o passo for 10)
                readonly property real unitsPerLineSpacing: 10
                readonly property real pixelPerUnit: barraLateralEsquerda.lineSpacing / barraLateralEsquerda.unitsPerLineSpacing
                property real scrollOffsetY: -1 * barraLateralEsquerda.current_value * barraLateralEsquerda.pixelPerUnit

                Rectangle{
                    id: rectAirspeed
                    anchors.fill: parent
                    color: hudGrey
                    border.color: "white"
                    border.width: 2
                }


                // ⚙️ Repeater para criar a escala
                Repeater {
                    model: barraLateralEsquerda.totalLines
                    delegate: Item {
                        width: parent.width
                        height: barraLateralEsquerda.lineSpacing
                        property int angle: 190 - index * 10
                        readonly property real centerOffset: barraLateralEsquerda.height / 2 - (19 * barraLateralEsquerda.lineSpacing)
                        y: ((index-0.5) * barraLateralEsquerda.lineSpacing) + barraLateralEsquerda.scrollOffsetY + centerOffset

                        visible: y + height >= 0 && y <= barraLateralEsquerda.height

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 0
                            height: 2
                            // Linha longa a cada 10 unidades. Se o passo é 10, todas são longas.
                            width: angle % 10 === 0 ? parent.width * 0.5 : parent.width * 0.25
                            color: "white"
                        }

                        Text {
                            // Exibe o texto apenas para múltiplos de 10
                            visible: angle % 10 === 0
                            // Se angle for 0, toFixed(0) é 0.
                            text: angle.toFixed(0)
                            color: "white"
                            font.pixelSize: _androidBuild? 12 : ScreenTools.defaultFontPixelWidth*2
                            anchors.verticalCenter: parent.verticalCenter
                            font.bold: true
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width * 0.55 // Ajustado para ficar à direita da linha
                            z: parent.z + 20
                        }
                    }
                }

                // 🎯 Indicador Fixo (Central)
                QGCColoredImage {
                    id: airspeedPointer
                    width: parent.width * 0.5
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"
                    z: 10
                    source: "/qmlimages/rollPointer.svg"
                    rotation: 270
                    smooth: false
                }
                Rectangle {
                    id: airspeedValuetextBox
                    width: _androidBuild? ScreenTools.defaultFontPixelWidth * 5 : ScreenTools.defaultFontPixelWidth * 8 // Mantém a largura original
                    height: ScreenTools.defaultFontPixelHeight
                    anchors.left: airspeedPointer.right
                    anchors.leftMargin: -_toolsMargin*3
                    anchors.verticalCenter: parent.verticalCenter
                    color: "black"
                    border.color: "white"
                    border.width: 1
                }

                Text {
                    text: _activeVehicle.airSpeed.rawValue.toFixed(1).padStart(3, '0')
                    color: "white"
                    font.pixelSize: _androidBuild? ScreenTools.defaultFontPixelWidth * 1.5 : ScreenTools.defaultFontPixelWidth * 2
                    font.bold: true
                    anchors.centerIn: airspeedValuetextBox // Centraliza horizontal e verticalmente
                    z: parent.z + 20
                }

            }
            Item{
                id: subbarraLateralEsquerda
                anchors.top: barraLateralEsquerda.bottom
                anchors.left: barraLateralEsquerda.left
                width: barraLateralEsquerda.width
                height:ScreenTools.defaultFontPixelHeight*1.2
                clip: true

                Rectangle{
                    id: groundSpeedValuetextBox
                    anchors.fill:parent
                    color:"black"
                    anchors.topMargin: -2
                    border.width: 2
                    border.color: "white"
                }
                Text {
                    text: "GS: " + _activeVehicle.groundSpeed.rawValue.toFixed(1).padStart(3, '0')
                    color: "white"
                    font.pixelSize: _androidBuild? ScreenTools.defaultFontPixelWidth * 1.5 : ScreenTools.defaultFontPixelWidth * 2
                    font.bold: true
                    anchors.centerIn: groundSpeedValuetextBox // Centraliza horizontal e verticalmente
                    z: parent.z + 20
                }
            }
            ///// FIM BARRA LATERAL / VELOCIDADES HORIZONTAIS


            Item{
                id: barraLateralDireita
                width: parent.width/10
                height: parent.height*2/3
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: crosshair_central.right
                anchors.leftMargin: _toolsMargin*10
                clip: true

                // 💨 Valor Atual: Usamos a altitude. Removemos o sinal '-' inicial, pois a rolagem é tratada no scrollOffsetY.
                property real current_value: -_activeVehicle.altitudeRelative.rawValue.toFixed(1)

                // 📏 Definições da Escala
                property real lineSpacing: height / 6
                // Novo total de linhas: (200 - (-200)) / 10 + 1 = 41 linhas (de -200 a 200, incluindo 0)
                readonly property int totalLines: 41

                // O índice da linha que deve ter o valor 0 (index 20: -200 + 20*10 = 0)
                readonly property int _ZERO_INDEX: 20

                // 📐 Fatores de Rolagem
                readonly property real unitsPerLineSpacing: 10
                readonly property real pixelPerUnit: barraLateralDireita.lineSpacing / barraLateralDireita.unitsPerLineSpacing

                // 2. O valor de deslocamento total (quanto o modelo deve rolar)
                // O modelo rola para baixo (Y positivo) quando a altitude diminui (valor negativo).
                // O valor deve ser *positivo* para que a escala mova para baixo quando a altitude aumenta.
                // Se a altitude aumenta, a escala deve rolar para baixo (para trazer os valores maiores para o centro)
                property real scrollOffsetY: -1 * barraLateralDireita.current_value * barraLateralDireita.pixelPerUnit

                // 3. Offset de Centralização Fixo (move o _ZERO_INDEX para o centro)
                readonly property real centerOffset: (barraLateralDireita.height / 2) - (barraLateralDireita._ZERO_INDEX * barraLateralDireita.lineSpacing)


                Rectangle{
                    id: rectAltitude
                    anchors.fill: parent
                    color:hudGrey
                    border.color: "white"
                    border.width: 2 // Borda padrão
                    // Se precisar de borda esquerda 0, use: border.widths: [2, 2, 2, 0]
                }

                // ⚙️ Repeater para criar a escala de Altitude
                Repeater {
                    model: barraLateralDireita.totalLines
                    delegate: Item {
                        width: parent.width
                        height: barraLateralDireita.lineSpacing

                        // 🌟 Cálculo do valor exibido: Começa em -200 e incrementa de 10 em 10
                        property int altitudeScale: 200 - index * 10

                        // ⬇️ Cálculo da Posição Y da linha (Agora Corrigida)
                        // = Posição Estática (do topo) + Deslocamento Rolante + Offset Fixo para Centralizar o '0'
                        y: ((index-0.5) * barraLateralDireita.lineSpacing) + barraLateralDireita.scrollOffsetY + barraLateralDireita.centerOffset

                        // Restrição de visibilidade para limitar desenho
                        visible: y + height >= 0 && y <= barraLateralDireita.height

                        // Linha da escala
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            x: 0
                            height: 2
                            // Linha longa a cada 10 unidades
                            width: altitudeScale % 10 === 0 ? parent.width * 0.5 : parent.width * 0.25
                            color: "white"
                        }

                        // Texto da escala
                        Text {
                            visible: altitudeScale % 10 === 0
                            text: altitudeScale.toFixed(0)
                            color: "white"
                            font.pixelSize: _androidBuild? 12 : ScreenTools.defaultFontPixelWidth*2
                            anchors.verticalCenter: parent.verticalCenter
                            font.bold: true
                            // O texto fica à direita do painel da direita (Altitude)
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width * 0.55 // Ajustado para ficar à esquerda da linha
                            z: parent.z + 20
                        }
                    }
                }

                QGCColoredImage {
                    id: altitudePointer
                    width: parent.width * 0.5
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    color: "white"
                    z: 10
                    source: "/qmlimages/rollPointer.svg"
                    rotation: 90
                    smooth: false
                }
                Rectangle {
                    id: altitudeValuetextBox
                    width: _androidBuild? ScreenTools.defaultFontPixelWidth * 5 : ScreenTools.defaultFontPixelWidth * 8
                    height: ScreenTools.defaultFontPixelHeight
                    anchors.right: altitudePointer.left
                    anchors.rightMargin: -_toolsMargin*3
                    anchors.verticalCenter: parent.verticalCenter
                    color: "black"
                    border.color: "white"
                    border.width: 1
                }

                Text {
                    text: _activeVehicle.altitudeRelative.rawValue.toFixed(1).padStart(3, '0')
                    color: "white"
                    font.pixelSize: _androidBuild? ScreenTools.defaultFontPixelWidth * 1.5 : ScreenTools.defaultFontPixelWidth * 2
                    font.bold: true
                    anchors.centerIn: altitudeValuetextBox // Centraliza horizontal e verticalmente
                    z: parent.z + 20
                }
            }


            Item{
                id: subBarraLateralDireita
                width: barraLateralDireita.width*0.85
                height: barraLateralDireita.height*0.85
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: barraLateralDireita.right
                clip: true

                // 💨 Valor Atual: Vertical Speed (m/s)
                property real current_value: -_activeVehicle.climbRate.rawValue.toFixed(2)

                // 📏 Definições da Escala

                // Novo passo da escala (0.5 m/s)
                readonly property real speedStep: 0.5

                // lineSpacing: Se 3 unidades (3 m/s) preenchem a altura,
                // e cada unidade tem 2 linhas de 0.5m/s,
                // lineSpacing * 6 = height. lineSpacing é a altura de cada passo de 0.5 m/s.
                property real lineSpacing: height / 6

                // Novo total de linhas: (20 - (-20)) / 0.5 + 1 = 81 linhas
                readonly property int totalLines: 81

                // O índice da linha que deve ter o valor 0 (index 40: -20 + 40*0.5 = 0)
                readonly property int _ZERO_INDEX: 40

                // 📐 Fatores de Rolagem
                // A escala muda de 0.5 em 0.5 unidade de velocidade.
                readonly property real unitsPerLineSpacing: subBarraLateralDireita.speedStep // 0.5 unidade de velocidade por marcação

                // Pixels por 0.5 unidade: lineSpacing / 0.5. Isso é igual a 2 * lineSpacing.
                readonly property real pixelPerUnit: subBarraLateralDireita.lineSpacing / subBarraLateralDireita.unitsPerLineSpacing

                // Deslocamento de rolagem: Se a velocidade AUMENTA, a escala rola para CIMA (Y negativo)
                property real scrollOffsetY: -1 * subBarraLateralDireita.current_value * subBarraLateralDireita.pixelPerUnit

                // Offset de Centralização Fixo (move o ZERO_INDEX para o centro)
                readonly property real centerOffset: (subBarraLateralDireita.height / 2) - (subBarraLateralDireita._ZERO_INDEX * subBarraLateralDireita.lineSpacing)


                Rectangle{
                    id: rectVertSpeed
                    anchors.fill: parent
                    color: hudGrey
                    border.color: "white"

                    // Borda esquerda zero
                    border.width: 2
                    anchors.leftMargin: -2
                }

                // ⚙️ Repeater para criar a escala de Velocidade Vertical
                Repeater {
                    model: subBarraLateralDireita.totalLines
                    delegate: Item {
                        width: parent.width
                        height: subBarraLateralDireita.lineSpacing

                        // 🌟 Cálculo do valor exibido: Começa em -20 e incrementa de 0.5 em 0.5
                        property real verticalScale: 20 - index * subBarraLateralDireita.speedStep

                        // ⬇️ Cálculo da Posição Y da linha
                        y: ((index-0.5) * subBarraLateralDireita.lineSpacing) + subBarraLateralDireita.scrollOffsetY + subBarraLateralDireita.centerOffset

                        // Restrição de visibilidade
                        visible: y + height >= 0 && y <= subBarraLateralDireita.height

                        // Linha da escala (Fixa na esquerda)
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            height: 2

                            // --- Lógica de Largura das Linhas (0.5, 1, 5) ---

                            // Se for múltiplo de 5 (ex: -5, 0, 5, 10): Linha Longa
                            property bool isMultipleOfFive: (verticalScale * 10) % 50 === 0
                            // Se for múltiplo de 1 (ex: -1, 1, 2, 3), mas NÃO múltiplo de 5: Linha Média
                            property bool isMultipleOfOne: (verticalScale * 10) % 10 === 0 && !isMultipleOfFive
                            // Se for múltiplo de 0.5 (ex: -0.5, 0.5, 1.5), e NÃO múltiplo de 1: Linha Curta

                            width: isMultipleOfFive ? parent.width * 0.7 :
                                   isMultipleOfOne ? parent.width * 0.5 :
                                   parent.width * 0.3

                            color: "white"
                        }

                        // Texto da escala
                        Text {
                            // Exibe o texto apenas para múltiplos de 5 (ex: -10, -5, 0, 5, 10)
                            visible: verticalScale % 1 === 0
                            // Formata o texto: 0 casas decimais para inteiros, 1 casa decimal caso contrário (embora só mostre múltiplos de 5)
                            text: verticalScale.toFixed(0)

                            color: "white"
                            font.pixelSize: _androidBuild? 12 : ScreenTools.defaultFontPixelWidth*2
                            anchors.verticalCenter: parent.verticalCenter
                            font.bold: true
                            // Alinha o texto na borda direita
                            anchors.left: parent.left
                            anchors.leftMargin: _toolsMargin
                            z: parent.z + 20
                        }
                    }
                }


                QGCColoredImage {
                    id: climbSpeedPointer
                    width: parent.width * 0.5
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    color: "white"
                    z: 10
                    source: "/qmlimages/rollPointer.svg"
                    rotation: 90
                    smooth: false
                }
                Rectangle {
                    id: climbSpeedValuetextBox
                    width: _androidBuild? ScreenTools.defaultFontPixelWidth * 5 : ScreenTools.defaultFontPixelWidth * 7
                    height: ScreenTools.defaultFontPixelHeight
                    anchors.right: climbSpeedPointer.left
                    anchors.rightMargin: -_toolsMargin*3
                    anchors.verticalCenter: parent.verticalCenter
                    color: "black"
                    border.color: "white"
                    border.width: 1
                }

                Text {
                    text: _activeVehicle.climbRate.rawValue.toFixed(1).padStart(3, '0')
                    color: "white"
                    font.pixelSize: _androidBuild? ScreenTools.defaultFontPixelWidth * 1.5 : ScreenTools.defaultFontPixelWidth * 2
                    font.bold: true
                    anchors.centerIn: climbSpeedValuetextBox // Centraliza horizontal e verticalmente
                    z: parent.z + 20
                }
            }



        }









        Popup {
            id: breachAlertPopup
            x: (parent.width - width) / 2
            y: 10  // optional: vertical position
            width: parent.width/4
            height: 100
            modal: false
            focus: false
            background: null
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            visible: false

            Rectangle {
                anchors.fill: parent
                color: _breachAlertColor
                border.color: "black"
                visible: false

                Text {
                    anchors.centerIn: parent
                    text: popUp_breachAlert
                    font.bold: true
                    visible: false
                    // font.pixelSize: _androidBuild? 8 : 14
                }
            }
        }

        Popup {



            id: generatorAlertPopup
            x: (parent.width - width) / 2
            y: 10  // optional: vertical position
            width: parent.width/4
            height: 100
            modal: false
            focus: false
            background: null
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            visible: alertCounts>0

            Rectangle {
                anchors.fill: parent
                color: "red"
                border.color: "black"
                visible: true
                Text {
                    anchors.centerIn: parent
                    text: requestedAlerts
                    font.bold: false
                    visible: true

                     font.pixelSize: _androidBuild? 12 : 14
                }
            }
        }




        Item {
            id: cameraControlOverlay
            z: QGroundControl.zOrderTopMost
            visible: QGroundControl.videoManager.hasVideo

            property int cameraIndex: 0

            states: [
                State {
                    name: "full"
                    when: !((videoControl.pipState.state === videoControl.pipState.pipState) && (!_pipOverlay._isExpanded))
                    PropertyChanges {
                        target: cameraControlOverlay
                        anchors.top: parent.top
                        anchors.bottom: null
                        anchors.right: parent.right
                        anchors.margins: 25
                    }
                },
                State {
                    name: "hidden"
                    when: ((videoControl.pipState.state === videoControl.pipState.pipState) && (!_pipOverlay._isExpanded))
                    PropertyChanges {
                        target: cameraControlOverlay
                        visible: false
                    }
                }
            ]

            Row {
                spacing: ScreenTools.defaultFontPixelWidth
                anchors.right: parent.right
                anchors.top: parent.top

                Rectangle {
                    id: cameraTextBackground
                    color: "#80000000"
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: ScreenTools.defaultFontPixelWidth / 2
                    anchors.rightMargin: ScreenTools.defaultFontPixelWidth / 2
                    height: cameraText.implicitHeight + ScreenTools.defaultFontPixelHeight
                    width: cameraText.implicitWidth + ScreenTools.defaultFontPixelWidth * 2

                    Text {
                        id: cameraText
                        anchors.centerIn: parent
                        text: {
                            if (QGroundControl.videoManager.streams.length > 0 && cameraControlOverlay.cameraIndex < QGroundControl.videoManager.streams.length) {
                                var element = QGroundControl.videoManager.streams[cameraControlOverlay.cameraIndex]
                                return element.alias ? element.alias : element.url
                            } else {
                                return "Sem câmeras"
                            }
                        }
                        color: "white"
                        font.bold: true
                    }
                }


                QGCColoredImage {
                    id: cameraButton
                    source: "/qmlimages/camera"
                    width: ScreenTools.defaultFontPixelHeight * 2
                    height: width
                    fillMode: Image.PreserveAspectFit
                    color: "white"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            _activeVehicle.overwriteRC();
                            if (QGroundControl.videoManager.streams.length > 0) {
                                cameraControlOverlay.cameraIndex = (cameraControlOverlay.cameraIndex + 1) % QGroundControl.videoManager.streams.length

                                var element = QGroundControl.videoManager.streams[cameraControlOverlay.cameraIndex]
                                if (element.ip) {
                                    QGroundControl.settingsManager.videoSettings.rtspUrl.rawValue = element.ip
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


