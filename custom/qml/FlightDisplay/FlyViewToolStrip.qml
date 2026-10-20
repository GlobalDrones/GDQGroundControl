/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

// Global Drones: substitui o FlyViewToolStrip da base em todos os produtos.
// Repassa os sinais das ações GD ("+Info", "Aim", "Cam") ao FlyViewWidgetLayer.

import QtQml.Models 2.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.FlightDisplay 1.0

ToolStrip {
    id:     _root
    title:  qsTr("Fly")

    property bool showCrosshairAction:  true
    property bool showCamControlAction: true

    signal displayPreFlightChecklist
    signal modoEngenheiroToggle
    signal crosshairToggle
    signal camControlToggle

    FlyViewToolStripActionList {
        id:                     flyViewToolStripActionList
        showCrosshairAction:    _root.showCrosshairAction
        showCamControlAction:   _root.showCamControlAction

        onDisplayPreFlightChecklist:    _root.displayPreFlightChecklist()
        onModoEngenheiroToggle:         _root.modoEngenheiroToggle()
        onCrosshairToggle:              _root.crosshairToggle()
        onCamControlToggle:             _root.camControlToggle()
    }

    model: flyViewToolStripActionList.model
}
