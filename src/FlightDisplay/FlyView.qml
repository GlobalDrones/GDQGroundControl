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

    property real  mainViewHeight: parent.height*5/6
    property real  mainViewWidth : parent.width - (parent.height - mainViewHeight) //garantir simetria
    property bool _cameraExchangeActive : false
    property var _pct_bateria_1: 0//_activeVehicle.batteries.get(0).percentRemaining.valueString + "%"
    property var _tensao_bateria_1:  0 //modificado em MainWindow
    property var _current_bateria_1:  0

    property var _pct_bateria_2: 0//_activeVehicle.batteries.get(0).percentRemaining.valueString + "%"
    property var _tensao_bateria_2:  0 //modificado em MainWindow
    property var _current_bateria_2:  0

    property var _current_generator: 0
    property real _gasolina: 50//_activeVehicle.batteries.get(1).voltage (P/ GD25)

    property int _battery1Index: 0
    property int _battery2Index: 0
    property int _gasolineIndex: 1
    property int _generatorIndex: 2


    property int _satCount: 0
    property int _satPDOP: 0
    property var _rcQuality: 0
    property var _rcQuality_ARRAY: []
    property var _rcQuality_mean: 0
    property var _current_battery_ARRAY: []
    property var _current_generator_ARRAY: []
    property var _returnFunctionArray: []
    property bool flagAlertaGerador: false
    property var oldGeneratorMediamValue: 0
    property int  maxGeneratorCurrent: 120
    property var  _distanceToHome:     _activeVehicle.distanceToHome.rawValue.toFixed(2)
    property var  _distanceToWP: _activeVehicle.distanceToNextWP.rawValue.toFixed(2)
    property var _mavlinkLossPercent: _activeVehicle.mavlinkLossPercent.rawValue


    property real _tensao_cell_1: 50 //PLACEHOLDER
    property real _tensao_cell_2: 45 //PLACEHOLDER
    property real _tensao_cell_3: 70 //PLACEHOLDER
    property real _tensao_cell_4: 20 //PLACEHOLDER
    property real _tensao_cell_5: 80 //PLACEHOLDER
    property real _tensao_cell_6: 50 //PLACEHOLDER
    property real _tensao_cell_7: 60 //PLACEHOLDER
    property real _tensao_cell_8: 28 //PLACEHOLDER
    property real _tensao_cell_9: 80 //PLACEHOLDER
    property real _tensao_cell_10: 50 //PLACEHOLDER
    property real _tensao_cell_11: 40 //PLACEHOLDER
    property real _tensao_cell_12: 90 //PLACEHOLDER

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

    property bool overrideActive: false
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
    property var array_valores_rc: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    property bool override_first_clicked: false;

    property var lastRcOverrideTimestamp;
    property var activeOverrideID: -1;

    property var gcsID: -1;

    property real _groundSpeed: 0
    property real _altitudeAMSL: 0
    property int _flightTime:0

    Timer {
        id: breachCooldownTimer
        interval: 10000 // cooldown de 10 segundos
        running: false
        repeat: false
        onTriggered: canShowBreachAlert = true
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
        id: gasolineValuesUpdater
        interval: 100
        running: true
        repeat: true

        onTriggered:{
            //console.log( "Firmware Detectado:", _activeVehicle.firmwareTypeString ,"major:", _activeVehicle.firmwareMajorVersion.toString() , _activeVehicle.firmwareMinorVersion.toString())
            _gasolina = _activeVehicle.batteries.get(_gasolineIndex).percentRemaining.value
            horas_restantes = Math.floor((7200*(_gasolina/100))/3600)
            minutos_restantes = Math.floor(((7200*(_gasolina/100))%3600)/60)
            segundos_restantes = (7200 * (_gasolina/100))%60

            //console.log("TESTERPMFLYVIEW: ",_activeVehicle._GD_GeneratorRPM.rawValue.toFixed(0))

            if(horas_restantes<10) {horas_restantes_string = "0"+horas_restantes.toString()}
            else {horas_restantes_string = horas_restantes.toString()}
            if(minutos_restantes < 10){ minutos_restantes_string = "0" +minutos_restantes.toString()}
            else {minutos_restantes_string = minutos_restantes.toString()}
            if(segundos_restantes <10) {segundos_restantes_string = "0" + segundos_restantes.toString()}
            else {segundos_restantes_string = segundos_restantes.toString()}

            _groundSpeed = _activeVehicle.groundSpeed.value.toFixed(1)
            _altitudeAMSL = _activeVehicle.altitudeAMSL.value
            _flightTime = (_activeVehicle.flightTimeCustom.value).toFixed(0)

            //widgetLayer.visible_custom_telemetry= false
        }
    }

    Timer{
        id: propertyValuesUpdater
        interval: 100
        running: true
        repeat: true

        onTriggered:{
            /*console.log("TESTING BATTERY ACCESS")
            console.log(_activeVehicle.batteries.count)
            console.log(_activeVehicle.batteries.get(0).voltage.rawValue)
            console.log(_activeVehicle.batteries.columnCount())
            console.log(_activeVehicle.batteries.get(1).voltage.rawValue)*/
            //console.log(_activeVehicle.batteries.index(1,0).voltage.rawValue)
            gcsID = QGroundControl.mavlinkSystemID.valueOf(); //tem que ficar atualizando. tem jeito melhor pra fazer mas isso é pequisa futura e o desempenho ta satisfatório pra agora
            //console.log("ID DA GCS: ",gcsID);
            if(_activeVehicle.firmwareMajorVersion.toString() == "255"){ // Caso esteja rodando nosso Ardupilot custom (Major Version 255)
                let allMessages = _activeVehicle.formattedMessages;
                    let lines = allMessages.split("<br/>").filter(line => line.trim() !== "");

                    if (lines.length > 0) {
                        let lastLine = lines[lines.length - 1].replace(/<[^>]*>/g, "");

                        // 1. Regex para capturar o Tempo e o ID (Grupo 5)
                        // Note o [ID: (\d+)] no final para pegar o número
                        let match = lastLine.match(/\[(\d{2}):(\d{2}):(\d{2})\.(\d{3})\].*RC Override: Ativo \[ID: (\d+)\]/);

                        if (match) {
                            // Se entramos aqui, a ÚLTIMA mensagem é um "Ativo"
                            let msgTime = new Date();
                            msgTime.setHours(parseInt(match[1]), parseInt(match[2]), parseInt(match[3]), parseInt(match[4]));

                            // Atualizamos o timestamp de controle com o tempo da MENSAGEM
                            lastRcOverrideTimestamp = msgTime.getTime();
                            activeOverrideID = parseInt(match[5]);
                            overrideActive = true;
                        }
                        else if (lastLine.includes("RC Override") && !lastLine.includes("Ativo")) {
                            // Se a última mensagem for explicitamente de desativação
                            overrideActive = false;
                            activeOverrideID = -1;

                        }
                    }

                    // 2. Lógica de Expiração (independente de qual seja a última mensagem)
                    if (overrideActive) {
                        let now = new Date().getTime();
                        let diffMs = now - lastRcOverrideTimestamp;

                        // Se passou de 7.5 segundos desde a última mensagem de "Ativo" encontrada
                        if (diffMs > 7500) {
                            overrideActive = false;
                            activeOverrideID = -1;
                            console.log("RC Override expirou por tempo (7.5s)");
                        }
                    }
                }

                _pct_bateria_1 = ((((_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2) - 42)/8.2)*100).toFixed(2)//(((_activeVehicle.batteries.get(0).voltage.rawValue/100)/50)*10000).toFixed(2)//_activeVehicle.batteries.get(0).percentRemaining.rawValue
                _tensao_bateria_1 = (_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2)
                _current_bateria_1 = (_activeVehicle.batteries.get(_battery1Index).current.rawValue).toFixed(2)




            _satCount = _activeVehicle.gps.count.rawValue
            _satPDOP = _activeVehicle.gps.lock.rawValue

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

                breachAlertPopup.open()
                breachAlertPopup.visible = true
                canShowBreachAlert = false
                breachCooldownTimer.start()
            }

            // console.log(_activeVehicle.rcRSSI.valueOf())
            //_gasolina = _activeVehicle.batteries.index(0,1).voltage.rawValue
            //console.log("Gasolina: ",_activeVehicle.batteries.get(_gasolineIndex).percentRemaining,"|",)
            if(_activeVehicle.rcRSSI != 0){
                _rcQuality = _activeVehicle.rcRSSI//(100 - _activeVehicle.mavlinkLossPercent.valueOf().toFixed(1)).toFixed(1)
                _rcQuality_ARRAY.push(_rcQuality)
                if(_rcQuality_ARRAY.length === 10){
                    var qual_temp1 = 0;
                    for(var i =0; i<10; i++){
                        qual_temp1 = _rcQuality_ARRAY[i] + qual_temp1
                    }
                    qual_temp1 = qual_temp1/10
                    _rcQuality_mean = qual_temp1
                    _rcQuality_mean = _rcQuality_mean.toFixed(0)
                    _rcQuality_ARRAY.shift();
                }
                //console.log("RCQUALITY: ",_rcQuality, " MEDIA: ",_rcQuality_mean, " ARRAY: ", _rcQuality_ARRAY)
            }

            /*console.log("poly count: ",_geoFenceController.polygons.count.toString())
            console.log("  poly 0 -> ",_geoFenceController.polygons.get(0).path)
            console.log("  poly first NS coord -> ",_geoFenceController.polygons.get(0).path[0])
            console.log("  poly first WE coord -> ",_geoFenceController.polygons.get(0).path[1])
            console.log("  vehicle pos -> ", _activeVehicle.coordinate.toString())*/




                aceleracao_rotor_1_ARRAY.push(_aceleracao_rotor_1)
                aceleracao_rotor_2_ARRAY.push(_aceleracao_rotor_2)
                aceleracao_rotor_3_ARRAY.push(_aceleracao_rotor_3)
                aceleracao_rotor_4_ARRAY.push(_aceleracao_rotor_4)
                aceleracao_rotor_5_ARRAY.push(_aceleracao_rotor_5)
                aceleracao_rotor_6_ARRAY.push(_aceleracao_rotor_6)

            _current_generator_ARRAY.push(_current_generator)

            // console.log("maxvel: ",_maxVel)
            //var params = _activeVehicle.parameterNames(1); // Chama a função C++
            //console.log("Parameters:", params); // Imprime no console do QML
            //params.forEach(param => console.log(param.toString())); //TODO: typeError. QStringList e QString não são reconhecidos pelo QML padrão. Resolver isso depois
            _current_generator = _activeVehicle.batteries.get(_generatorIndex).current.rawValue.toFixed(2)
            _current_bateria_1 = _activeVehicle.batteries.get(_battery1Index).current.rawValue.toFixed(2)



            if(_current_generator_ARRAY.length >= 20){ //sabendo que recebemos um dado novo a cada 0.1 segundos, (ver c/ Erich)
                _returnFunctionArray = generatorAlert(_current_battery_ARRAY, _current_generator_ARRAY, oldGeneratorMediamValue);//executa função
                flagAlertaGerador = _returnFunctionArray[0]; //atualiza flag geral com valor booleano retornado da função
                oldGeneratorMediamValue = _returnFunctionArray[1]; //atualiza valor de média
                _current_battery_ARRAY.shift(); //apaga primeiro elemento (ver c/Erich se é pra apagar o primeiro elemento ou todos)
                _current_generator_ARRAY.shift();
                //console.log(_current_battery_ARRAY);
                //console.log(_current_generator_ARRAY);
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


    //**************************************************************************************************//
    //                          BOTTOM VIEW AREA                                                        //
    //**************************************************************************************************//
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
                        visible:true
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
                        hoverEnabled: true
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
                            font.pixelSize:         20
                        }
                        Text {
                            Layout.alignment:       Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   "RPM: "
                            font.bold: true
                            font.pixelSize:         20
                        }
                        Text {
                            Layout.alignment:       Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _activeVehicle._GD_GeneratorRPM.rawValue.toFixed(0).toString()
                            font.bold: true
                            font.pixelSize:         20
                        }
                    }



                    Rectangle {
                        id: rotorsTempArea
                        anchors.top: parent.top
                        anchors.left: motorTempInfoColumn.right
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

                                    accellRotorModel.set(0, { aceleracao: _activeVehicle._GD_RPM1.rawValue.toFixed(0)/3850 });
                                    accellRotorModel.set(1, { aceleracao: _activeVehicle._GD_RPM2.rawValue.toFixed(0)/3850 });
                                    accellRotorModel.set(2, { aceleracao: _activeVehicle._GD_RPM3.rawValue.toFixed(0)/3850 });
                                    accellRotorModel.set(3, { aceleracao: _activeVehicle._GD_RPM4.rawValue.toFixed(0)/3850 });
                                    accellRotorModel.set(4, { aceleracao: _activeVehicle._GD_RPM5.rawValue.toFixed(0)/3850 });
                                    accellRotorModel.set(5, { aceleracao: _activeVehicle._GD_RPM6.rawValue.toFixed(0)/3850 });



                            }
                        }

                        Repeater {
                            model: accellRotorModel

                            Rectangle {
                                width: parent.width / 6
                                height: model.aceleracao* parent.height // Altura proporcional à aceleracao
                                x: index * parent.width / 6 // Posiciona horizontalmente
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


                    Item {
                        id: _dataBox
                        height: parent.height * 2/3
                        width: parent.width*0.45
                        anchors.top: parent.top
                        anchors.left: rotorsTempArea.right
                        anchors.margins: _toolsMargin * 1.5
                        property int _borderWidth: 2
                        property int _fontSize: 10//_androidBuild ?  15 : 20

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
                                        text: "Generator Current " + _dataBox.formatNumber(_current_generator, 2)+"A"
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
                                        text: {
                                            var totalSeconds = _activeVehicle.flightTimeCustom.rawValue
                                            var hours = Math.floor(totalSeconds / 3600)
                                            var minutes = Math.floor((totalSeconds % 3600) / 60)
                                            var seconds = Math.floor(totalSeconds % 60)

                                            // Formata para garantir dois dígitos (00:00:00)
                                            return "Flighttime: " + (hours > 0 ? (hours < 10 ? "0" + hours : hours) + ":" : "00:") +
                                                   (minutes < 10 ? "0" + minutes : minutes) + ":" +
                                                   (seconds < 10 ? "0" + seconds : seconds)
                                        }
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
                                        text: "Battery Current " + _dataBox.formatNumber(_current_bateria_1, 2)
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
                                        text: "Ground Speed: " + _dataBox.formatNumber(_groundSpeed, 2)+"m/s"
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
                                        text: "Altitude AMSL: " + _dataBox.formatNumber(_altitudeAMSL, 2)+"m"
                                        font.bold: true
                                        font.pointSize: _dataBox._fontSize
                                        color: "white"
                                    }
                                }
                            }
                        }
                    }

                    Item{
                        width: parent.width*0.35
                        //height: parent.height *2/3
                        anchors.top: parent.top
                        //anchors.bottom: parent.bottom
                        anchors.left: _dataBox.right


                        Loader {
                            width:  parent.width/2
                            source: "qrc:/qml/QGCInstrumentWidget.qml"

                        }
                    }


                }

            }
        }


    //**************************************************************************************************//
    //                          LATERAL VIEW AREA                                                       //
    //**************************************************************************************************//
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
                            text:                   _activeVehicle.distanceToHome.value === "NaN"? 0 : _activeVehicle.distanceToHome.value.toFixed(2)+"m"
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
                            text:                   _activeVehicle.distanceToNextWP.value == "NaN"? 0 : _activeVehicle.distanceToNextWP.value+"m"
                            //font.pixelSize:         _androidBuild ?  26 : 24//ScreenTools.smallFontPixelHeight
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
                            text:                   _activeVehicle.rangeFinderDist.value.toFixed(2) + "m" //altitudeRelative.value*10)/10 + "m"
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
                            text:                   Math.round(_activeVehicle.altitudeAMSL.value*10)/10 + "m"
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
        }
    }

    //**************************************************************************************************//
    //                          MAIN VIEW AREA                                                          //
    //**************************************************************************************************//
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


        /*GuidedActionConfirm {
                id:                         guidedActionConfirm
                anchors.margins:            _margins
                anchors.bottom:             parent.bottom
                anchors.horizontalCenter:   parent.horizontalCenter
                z:                          QGroundControl.zOrderTopMost
                guidedController:           _guidedController
                altitudeSlider:             _guidedAltSlider
            }*/
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
                visible: parent.open()

                Text {
                    anchors.centerIn: parent
                    text: popUp_breachAlert
                    font.bold: true
                    visible: parent.visible
                     font.pixelSize: _androidBuild? 16 : 20
                }
            }
        }

        Item {
            id: cameraControlOverlay
            z: QGroundControl.zOrderTopMost
            visible: QGroundControl.videoManager.hasVideo

            // Lista com pares: texto + URL correspondente
            /*property var cameraList: [
                { name: "Video 1", url: "rtsp://192.168.144.25:8554/video1" },
                { name: "Video 2", url: "rtsp://192.168.144.25:8554/video2" },
                { name: "FPV",     url: "rtsp://192.168.144.26:554/main.264" }
            ]*/
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

        Rectangle {
                    id: btnOverride
                    width: parent.width*0.15
                    height: parent.height*0.1
                    radius: 5
                    color: overrideActive ? ((activeOverrideID===-1 || activeOverrideID===gcsID) ? "red":"grey") : "green"  // cor dinâmica. Ativado mas
                    border.color: "black"
                    border.width: 1
                    //anchors.horizontalCenter:  parent.horizontalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottomz
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

    }
}
