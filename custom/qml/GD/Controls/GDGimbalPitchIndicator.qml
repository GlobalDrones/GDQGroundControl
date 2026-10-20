import QtQuick 2.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

// Pitch do gimbal: ícone de câmera girado pelo ângulo, com o valor em graus.
// Lê o fato _GD_GimbalPitch do veículo (GIMBAL_DEVICE_ATTITUDE_STATUS).
//
// Uso: só posicionar (anchors/Row do pai). Tamanho próprio, quadrado de 2,5
// alturas de fonte. Não depende da fonte de vídeo.
//   vehicle     veículo lido (padrão: o ativo)
//   pitch       (leitura) último pitch válido em graus, já no sentido da tela:
//               positivo gira o ícone no sentido horário (câmera para baixo)
//   available   (leitura) há veículo com o fato _GD_GimbalPitch
// Fica visível sozinho só com `available`.
Item {
    id:         control
    width:      ScreenTools.defaultFontPixelHeight * 2.5
    height:     width
    visible:    available

    property var vehicle: QGroundControl.multiVehicleManager.activeVehicle

    readonly property bool available:   _pitchFact !== null
    readonly property real pitch:       _pitch

    property var  _pitchFact:   vehicle && vehicle._GD_GimbalPitch ? vehicle._GD_GimbalPitch : null
    property real _pitch:       0

    QGCPalette { id: qgcPal; colorGroupEnabled: control.enabled }

    Connections {
        target: control._pitchFact

        function onRawValueChanged() {
            var v = control._pitchFact.rawValue
            // Ignora zeros espúrios da telemetria
            if (Math.abs(v) > 0.01) {
                control._pitch = -v
            }
        }
    }

    // Gira o ícone e o rótulo juntos
    Item {
        anchors.fill:       parent
        rotation:           control.pitch
        transformOrigin:    Item.Center

        QGCColoredImage {
            anchors.fill:   parent
            source:         "/qmlimages/camera_video.svg"
            fillMode:       Image.PreserveAspectFit
            color:          "white"
        }

        Rectangle {
            width:                          parent.width * 0.5
            height:                         parent.width * 0.4
            anchors.verticalCenter:         parent.verticalCenter
            anchors.horizontalCenter:       parent.horizontalCenter
            anchors.horizontalCenterOffset: -parent.width * 0.15
            border.color:                   qgcPal.text
            color:                          "#80000000"

            QGCLabel {
                anchors.centerIn:   parent
                text:               Number(control.pitch).toFixed(0) + "°"
                color:              qgcPal.text
                font.pointSize:     8
            }
        }
    }
}
