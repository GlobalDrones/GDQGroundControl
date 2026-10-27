// GD70: painel lateral do FlyView comum (import GD.Variant 1.0).
// Origem: archive/gd70 src/FlightDisplay/FlyViewLateralViewArea.qml.
//
// Gasolina e "Est. Time" vêm do sensor de nível (bateria id 2), em litros, pela
// média móvel mahConsumedAvg (leituras 255 ignoradas). Origem: GitHub
// QGC-GD70/GD70_Dev 85dc9f7.

import QtQuick          2.12
import QtQuick.Layouts  1.12

import QGroundControl           1.0
import QGroundControl.Palette   1.0

Item {
    id: root

    // Interface com o FlyView comum
    property var activeVehicle

    property int    _gasolineBatteryId: 2       // sensor de nível de combustível = Batt[2]
    property real   _maxConsumed:       5000    // capacidade do tanque (mL), igual ao BatteryIndicator
    property real   _secondsPerLiter:   600     // 1 L a cada 10 min

    property real   sectionHeight:  height / 6

    property real gasolinaLiters: {
        if (!activeVehicle) return NaN
        for (var i = 0; i < activeVehicle.batteries.count; i++) {
            var battery = activeVehicle.batteries.get(i)
            if (battery.id.rawValue === _gasolineBatteryId) {
                return Math.max(0, (_maxConsumed - battery.mahConsumedAvg.rawValue) / 1000)
            }
        }
        return NaN
    }

    // Autonomia estimada pelos litros restantes
    property string estimatedTimeText: {
        if (!activeVehicle) return "--:--:--"

        var totalSeconds = gasolinaLiters * _secondsPerLiter
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
                    text: activeVehicle ? safe(activeVehicle.groundSpeed.value, 1) + " m/s" : "--"
                    color: activeVehicle && activeVehicle.groundSpeed.value > 15 ? "red" : "white"
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
