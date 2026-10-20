/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

// Global Drones: substitui src/FlightDisplay/GuidedActionsController.qml em
// TODOS os produtos, inclusive GD30/GD60 com FlyView próprio (ver
// custom/README.md). É a chave central das ações guiadas.
//
// Decisão de produto: ações guiadas pela GCS escondidas de vez (ir até o ponto,
// orbitar, ROI, iniciar/continuar missão, pausa, decolar, pousar, RTL, mudar
// altitude, abortar pouso, ações multiveículo, trocar waypoint). Nos produtos
// GD o diálogo de confirmação nunca foi registrado (GuidedActionConfirm), então
// essas ações só lançavam TypeError.
//
// - Todos os show* das ações guiadas são constantes false (readonly): nenhum
//   item da base que dependa deles aparece (GuidedActionList, GuidedToolStrip*,
//   lista de ações). Nenhum disparo automático (Start Mission ao carregar
//   missão, Continue Mission, Land Abort) acontece.
// - confirmAction() não abre diálogo nem lança erro: só registra no log.
//   Os botões Arm/Disarm/Force Arm da barra superior nunca armaram nos
//   produtos GD e foram escondidos no MainStatusIndicator comum: arma-se pelo
//   rádio. A transição VTOL ainda chega aqui pelos sinais do mainWindow.
// - executeAction() só executa "Retomar missão" (botão do diálogo de fim de
//   voo, FlyViewMissionCompleteDialog), que reenvia a missão ao veículo e não
//   comanda voo.
// - guidedUIVisible é sempre false (a base ligava em confirmDialog.visible,
//   que dava erro com confirmDialog nunca atribuído).
//
// Mantém as mesmas propriedades, constantes, textos e funções da base para os
// arquivos que ainda leem o controlador (GuidedActionList, GuidedActionConfirm,
// FlyViewMissionCompleteDialog).

import QtQuick 2.12

import QGroundControl 1.0

Item {
    id: _root

    property var missionController
    property var confirmDialog      // Nunca atribuído nos produtos GD
    property var actionList
    property var altitudeSlider
    property var orbitMapCircle     // Não é mais atribuído (menu do mapa removido)

    readonly property string emergencyStopTitle:            qsTr("EMERGENCY STOP")
    readonly property string armTitle:                      qsTr("Arm")
    readonly property string forceArmTitle:                 qsTr("Force Arm")
    readonly property string disarmTitle:                   qsTr("Disarm")
    readonly property string rtlTitle:                      qsTr("Return")
    readonly property string takeoffTitle:                  qsTr("Takeoff")
    readonly property string landTitle:                     qsTr("Land")
    readonly property string startMissionTitle:             qsTr("Start Mission")
    readonly property string mvStartMissionTitle:           qsTr("Start Mission (MV)")
    readonly property string continueMissionTitle:          qsTr("Continue Mission")
    readonly property string resumeMissionUploadFailTitle:  qsTr("Resume FAILED")
    readonly property string pauseTitle:                    qsTr("Pause")
    readonly property string mvPauseTitle:                  qsTr("Pause (MV)")
    readonly property string changeAltTitle:                qsTr("Change Altitude")
    readonly property string orbitTitle:                    qsTr("Orbit")
    readonly property string landAbortTitle:                qsTr("Land Abort")
    readonly property string setWaypointTitle:              qsTr("Set Waypoint")
    readonly property string gotoTitle:                     qsTr("Go To Location")
    readonly property string vtolTransitionTitle:           qsTr("VTOL Transition")
    readonly property string roiTitle:                      qsTr("ROI")
    readonly property string actionListTitle:               qsTr("Action")

    readonly property string armMessage:                        qsTr("Arm the vehicle.")
    readonly property string forceArmMessage:                   qsTr("WARNING: This will force arming of the vehicle bypassing any safety checks.")
    readonly property string disarmMessage:                     qsTr("Disarm the vehicle")
    readonly property string emergencyStopMessage:              qsTr("WARNING: THIS WILL STOP ALL MOTORS. IF VEHICLE IS CURRENTLY IN THE AIR IT WILL CRASH.")
    readonly property string takeoffMessage:                    qsTr("Takeoff from ground and hold position.")
    readonly property string startMissionMessage:               qsTr("Takeoff from ground and start the current mission.")
    readonly property string continueMissionMessage:            qsTr("Continue the mission from the current waypoint.")
    readonly property string resumeMissionUploadFailMessage:    qsTr("Upload of resume mission failed. Confirm to retry upload")
    readonly property string landMessage:                       qsTr("Land the vehicle at the current position.")
    readonly property string rtlMessage:                        qsTr("Return to the launch position of the vehicle.")
    readonly property string changeAltMessage:                  qsTr("Change the altitude of the vehicle up or down.")
    readonly property string gotoMessage:                       qsTr("Move the vehicle to the specified location.")
             property string setWaypointMessage:                qsTr("Adjust current waypoint to %1.").arg(_actionData)
    readonly property string orbitMessage:                      qsTr("Orbit the vehicle around the specified location.")
    readonly property string landAbortMessage:                  qsTr("Abort the landing sequence.")
    readonly property string pauseMessage:                      qsTr("Pause the vehicle at it's current position, adjusting altitude up or down as needed.")
    readonly property string mvPauseMessage:                    qsTr("Pause all vehicles at their current position.")
    readonly property string vtolTransitionFwdMessage:          qsTr("Transition VTOL to fixed wing flight.")
    readonly property string vtolTransitionMRMessage:           qsTr("Transition VTOL to multi-rotor flight.")
    readonly property string roiMessage:                        qsTr("Make the specified location a Region Of Interest.")

    readonly property int actionRTL:                        1
    readonly property int actionLand:                       2
    readonly property int actionTakeoff:                    3
    readonly property int actionArm:                        4
    readonly property int actionDisarm:                     5
    readonly property int actionEmergencyStop:              6
    readonly property int actionChangeAlt:                  7
    readonly property int actionGoto:                       8
    readonly property int actionSetWaypoint:                9
    readonly property int actionOrbit:                      10
    readonly property int actionLandAbort:                  11
    readonly property int actionStartMission:               12
    readonly property int actionContinueMission:            13
    readonly property int actionResumeMission:              14
    readonly property int _actionUnused:                    15
    readonly property int actionResumeMissionUploadFail:    16
    readonly property int actionPause:                      17
    readonly property int actionMVPause:                    18
    readonly property int actionMVStartMission:             19
    readonly property int actionVtolTransitionToFwdFlight:  20
    readonly property int actionVtolTransitionToMRFlight:   21
    readonly property int actionROI:                        22
    readonly property int actionActionList:                 23
    readonly property int actionForceArm:                   24

    // GD: ações guiadas sempre escondidas. readonly para um FlyView de variante
    // não religar sem querer.
    readonly property bool showEmergenyStop:     false
    readonly property bool showArm:              false
    readonly property bool showForceArm:         false
    readonly property bool showDisarm:           false
    readonly property bool showRTL:              false
    readonly property bool showTakeoff:          false
    readonly property bool showLand:             false
    readonly property bool showStartMission:     false
    readonly property bool showContinueMission:  false
    readonly property bool showPause:            false
    readonly property bool showChangeAlt:        false
    readonly property bool showOrbit:            false
    readonly property bool showROI:              false
    readonly property bool showLandAbort:        false
    readonly property bool showGotoLocation:     false
    readonly property bool showActionList:       false

    // Igual à base: botão "Resume Mission" do diálogo de fim de voo.
    // Note: The '_missionItemCount - 2' is a hack to not trigger resume mission when a mission ends with an RTL item
    property bool showResumeMission:    _activeVehicle && !_vehicleArmed && _vehicleWasFlying && _missionAvailable && _resumeMissionIndex > 0 && (_resumeMissionIndex < _missionItemCount - 2)

    readonly property bool guidedUIVisible: false

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property bool   _missionAvailable:      missionController ? missionController.containsItems : false
    property bool   _vehicleArmed:          _activeVehicle ? _activeVehicle.armed  : false
    property bool   _vehicleFlying:         _activeVehicle ? _activeVehicle.flying  : false
    property bool   _vehicleWasFlying:      false
    property int    _missionItemCount:      missionController ? missionController.missionItemCount : 0
    property int    _resumeMissionIndex:    missionController ? missionController.resumeMissionIndex : 0
    property var    _actionData

    on_VehicleFlyingChanged: {
        if (!_vehicleFlying) {
            // We use _vehicleWasFLying to help trigger Resume Mission only if the vehicle actually flew and came back down.
            // Otherwise it may trigger during the Start Mission sequence due to signal ordering or armed and resume mission index.
            _vehicleWasFlying = true
        }
    }

    Connections {
        target: missionController
        function onResumeMissionUploadFail() {
            console.warn("GD: falha ao enviar a missão retomada (sem diálogo de nova tentativa nos produtos GD)")
        }
    }

    // Sinais do mainWindow (Arm/Disarm escondidos na barra; sobra a transição VTOL)
    Connections {
        target: mainWindow
        function onArmVehicleRequest() { armVehicleRequest() }
        function onForceArmVehicleRequest() { forceArmVehicleRequest() }
        function onDisarmVehicleRequest() { disarmVehicleRequest() }
        function onVtolTransitionToFwdFlightRequest() { vtolTransitionToFwdFlightRequest() }
        function onVtolTransitionToMRFlightRequest() { vtolTransitionToMRFlightRequest() }
    }

    function armVehicleRequest() {
        confirmAction(actionArm)
    }

    function forceArmVehicleRequest() {
        confirmAction(actionForceArm)
    }

    function disarmVehicleRequest() {
        confirmAction(actionDisarm)
    }

    function vtolTransitionToFwdFlightRequest() {
        confirmAction(actionVtolTransitionToFwdFlight)
    }

    function vtolTransitionToMRFlightRequest() {
        confirmAction(actionVtolTransitionToMRFlight)
    }

    // Com guarda: confirmDialog nunca é atribuído nos produtos GD
    function closeAll() {
        if (confirmDialog) {
            confirmDialog.visible = false
        }
        if (actionList) {
            actionList.visible = false
        }
        if (altitudeSlider) {
            altitudeSlider.visible = false
        }
    }

    // GD: não confirma nem executa nada. Fecha o que estiver aberto e devolve
    // o indicador do mapa, se houver.
    function confirmAction(actionCode, actionData, mapIndicator) {
        closeAll()
        _actionData = actionData
        console.warn("GD: ação guiada desativada nos produtos GD (código " + actionCode + ")")
        if (mapIndicator && mapIndicator.actionCancelled) {
            mapIndicator.actionCancelled()
        }
    }

    // GD: só "Retomar missão" (diálogo de fim de voo). Qualquer outra ação
    // guiada é recusada aqui também, caso algum QML ainda chame direto.
    function executeAction(actionCode, actionData, actionAltitudeChange, optionChecked) {
        switch (actionCode) {
        case actionResumeMission:
        case actionResumeMissionUploadFail:
            if (missionController) {
                missionController.resumeMission(missionController.resumeMissionIndex)
            }
            break
        default:
            console.warn("GD: ação guiada desativada nos produtos GD (código " + actionCode + ")")
            break
        }
    }
}
