

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
import QGroundControl.FactSystem 1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Vehicle 1.0

Item {
    id: _root

    // These should only be used by MainRootWindow
    property var planController: _planController
    property var guidedController: _guidedController

    PlanMasterController {
        id: _planController
        flyView: true
        Component.onCompleted: start()
    }

    property bool _mainWindowIsMap: mapControl.pipState.state === mapControl.pipState.fullState
    property bool _isFullWindowItemDark: _mainWindowIsMap ? mapControl.isSatelliteMap : true
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var _missionController: _planController.missionController
    property var _geoFenceController: _planController.geoFenceController
    property var _rallyPointController: _planController.rallyPointController
    property real _margins: ScreenTools.defaultFontPixelWidth / 2
    property var _guidedController: guidedActionsController
    property var _guidedActionList: guidedActionList
    property var _guidedAltSlider: guidedAltSlider
    property real _toolsMargin: ScreenTools.defaultFontPixelWidth * 0.75
    property rect _centerViewport: Qt.rect(0, 0, width, height)
    property real _rightPanelWidth: ScreenTools.defaultFontPixelWidth * 30
    property var _mapControl: mapControl

    property real _fullItemZorder: 0
    property real _pipItemZorder: QGroundControl.zOrderWidgets

    function _calcCenterViewPort() {
        var newToolInset = Qt.rect(0, 0, width, height)
        toolstrip.adjustToolInset(newToolInset)
        if (QGroundControl.corePlugin.options.instrumentWidget) {
            flightDisplayViewWidgets.adjustToolInset(newToolInset)
        }
    }

<<<<<<< HEAD
    QGCToolInsets {
        id: _toolInsets
        leftEdgeBottomInset: _pipOverlay.visible ? _pipOverlay.x + _pipOverlay.width : 0
        bottomEdgeLeftInset: _pipOverlay.visible ? parent.height - _pipOverlay.y : 0
=======

    Timer{
        id: propertyValuesUpdater
        interval: 100
        running: true
        repeat: true

        onTriggered:{
            gcsID = QGroundControl.mavlinkSystemID.valueOf(); //tem que ficar atualizando. tem jeito melhor pra fazer mas isso é pequisa futura e o desempenho ta satisfatório pra agora

            if (!_activeVehicle) {
                return
            }

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
                        }
                    }
                }



            /*var breach_val = breachDetection()
            if (breach_val.level > -1 && canShowBreachAlert) {

                if (breach_val.level === 0) {
                    popUp_breachAlert = "Invasão do Volume de Contingência!"
                    _breachAlertColor = "Yellow"
                }
                if (breach_val.level === 1) {
                    popUp_breachAlert = "Invasão do Volume de Ground Risk Buffer!"
                    _breachAlertColor = "Orange"
                }

               // breachAlertPopup.open()
               // breachAlertPopup.visible = true
                canShowBreachAlert = false
                breachCooldownTimer.start()
            }*/

        }
>>>>>>> e648974363b58b86e5464a75de2d3ee7258c9029
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
<<<<<<< HEAD
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
=======
        anchors.right: lateralDataLoader.left
        anchors.bottom: bottomArea.top

        Component.onCompleted:{
            let now = new Date();
            lateralDataLoader.active = true; bottomArea.active = true;}

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

        Item {
            id: crosshair
            width: parent.width*0.04
            height: width
            anchors.centerIn: parent // Garante que a mira fique no centro do elemento pai
            visible: widgetLayer.crosshair_visible
            z: 1000000000000

            // Linha Horizontal
            Rectangle {
                width: parent.width
                height: 5
                color: "red"
                //border.color: "black"
                //border.width: 1
                anchors.verticalCenter: parent.verticalCenter
            }

            // Linha Vertical
            Rectangle {
                width: 5
                height: parent.height
                color: "red"
                //border.color: "black"
                //border.width: 1
                anchors.horizontalCenter: parent.horizontalCenter
            }
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

        /*Popup {
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
        }*/

        Item {
            id: cameraControlOverlay
            z: QGroundControl.zOrderTopMost
            // Only shown (and only ever touches the video source) while "Streams List" is the
            // selected Source in Settings - otherwise it must not interfere with whatever single
            // source (RTSP/UDP/etc) is manually configured there.
            visible: QGroundControl.videoManager.hasVideo &&
                     QGroundControl.settingsManager.videoSettings.videoSource.rawValue === QGroundControl.settingsManager.videoSettings.streamsListVideoSource

            // Lista com pares: texto + URL correspondente
            /*property var cameraList: [
                { name: "Video 1", url: "rtsp://192.168.144.25:8554/video1" },
                { name: "Video 2", url: "rtsp://192.168.144.25:8554/video2" },
                { name: "FPV",     url: "rtsp://192.168.144.26:554/main.264" }
            ]*/

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
                            var streams = QGroundControl.videoManager.streams
                            var idx = QGroundControl.videoManager.currentStreamIndex
                            if (streams.length > 0 && idx >= 0 && idx < streams.length) {
                                var element = streams[idx]
                                return element.alias ? element.alias : element.ip
                            } else {
                                return qsTr("Sem câmeras")
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
                            var streams = QGroundControl.videoManager.streams
                            if (streams.length > 0) {
                                var nextIndex = (QGroundControl.videoManager.currentStreamIndex + 1) % streams.length
                                QGroundControl.videoManager.selectStream(nextIndex)
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
        Text {
            id: photoText
            text: "📸 Photo Captured"
            anchors.horizontalCenter: cameraControlOverlay.horizontalCenter
            anchors.top: cameraControlOverlay.bottom
            font.pixelSize: 24
            visible: false
        }

        Timer {
            id: photoTextTimer
            interval: 1500
            onTriggered: photoText.visible = false
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
                                                        _activeVehicle.overwriteRC(arrayInt, true)
                                                        overrideActive = true
                                                        override_first_clicked = false;
                                                        _simText.color = "white"
                                                        btnYes.color = "#66bb6a"
                                                        _alertaForceOverride.text = ""
                                                        confirmOverridePopup.close()


                                                } else {
                                                    _activeVehicle.stopRCOverride()
                                                    overrideActive = false
                                                    override_first_clicked = false;
                                                    confirmOverridePopup.close()
                                                }
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

>>>>>>> e648974363b58b86e5464a75de2d3ee7258c9029
    }
}
