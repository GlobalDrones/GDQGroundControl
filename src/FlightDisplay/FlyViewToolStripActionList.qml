/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQml.Models 2.12

import QGroundControl           1.0
import QGroundControl.Controls  1.0

ToolStripActionList {
    id: _root

    signal displayPreFlightChecklist
    signal modoEngenheiroToggle
    signal crosshairToggle
    signal camControlToggle
    property bool _modoEngenheiroChecked: false
    property bool _crosshairChecked: false
    property bool _camControlChecked: false
    model: [
        ToolStripAction {
            text:           qsTr("Plan")
            iconSource:     "/qmlimages/Plan.svg"
            onTriggered:    mainWindow.showPlanView()
        },
        PreFlightCheckListShowAction { onTriggered: displayPreFlightChecklist() },
        ToolStripAction {
            text: qsTr("+Info")
            iconSource: "/qmlimages/Gears.svg"
            onTriggered: {
                modoEngenheiroToggle() //trigger do sinal
                _modoEngenheiroChecked: !_modoEngenheiroChecked
            }

            checked: _modoEngenheiroChecked
        },

        ToolStripAction {
            text: qsTr("Aim")
            iconSource: "/qmlimages/MapAddMission.svg"
            onTriggered: {
                crosshairToggle() //trigger do sinal
                _crosshairChecked: !_crosshairChecked
            }

            checked: _crosshairChecked
        },

        ToolStripAction {
            text: qsTr("Cam")
            iconSource: "/qmlimages/camera.svg"
            onTriggered: {
                camControlToggle() //trigger do sinal
                _camControlChecked: !_camControlChecked
            }

            checked: _camControlChecked
        }
        //GuidedActionTakeoff { },
        //GuidedActionLand { },
        //GuidedActionRTL { },
        //GuidedActionPause { },
        //GuidedActionActionList { }
    ]
}
