import QtQuick          2.12
import QtQuick.Layouts  1.12

// GD150: painel lateral do Fly View (distâncias, altitude e velocidades).
// Instanciado pelo FlyView comum. qgcPal vem do MainRootWindow.
Item {
    id: root

    // Interface do FlyView comum
    property var activeVehicle

    property real sectionHeight: height / 6

    function safe(v, digits) {
        if (!v || isNaN(v))
            return "0"
        return Number(v).toFixed(digits)
    }

    Rectangle {
        anchors.fill:   parent
        color:          qgcPal.toolbarBackground
    }

    Column {
        anchors.fill:   parent
        spacing:        0

        //==============================================================
        // DIST HOME
        //==============================================================

        Item {
            width:  parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment:   Qt.AlignHCenter
                    text:               "Dist. Home"
                    color:              "white"
                    font.pointSize:     14
                    font.bold:          true
                }

                Text {
                    Layout.alignment:   Qt.AlignHCenter
                    text:               activeVehicle ? safe(activeVehicle.distanceToHome.value, 2) + " m" : "--"
                    color:              "white"
                    font.pointSize:     14
                    font.bold:          true
                }
            }
        }

        //==============================================================
        // DIST WP
        //==============================================================

        Item {
            width:  parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment:   Qt.AlignHCenter
                    text:               "Dist. WP"
                    color:              "white"
                    font.pointSize:     14
                    font.bold:          true
                }

                Text {
                    Layout.alignment:   Qt.AlignHCenter
                    text:               activeVehicle ? safe(activeVehicle.distanceToNextWP.value, 2) + " m" : "--"
                    color:              "white"
                    font.pointSize:     14
                    font.bold:          true
                }
            }
        }

        //==============================================================
        // ALT AMSL
        //==============================================================

        Item {
            width:  parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment:   Qt.AlignHCenter
                    text:               "Alt. AMSL"
                    color:              "white"
                    font.pointSize:     14
                    font.bold:          true
                }

                Text {
                    Layout.alignment:   Qt.AlignHCenter
                    text:               activeVehicle ? safe(activeVehicle.altitudeAMSL.value, 1) + " m" : "--"
                    color:              "white"
                    font.pointSize:     14
                    font.bold:          true
                }
            }
        }

        //==============================================================
        // HOR SPEED (airSpeed; vermelho acima de 17 m/s)
        //==============================================================

        Item {
            width:  parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment:   Qt.AlignHCenter
                    text:               "Hor. Speed"
                    color:              "white"
                    font.pointSize:     14
                    font.bold:          true
                }

                Text {
                    Layout.alignment:   Qt.AlignHCenter
                    text:               activeVehicle ? safe(activeVehicle.airSpeed.value, 1) + " m/s" : "--"
                    color:              activeVehicle && activeVehicle.airSpeed.value > 17 ? "red" : "white"
                    font.pointSize:     14
                    font.bold:          true
                }
            }
        }

        //==============================================================
        // VERT SPEED
        //==============================================================

        Item {
            width:  parent.width
            height: root.sectionHeight

            ColumnLayout {
                anchors.fill: parent

                Text {
                    Layout.alignment:   Qt.AlignHCenter
                    text:               "Vert. Speed"
                    color:              "white"
                    font.pointSize:     14
                    font.bold:          true
                }

                Text {
                    Layout.alignment:   Qt.AlignHCenter
                    text:               activeVehicle ? safe(activeVehicle.climbRate.value, 1) + " m/s" : "--"
                    color:              "white"
                    font.pointSize:     14
                    font.bold:          true
                }
            }
        }
    }
}
