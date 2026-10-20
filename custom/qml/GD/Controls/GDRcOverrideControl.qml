import QtQuick          2.12
import QtQuick.Controls 2.12

import QGroundControl   1.0
import GD.RcOverride    1.0

// Botão do RC Override e confirmação. O envio dos canais é do GDRcOverride
// (C++); aqui fica só a interface.
//
// O FlyView de cada produto posiciona o botão (anchors, z e, se quiser,
// width/height). Nos produtos sem RC Override ele fica invisível: não ligue
// visible por fora.
Rectangle {
    id: root

    // Tamanho do GD25. O GD60 usa width: parent.width * 0.75
    width:  parent ? parent.width * 0.15 : 0
    height: parent ? parent.height * 0.1 : 0

    /// Tamanho da confirmação. Padrão: relativo ao item que contém o botão.
    property real popupWidth:   parent ? parent.width * 0.4 : 0
    property real popupHeight:  parent ? parent.height * 0.25 : 0

    /// Override ativo: esta GCS está enviando os canais
    readonly property bool overrideActive: GDRcOverride.running

    property bool _available: QGroundControl.corePlugin.gdRcOverride && GDRcOverride.available

    visible:        _available
    radius:         5
    color:          overrideActive ? "red" : "green"
    border.color:   "black"
    border.width:   1

    Text {
        anchors.centerIn:   parent
        text:               overrideActive ? "Stop Override" : "Override RC"
        color:              "white"
        font.bold:          true
    }

    MouseArea {
        anchors.fill:   parent
        onClicked: {
            alertText.text = ""
            confirmOverridePopup.open()
        }
    }

    Popup {
        id:                 confirmOverridePopup
        modal:              true
        focus:              true
        width:              root.popupWidth
        height:             root.popupHeight
        anchors.centerIn:   Overlay.overlay

        background: Rectangle {
            color:          "#333"
            radius:         8
            border.color:   "white"
        }

        Column {
            spacing:            20
            anchors.centerIn:   parent

            Text {
                text: !overrideActive
                      ? "Tem certeza que deseja ATIVAR o Override RC?"
                      : "Tem certeza que deseja DESATIVAR o Override RC?"
                color:                  "white"
                font.pixelSize:         18
                wrapMode:               Text.WordWrap
                horizontalAlignment:    Text.AlignHCenter
            }

            Row {
                spacing:                    20
                anchors.horizontalCenter:   parent.horizontalCenter

                Rectangle {
                    id:             btnYes
                    width:          150
                    height:         80
                    radius:         5
                    color:          "#66bb6a"
                    border.width:   btnYesMouseArea.containsMouse ? 3 : 0
                    border.color:   "yellow"

                    Text {
                        anchors.centerIn:   parent
                        text:               "SIM"
                        color:              "white"
                        font.bold:          true
                    }

                    MouseArea {
                        id:             btnYesMouseArea
                        anchors.fill:   parent
                        hoverEnabled:   true
                        onClicked: {
                            if (overrideActive) {
                                GDRcOverride.stop()
                            } else if (!GDRcOverride.start()) {
                                // Popup aberto com o motivo: o override não ligou
                                alertText.text = "ATENÇÃO: " + GDRcOverride.lastError
                                return
                            }
                            confirmOverridePopup.close()
                        }
                    }
                }

                Rectangle {
                    id:             btnNo
                    width:          150
                    height:         80
                    radius:         5
                    color:          "#e53935"
                    border.width:   btnNoMouseArea.containsMouse ? 3 : 0
                    border.color:   "yellow"

                    Text {
                        anchors.centerIn:   parent
                        text:               "NÃO"
                        color:              "white"
                        font.bold:          true
                    }

                    MouseArea {
                        id:             btnNoMouseArea
                        anchors.fill:   parent
                        hoverEnabled:   true
                        onClicked:      confirmOverridePopup.close()
                    }
                }
            }
        }

        Text {
            id:                         alertText
            width:                      parent.width
            anchors.bottom:             parent.bottom
            anchors.horizontalCenter:   parent.horizontalCenter
            font.pixelSize:             18
            wrapMode:                   Text.WordWrap
            horizontalAlignment:        Text.AlignHCenter
            color:                      "white"
        }
    }
}
