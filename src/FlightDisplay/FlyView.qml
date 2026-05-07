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

    property var activeOverrideID: -1;
    property var gcsID: gcsID = QGroundControl.mavlinkSystemID.valueOf();

    property string popUp_breachAlert
    property string _breachAlertColor

    property bool canShowBreachAlert: true

    property string requestedAlerts
    property int alertCounts: 0;
    property color hudGrey: "#85333366"
    property color hudPaleGreen: "#9AFF75"
    property color hudPaleBlue: "#00ffff"
    property color hudPalePurple: "#ff00ff"
    property bool overrideActive: false

    property real start_roll_angle: Math.PI * 1.138 //1.08-> 195°
    property real end_roll_angle: Math.PI * 1.805 //1.92 -> 315°
    property real diff_roll_angle: Math.abs(end_roll_angle - start_roll_angle)


    /* valores teóricos do Guilherme:
        V_estol = 22m/s
        V_segura acima de  26,4 até 44,44
        V_max = 44,44 m/s
        V_nunca exceder = 47,22 m/s

    */
    readonly property real v_estol: 22
    readonly property real v_segura_min: 22
    readonly property real v_segura_max: 44
    readonly property real v_max: 47.22

    property var array_valores_rc: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    property bool override_first_clicked: false;

    property var servo_output14: 0
    property var servo_output16: 0

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

    function degToArcRad(deg) {
        var t = (deg + 60) / 120          // normaliza -60..60 → 0..1
        return start_roll_angle+ t * diff_roll_angle
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

            //console.log("Listing all ESC Status Fact Names:")

                        // Iterate over all properties of the escStatus FactGroup
                        for (var prop in _activeVehicle.escStatus) {
                            // We check if the property is a "Fact" object
                            // FactGroups often have other QObject properties, so we filter them
                            var fact = _activeVehicle.escStatus[prop]

                            // Check if it's a valid object and looks like a Fact (has a name/value)
                            //if (fact && fact.hasOwnProperty("name") && fact.hasOwnProperty("value")) {
                            //    console.log("Fact Name found: " + prop + " (Display Name: " + fact.name + ")")
                            //}
                        }
                        //console.log("aaaaaaaa: ",)
                        //console.log("aaaaaaaa: ", _activeVehicle.escStatus["rpmSecond"].name, _activeVehicle.escStatus["rpmSecond"].value)
                        //console.log("aaaaaaaa: ", _activeVehicle.escStatus["rpmThird"].name, _activeVehicle.escStatus["rpmThird"].value)
                        //console.log("aaaaaaaa: ", _activeVehicle.escStatus["rpmFourth"].name, _activeVehicle.escStatus["rpmFourth"].value)
                        //console.log("bbbbbbbb: ", _activeVehicle.escStatus["temperatureFirst"].name, _activeVehicle.escStatus["temperatureFirst"].value)
                        //console.log("bbbbbbbb: ", _activeVehicle.escStatus["temperatureSecond"].name, _activeVehicle.escStatus["temperatureSecond"].value)
                        //console.log("bbbbbbbb: ", _activeVehicle.escStatus["temperatureThird"].name, _activeVehicle.escStatus["temperatureThird"].value)
                        //console.log("bbbbbbbb: ", _activeVehicle.escStatus["temperatureFourth"].name, _activeVehicle.escStatus["temperatureFourth"].value)




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
                _aceleracao_rotor_1 = _activeVehicle.escStatus["rpmFirst"].value
                _aceleracao_rotor_2 = _activeVehicle.escStatus["rpmSecond"].value
                _aceleracao_rotor_3 = _activeVehicle.escStatus["rpmThird"].value
                _aceleracao_rotor_4 = _activeVehicle.escStatus["rpmFourth"].value
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
                        Timer {interval: 50;running: true;repeat: true;onTriggered: {parent.requestPaint();parent.angleRPM1= mapValueToRadians(_aceleracao_rotor_1, 0, 5000, Math.PI, Math.PI*1.5);}}

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
                        Timer {interval: 50;running: true;repeat: true;onTriggered: {parent.requestPaint();parent.angleRPM2= mapValueToRadians(_aceleracao_rotor_2, 0, 5000, Math.PI*2, Math.PI*1.5)}}

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
                        Timer {interval: 50;running: true;repeat: true;onTriggered: {parent.requestPaint();parent.angleRPM3= mapValueToRadians(_aceleracao_rotor_3, 0, 5000, Math.PI, Math.PI*0.5);}}

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
                        Timer {interval: 50;running: true;repeat: true;onTriggered: {parent.requestPaint();parent.angleRPM4= mapValueToRadians(_aceleracao_rotor_4, 0, 5000, 0, Math.PI*0.5);}}

                    }

                }//fim RPM4

                //RPM HORIZONTAL1 TODO: RPM DO HORIZONTAL1 NÃO EXISTE COMO INFO AINDA
                Item{
                    id: dialRPMHORIZONTAL1
                    anchors.left: parent.left
                    anchors.top: text_rpm3.bottom
                    anchors.topMargin:    _toolsMargin*2
                    height: parent.width
                    width: height
                    Canvas {
                        anchors.fill: parent
                        id: rotorHORIZONTAL1Arc
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
                        Timer {interval: 50;running: true;repeat: true;onTriggered: {parent.requestPaint();parent.angleRPMGerador= mapValueToRadians(servo_output14, 800, 2200, Math.PI, Math.PI*2);}}
                    }


                }//fim RPM GERADOR

                Text{
                    id: text_rpmHORIZONTAL1
                    width: 1
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: dialRPMHORIZONTAL1.bottom
                    anchors.topMargin: -parent.width*0.45 // um pouco menos da metade para não ficar colado
                    font.pixelSize: _androidBuild? 20 : 18
                    text: servo_output14 //TODO: TROCAR PRA INFO DE RPM DO MOTOR CENTRAL
                    color:"green"
                    font.bold: true
                    horizontalAlignment: parent.width
                }

                //RPM GERADOR TODO: RPM DO GERADOR NÃO EXISTE COMO INFO AINDA
                Item{
                    id: dialRPMHORIZONTAL2
                    anchors.left: parent.left
                    anchors.top: text_rpmHORIZONTAL1.bottom
                    anchors.topMargin:    _toolsMargin*2
                    height: parent.width
                    width: height
                    Canvas {
                        anchors.fill: parent
                        id: rotorHORIZONTAL2Arc
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
                        Timer {interval: 50;running: true;repeat: true;onTriggered: {parent.requestPaint();parent.angleRPMGerador= mapValueToRadians(servo_output16, 800, 2200, Math.PI, Math.PI*2);}}
                    }


                }//fim RPM GERADOR

                Text{
                    id: text_rpmHORIZONTAL2
                    width: 1
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: dialRPMHORIZONTAL2.bottom
                    anchors.topMargin: -parent.width*0.45 // um pouco menos da metade para não ficar colado
                    font.pixelSize: _androidBuild? 20 : 18
                    text: servo_output16 //TODO: TROCAR PRA INFO DE RPM DO MOTOR CENTRAL
                    color:"green"
                    font.bold: true
                    horizontalAlignment: parent.width
                }

                Grid {
                    id: textMatrix2x2

                    // âncoras e dimensões mantidas
                    anchors.top: text_rpmHORIZONTAL2.bottom
                    anchors.topMargin: _toolsMargin + (_androidBuild ? 24 : 22)
                    anchors.leftMargin: _toolsMargin
                    anchors.rightMargin: _toolsMargin

                    width: parent.width - _toolsMargin * (_androidBuild? 4 : 8) // Correção: Subtrair _toolsMargin duas vezes
                    height: width/2

                    anchors.horizontalCenter: parent.horizontalCenter

                    columns: 2
                   //spacing: 5 // Manter o spacing para a fórmula de cálculo de tamanho

                    // Definindo a largura/altura implícita em uma variável para simplificar a leitura
                    property real cellDimension: width / 2 - spacing * 1.5 // Ajuste para compensar o spacing

                    // Se o spacing for 5, a largura total é W = 2*W_cell + 1*Spacing. W_cell = (W - Spacing)/2

                    // LINHA 1 - Células com Retângulos Transparentes
                    Rectangle {
                        color: "transparent"      // 🌟 TRANSPARENTE
                        border.color: "white"     // 🌟 BORDA BRANCA
                        border.width: 2

                        // Cálculo de dimensão com base no spacing de 5
                        implicitWidth: (textMatrix2x2.width - textMatrix2x2.spacing) / 2
                        implicitHeight: (textMatrix2x2.height - textMatrix2x2.spacing) / 2

                        Text {
                            anchors.centerIn: parent
                            text: _activeVehicle.gd60_Sensor1.rawValue.toFixed(0).toString() + "° \n TEMP1"       // 🌟 TEXTO NOVO
                            color: "white"          // 🌟 COR BRANCA
                            font.bold: true
                            font.pixelSize: _androidBuild? 14 : 18
                            horizontalAlignment: Text.AlignHCenter // Para alinhar o texto de várias linhas
                        }
                    }
                    Rectangle {
                        color: "transparent"
                        border.color: "white"
                        border.width: 2
                        implicitWidth: (textMatrix2x2.width - textMatrix2x2.spacing) / 2
                        implicitHeight: (textMatrix2x2.height - textMatrix2x2.spacing) / 2
                        Text {
                            anchors.centerIn: parent
                            text: _activeVehicle.gd60_Sensor2.rawValue.toFixed(0).toString() + "° \n TEMP2"       // 🌟 TEXTO NOVO
                            color: "white"
                            font.bold: true
                            font.pixelSize: _androidBuild? 14 : 18
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    // LINHA 2 - Células com Retângulos Transparentes
                    Rectangle {
                        color: "transparent"
                        border.color: "white"
                        border.width: 2
                        implicitWidth: (textMatrix2x2.width - textMatrix2x2.spacing) / 2
                        implicitHeight: (textMatrix2x2.height - textMatrix2x2.spacing) / 2
                        Text {
                            anchors.centerIn: parent
                            text: _activeVehicle.gd60_Sensor3.rawValue.toFixed(0).toString() + "° \n TEMP3"       // 🌟 TEXTO NOVO
                            color: "white"
                            font.bold: true
                            font.pixelSize: _androidBuild? 14 : 18
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    Rectangle {
                        color: "transparent"
                        border.color: "white"
                        border.width: 2
                        implicitWidth: (textMatrix2x2.width - textMatrix2x2.spacing) / 2
                        implicitHeight: (textMatrix2x2.height - textMatrix2x2.spacing) / 2
                        Text {
                            anchors.centerIn: parent
                            text: {
                               var max_temp = Math.max(_activeVehicle.escStatus["temperatureFirst"].value,
                                         _activeVehicle.escStatus["temperatureSecond"].value,
                                         _activeVehicle.escStatus["temperatureThird"].value,
                                         _activeVehicle.escStatus["temperatureFourth"].value);
                                return max_temp.toString()+"° \n ESC";
                            }
                            color: "white"
                            font.bold: true
                            font.pixelSize: _androidBuild? 14 : 18
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }


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

                        anchors.top: null
                        anchors.bottom: btnOverride.top
                        anchors.bottomMargin: _toolsMargin * 2
                        anchors.right: parent.right
                        anchors.margins: 25

                        visible: true
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
                anchors.bottom: parent.bottom
                anchors.margins: 0

                Rectangle {
                    id: cameraTextBackground
                    color: "#80000000"
                    radius: 4

                    anchors.verticalCenter: parent.verticalCenter

                    width: ScreenTools.defaultFontPixelWidth * 12
                    height: ScreenTools.defaultFontPixelHeight * 2

                    Text {
                        id: cameraText

                        anchors.fill: parent
                        anchors.margins: ScreenTools.defaultFontPixelWidth * 0.5

                        text: {
                            if (QGroundControl.videoManager.streams.length > 0 &&
                                cameraControlOverlay.cameraIndex < QGroundControl.videoManager.streams.length) {

                                var element = QGroundControl.videoManager.streams[cameraControlOverlay.cameraIndex]
                                return element.alias ? element.alias : element.url
                            } else {
                                return "Sem câmeras"
                            }
                        }

                        color: "white"
                        font.bold: true

                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                    }
                }

                QGCColoredImage {
                    id: cameraButton
                    source: "/qmlimages/camera"
                    width: ScreenTools.defaultFontPixelHeight * 2
                    height: width
                    fillMode: Image.PreserveAspectFit
                    color: "white"

                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (QGroundControl.videoManager.streams.length > 0) {
                                cameraControlOverlay.cameraIndex =
                                    (cameraControlOverlay.cameraIndex + 1) %
                                    QGroundControl.videoManager.streams.length

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



        Rectangle {
                    id: btnOverride
                    width: parent.width*0.75
                    height: parent.height*0.1
                    radius: 5
                    color: overrideActive ? ((activeOverrideID===-1 || activeOverrideID===gcsID) ? "red":"grey") : "green"  // cor dinâmica. Ativado mas
                    border.color: "black"
                    border.width: 1
                    //anchors.horizontalCenter:  parent.horizontalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    z: _fullItemZorder + 10

                    // texto centralizado
                    Text {
                        anchors.centerIn: parent
                        text:  overrideActive ? ((activeOverrideID===-1 || activeOverrideID===gcsID) ? "Stop Override": "Active by:"+activeOverrideID):"Override RC"
                        color: "white"
                        font.bold: true
                    }

                    // efeito de clique
                    MouseArea {
                            anchors.fill: parent
                            hoverEnabled: (activeOverrideID===-1 || activeOverrideID===gcsID)
                           //cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                // botão apenas abre popup
                                if (activeOverrideID === -1 || activeOverrideID === gcsID) {
                                        confirmOverridePopup.wantsToEnable = !overrideActive
                                        confirmOverridePopup.open()
                                    } else {
                                        console.log("Clique bloqueado: Outro ID tem o controle:", activeOverrideID)
                                    }
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


        Popup {
                    id: confirmOverridePopup
                    modal: true
                    focus: true
                    width: parent.width * 0.4
                    height: parent.height * 0.25
                    anchors.centerIn: Overlay.overlay

                    // popup precisa saber se vai ativar ou desativar
                    property bool wantsToEnable: true

                    background: Rectangle {
                        color: "#333"
                        radius: 8
                        border.color: "white"

                    }

                    Column {
                        spacing: 20
                        anchors.centerIn: parent


                        Text {
                            text: !overrideActive
                                  ? "Tem certeza que deseja ATIVAR o Override RC?"
                                  : "Tem certeza que deseja DESATIVAR o Override RC?"
                            color: "white"
                            font.pixelSize: 18
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Row {
                            spacing: 20
                            anchors.horizontalCenter: parent.horizontalCenter

                            // BOTÃO "SIM"
                            Rectangle {
                                property bool selected: false
                                id: btnYes
                                width: 150
                                height: 80
                                radius: 5
                                color: "#66bb6a"
                                border.width: selected ? 3 : 0
                                border.color: "yellow"

                                Text {
                                    id: _simText
                                    anchors.centerIn: parent
                                    text: "SIM"
                                    color: "white"
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: {
                                        //array_valores_rc

                                        var arrayInt = array_valores_rc.map(v => Number(v) | 0)
                                        if (!overrideActive) {
                                            //if(!override_first_clicked && _activeVehicle.firmwareMajorVersion.toString() == "255"){
                                            //    var try_override = _activeVehicle.validateRCChannels(arrayInt);
                                            //    console.log("RESULTADO TRY_OVERRIDE: ",try_override)
                                            //    if(try_override!==""){
                                            //        _alertaForceOverride.text = "ATENÇÃO: "+try_override
                                            //        override_first_clicked = true;
                                            //        _simText.color = "black"
                                            //        btnYes.color = "yellow"
                                            //    }
                                            //    else{
                                            //        overrideActive = true
                                            //        confirmOverridePopup.close()
                                            //    }
                                            //    //confirmOverridePopup.wantsToEnable = false
                                            //}
                                            //else{
                                                console.log("FORÇANDO OVERRIDE")
                                                _activeVehicle.overwriteRC(arrayInt, true)
                                                overrideActive = true
                                                override_first_clicked = false;
                                                _simText.color = "white"
                                                btnYes.color = "#66bb6a"
                                                _alertaForceOverride.text = ""
                                                confirmOverridePopup.close()
                                            //}

                                        } else {
                                            _activeVehicle.stopRCOverride()
                                            overrideActive = false
                                            override_first_clicked = false;
                                            confirmOverridePopup.close()
                                        }
                                        //confirmOverridePopup.close()
                                    }
                                    hoverEnabled: true
                                    onEntered: btnYes.selected = true
                                    onExited: btnYes.selected = false
                                }
                            }

                            // BOTÃO "NÃO"
                            Rectangle {
                                id: btnNo
                                property bool selected: false
                                width: 150
                                height: 80
                                radius: 5
                                color: "#e53935"
                                border.width: selected ? 3 : 0
                                border.color: "yellow"

                                Text {
                                    anchors.centerIn: parent
                                    text: "NÃO"
                                    color: "white"
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        confirmOverridePopup.close()
                                        _simText.color = "white"
                                        btnYes.color = "#66bb6a"
                                        _alertaForceOverride.text = ""
                                        override_first_clicked = false
                                    }
                                    onEntered: btnNo.selected = true
                                    onExited: btnNo.selected = false
                                }
                            }

                        }

                    }
                    Text {
                        id: _alertaForceOverride
                        text: ""
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 18
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        color: "white"
                    }
                }

        /*FlyViewCustomLayer {
            id: customOverlay
            anchors.fill: widgetLayer
            z: _fullItemZorder + 2
            parentToolInsets: widgetLayer.totalToolInsets
            mapControl: _mapControl
            visible: !QGroundControl.videoManager.fullScreen
        }*/

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

                property real pitch:-_activeVehicle.pitch.rawValue.toFixed(2)
                property real lineSpacing: height / 5
                readonly property int totalLines: 37 // -90 a 90 a cada 5 graus

                // Calcula o deslocamento vertical para ajustar o movimento conforme pitch
                property real pitchOffsetY: (pitch+80) / 5 * lineSpacing //+80 pra dar offset inicial, se não o valor 0 do indicador é -80

                Repeater {
                    model: pitchArea.totalLines
                    delegate: Item {
                        width: parent.width
                        height: pitchArea.lineSpacing
                        rotation: _activeVehicle.roll.rawValue.toFixed(1)
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
                            color: hudPaleGreen//"#00FF00"
                            border.width: 1
                            border.color:"black"
                        }

                        Text {
                            visible: angle % 10 === 0
                            text: angle + "°"
                            color: hudPaleGreen//"#00FF00"
                            font.pixelSize: _androidBuild? 18 : ScreenTools.defaultFontPixelWidth*2
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
                color: hudPaleGreen
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
                width: parent.width*1.5
                height: parent.width / 2
                rotation: 5
                // ---------------------------------------------------
                // Conversão de graus de -60 a +60 para ângulo do arco
                // ---------------------------------------------------

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

                    //layer.enabled: true
                    //layer.smooth: true
                    layer.effect: DropShadow {
                        color: "black"
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 2
                        smooth: true
                        samples: 32
                        spread: 0.8
                    }


                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.clearRect(0, 0, width, height)

                        var centerX = width / 2
                        var centerY = height / 2
                        var radius = Math.min(width, height) / 2.5

                        // -----------------------
                        // Arco principal (verde)
                        // -----------------------
                        ctx.strokeStyle = hudPaleGreen
                        ctx.lineWidth = 5
                        ctx.beginPath()
                        ctx.arc(centerX, centerY, radius - 10,
                                start_roll_angle, end_roll_angle, false)
                        ctx.stroke()

                        // -----------------------------------------
                        // Listras das marcações -60..60
                        // -----------------------------------------
                        var marcacoes = [-60, -45, -30, -20, -10, 0, 10, 20, 30, 45, 60]

                        for (var i = 0; i < marcacoes.length; i++) {
                            var deg = marcacoes[i]
                            var rad = degToArcRad(deg)

                            var innerRadius = radius - 10
                            var outerRadius

                            // Listras maiores
                            if (deg === -60 || deg === -30 || deg === 30 || deg === 60)
                                outerRadius = radius + 25
                            else
                                outerRadius = radius + 5

                            var xStart = centerX + innerRadius * Math.cos(rad)
                            var yStart = centerY + innerRadius * Math.sin(rad)
                            var xEnd = centerX + outerRadius * Math.cos(rad)
                            var yEnd = centerY + outerRadius * Math.sin(rad)

                            ctx.beginPath()
                            ctx.moveTo(xStart, yStart)
                            ctx.lineTo(xEnd, yEnd)
                            ctx.stroke()
                        }
                    }

                    // Atualização do roll vindo do veículo
                    Timer {
                        interval: 50; running: true; repeat: true
                        onTriggered: {
                            parent.requestPaint()
                            var rollDeg = _activeVehicle.roll.rawValue   // -150..150 possível
                            rollDeg = Math.max(-60, Math.min(60, rollDeg)) // limita para -60..60

                            parent.angleRoll = degToArcRad(rollDeg)
                        }
                    }
                }

                // --------------------------
                // PONTEIRO
                // --------------------------
                QGCColoredImage {
                    id: pointerRoll
                    width: dialRoll.width / 15
                    height: dialRoll.height / 2
                    anchors.horizontalCenter: rollArc.horizontalCenter
                    anchors.verticalCenter: rollArc.verticalCenter
                    anchors.verticalCenterOffset: -dialRoll.height/4

                    color: hudPaleGreen
                    source: "/qmlimages/rollPointer.svg"
                    transformOrigin: Item.Bottom

                    // Converte radianos para graus e alinha o topo em 0°
                    rotation: (rollArc.angleRoll * 180 / Math.PI) - 270

                    smooth: true
                    //layer.enabled: true
                    //layer.smooth: true
                    layer.effect: DropShadow {
                        color: "black"
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 2
                        smooth: true
                        samples: 32
                        spread: 0.8
                    }
                }
            }
            ///// FIM DO ROLL

            //_activeVehicle.headingToNextWP. rollPointer.svg
            /////COMEÇO DO HEADING
            QGCColoredImage {
                id: headingIndicator
                width: parent.width *0.25
                height: parent.width *0.25
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: pitchArea.bottom
                anchors.margins: _toolsMargin*0.5
                source: "/qmlimages/compassInstrumentDial.svg"
                color: hudPaleGreen
                rotation: -_activeVehicle.heading.rawValue.toFixed(2)
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
                color: hudPaleGreen
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
                color: hudPaleGreen
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
            QGCColoredImage {
                id: pointerHeadingWayPoint
                width: headingIndicator.width / 7
                height: width
                color: hudPaleBlue
                source: "/qmlimages/rollPointer.svg"
                rotation: angle_fixed +90
                smooth: true
                layer.enabled: true
                layer.smooth: true

                // centro da bússola
                property real centerX: headingIndicator.x + headingIndicator.width / 2
                property real centerY: headingIndicator.y + headingIndicator.height / 2

                // raio interno
                property real innerRadius: headingIndicator.width * 0.40

                // heading real do drone
                property real headingActual: _activeVehicle.heading.rawValue

                // heading do waypoint
                property real headingWP: _activeVehicle.headingToNextWP.value

                // ângulo final relativo ao disco da bússola
                property real angle_fixed: (headingWP - headingActual - 90)

                // converter para radianos
                property real angleRad: angle_fixed * Math.PI / 180

                // posição cartesiana
                x: centerX + innerRadius * Math.cos(angleRad) - width/2
                y: centerY + innerRadius * Math.sin(angleRad) - height/2

                // rotação visual do ponteiro (deixo igual ao movimento de posição)
                transform: Rotation {
                    origin.x: pointerHeadingWayPoint.width / 2
                    origin.y: pointerHeadingWayPoint.height / 2
                    angle: angle_fixed
                }

                layer.effect: DropShadow {
                    color: "black"
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 1
                    smooth: true
                    samples: 32
                    spread: 0.5
                }
            }

            QGCColoredImage {
                id: pointerHeadingHome
                width: headingIndicator.width / 7
                height: width
                color: hudPalePurple
                source: "/qmlimages/rollPointer.svg"
                rotation: angle_fixed +90
                smooth: true
                layer.enabled: true
                layer.smooth: true

                // centro da bússola
                property real centerX: headingIndicator.x + headingIndicator.width / 2
                property real centerY: headingIndicator.y + headingIndicator.height / 2

                // raio interno
                property real innerRadius: headingIndicator.width * 0.40

                // heading real do drone
                property real headingActual: _activeVehicle.heading.rawValue

                // heading do waypoint
                property real headingHome: _activeVehicle.headingToHome.value

                // ângulo final relativo ao disco da bússola
                property real angle_fixed: (headingHome - headingActual - 90)

                // converter para radianos
                property real angleRad: angle_fixed * Math.PI / 180

                // posição cartesiana
                x: centerX + innerRadius * Math.cos(angleRad) - width/2
                y: centerY + innerRadius * Math.sin(angleRad) - height/2

                // rotação visual do ponteiro (deixo igual ao movimento de posição)
                transform: Rotation {
                    origin.x: pointerHeadingWayPoint.width / 2
                    origin.y: pointerHeadingWayPoint.height / 2
                    angle: angle_fixed
                }

                layer.effect: DropShadow {
                    color: "black"
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 1
                    smooth: true
                    samples: 32
                    spread: 0.5
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
                    border.color: hudPaleGreen
                    border.width: 1
                }

                Text {
                    text: _activeVehicle.heading.rawValue.toFixed(0).padStart(3, '0') + "°"
                    color: hudPaleGreen
                    font.pixelSize: ScreenTools.defaultFontPixelWidth * 2
                    font.bold: true
                    anchors.centerIn: headingValuetextBox // Centraliza horizontal e verticalmente
                    z: parent.z + 20
                }
            }
            Item {
                id: headingWayPointTextBox
                width: ScreenTools.defaultFontPixelWidth * 10 // Mantém a largura original
                height: ScreenTools.defaultFontPixelHeight
                anchors.right: pointerHeading.left
                anchors.rightMargin: _toolsMargin
                anchors.verticalCenter:  pointerHeading.verticalCenter

                Rectangle {
                    id: headingWayPointValuetextBox
                    anchors.fill: parent
                    color: "black"
                    border.color: hudPaleGreen
                    border.width: 1
                }

                Text {
                    text: " WP: "+_activeVehicle.headingToNextWP.rawValue.toFixed(0).padStart(3, '0') + "°"
                    color: hudPaleBlue
                    font.pixelSize: ScreenTools.defaultFontPixelWidth * 2
                    font.bold: true
                    anchors.centerIn: headingValuetextBox // Centraliza horizontal e verticalmente
                    z: parent.z + 20
                }
            }
            Item {
                id: headingHomeTextBox
                width: ScreenTools.defaultFontPixelWidth * 10 // Mantém a largura original
                height: ScreenTools.defaultFontPixelHeight
                anchors.left: pointerHeading.right
                anchors.leftMargin: _toolsMargin
                anchors.verticalCenter:  pointerHeading.verticalCenter

                Rectangle {
                    id: headingHomeValuetextBox
                    anchors.fill: parent
                    color: "black"
                    border.color: hudPaleGreen
                    border.width: 1
                }

                Text {
                    text: " HM: "+_activeVehicle.headingToHome.rawValue.toFixed(0).padStart(3, '0') + "°"
                    color: hudPalePurple
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
                anchors.rightMargin: _toolsMargin*20
                clip: true
                property real current_value: -_activeVehicle.airSpeed.rawValue.toFixed(2) // Usando o rawValue para cálculo
                property real lineSpacing: height / 10
                readonly property int totalLines: 80 // De -190 a 200 (se o passo for 10)
                readonly property real unitsPerLineSpacing: 5
                readonly property real pixelPerUnit: barraLateralEsquerda.lineSpacing / barraLateralEsquerda.unitsPerLineSpacing
                property real scrollOffsetY: -1 * barraLateralEsquerda.current_value * barraLateralEsquerda.pixelPerUnit

                Rectangle{
                    id: rectAirspeed
                    anchors.fill: parent
                    color: hudGrey
                    border.color: hudPaleGreen
                    border.width: 2
                }


                // ⚙️ Repeater para criar a escala
                Repeater {
                    model: barraLateralEsquerda.totalLines
                    delegate: Item {
                        width: parent.width
                        height: barraLateralEsquerda.lineSpacing
                        property int angle: 190 - index * 5
                        readonly property real indexZero: 190 / 5   // = 38
                        readonly property real centerOffset: barraLateralEsquerda.height/2 - (indexZero * barraLateralEsquerda.lineSpacing)
                        y: ((index - 0.5) * barraLateralEsquerda.lineSpacing)
                           + barraLateralEsquerda.scrollOffsetY
                           + centerOffset

                        visible: y + height >= 0 && y <= barraLateralEsquerda.height

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 0
                            height: 2
                            // Linha longa a cada 10 unidades. Se o passo é 10, todas são longas.
                            width: angle % 10 === 0 ? parent.width * 0.5 : parent.width * 0.25
                            color: hudPaleGreen
                        }

                        Text {
                            // Exibe o texto apenas para múltiplos de 10
                            visible: angle % 10 === 0
                            // Se angle for 0, toFixed(0) é 0.
                            text: angle.toFixed(0)
                            color: hudPaleGreen
                            font.pixelSize: _androidBuild? 15 : ScreenTools.defaultFontPixelWidth*2
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
                    color: hudPaleGreen
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
                    border.color: hudPaleGreen
                    border.width: 1
                    z: airspeedPointer.z +1
                }

                Text {
                    text: _activeVehicle.airSpeed.rawValue.toFixed(1).padStart(3, '0')
                    color: hudPaleGreen
                    font.pixelSize: _androidBuild? ScreenTools.defaultFontPixelWidth * 2 : ScreenTools.defaultFontPixelWidth * 2
                    font.bold: true
                    anchors.centerIn: airspeedValuetextBox // Centraliza horizontal e verticalmente
                    z: parent.z + 20
                }

            }
            // === barra de cores de velocidade ===
            Item {
                id: speedColorBar
                width: barraLateralEsquerda.width * 0.1
                anchors.top: barraLateralEsquerda.top
                anchors.bottom: barraLateralEsquerda.bottom
                anchors.left: barraLateralEsquerda.right
                clip: true
                //anchors.leftMargin: 4

                // conversão unidade → pixel
                property real px_per_unit: barraLateralEsquerda.pixelPerUnit
                property real scroll_y: barraLateralEsquerda.scrollOffsetY
                //readonly property real v_estol: 2.0
                //readonly property real v_segura_min: 5.01
                //readonly property real v_segura_max: 15.44
                //readonly property real v_max: 47.22


                // valores principais (minúsculas)

                // função de conversão para Y
                function y_for(v) {
                    let center = barraLateralEsquerda.height / 2
                    return center - (v * px_per_unit) + scroll_y
                }

                Rectangle {
                    // faixa vermelho (stall)
                    property real v1: -v_segura_min
                    property real v2: v_segura_min
                    width: parent.width
                    y: speedColorBar.y_for(v2)
                    height: Math.abs(v2 - v1) * speedColorBar.px_per_unit
                    color: "red"
                    opacity: 0.75
                    border.width: 1
                    border.color: hudPaleGreen
                }

                Rectangle {
                    property real v1: v_segura_min
                    property real v2: v_segura_max
                    width: parent.width
                    y: speedColorBar.y_for(v2)
                    height: Math.abs(v2 - v1) * speedColorBar.px_per_unit
                    color: "green"
                    opacity: 0.75
                    border.width: 1
                    border.color: hudPaleGreen
                }


                Rectangle {
                    property real v1: v_segura_max
                    property real v2: v_max
                    width: parent.width
                    y: speedColorBar.y_for(v2)
                    height: Math.abs(v2 - v1) * speedColorBar.px_per_unit
                    color: "yellow"
                    opacity: 0.75
                    border.width: 1
                    border.color: hudPaleGreen
                }

                Rectangle {
                    property real v1: v_max
                    property real v2: 80     // limite arbitrário superior
                    width: parent.width
                    y: speedColorBar.y_for(v2)
                    height: Math.abs(v2 - v1) * speedColorBar.px_per_unit
                    color: "red"
                    opacity: 0.75
                    border.width: 1
                    border.color: hudPaleGreen
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
                    border.color: hudPaleGreen
                }
                Text {
                    text: "GS: " + _activeVehicle.groundSpeed.rawValue.toFixed(1).padStart(3, '0')
                    color: hudPaleGreen
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
                anchors.leftMargin: _toolsMargin*20
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
                    border.color: hudPaleGreen
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
                            color: hudPaleGreen
                        }

                        // Texto da escala
                        Text {
                            visible: altitudeScale % 10 === 0
                            text: altitudeScale.toFixed(0)
                            color: hudPaleGreen
                            font.pixelSize: _androidBuild? 14 : ScreenTools.defaultFontPixelWidth*2
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
                    color: hudPaleGreen
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
                    border.color: hudPaleGreen
                    border.width: 1
                    z:altitudePointer.z+1
                }

                Text {
                    text: _activeVehicle.altitudeRelative.rawValue.toFixed(1).padStart(3, '0')
                    color: hudPaleGreen
                    font.pixelSize: _androidBuild? ScreenTools.defaultFontPixelWidth * 1.5 : ScreenTools.defaultFontPixelWidth * 2
                    font.bold: true
                    anchors.centerIn: altitudeValuetextBox // Centraliza horizontal e verticalmente
                    z: parent.z + 20
                }
            }
            Item{
                id: underBarraLateralDireita
                anchors.top: barraLateralDireita.bottom
                anchors.left: barraLateralDireita.left
                width: barraLateralDireita.width
                height:ScreenTools.defaultFontPixelHeight*1.2
                clip: true

                Rectangle{
                    id: lidarSpeedValuetextBox
                    anchors.fill:parent
                    color:"black"
                    anchors.topMargin: -2
                    border.width: 2
                    border.color: hudPaleGreen
                }
                Text {
                    text: "LD: " + _activeVehicle.rangeFinderDist.value.toFixed(1).padStart(3,'0')
                    color: hudPaleGreen
                    font.pixelSize: _androidBuild? ScreenTools.defaultFontPixelWidth * 1.5 : ScreenTools.defaultFontPixelWidth * 2
                    font.bold: true
                    anchors.centerIn: lidarSpeedValuetextBox // Centraliza horizontal e verticalmente
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
                    border.color: hudPaleGreen

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

                            color: hudPaleGreen
                        }

                        // Texto da escala
                        Text {
                            // Exibe o texto apenas para múltiplos de 5 (ex: -10, -5, 0, 5, 10)
                            visible: verticalScale % 1 === 0
                            // Formata o texto: 0 casas decimais para inteiros, 1 casa decimal caso contrário (embora só mostre múltiplos de 5)
                            text: verticalScale.toFixed(0)

                            color: hudPaleGreen
                            font.pixelSize: _androidBuild? 15 : ScreenTools.defaultFontPixelWidth*2
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
                    color: hudPaleGreen
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
                    border.color: hudPaleGreen
                    border.width: 1
                    z: climbSpeedPointer.z+1
                }

                Text {
                    text: _activeVehicle.climbRate.rawValue.toFixed(1).padStart(3, '0')
                    color: hudPaleGreen
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
                visible: false//true
                Text {
                    anchors.centerIn: parent
                    text: requestedAlerts
                    font.bold: false
                    visible: false//true

                     font.pixelSize: _androidBuild? 12 : 14
                }
            }
        }





    }
}

