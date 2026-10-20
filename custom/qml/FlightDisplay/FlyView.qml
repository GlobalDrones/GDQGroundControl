/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

// Global Drones: FlyView comum (GD25, GD70, GD150). GD30 e GD60 substituem este
// arquivo na variante, mas usam o mesmo FlyViewWidgetLayer, FlyViewMap e os
// componentes GD.Controls.
//
//  +-------------------------------+---------+
//  | mainViewArea                  | painel  |
//  | mapa/vídeo + widgets + GD     | lateral |
//  +-------------------------------+---------+
//  | painel inferior                         |
//  +-----------------------------------------+
//
// Os painéis são do produto (import GD.Variant 1.0). Além do que recebem na
// instância, leem por escopo dinâmico _toolsMargin e _fullItemZorder deste
// arquivo: não renomear.

import QtQuick 2.12

import QGroundControl               1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

import SiYi.Object 1.0

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

    // Área principal: 5/6 da altura; o painel lateral fica com a mesma
    // espessura do inferior.
    property real   mainViewHeight: height * 5 / 6
    property real   mainViewWidth:  width - (height - mainViewHeight)

    property bool   _androidBuild:  Qt.platform.os === "ios" || Qt.platform.os === "android"
    property var    _siyiCamera:    SiYi.camera

    //-- Painel inferior do produto
    FlyViewBottomViewArea {
        id:             bottomArea
        anchors.left:   parent.left
        anchors.bottom: parent.bottom
        width:          parent.width
        height:         parent.height - mainViewHeight
        toolsMargin:    _root._toolsMargin
        _androidBuild:  _root._androidBuild
    }

    //-- Painel lateral do produto
    FlyViewLateralViewArea {
        id:             lateralArea
        anchors.top:    parent.top
        anchors.right:  parent.right
        anchors.bottom: bottomArea.top
        width:          parent.width - mainViewWidth
        activeVehicle:  _root._activeVehicle
    }

    Item {
        id:             mainViewArea
        anchors.top:    parent.top
        anchors.left:   parent.left
        anchors.right:  lateralArea.left
        anchors.bottom: bottomArea.top

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

        // Ações guiadas escondidas de vez: este GuidedActionsController é o comum
        // (/gdc), sem ações guiadas. A lista de ações e o slider de altitude
        // ficam porque a base ainda os referencia (_guidedActionList,
        // _guidedAltSlider), mas nunca aparecem.
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

        //-- Componentes GD (declarados depois do mapa/vídeo para ficarem por cima)

        // Mira da ação "Aim"
        GDCrosshair {
            anchors.centerIn:   parent
            z:                  QGroundControl.zOrderTopMost
            visible:            widgetLayer.crosshair_visible
        }

        // Seletor de stream e pitch do gimbal no canto superior direito. Somem
        // quando o vídeo está no PiP recolhido. Cada componente decide sozinho
        // se aparece (o seletor só com a fonte "Streams List"), então o pitch
        // do gimbal continua visível com fonte única.
        Row {
            id:                 cameraOverlay
            anchors.top:        parent.top
            anchors.right:      parent.right
            anchors.margins:    25
            spacing:            ScreenTools.defaultFontPixelWidth
            z:                  QGroundControl.zOrderTopMost
            visible:            QGroundControl.videoManager.hasVideo
                                && !(videoControl.pipState.state === videoControl.pipState.pipState && !_pipOverlay._isExpanded)

            GDStreamSelector {
                anchors.verticalCenter: parent.verticalCenter
            }

            GDGimbalPitchIndicator {
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Aparece enquanto a câmera SiYi grava. O texto fala em foto, mas desde
        // 38c19c4 o gatilho é a gravação; mantido como está nos produtos.
        Text {
            id:                         photoText
            anchors.horizontalCenter:   cameraOverlay.horizontalCenter
            anchors.top:                cameraOverlay.bottom
            text:                       "📸 Photo Captured"
            font.pixelSize:             24
            visible:                    _siyiCamera ? _siyiCamera.isRecording : false
        }

        // Alerta de violação das zonas de voo (só com exatamente 3 polígonos na
        // geofence), no topo ao centro. Mostra e esconde sozinho.
        GDBreachAlert {
            anchors.top:                parent.top
            anchors.topMargin:          10
            anchors.horizontalCenter:   parent.horizontalCenter
            z:                          QGroundControl.zOrderTopMost
            vehicle:                    _activeVehicle
            geoFenceController:         _geoFenceController
        }

        // Botão e confirmação do RC Override, embaixo no centro. O tamanho padrão
        // do componente (15% x 10% da área principal) é o destes produtos. Nos
        // produtos sem RC Override ele fica invisível sozinho.
        GDRcOverrideControl {
            anchors.horizontalCenter:   parent.horizontalCenter
            anchors.bottom:             parent.bottom
            z:                          _fullItemZorder + 10
        }
    }
}
