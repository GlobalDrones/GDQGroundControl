/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

// Global Drones GD25: painel lateral do FlyView comum (import GD.Variant 1.0).
// Seis linhas: tempo estimado, distância até a home, distância até o WP,
// altitude AMSL, velocidade horizontal e vertical.
//
// Interface usada pelo FlyView comum:
//   activeVehicle   veículo ativo (pode ser nulo)

import QtQuick          2.12
import QtQuick.Layouts  1.12

import QGroundControl.Palette   1.0

Item {
    id: root

    property var activeVehicle

    // Instância de bateria da gasolina (posição na lista do veículo)
    property int _gasolineIndex: 1

    property real gasolinaPercent: (activeVehicle && activeVehicle.batteries.count > _gasolineIndex)
                                   ? activeVehicle.batteries.get(_gasolineIndex).percentRemaining.value
                                   : 0

    // Tempo estimado: 2 h com o tanque cheio, proporcional à gasolina
    property string estimatedTimeText: {
        if (!activeVehicle) return "--:--:--"

        var totalSeconds = 7200 * (gasolinaPercent / 100)

        if (!totalSeconds || isNaN(totalSeconds))
            return "--:--:--"

        var h = Math.floor(totalSeconds / 3600)
        var m = Math.floor((totalSeconds % 3600) / 60)
        var s = Math.floor(totalSeconds % 60)

        function pad(v) { return v < 10 ? "0" + v : v }

        return pad(h) + ":" + pad(m) + ":" + pad(s)
    }

    property real sectionHeight: height / 6

    function safe(v, digits) {
        if (!v || isNaN(v))
            return "0"
        return Number(v).toFixed(digits)
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    Rectangle {
        anchors.fill: parent
        color: qgcPal.toolbarBackground
    }

    Column {
        anchors.fill: parent
        spacing: 0

        //==============================================================
        // TEMPO ESTIMADO
        //==============================================================

        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Est. Time"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: estimatedTimeText
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }

        //==============================================================
        // DISTÂNCIA ATÉ A HOME
        //==============================================================

        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Dist. Home"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: activeVehicle ? safe(activeVehicle.distanceToHome.value, 2) + " m" : "--"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }

        //==============================================================
        // DISTÂNCIA ATÉ O WP
        //==============================================================

        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Dist. WP"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: activeVehicle ? safe(activeVehicle.distanceToNextWP.value, 2) + " m" : "--"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }

        //==============================================================
        // ALTITUDE AMSL
        //==============================================================

        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Alt. AMSL"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: activeVehicle ? safe(activeVehicle.altitudeAMSL.value, 1) + " m" : "--"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }

        //==============================================================
        // VELOCIDADE HORIZONTAL (airSpeed, como no app anterior)
        //==============================================================

        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Hor. Speed"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }

                // Vermelho acima de 17 m/s
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: activeVehicle ? safe(activeVehicle.airSpeed.value, 1) + " m/s" : "--"
                    color: activeVehicle && activeVehicle.airSpeed.value > 17 ? "red" : "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }

        //==============================================================
        // VELOCIDADE VERTICAL
        //==============================================================

        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Vert. Speed"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: activeVehicle ? safe(activeVehicle.climbRate.value, 1) + " m/s" : "--"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }
    }
}
