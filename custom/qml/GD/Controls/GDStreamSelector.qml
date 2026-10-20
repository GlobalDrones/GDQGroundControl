import QtQuick 2.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

// Seletor de câmera da fonte "Streams List": mostra o stream selecionado (alias
// ou, sem alias, o endereço) e o botão que passa para o próximo da lista.
//
// Uso: só posicionar (anchors/Row do pai). O tamanho é o do conteúdo.
//   textWidth   largura fixa da caixa de texto; o texto diminui e é cortado
//               para caber (painel estreito do GD60). 0 = largura do texto.
//   available   (leitura) a fonte de vídeo é "Streams List" e a lista tem câmeras
// Fica visível sozinho só nesse caso: trocar de câmera aqui nunca mexe numa
// fonte única (RTSP, SRT...), e com a lista vazia o botão não teria o que
// trocar. Não sobrescreva `visible`; para esconder (PiP recolhido etc.),
// esconda o pai.
Row {
    id:         control
    spacing:    ScreenTools.defaultFontPixelWidth
    visible:    available

    property real textWidth: 0

    readonly property bool available: QGroundControl.videoManager.hasVideo
                                      && _videoSettings.videoSource.rawValue === _videoSettings.streamsListVideoSource
                                      && QGroundControl.videoManager.streams.length > 0

    property var _videoSettings: QGroundControl.settingsManager.videoSettings

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        color:                  "#80000000"
        radius:                 4
        width:                  control.textWidth > 0 ? control.textWidth : cameraText.implicitWidth + ScreenTools.defaultFontPixelWidth * 2
        height:                 control.textWidth > 0 ? ScreenTools.defaultFontPixelHeight * 2 : cameraText.implicitHeight + ScreenTools.defaultFontPixelHeight

        Text {
            id:                     cameraText
            anchors.centerIn:       parent
            width:                  control.textWidth > 0 ? parent.width - ScreenTools.defaultFontPixelWidth : implicitWidth
            height:                 control.textWidth > 0 ? parent.height - ScreenTools.defaultFontPixelWidth : implicitHeight
            color:                  "white"
            font.bold:              true
            elide:                  Text.ElideRight
            horizontalAlignment:    Text.AlignHCenter
            verticalAlignment:      Text.AlignVCenter
            fontSizeMode:           control.textWidth > 0 ? Text.Fit : Text.FixedSize
            minimumPixelSize:       8
            text: {
                var streams = QGroundControl.videoManager.streams
                var idx = QGroundControl.videoManager.currentStreamIndex
                if (streams.length > 0 && idx >= 0 && idx < streams.length) {
                    var element = streams[idx]
                    return element.alias ? element.alias : element.ip
                }
                return qsTr("Sem câmeras")
            }
        }
    }

    QGCColoredImage {
        anchors.verticalCenter: parent.verticalCenter
        source:                 "/qmlimages/camera.svg"
        width:                  ScreenTools.defaultFontPixelHeight * 2
        height:                 width
        fillMode:               Image.PreserveAspectFit
        color:                  "white"

        MouseArea {
            anchors.fill:   parent
            onClicked: {
                var count = QGroundControl.videoManager.streams.length
                if (count > 0) {
                    QGroundControl.videoManager.selectStream((QGroundControl.videoManager.currentStreamIndex + 1) % count)
                }
            }
        }
    }
}
