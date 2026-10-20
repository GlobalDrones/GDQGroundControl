/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

// Global Drones GD60: FlyView próprio, no lugar do comum.
//
//  +------------------------------------+-----------------+
//  | mainViewArea                       | painel lateral  |
//  | mapa/vídeo + widgets + HUD piloto  | RPM, ECU, ESC   |
//  |                                    | troca de câmera |
//  |                                    | RC Override     |
//  +------------------------------------+-----------------+
//
// Sem painel inferior: mainViewHeight é 70% da altura e o painel lateral fica
// com os outros 30% como largura. FlyViewWidgetLayer, FlyViewMap e os
// componentes GD.Controls são os comuns (inclusive o alerta das 3 zonas); HUD
// e painel lateral vêm de GD.Variant (custom/variants/gd60/qml/GD/Variant).
//
// A base e os arquivos comuns leem por escopo dinâmico as propriedades da raiz
// e os ids _root, _planController, mapControl, videoControl, _pipOverlay,
// widgetLayer, customOverlay, guidedActionsController, guidedActionList e
// guidedAltSlider: não renomear.

import QtQuick 2.12

import QGroundControl               1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

import GD.Controls 1.0
import GD.Variant  1.0

Item {
    id: _root

    // These should only be used by MainRootWindow
    property var planController:    _planController
    property var guidedController:  _guidedController

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
    property var    _guidedAltSlider:       guidedAltSlider
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property var    _mapControl:            mapControl

    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    // Área principal com 70% da altura; o painel lateral tem como largura os
    // 30% restantes
    property real   mainViewHeight: height * 0.7
    property real   mainViewWidth:  width - (height - mainViewHeight)

    property bool   _androidBuild:  Qt.platform.os === "ios" || Qt.platform.os === "android"

    //-- Painel lateral
    Item {
        id:             lateralArea
        anchors.top:    parent.top
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        width:          parent.width - mainViewWidth

        // Carregado em segundo plano, como no app anterior, para não atrasar a
        // abertura do Fly View
        Loader {
            id:                 lateralDataLoader
            anchors.fill:       parent
            asynchronous:       true
            sourceComponent:    Component {
                FlyViewLateralViewArea {
                    activeVehicle:  _root._activeVehicle
                    androidBuild:   _root._androidBuild
                    toolsMargin:    _root._toolsMargin
                    iconSize:       pilotHud.headingDialSize / 1.5
                }
            }
        }

        // Troca de câmera logo acima do botão de Override, perto da mão do
        // piloto (76c1773). O seletor decide sozinho se aparece (fonte "Streams
        // List"); aqui ele só some com o vídeo no PiP recolhido.
        Item {
            id:                     cameraControlOverlay
            anchors.right:          parent.right
            anchors.rightMargin:    25
            anchors.bottom:         btnOverride.top
            anchors.bottomMargin:   _toolsMargin * 2
            width:                  streamSelector.width
            height:                 streamSelector.height
            z:                      QGroundControl.zOrderTopMost
            visible:                !(videoControl.pipState.state === videoControl.pipState.pipState && !_pipOverlay._isExpanded)

            GDStreamSelector {
                id:         streamSelector
                textWidth:  ScreenTools.defaultFontPixelWidth * 12
            }
        }

        // RC Override no rodapé do painel lateral; a confirmação tem o tamanho
        // relativo à área principal, como antes
        GDRcOverrideControl {
            id:                         btnOverride
            width:                      parent.width * 0.75
            anchors.horizontalCenter:   parent.horizontalCenter
            anchors.bottom:             parent.bottom
            z:                          _fullItemZorder + 10
            popupWidth:                 mainViewArea.width * 0.4
            popupHeight:                mainViewArea.height * 0.25
        }
    }

    //-- Área principal
    Item {
        id:             mainViewArea
        anchors.top:    parent.top
        anchors.left:   parent.left
        anchors.right:  lateralArea.left
        anchors.bottom: parent.bottom

        // QtObject não tem parent: "parent.height" aqui seria a altura do FlyView
        // inteiro, não da área principal onde o PiP está.
        QGCToolInsets {
            id:                     _toolInsets
            leftEdgeBottomInset:    _pipOverlay.visible ? _pipOverlay.x + _pipOverlay.width : 0
            bottomEdgeLeftInset:    _pipOverlay.visible ? mainViewArea.height - _pipOverlay.y : 0
        }

        FlyViewWidgetLayer {
            id:                 widgetLayer
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            anchors.left:       parent.left
            anchors.right:      guidedAltSlider.visible ? guidedAltSlider.left : parent.right
            z:                  _fullItemZorder + 1
            parentToolInsets:   _toolInsets
            mapControl:         _mapControl
            visible:            !QGroundControl.videoManager.fullScreen
        }

        FlyViewCustomLayer {
            id:                 customOverlay
            anchors.fill:       widgetLayer
            z:                  _fullItemZorder + 2
            parentToolInsets:   widgetLayer.totalToolInsets
            mapControl:         _mapControl
            visible:            !QGroundControl.videoManager.fullScreen
        }

        GuidedActionsController {
            id:                 guidedActionsController
            missionController:  _missionController
            actionList:         _guidedActionList
            altitudeSlider:     _guidedAltSlider
        }

        GuidedActionList {
            id:                         guidedActionList
            anchors.margins:            _margins
            anchors.bottom:             parent.bottom
            anchors.horizontalCenter:   parent.horizontalCenter
            z:                          QGroundControl.zOrderTopMost
            guidedController:           _guidedController
        }

        //-- Altitude slider
        GuidedAltitudeSlider {
            id:                 guidedAltSlider
            anchors.margins:    _toolsMargin
            anchors.right:      parent.right
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            z:                  QGroundControl.zOrderTopMost
            radius:             ScreenTools.defaultFontPixelWidth / 2
            width:              ScreenTools.defaultFontPixelWidth * 10
            color:              qgcPal.window
            visible:            false
        }

        FlyViewMap {
            id:                     mapControl
            planMasterController:   _planController
            rightPanelWidth:        ScreenTools.defaultFontPixelHeight * 9
            pipMode:                !_mainWindowIsMap
            toolInsets:             customOverlay.totalToolInsets
            mapName:                "FlightDisplayView"
        }

        FlyViewVideo {
            id:             videoControl
            iconLeftMargin: widgetLayer.iconLeftMargin
        }

        QGCPipOverlay {
            id:                     _pipOverlay
            anchors.left:           parent.left
            anchors.bottom:         parent.bottom
            anchors.margins:        _toolsMargin
            item1IsFullSettingsKey: "MainFlyWindowIsMap"
            item1:                  mapControl
            item2:                  QGroundControl.videoManager.hasVideo ? videoControl : null
            fullZOrder:             _fullItemZorder
            pipZOrder:              _pipItemZorder
            show:                   !QGroundControl.videoManager.fullScreen
                                    && (videoControl.pipState.state === videoControl.pipState.pipState
                                        || mapControl.pipState.state === mapControl.pipState.pipState)
        }

        // HUD do piloto: sempre visível, sobre o mapa ou o vídeo, acima do PiP
        PilotHud {
            id:                 pilotHud
            anchors.centerIn:   parent
            width:              parent.width * 0.65
            height:             parent.height * 0.95
            z:                  _pipOverlay.z + 20
            activeVehicle:      _root._activeVehicle
            androidBuild:       _root._androidBuild
            toolsMargin:        _root._toolsMargin
        }

        // Mira vermelha da ação "Aim". Não é o símbolo central do HUD, que fica
        // sempre visível.
        GDCrosshair {
            anchors.centerIn:   parent
            z:                  QGroundControl.zOrderTopMost
            visible:            widgetLayer.crosshair_visible
        }

        // Alerta de violação das zonas de voo (só com exatamente 3 polígonos na
        // geofence), no topo ao centro, acima do HUD. Mostra e esconde sozinho.
        // Largura 0,3 (padrão 1/4): a área principal do GD60 é mais estreita
        // (painel lateral mais largo); assim o alerta fica com largura próxima
        // à do GD30 e o texto quebra em menos linhas.
        GDBreachAlert {
            anchors.top:                parent.top
            anchors.topMargin:          10
            anchors.horizontalCenter:   parent.horizontalCenter
            width:                      parent.width * 0.3
            z:                          QGroundControl.zOrderTopMost
            vehicle:                    _activeVehicle
            geoFenceController:         _geoFenceController
        }
    }
}
