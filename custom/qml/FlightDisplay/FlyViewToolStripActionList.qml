/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

// Global Drones: substitui o FlyViewToolStripActionList da base em todos os produtos.
//
// - As ações de voo guiado (decolar, pousar, RTL, pausa, lista de ações) saíram
//   da barra em todos os produtos GD (03aadb8).
// - "+Info", "Aim" e "Cam" são liga/desliga independentes. Quem guarda o estado
//   é o FlyViewWidgetLayer, que recebe os sinais. Os botões não ficam marcados:
//   o ToolStrip da base trata "checked" como exclusivo e desmarcaria um ao
//   ligar outro.

import QtQml.Models 2.12

import QGroundControl           1.0
import QGroundControl.Controls  1.0

ToolStripActionList {
    id: _root

    // A variante pode esconder "Aim" e "Cam" (ver FlyViewWidgetLayer)
    property bool showCrosshairAction:  true
    property bool showCamControlAction: true

    signal displayPreFlightChecklist
    signal modoEngenheiroToggle
    signal crosshairToggle
    signal camControlToggle

    model: [
        ToolStripAction {
            text:           qsTr("Plan")
            iconSource:     "/qmlimages/Plan.svg"
            onTriggered:    mainWindow.showPlanView()
        },
        PreFlightCheckListShowAction { onTriggered: displayPreFlightChecklist() },
        ToolStripAction {
            text:           qsTr("+Info")
            iconSource:     "/qmlimages/Gears.svg"
            onTriggered:    _root.modoEngenheiroToggle()
        },
        ToolStripAction {
            text:           qsTr("Aim")
            iconSource:     "/qmlimages/MapAddMission.svg"
            visible:        _root.showCrosshairAction
            onTriggered:    _root.crosshairToggle()
        },
        ToolStripAction {
            text:           qsTr("Cam")
            iconSource:     "/qmlimages/camera.svg"
            visible:        _root.showCamControlAction
            onTriggered:    _root.camControlToggle()
        }
    ]
}
