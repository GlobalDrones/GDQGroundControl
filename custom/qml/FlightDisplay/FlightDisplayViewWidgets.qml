/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

// Global Drones: instrumento de atitude/bússola do painel direito do FlyView
// (FlyViewInstrumentPanel). Cada produto mostra esse instrumento num lugar:
//   GD25, GD70  no painel inferior do produto (FlyViewBottomViewArea)
//   GD60        no HUD
//   GD30, GD150 aqui, no painel direito
// O comum não mostra nada. GD30 e GD150 substituem este arquivo pela versão da
// base SiYi (Loader do QGCInstrumentWidget). O FlyViewWidgetLayer percebe pela
// altura se há instrumento e afasta a barra de telemetria.

import QtQuick 2.12

Item {
    width: parent.width

    property var missionController
}
