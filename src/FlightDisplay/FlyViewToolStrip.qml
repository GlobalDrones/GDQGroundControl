/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQml.Models 2.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.FlightDisplay 1.0

ToolStrip {
    id:     _root
    title:  qsTr("Fly")

    signal displayPreFlightChecklist
    signal modoEngenheiroToggle
    signal crosshairToggle
    signal camControlToggle
    FlyViewToolStripActionList {
        id: flyViewToolStripActionList

        onDisplayPreFlightChecklist: _root.displayPreFlightChecklist()
        onModoEngenheiroToggle: _root.modoEngenheiroToggle()
        onCrosshairToggle: _root.crosshairToggle()
        onCamControlToggle: _root.camControlToggle()
    }




    model: flyViewToolStripActionList.model
}
