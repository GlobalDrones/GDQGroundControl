/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

// Global Drones: substitui src/FlightDisplay/MultiVehicleList.qml em todos os
// produtos (ver custom/README.md). Painel "Multi-Vehicle" do Fly View, que só
// aparece com mais de um veículo conectado.
//
// Ações guiadas escondidas de vez (ver GuidedActionsController comum):
// - Saiu o bloco "aplicar a todos os veículos" (Pause / Start Mission), que
//   chamava guidedController.confirmAction.
// - Saíram os botões por veículo "Start Mission" e "Pause", que comandavam o
//   veículo direto, sem confirmação.
// Ficam o modo de voo, Arm, RTL e "Take control" (troca de modo de voo, igual
// ao menu de modos).

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.FlightMap     1.0

Item {
    property real   _margin:            ScreenTools.defaultFontPixelWidth / 2
    property real   _widgetHeight:      ScreenTools.defaultFontPixelHeight * 3
    property color  _textColor:         "black"
    property real   _rectOpacity:       0.8

    QGCPalette { id: qgcPal }

    QGCListView {
        id:                 missionItemEditorListView
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        spacing:            ScreenTools.defaultFontPixelHeight / 2
        orientation:        ListView.Vertical
        model:              QGroundControl.multiVehicleManager.vehicles
        cacheBuffer:        _cacheBuffer < 0 ? 0 : _cacheBuffer
        clip:               true

        property real _cacheBuffer:     height * 2

        delegate: Rectangle {
            width:      missionItemEditorListView.width
            height:     innerColumn.y + innerColumn.height + _margin
            color:      qgcPal.missionItemEditor
            opacity:    _rectOpacity
            radius:     _margin

            property var    _vehicle:   object

            ColumnLayout {
                id:                 innerColumn
                anchors.margins:    _margin
                anchors.top:        parent.top
                anchors.left:       parent.left
                anchors.right:      parent.left
                spacing:            _margin

                RowLayout {
                    Layout.fillWidth:       true

                    QGCLabel {
                        Layout.alignment:   Qt.AlignTop
                        text:               _vehicle ? _vehicle.id : ""
                        color:              _textColor
                    }

                    ColumnLayout {
                        Layout.alignment:   Qt.AlignCenter
                        spacing:            _margin

                        FlightModeMenu {
                            Layout.alignment:           Qt.AlignHCenter
                            font.pointSize:             ScreenTools.largeFontPointSize
                            color:                      _textColor
                            currentVehicle:             _vehicle
                        }

                        QGCLabel {
                            Layout.alignment:           Qt.AlignHCenter
                            text:                       _vehicle && _vehicle.armed ? qsTr("Armed") : qsTr("Disarmed")
                            color:                      _textColor
                        }
                    }

                    QGCCompassWidget {
                        size:       _widgetHeight
                        usedByMultipleVehicleList: true
                        vehicle:    _vehicle
                    }

                    QGCAttitudeWidget {
                        size:       _widgetHeight
                        vehicle:    _vehicle
                    }
                } // RowLayout

                Row {
                    spacing: ScreenTools.defaultFontPixelWidth

                    QGCButton {
                        text:       qsTr("Arm")
                        visible:    _vehicle && !_vehicle.armed
                        onClicked:  _vehicle.armed = true
                    }

                    QGCButton {
                        text:       qsTr("RTL")
                        visible:    _vehicle && _vehicle.armed && _vehicle.flightMode !== _vehicle.rtlFlightMode
                        onClicked:  _vehicle.flightMode = _vehicle.rtlFlightMode
                    }

                    QGCButton {
                        text:       qsTr("Take control")
                        visible:    _vehicle && _vehicle.armed && _vehicle.flightMode !== _vehicle.takeControlFlightMode
                        onClicked:  _vehicle.flightMode = _vehicle.takeControlFlightMode
                    }
                } // Row
            } // ColumnLayout
        } // delegate - Rectangle
    } // QGCListView
} // Item
