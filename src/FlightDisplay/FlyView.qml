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

    property bool _GD60: false

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
    property real _gasolina: 50//_activeVehicle.batteries.get(1).voltage

    property int _battery1Index: _GD60? 0:0
    property int _gasolineIndex: _GD60? 0:1
    property int _generatorIndex: _GD60? 0:2
    property int _battery2Index: _GD60? 0:0

    property int _satCount: 0
    property int _satPDOP: 0
    property var _rcQuality: 0
    property var _rcQuality_ARRAY: []
    property var _rcQuality_mean: 0
    property var _current_battery_ARRAY: []
    property var _current_generator_ARRAY: []
    property var _returnFunctionArray: []
    property bool flagAlertaGerador: false
    property real oldGeneratorMediamValue: 0
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

    property real _maxVel: _activeVehicle.parameterManager.componentIds()


    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    property var res_x: parent.width
    property var res_y: parent.height
    property real radianPI: Math.PI/180

    property string popUp_breachAlert
    property string _breachAlertColor

    property bool canShowBreachAlert: true

    Timer {
        id: breachCooldownTimer
        interval: 10000 // cooldown de 10 segundos
        running: false
        repeat: false
        onTriggered: canShowBreachAlert = true
    }

    ListModel {
        id: ipModel
        // você pode pré‑popular se quiser:
        // ListElement { url: _videoSettings.rtspUrl.rawValue }
    }
    Component.onCompleted: {
        var loaded = QGroundControl.videoManager.loadSavedUrls()
        console.log("✅ URLs carregadas do C++:", loaded)
        ipModel.clear()
        for (var i = 0; i < loaded.length; ++i) {
            ipModel.append({"url": loaded[i].url})
            console.log("✅ Adicionado ao ipModel:", loaded[i].url)
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

    /*
            console.log("poly count: ",_geoFenceController.polygons.count.toString())
            console.log("  poly 0 -> ",_geoFenceController.polygons.get(0).path)
            console.log("  poly first NS coord -> ",_geoFenceController.polygons.get(0).path[0])
            console.log("  poly first WE coord -> ",_geoFenceController.polygons.get(0).path[1])
            console.log("  vehicle pos -> ", _activeVehicle.coordinate.toString())
    */

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
            /*console.log("TESTING BATTERY ACCESS")
            console.log(_activeVehicle.batteries.count)
            console.log(_activeVehicle.batteries.get(0).voltage.rawValue)
            console.log(_activeVehicle.batteries.columnCount())
            console.log(_activeVehicle.batteries.get(1).voltage.rawValue)*/
            //console.log(_activeVehicle.batteries.index(1,0).voltage.rawValue)

            _pct_bateria_1 = ((((_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2) - 42)/8.2)*100).toFixed(2)//(((_activeVehicle.batteries.get(0).voltage.rawValue/100)/50)*10000).toFixed(2)//_activeVehicle.batteries.get(0).percentRemaining.rawValue
            _tensao_bateria_1 = (_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2)
            _current_bateria_1 = (_activeVehicle.batteries.get(_battery1Index).current.rawValue).toFixed(2)

            _pct_bateria_2 = ((((_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2) - 20)/5.2)*100).toFixed(2)//(((_activeVehicle.batteries.get(0).voltage.rawValue/100)/50)*10000).toFixed(2)//_activeVehicle.batteries.get(0).percentRemaining.rawValue
            _tensao_bateria_2 = (_activeVehicle.batteries.get(_battery1Index).voltage.rawValue).toFixed(2)
            _current_bateria_2 = (_activeVehicle.batteries.get(_battery1Index).current.rawValue).toFixed(2)

            _satCount = _activeVehicle.gps.count.rawValue
            _satPDOP = _activeVehicle.gps.lock.rawValue


            // console.log(_activeVehicle.rcRSSI.valueOf())
            _gasolina = _activeVehicle.batteries.get(_gasolineIndex).percentRemaining.rawValue//_activeVehicle.batteries.index(0,1).voltage.rawValue


            _rcQuality = _activeVehicle.rcSSI//(100 - _activeVehicle.mavlinkLossPercent.valueOf().toFixed(1)).toFixed(1)
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

            //_gasolina = 15
            horas_restantes = Math.floor((7200*(_gasolina/100))/3600)
            minutos_restantes = Math.floor(((7200*(_gasolina/100))%3600)/60)
            segundos_restantes = (7200 * (_gasolina/100))%60



            if(horas_restantes<10) {horas_restantes_string = "0"+horas_restantes.toString()}
            else {horas_restantes_string = horas_restantes.toString()}
            if(minutos_restantes < 10){ minutos_restantes_string = "0" +minutos_restantes.toString()}
            else {minutos_restantes_string = minutos_restantes.toString()}
            if(segundos_restantes <10) {segundos_restantes_string = "0" + segundos_restantes.toString()}
            else {segundos_restantes_string = segundos_restantes.toString()}

            /*console.log("poly count: ",_geoFenceController.polygons.count.toString())
            console.log("  poly 0 -> ",_geoFenceController.polygons.get(0).path)
            console.log("  poly first NS coord -> ",_geoFenceController.polygons.get(0).path[0])
            console.log("  poly first WE coord -> ",_geoFenceController.polygons.get(0).path[1])
            console.log("  vehicle pos -> ", _activeVehicle.coordinate.toString())*/

            var breach_val = breachDetection()
            if (breach_val.level > -1 && canShowBreachAlert) {
                //console.log("VIOLACAO DE ESPAÇO AEREO NÍVEL ", breach_val.level + 1)

                if (breach_val.level === 0) {
                    popUp_breachAlert = "Invasão do Volume de Contingência!"
                    _breachAlertColor = "Yellow"
                }
                if (breach_val.level === 1) {
                    popUp_breachAlert = "Invasão do Volume de Ground Risk Buffer!"
                    _breachAlertColor = "Orange"
                }

                breachAlertPopup.open()
                canShowBreachAlert = false
                breachCooldownTimer.start()
            }

            //console.log(horas_restantes,minutos_restantes,segundos_restantes)
            //console.log(res_x, res_y)

            //update()


            //Monitoramento do gerador TODO: DESCOMENTAR DEPOIS
            //_current_battery_ARRAY.push(_current_bateria_1) //populando dinamicamente array de valores de corrente da bateria
            //_current_generator_ARRAY.push(_current_generator)//populando dinamicamente array de valores de corrente do gerador
            if(_GD60){
                if (_activeVehicle.armed || _activeVehicle.flying){
                    _aceleracao_rotor_1 = Math.random() * (555-480) + 480
                    _aceleracao_rotor_2 = Math.random() * (555-480) + 480
                    _aceleracao_rotor_3 = Math.random() * (555-480) + 480
                    _aceleracao_rotor_4 = Math.random() * (555-480) + 480
                }
            }
            else{
                _current_generator_ARRAY.push(_current_generator)
                aceleracao_rotor_1_ARRAY.push(_aceleracao_rotor_1)
                aceleracao_rotor_2_ARRAY.push(_aceleracao_rotor_2)
                aceleracao_rotor_3_ARRAY.push(_aceleracao_rotor_3)
                aceleracao_rotor_4_ARRAY.push(_aceleracao_rotor_4)
                aceleracao_rotor_5_ARRAY.push(_aceleracao_rotor_5)
                aceleracao_rotor_6_ARRAY.push(_aceleracao_rotor_6)
            }

            //AQUI PRA CIMA É SÓ PRA TESTE
            // console.log((oldGeneratorMediamValue/20)/maxGeneratorCurrent, (40/maxGeneratorCurrent))
            //_mavlinkLossPercent = _activeVehicle.mavlinkLossPercent.rawValue

            // console.log("maxvel: ",_maxVel)
            //var params = _activeVehicle.parameterNames(1); // Chama a função C++
            //console.log("Parameters:", params); // Imprime no console do QML
            //params.forEach(param => console.log(param.toString())); //TODO: typeError. QStringList e QString não são reconhecidos pelo QML padrão. Resolver isso depois
            _current_generator = _activeVehicle.batteries.get(_generatorIndex).current.rawValue.toFixed(2)
            _current_bateria_1 = _activeVehicle.batteries.get(_battery1Index).current.rawValue.toFixed(2)



            if(_current_generator_ARRAY.length === 20){ //sabendo que recebemos um dado novo a cada 0.1 segundos, (ver c/ Erich)
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
                for (var i = 0; i<20; i++){
                    temp1 = temp1 + aceleracao_rotor_1_ARRAY[i];
                    temp2 = temp2 + aceleracao_rotor_2_ARRAY[i];
                    temp3 = temp3 + aceleracao_rotor_3_ARRAY[i];
                    temp4 = temp4 + aceleracao_rotor_4_ARRAY[i];
                    temp5 = temp5 + aceleracao_rotor_5_ARRAY[i];
                    temp6 = temp6 + aceleracao_rotor_6_ARRAY[i];
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
            //console.log(_pct_bateria_1)
            //console.log(_pct_bateria_1/100)
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
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _pct_bateria_1 > 9? _pct_bateria_1+"%": "0"+_pct_bateria_1+"%"
                            font.pixelSize:       _androidBuild ?  13 : 21//ScreenTools.smallFontPixelHeight
                            visible: textBoxBatteryInfo_1.visible
                            font.bold: true
                        }
                        Text {
                            id: textBoxBatteryInfo_1TENSION
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _tensao_bateria_1 + " V"
                            font.pixelSize:         _androidBuild ?  13 : 21///ScreenTools.smallFontPixelHeight
                            visible: textBoxBatteryInfo_1.visible
                            font.bold: true
                        }
                        Text {
                            id: textBoxBatteryInfo_1CURRENT
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _current_bateria_1 + " A"
                            font.pixelSize:         _androidBuild ?  13 : 21///ScreenTools.smallFontPixelHeight
                            visible: textBoxBatteryInfo_1.visible
                            font.bold: true
                        }

                    }
                }

                QGCColoredImage {
                    id: batteryPercentageIcon_2
                    anchors.top:        parent.top
                    anchors.left:       textBoxBatteryInfo_1.right
                    anchors.margins:    _toolsMargin
                    width:              height
                    height:             parent.height*2/3
                    source:             "/qmlimages/Battery.svg"
                    fillMode:           Image.PreserveAspectFit
                    color:              "white"
                    visible: _GD60//true
                }

                Rectangle{
                    id: batteryPercentageBar_2
                    anchors.top: batteryPercentageIcon_2.top
                    anchors.left: batteryPercentageIcon_2.left
                    //anchors.margins: _toolsMargin
                    width: batteryPercentageIcon_2.width
                    height: batteryPercentageIcon_2.height
                    color: "transparent"//batMouseArea.containsMouse? "green": "red"
                    visible: false
                    Rectangle{
                        y: parent.height*0.1
                        anchors.horizontalCenter: parent.horizontalCenter
                        //anchors.left: parent.left
                        width: parent.width/2
                        height: parent.height*0.85 //fixo pra não ultrapassar o desenho
                        color: (_pct_bateria_2) > 50 ? "green" : ((_pct_bateria_2) > 30 ? "orange" : "red") //cor dinamica de acordo com o _pct_bateria_1
                    }
                    Rectangle{ //BARRA DE ALTURA DINAMICA PRA INDICAR O NÍVEL DE bateria -> HEIGHT = 1-bateria%

                        anchors.horizontalCenter: parent.horizontalCenter
                        //anchors.left: parent.left
                        width: parent.width/2
                        height: parent.height*(0.15 + 0.85*(1-_pct_bateria_2/100) )// bateria | dinamico de acordo com 1-(% bateria). cor há de ser dinamica também
                        color: qgcPal.toolbarBackground
                    }

                }

                OpacityMask{
                    anchors.fill: batteryPercentageBar_2
                    source: batteryPercentageBar_2
                    maskSource: batteryPercentageIcon_2
                    invert: true
                    MouseArea{
                        id: batMouseArea_2
                        anchors.fill: parent
                        hoverEnabled : true

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
                    visible: _GD60//true//batMouseArea_1.containsMouse? true: false
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
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _pct_bateria_2 > 9? _pct_bateria_2+"%": "0"+_pct_bateria_2+"%"
                            font.pixelSize:       _androidBuild ?  13 : 21//ScreenTools.smallFontPixelHeight
                            visible: _GD60//textBoxBatteryInfo_1.visible
                            font.bold: true
                        }
                        Text {
                            id: textBoxBatteryInfo_2TENSION
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _tensao_bateria_2 + " V"
                            font.pixelSize:         _androidBuild ?  13 : 21///ScreenTools.smallFontPixelHeight
                            visible: _GD60//textBoxBatteryInfo_1.visible
                            font.bold: true
                        }
                        Text {
                            id: textBoxBatteryInfo_2CURRENT
                            Layout.alignment:       Qt.AlignHCenter
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
                    anchors.left: _GD60 ? textBoxBatteryInfo_2.right :textBoxBatteryInfo_1.right
                    anchors.rightMargin: _toolsMargin
                    anchors.leftMargin: _toolsMargin*2
                    anchors.topMargin: _toolsMargin
                    width: gasolineIconLoader.item ? gasolineIconLoader.item.height : 0
                    height: parent.height * 2 / 3
                    active: false  // set true when you want to load it
                    visible: gasolineIconLoader.item ? gasolineIconLoader.item.visible : false

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
                    source: gasolineIconLoader
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
                    //anchors.fill:parent
                    id: generatorCurrentBar
                    anchors.left: generatorFunctionalityIcon.right
                    anchors.top: parent.top
                    anchors.leftMargin: _toolsMargin*2
                    anchors.topMargin:  _toolsMargin*2
                    width:height/3
                    height: parent.height*2/3
                    color:"green"
                    //z:1000000
                    Rectangle{
                        anchors.top:generatorCurrentBar.top
                        anchors.left:generatorCurrentBar.left
                        width:generatorCurrentBar.width
                        height: _current_generator >= 0 ?  generatorCurrentBar.height * (1-(_current_generator/maxGeneratorCurrent)): generatorCurrentBar.height
                        color:"black"
                    }
                    Rectangle{
                        anchors.fill:parent
                        border.width:2
                        border.color: "lightgray"
                        color:"transparent"
                    }
                    Rectangle{
                        anchors.horizontalCenter: generatorCurrentBar.horizontalCenter
                        width: generatorCurrentBar.width + _toolsMargin
                        height: generatorCurrentBar.height/20
                        y: generatorCurrentBar.height*(oldGeneratorMediamValue/20)/maxGeneratorCurrent
                        color: "white"
                        border.width:1
                        border.color:"black"
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
                        Layout.alignment:       Qt.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   _current_generator + "A"
                        font.bold: true
                        //font.pointSize:         ScreenTools.mediumFontPixelHeight
                    }

                }



                //satelite https://forest-gis.com/2018/01/acuracia-gps-o-que-sao-pdop-hdop-gdop-multi-caminho-e-outros.html/?srsltid=AfmBOorX7DD9JggA1vLTP2DuhOK44T28jHasCbLA0nv5nSnLX7irYLlW
                //activeVehicle.gps.count.rawValue (NUM SATELITES); _activeVehicle.gps.hdop.rawValue (HDOP); globals.activeVehicle.gps.lock.rawValue (PDOP)
                QGCColoredImage {
                    id: satteliteInformationIcon
                    anchors.top:        parent.top
                    anchors.left:       generatorCurrentBar.right
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
                        Layout.alignment:       Qt.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   "Count: " + _satCount
                        font.bold: true
                        font.pixelSize:         _androidBuild ?  13 : 24
                    }
                    Text {
                        Layout.alignment:       Qt.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   "PDOP: "+ _satPDOP
                        font.bold: true
                        font.pixelSize:         _androidBuild ?  13 : 24
                        //font.pointSize:         ScreenTools.mediumFontPixelHeight
                    }

                }

                //enlace
                QGCColoredImage {
                    id: rcInformationIcon
                    anchors.top:        parent.top
                    anchors.left:       textBoxSatteliteInfo.right
                    //anchors.leftMargin: _toolsMargin
                    anchors.topMargin:  _toolsMargin*2
                    width:              height
                    height:             parent.height*2/3
                    source:             "/qmlimages/RC.svg"
                    fillMode:           Image.PreserveAspectFit
                    color:           _rcQuality_mean >= 60 ? "green" : (_rcQuality_mean>=30? "yellow": (_rcQuality_mean >= 20 ? "orange":"red"))
                    visible: false
                }

                Rectangle{
                    id: rcQualityBar
                    anchors.top: parent.top
                    anchors.left: rcInformationIcon.left
                    anchors.margins: _toolsMargin
                    width: rcInformationIcon.width
                    height: parent.height*2/3
                    color: _rcQuality_mean >= 60 ? "green" : (_rcQuality_mean>=30? "yellow": (_rcQuality_mean >= 20 ? "orange":"red"))//rcMouseArea.containsMouse? "green": "red"
                    visible: false

                    Rectangle{
                        anchors.top: parent.top
                        anchors.left: parent.left
                        width: parent.width
                        height: parent.height*((0/255)) // dinamico de acordo com 1-(% RC). cor há de ser dinamica também. Ver como pegar esse valor
                        color: "black"
                    }

                }

                OpacityMask{
                    anchors.fill: rcQualityBar
                    source: rcQualityBar
                    maskSource: rcInformationIcon
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
                    width: satteliteInformationIcon.width
                    visible: _androidBuild ? false : rcMouseArea.containsMouse
                    color: "black"
                    border.width: 1
                    border.color: "lightgray"
                }
                ColumnLayout {
                    id:                     rcInfoColumn
                    anchors.fill: textBoxRCInfo
                    spacing:                0
                    visible: textBoxRCInfo.visible


                    Text {
                        Layout.alignment:       Qt.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   _rcQuality_mean.toString()+"%"//_activeVehicle.rcRSSI.toString() +"%"//_rcQuality + "%"
                        font.bold: true
                        //font.pointSize:         ScreenTools.mediumFontPixelHeight
                    }
                    /* Text {
                    Layout.alignment:       Qt.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    color:                  "White"
                    text:                   "pkgs lost: " + _mavlinkLossPercent +"%"
                    font.bold: true
                    //font.pointSize:         ScreenTools.mediumFontPixelHeight
                }*/
                }


                //Temperatura Gerador
                QGCColoredImage {
                    id: motorTemperatureInformationIcon
                    anchors.top:        parent.top
                    anchors.left:       rcQualityBar.right
                    anchors.topMargin:  _toolsMargin*2
                    width:              height
                    height:             parent.height*2/3
                    source:             "/qmlimages/MotorTemp.svg"
                    fillMode:           Image.PreserveAspectFit
                    color:              "white"
                }
                QGCColoredImage {
                    id: motorTemperatureInformationIcon2
                    anchors.top:        parent.top
                    anchors.left:       rcQualityBar.right
                    anchors.topMargin:  _toolsMargin*2
                    width:              height
                    height:             parent.height*2/3
                    source:             "/qmlimages/MotorTermometer.png"
                    fillMode:           Image.PreserveAspectFit
                    color:              "yellow"
                }

                Rectangle{
                    id: textBoxMotorTempInfo
                    anchors.verticalCenter: motorTemperatureInformationIcon.verticalCenter
                    anchors.horizontalCenter: motorTemperatureInformationIcon.horizontalCenter
                    height: motorTemperatureInformationIcon.height*1.2
                    width: motorTemperatureInformationIcon.width
                    visible:  _androidBuild ? false : motorTempMouseArea.containsMouse//motorTempMouseArea.containsMouse? true: false
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
                        Layout.alignment:       Qt.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   _motor_temp.toString()+"°C"
                        font.bold: true
                        font.pixelSize:         _androidBuild ?  20 : (_GD60? 10:20)
                    }
                    Text {
                        Layout.alignment:       Qt.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   "RPM: "
                        font.bold: true
                        font.pixelSize:         _androidBuild ?  20 : (_GD60? 10:20)
                    }
                    Text {
                        Layout.alignment:       Qt.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   _motor_rpm.toFixed(0)
                        font.bold: true
                        font.pixelSize:         _androidBuild ?  20 : (_GD60? 10:20)
                    }
                    Text {
                        Layout.alignment:       Qt.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   _motor_temp.toString()+"°C"
                        font.bold: true
                        font.pixelSize:         _androidBuild ?  20 : (_GD60? 10:20)
                        visible: _GD60? true:false
                    }

                    Text {
                        Layout.alignment:       Qt.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        color:                  "White"
                        text:                   "RPM: "+_motor_rpm.toFixed(0)
                        font.bold: true
                        font.pixelSize:         _androidBuild ?  20 : (_GD60? 10:20)
                        visible: _GD60? true:false
                    }
                }



                //Temperatura Rotores
                QGCColoredImage {
                    id: rotorAccelerationInformationIcon
                    anchors.top:        parent.top
                    anchors.left:       motorTemperatureInformationIcon.right
                    anchors.leftMargin: _toolsMargin
                    anchors.topMargin:  _toolsMargin*2
                    width:              height
                    height:             parent.height*2/3
                    source:             "/qmlimages/rotorsAccell.png"
                    fillMode:           Image.PreserveAspectFit
                    color:              "white"

                }
                Rectangle {
                    id: rotorsTempArea
                    anchors.top: parent.top
                    anchors.left: rotorAccelerationInformationIcon.right
                    anchors.margins: _toolsMargin * 1.5
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
                        if (_GD60){
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_1)/3850 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_2)/3850 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_3)/3850 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_4)/3850 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_5)/3850 });
                            accellRotorModel.append({ aceleracao: (_aceleracao_rotor_6)/3850 });
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
                            accellRotorModel.set(0, { aceleracao: _aceleracao_rotor_1/3850 });
                            accellRotorModel.set(1, { aceleracao: _aceleracao_rotor_2/3850 });
                            accellRotorModel.set(2, { aceleracao: _aceleracao_rotor_3/3850 });
                            accellRotorModel.set(3, { aceleracao: _aceleracao_rotor_4/3850 });
                            if (!_GD60){
                                accellRotorModel.set(4, { aceleracao: _aceleracao_rotor_5/3850 });
                                accellRotorModel.set(5, { aceleracao: _aceleracao_rotor_6/3850 });}
                            //console.log((_aceleracao_rotor_1-1000)/1000,_aceleracao_rotor_2,_aceleracao_rotor_3)
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
                            }//"black"//index === 0 ? (motor1_selected ? "yellow" : "black") : "black"
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
                            }//parent.height*(oldGeneratorMediamValue/20)/maxGeneratorCurrent
                            x: index*parent.width/6
                            z:1000
                            color: "white"
                            border.color:"black"
                            border.width:0.5
                            visible: false
                        }
                    }

                }

                // Dial Accelerometer
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
                    MouseArea { // Torna o  interativa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            console.log("Click Test");
                        }
                        onContainsMouseChanged: {
                            _selected_rotor_1 = !_selected_rotor_1
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
                    MouseArea { // Torna o  interativa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            console.log("Click Test");
                        }
                        onContainsMouseChanged: {
                            _selected_rotor_1 = !_selected_rotor_1
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
                //Ilustração Aeronave {EXPERIMENTAR COLOCAR NO FUNDO DO LATERAL VIEW AREA PRA MANTER CENTRALIZAÇÃO HORIZONTAL}

                Rectangle {
                    anchors.fill: parent
                    color:qgcPal.toolbarBackground
                    //gradient: Gradient {
                    //    GradientStop { position: 0.7; color:  qgcPal.toolbarBackground} // Top color
                    //    GradientStop { position: 1.0; color:  toolbar._mainStatusBGColor} // Bottom color
                    //}
                }
                Item{
                    id: flightTimeArea
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: (parent.height -bottomDataLoader.height)/6
                    /*Text {
                    text: "Flight Time\n 00.00.00"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: maxSpeedText.top
                    anchors.margins: _toolsMargin // Adiciona um pequeno espaço do canto
                    font.bold: true
                    Layout.alignment:       Qt.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    font.pointSize: ScreenTools.smallFontPixelHeight
                    color: "white"
                    z:1000
                }*/
                    ColumnLayout {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing:                0
                        height: (parent.height -bottomDataLoader.height)/6

                        Text {
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   "Est. Time"
                            font.pixelSize:         _androidBuild ?  15 : 24//ScreenTools.smallFontPixelHeight
                            font.bold: true
                        }
                        Text {
                            Layout.alignment:       Qt.AlignHCenter
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
                    height: (parent.height -bottomDataLoader.height)/6
                    ColumnLayout {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing:                0
                        height: (parent.height -bottomDataLoader.height)/6

                        Text {
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   "Dist. Home"
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                        Text {
                            Layout.alignment:       Qt.AlignHCenter
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
                    height: (parent.height -bottomDataLoader.height)/6
                    ColumnLayout {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing:                0
                        height: (parent.height -bottomDataLoader.height)/6

                        Text {
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   "Dist. WP"
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                        Text {
                            Layout.alignment:       Qt.AlignHCenter
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
                    height: (parent.height -bottomDataLoader.height)/6
                    ColumnLayout {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing:                0
                        height: (parent.height -bottomDataLoader.height)/6

                        Text {
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   "Alt. LIDAR"
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                        Text {
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   _activeVehicle.rangeFinderDist.value.toFixed(2) + "m" //altitudeRelative.value*10)/10 + "m"
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                    }
                }
                Item{
                    id: altitudeBarometricArea
                    anchors.top: altitudeRelativeArea.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: (parent.height -bottomDataLoader.height)/6
                    ColumnLayout {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing:                0
                        height: (parent.height -bottomDataLoader.height)/6

                        Text {
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   "Alt. AMSL"
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                        Text {
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   Math.round(_activeVehicle.altitudeAMSL.value*10)/10 + "m"
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                    }
                }
                Item{
                    id: horSpeedArea
                    anchors.top: altitudeBarometricArea.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: (parent.height -bottomDataLoader.height)/6
                    ColumnLayout {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing:                0
                        height: (parent.height -bottomDataLoader.height)/6

                        Text {
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   "Hor. speed"
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                        Text {
                            Layout.alignment:       Qt.AlignHCenter
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
                    height: (parent.height -bottomDataLoader.height)/6
                    ColumnLayout {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing:                0
                        height: (parent.height -bottomDataLoader.height)/6

                        Text {
                            Layout.alignment:       Qt.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            color:                  "White"
                            text:                   "Vert. speed"
                            font.pixelSize:         _androidBuild ?  15 : 24
                            font.bold: true
                        }
                        Text {
                            Layout.alignment:       Qt.AlignHCenter
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

            Rectangle {
                anchors.fill: parent
                color: _breachAlertColor
                border.color: "black"

                Text {
                    anchors.centerIn: parent
                    text: popUp_breachAlert
                    font.bold: true
                    // font.pixelSize: _androidBuild? 8 : 14
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
                            // Verifica se há itens no ipModel
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
                            // var loaded = QGroundControl.videoManager.loadSavedUrls()
                            // ipModel.clear()
                            // for (var i = 0; i < loaded.length; ++i) {
                            //     ipModel.append({"url": loaded[i].url})
                            // }
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
