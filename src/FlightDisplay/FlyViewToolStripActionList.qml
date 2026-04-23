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
    property bool _modoEngenheiroChecked: false
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
        }
        //GuidedActionTakeoff { },
        //GuidedActionLand { },
        //GuidedActionRTL { },
        //GuidedActionPause { },
        //GuidedActionActionList { }
    ]
}
