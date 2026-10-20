import QtQuick          2.12
import QtQuick.Layouts  1.12

import QGroundControl           1.0
import QGroundControl.Palette   1.0

// GD30: painel lateral do Fly View, 7 linhas de rótulo e valor: tempo estimado
// restante, distâncias, altitudes e velocidades.
//
// Calcula a própria telemetria a partir de activeVehicle (o FlyView passa o
// veículo ativo).
Item {
    id: _root

    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    property real sectionHeight: height / 7

    // "Est. Time": segundos restantes enviados pelo firmware (REMAIN_SEC)
    property int    _remainSecs:    activeVehicle ? Math.floor(activeVehicle.gd30_remainsecs.rawValue.toFixed(0)) : 0
    property string _remainText:    _twoDigits(Math.floor(_remainSecs / 3600)) + ":"
                                    + _twoDigits(Math.floor((_remainSecs % 3600) / 60)) + ":"
                                    + _twoDigits(_remainSecs % 60)

    // Mesmo arredondamento do app anterior para as velocidades
    property real   _airSpeed:      activeVehicle ? Math.round(activeVehicle.airSpeed.value * 10) / 10 : 0
    property real   _climbRate:     activeVehicle ? Math.round(activeVehicle.climbRate.value * 10) / 10 : 0
    property bool   _lidarHigh:     activeVehicle ? activeVehicle.rangeFinderDist.value.toFixed(2) > 120 : false

    function _twoDigits(value) {
        return (value < 10 ? "0" : "") + value.toString()
    }

    // Valor com 2 casas e unidade, ou "--" sem veículo/valor
    function safeValue(fact, unit) {
        if (!fact || fact.value === undefined || isNaN(fact.value))
            return "--"
        return fact.value.toFixed(2) + unit
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    Rectangle {
        anchors.fill:   parent
        color:          qgcPal.toolbarBackground
    }

    Column {
        anchors.fill: parent

        Item {
            width:  parent.width
            height: sectionHeight

            ColumnLayout {
                anchors.top:    parent.top
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         sectionHeight
                spacing:        0

                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              "White"
                    text:               "Est. Time"
                    font.pointSize:     14
                    font.bold:          true
                }
                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              "White"
                    text:               _remainText
                    font.pointSize:     14
                    font.bold:          true
                }
            }
        }

        Item {
            width:  parent.width
            height: sectionHeight

            ColumnLayout {
                anchors.top:    parent.top
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         sectionHeight
                spacing:        0

                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              "White"
                    text:               "Dist. Home"
                    font.pointSize:     14
                    font.bold:          true
                }
                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              "White"
                    text:               safeValue(activeVehicle ? activeVehicle.distanceToHome : null, " m")
                    font.pointSize:     14
                    font.bold:          true
                }
            }
        }

        Item {
            width:  parent.width
            height: sectionHeight

            ColumnLayout {
                anchors.top:    parent.top
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         sectionHeight
                spacing:        0

                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              "White"
                    text:               "Dist. WP"
                    font.pointSize:     14
                    font.bold:          true
                }
                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              "White"
                    text:               safeValue(activeVehicle ? activeVehicle.distanceToNextWP : null, " m")
                    font.pointSize:     14
                    font.bold:          true
                }
            }
        }

        // Altitude pelo LIDAR, em vermelho acima de 120 m
        Item {
            width:  parent.width
            height: sectionHeight

            ColumnLayout {
                anchors.top:    parent.top
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         sectionHeight
                spacing:        0

                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              _lidarHigh ? "red" : "white"
                    text:               "Alt. LIDAR"
                    font.pointSize:     14
                    font.bold:          true
                }
                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              _lidarHigh ? "red" : "white"
                    text:               safeValue(activeVehicle ? activeVehicle.rangeFinderDist : null, " m")
                    font.pointSize:     14
                    font.bold:          true
                }
            }
        }

        Item {
            width:  parent.width
            height: sectionHeight

            ColumnLayout {
                anchors.top:    parent.top
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         sectionHeight
                spacing:        0

                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              "white"
                    text:               "Alt. AMSL"
                    font.pointSize:     14
                    font.bold:          true
                }
                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              "white"
                    text:               safeValue(activeVehicle ? activeVehicle.altitudeAMSL : null, " m")
                    font.pointSize:     14
                    font.bold:          true
                }
            }
        }

        // O rótulo diz "Hor. speed", mas o valor é airSpeed (como no app anterior).
        // Vermelho a partir de 17 m/s.
        Item {
            width:  parent.width
            height: sectionHeight

            ColumnLayout {
                anchors.top:    parent.top
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         sectionHeight
                spacing:        0

                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              "White"
                    text:               "Hor. speed"
                    font.pointSize:     14
                    font.bold:          true
                }
                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              !activeVehicle || _airSpeed < 17 ? "White" : "Red"
                    text:               activeVehicle ? _airSpeed + "m/s" : ""
                    font.pointSize:     14
                    font.bold:          true
                }
            }
        }

        Item {
            width:  parent.width
            height: sectionHeight

            ColumnLayout {
                anchors.top:    parent.top
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         sectionHeight
                spacing:        0

                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              "White"
                    text:               "Vert. speed"
                    font.pointSize:     14
                    font.bold:          true
                }
                Text {
                    Layout.alignment:   Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    color:              "White"
                    text:               activeVehicle ? _climbRate + "m/s" : ""
                    font.pointSize:     14
                    font.bold:          true
                }
            }
        }
    }
}
