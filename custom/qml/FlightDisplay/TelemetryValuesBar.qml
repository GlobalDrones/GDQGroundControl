/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

// Global Drones (todos os produtos): igual à base SiYi, sem os ícones de modo
// inferior/lateral (bottomMode), que no GD não fazem nada: a posição da barra
// é fixa no FlyViewWidgetLayer comum. GD30 e GD60 já não mostravam esses
// ícones.
//
// GuidedActionConfirm vem do import explícito de QGroundControl.FlightDisplay,
// sem depender do import implícito do diretório (o interceptador não
// redireciona qmldir nem a listagem de diretório).

import QtQuick                      2.12
import QtQuick.Layouts              1.12

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.Palette       1.0

Rectangle {
    id:                 telemetryPanel
    height:             telemetryLayout.height + (_toolsMargin * 2)
    width:              telemetryLayout.width + (_toolsMargin * 2)
    color:              qgcPal.window
    radius:             ScreenTools.defaultFontPixelWidth / 2

    // Sempre embaixo. Mantida como na base (o FlyViewWidgetLayer da base a lê;
    // o comum fixa a posição e não a usa).
    property bool       bottomMode: true

    DeadMouseArea { anchors.fill: parent }

    ColumnLayout {
        id:                 telemetryLayout
        anchors.margins:    _toolsMargin
        anchors.bottom:     parent.bottom
        anchors.left:       parent.left

         RowLayout {
            visible: mouseArea.containsMouse || valueArea.settingsUnlocked

            QGCColoredImage {
                source:             valueArea.settingsUnlocked ? "/res/LockOpen.svg" : "/res/pencil.svg"
                mipmap:             true
                width:              ScreenTools.minTouchPixels * 0.75
                height:             width
                sourceSize.width:   width
                color:              qgcPal.text
                fillMode:           Image.PreserveAspectFit

                QGCMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    valueArea.settingsUnlocked = !valueArea.settingsUnlocked
                }
            }
        }

        QGCMouseArea {
            id:                         mouseArea
            x:                          telemetryLayout.x
            y:                          telemetryLayout.y
            width:                      telemetryLayout.width
            height:                     telemetryLayout.height
            hoverEnabled:               true
            propagateComposedEvents:    true
        }

        HorizontalFactValueGrid {
            id:                     valueArea
            userSettingsGroup:      telemetryBarUserSettingsGroup
            defaultSettingsGroup:   telemetryBarDefaultSettingsGroup
        }

        GuidedActionConfirm {
            Layout.fillWidth:   true
            guidedController:   _guidedController
            altitudeSlider:     _guidedAltSlider
        }
    }
}
