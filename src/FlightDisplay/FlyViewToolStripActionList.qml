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
    property bool modoEngenheiro: false
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
                _root.modoEngenheiro = !_root.modoEngenheiro
                //console.log("[A] modoEngenheiro_ActionList:",_root.modoEngenheiro)
                modoEngenheiroToggle() //trigger do sinal
            }
        }
        //GuidedActionTakeoff { },
        //GuidedActionLand { },
        //GuidedActionRTL { },
        //GuidedActionPause { },
        //GuidedActionActionList { }
    ]
}
