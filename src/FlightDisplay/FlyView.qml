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

    property var _returnFunctionArray: []
    property bool flagAlertaGerador: false
    property var oldGeneratorMediamValue: 0
    property int  maxGeneratorCurrent: 120
    property var generatorCurrentArray: []
    property var batteryCurrentArray: []
    property real generatorCurrentMed: 0
    property string popUp_generatorAlert: ""
    property string _generatorAlertColor: "red"
    property bool canShowGeneratorAlert: true


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
    property real _motor_rpm: 3000

    property int _rpm_horizontal1: 0
    property int _rpm_horizontal2: 0


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
    property real _filteredGimbalPitch: 0

    property var siyi: SiYi
    property SiYiCamera camera: siyi.camera

    Connections {
        target: _activeVehicle ? _activeVehicle.cameraManager : null
        //_activeVehicle.
        function onPhotoCapturedSignal()  {
            console.log("Photo taken signal received")
           // photoText.visible = true
          //  photoTextTimer.start()
        }
    }
    Connections {
        target: _activeVehicle ? _activeVehicle.cameraManager.currentCamera : null
        //_activeVehicle.
        function onPhotoCaptured()  {
            console.log("Photo taken signal received")
           // photoText.visible = true
           // photoTextTimer.start()
        }
    }

    Connections {
        target: _activeVehicle ? _activeVehicle.cameraManager : null

        function onRecordingStateChanged()  {
            console.log("recording taken signal received")
            //photoText.visible = !photoText.visible
            //photoTextTimer.start()
        }
    }

    Connections {
        target: _activeVehicle ? _activeVehicle : null

        function onPhotoTaken() {
            console.log("Photo taken signal received")

            //photoText.visible = true
            //photoTextTimer.start()
        }
    }
    Connections {
        target: camera ? camera : null

        function onIsRecordingChanged() {
            if (!camera) return

            console.log("Recording state:", camera.isRecording())

            //photoText.visible = true
            //photoTextTimer.start()

        }
    }

    Connections {
        target: _activeVehicle ? _activeVehicle._GD_GimbalPitch : null

        function onRawValueChanged() {
            if (!_activeVehicle) return

            var v = _activeVehicle._GD_GimbalPitch.rawValue

            // ignora zeros espúrios (ajuste tolerância se quiser)
            if (Math.abs(v) > 0.01) {
                _filteredGimbalPitch = -v
            }
        }
    }




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



    function accelerationPercentageToRadius(percentage){
        return percentage*0.015

    }






    Timer{
        id: propertyValuesUpdater
        interval: 100
        running: true
        repeat: true

        onTriggered:{
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

        }
    }


    //**************************************************************************************************//
    //                          BOTTOM VIEW AREA                                                        //
    //**************************************************************************************************//
    FlyViewBottomViewArea {
        id: bottomArea

        anchors.bottom: parent.bottom
        anchors.left: parent.left

        width: parent.width
        height: parent.height - mainViewHeight
        toolsMargin: _toolsMargin

        _androidBuild: _androidBuild

    }

    //**************************************************************************************************//
    //                          LATERAL VIEW AREA                                                       //
    //**************************************************************************************************//
    Loader {
        id: lateralDataLoader

        anchors.right: parent.right
        anchors.bottom: bottomArea.top
        anchors.top: toolbarsize.bottom

        width: parent.width - mainViewWidth
        height: mainViewHeight

        active: true

        sourceComponent: FlyViewLateralViewArea {
            anchors.fill: parent
            activeVehicle: _activeVehicle
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
        anchors.bottom: bottomArea.top

        Component.onCompleted:{
            let now = new Date();
            console.log("mainViewArea LOADED at " + now.toLocaleTimeString());lateralDataLoader.active = true; bottomArea.active = true;}

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
                Item {
                    id: cameraPitchIndication
                    width: ScreenTools.defaultFontPixelHeight * 2.5
                    height: width

                    // container que gira tudo junto
                    Item {
                        id: rotatingGroup
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height

                        rotation: {
                            _filteredGimbalPitch
                        }

                        transformOrigin: Item.Center

                        QGCColoredImage {
                            id: cameraPitch
                            source: "/qmlimages/camera_video"
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            color: "white"
                        }

                        Rectangle {
                            width: parent.width * 0.5
                            height: parent.width * 0.4

                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.horizontalCenterOffset: -parent.width * 0.15   // 👈 move para esquerda

                            border.color: qgcPal.text
                            color: "#80000000"
                            z: _fullItemZorder + 10

                            QGCLabel {
                                text: Number(_filteredGimbalPitch).toFixed(0) + "°"
                                anchors.centerIn: parent
                                color: qgcPal.text
                                font.pointSize: 8
                            }
                        }

                    }
                }

            }
        }


        Timer {
            id: photoTextTimer
            interval: 1500
            onTriggered: photoText.visible = false
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
    }
}
