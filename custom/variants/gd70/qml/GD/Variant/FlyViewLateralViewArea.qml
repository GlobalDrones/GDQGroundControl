// GD70: painel lateral do FlyView comum (import GD.Variant 1.0).
// Origem: archive/gd70 src/FlightDisplay/FlyViewLateralViewArea.qml.
//
// Correção: o archive lia a gasolina na instância 1 (a bateria, depois do
// remapeamento de f6ba286) e o "Est. Time" saía do % da bateria. Agora usa a
// mesma instância de gasolina do painel inferior (2).

import QtQuick          2.12
import QtQuick.Layouts  1.12

import QGroundControl           1.0
import QGroundControl.Palette   1.0

Item {
    id: root

    // Interface com o FlyView comum
    property var activeVehicle

    property int    _gasolineIndex: 2

    property real   sectionHeight:  height / 6

    property real gasolinaPercent: {
        if (!activeVehicle) return 0
        if (activeVehicle.batteries.count <= _gasolineIndex) return 0
        return activeVehicle.batteries.get(_gasolineIndex).percentRemaining.rawValue
    }

    // Autonomia estimada: tanque cheio = 2 h
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

    function safe(v, digits) {
        if (!v || isNaN(v))
            return "0"
        return Number(v).toFixed(digits)
    }

    QGCPalette { id: qgcPal }

    Rectangle {
        anchors.fill: parent
        color: qgcPal.toolbarBackground
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // EST. TIME
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

        // DIST. HOME
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

        // DIST. WP
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

        // ALT. REL (f6ba286 trocou AMSL por relativa)
        Item {
            width: parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Alt. Rel"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: activeVehicle ? safe(activeVehicle.altitudeRelative.value, 1) + " m" : "--"
                    color: "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }

        // HOR. SPEED (lê airSpeed, como nos outros produtos)
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

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: activeVehicle ? safe(activeVehicle.airSpeed.value, 1) + " m/s" : "--"
                    color: activeVehicle && activeVehicle.airSpeed.value > 17 ? "red" : "white"
                    font.pointSize: 14
                    font.bold: true
                }
            }
        }

        // VERT. SPEED
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
