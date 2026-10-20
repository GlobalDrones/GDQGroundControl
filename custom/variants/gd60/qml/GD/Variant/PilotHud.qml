import QtQuick          2.12
import QtGraphicalEffects 1.0

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

// GD60: HUD do piloto, desenhado sobre o mapa ou o vídeo (sem área de toque).
//   - escada de pitch girando com o roll e símbolo central (crossHair.svg);
//   - arco de roll de -60° a 60° com ponteiro;
//   - bússola com rumo, setas de waypoint (amarela), home (roxa) e vento (azul),
//     direção e velocidade do vento;
//   - fita de velocidade do ar com faixas de estol/segura/máxima e GS embaixo;
//   - fita de altitude relativa com LIDAR embaixo e fita de velocidade vertical.
// O símbolo central é do HUD e fica sempre visível; a mira "Aim" é outra
// (GDCrosshair, no FlyView).
Item {
    id: _root

    property var    activeVehicle
    property bool   androidBuild:   false
    property real   toolsMargin:    ScreenTools.defaultFontPixelWidth * 0.75

    /// Lado do mostrador de rumo (o painel lateral desenha o contorno do GD60
    /// com 2/3 desse tamanho)
    readonly property real headingDialSize: headingContainer.width

    readonly property color hudGrey:        "#85333366"
    readonly property color hudPaleGreen:   "#9AFF75"
    readonly property color hudPaleBlue:    "#00ffff"
    readonly property color hudPalePurple:  "#ff00ff"
    readonly property color hudYellow:      "#FFD700"

    // Arco de roll: -60°..60° desenhados de 1,138π a 1,805π
    readonly property real startRollAngle:  Math.PI * 1.138
    readonly property real endRollAngle:    Math.PI * 1.805
    readonly property real diffRollAngle:   Math.abs(endRollAngle - startRollAngle)

    // Faixas da fita de velocidade (m/s), valores do projeto do GD60:
    // estol 22, segura até 44, máxima 47,22
    readonly property real vSeguraMin:  22
    readonly property real vSeguraMax:  44
    readonly property real vMax:        47.22

    function degToArcRad(deg) {
        var t = (deg + 60) / 120    // -60..60 -> 0..1
        return startRollAngle + t * diffRollAngle
    }

    //-- Pitch
    Item {
        id:                 pitchArea
        width:              parent.width / 3
        height:             parent.width / 3
        anchors.centerIn:   parent
        clip:               true

        property real pitch:            activeVehicle ? -activeVehicle.pitch.rawValue.toFixed(2) : 0
        property real lineSpacing:      height / 5
        readonly property int totalLines: 37    // -90 a 90, de 5 em 5 graus
        // +80 de deslocamento inicial: sem ele o 0 do indicador fica em -80
        property real pitchOffsetY:     (pitch + 80) / 5 * lineSpacing

        Repeater {
            model: pitchArea.totalLines

            delegate: Item {
                width:      parent.width
                height:     pitchArea.lineSpacing
                rotation:   activeVehicle ? -activeVehicle.roll.rawValue.toFixed(1) : 0
                y:          index * pitchArea.lineSpacing + pitchArea.pitchOffsetY * -1
                visible:    y + height >= 0 && y <= pitchArea.height

                property int angle: 90 - index * 5

                Rectangle {
                    anchors.verticalCenter:     parent.verticalCenter
                    anchors.horizontalCenter:   parent.horizontalCenter
                    height:                     4
                    width:                      angle % 10 === 0 ? parent.width * 0.5 : parent.width * 0.25
                    color:                      hudPaleGreen
                    border.width:               1
                    border.color:               "black"
                }

                Text {
                    visible:                angle % 10 === 0
                    text:                   angle + "°"
                    color:                  hudPaleGreen
                    font.pixelSize:         androidBuild ? 18 : ScreenTools.defaultFontPixelWidth * 2
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold:              true
                    anchors.left:           parent.left
                    anchors.leftMargin:     width * 0.55
                    z:                      parent.z + 20
                    layer.enabled:          true
                    layer.smooth:           true
                    layer.effect: DropShadow {
                        color:              "black"
                        horizontalOffset:   0
                        verticalOffset:     0
                        radius:             3
                        smooth:             true
                        samples:            32
                        spread:             0.8
                    }
                }
            }
        }
    }

    // Símbolo central do HUD
    QGCColoredImage {
        id:                         crosshairCentral
        width:                      parent.width / 3
        height:                     parent.width / 5
        anchors.verticalCenter:     parent.verticalCenter
        anchors.horizontalCenter:   parent.horizontalCenter
        color:                      hudPaleGreen
        source:                     "/qmlimages/crossHair.svg"
        layer.enabled:              true
        layer.smooth:               true
        layer.effect: DropShadow {
            color:              "black"
            horizontalOffset:   0
            verticalOffset:     0
            radius:             2
            smooth:             true
            samples:            32
            spread:             0.8
        }
    }

    //-- Roll
    Item {
        id:                         dialRoll
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.top:                parent.top
        width:                      parent.width * 1.5
        height:                     parent.width / 2
        rotation:                   5

        Canvas {
            id:             rollArc
            anchors.fill:   parent
            renderTarget:   Canvas.Image
            renderStrategy: Canvas.Cooperative

            property real angleRoll: 0

            Behavior on angleRoll {
                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)

                var centerX = width / 2
                var centerY = height / 2
                var radius = Math.min(width, height) / 2.5

                // Arco principal
                ctx.strokeStyle = hudPaleGreen
                ctx.lineWidth = 5
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius - 10, startRollAngle, endRollAngle, false)
                ctx.stroke()

                // Marcas de -60 a 60; maiores em ±30 e ±60
                var marcacoes = [-60, -45, -30, -20, -10, 10, 20, 30, 45, 60]
                for (var i = 0; i < marcacoes.length; i++) {
                    var deg = marcacoes[i]
                    var rad = degToArcRad(deg)
                    var innerRadius = radius - 10
                    var outerRadius = (deg === -60 || deg === -30 || deg === 30 || deg === 60) ? radius + 25 : radius + 5

                    ctx.beginPath()
                    ctx.moveTo(centerX + innerRadius * Math.cos(rad), centerY + innerRadius * Math.sin(rad))
                    ctx.lineTo(centerX + outerRadius * Math.cos(rad), centerY + outerRadius * Math.sin(rad))
                    ctx.stroke()
                }
            }

            // Repinta a ~28 fps (cf577b2) e segue o roll do veículo, limitado a ±60°
            Timer {
                interval:   36
                running:    true
                repeat:     true
                onTriggered: {
                    rollArc.requestPaint()
                    if (activeVehicle) {
                        var rollDeg = Math.max(-60, Math.min(60, activeVehicle.roll.rawValue))
                        rollArc.angleRoll = degToArcRad(rollDeg)
                    }
                }
            }
        }

        // Marca fixa do zero
        QGCColoredImage {
            width:                          dialRoll.width / 20
            height:                         dialRoll.height / 2
            anchors.horizontalCenter:       rollArc.horizontalCenter
            anchors.verticalCenter:         rollArc.verticalCenter
            anchors.verticalCenterOffset:   -dialRoll.height * 0.95
            anchors.horizontalCenterOffset: -dialRoll.width * 0.0215
            color:                          hudPaleGreen
            source:                         "/qmlimages/rollPointer.svg"
            transformOrigin:                Item.Bottom
            rotation:                       175
            smooth:                         true
        }

        // Ponteiro do roll
        QGCColoredImage {
            width:                          dialRoll.width / 15
            height:                         dialRoll.height / 2
            anchors.horizontalCenter:       rollArc.horizontalCenter
            anchors.verticalCenter:         rollArc.verticalCenter
            anchors.verticalCenterOffset:   -dialRoll.height / 4
            color:                          hudPaleGreen
            source:                         "/qmlimages/rollPointer.svg"
            transformOrigin:                Item.Bottom
            rotation:                       (rollArc.angleRoll * 180 / Math.PI) - 270
            smooth:                         true
        }
    }

    //-- Rumo
    Item {
        id:                         headingContainer
        width:                      parent.width * 0.25
        height:                     width
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.top:                pitchArea.bottom
        anchors.margins:            toolsMargin * 0.5

        Rectangle {
            anchors.fill:   parent
            radius:         width / 2
            color:          hudGrey
            opacity:        0.85
            border.color:   hudPaleGreen
            border.width:   1
            layer.enabled:  true
            layer.smooth:   true
            layer.effect: DropShadow {
                color:              "black"
                horizontalOffset:   0
                verticalOffset:     0
                radius:             2
                smooth:             true
                samples:            32
                spread:             0.2
            }
        }

        QGCColoredImage {
            anchors.fill:   parent
            source:         "/qmlimages/compassInstrumentDial.svg"
            color:          hudPaleGreen
            rotation:       activeVehicle ? -activeVehicle.heading.rawValue.toFixed(2) : 0
            layer.enabled:  true
            layer.smooth:   true
            layer.effect: DropShadow {
                color:              "black"
                horizontalOffset:   0
                verticalOffset:     0
                radius:             1
                smooth:             true
                samples:            32
                spread:             0.5
            }
        }
    }

    // GD60 no centro da bússola
    QGCColoredImage {
        width:                      headingContainer.width / 2
        height:                     headingContainer.height / 2
        anchors.horizontalCenter:   headingContainer.horizontalCenter
        anchors.verticalCenter:     headingContainer.verticalCenter
        source:                     "/qmlimages/GD60_lowres.png"
        color:                      hudPaleGreen
        rotation:                   180
        layer.enabled:              true
        layer.smooth:               true
        layer.effect: DropShadow {
            color:              "black"
            horizontalOffset:   0
            verticalOffset:     0
            radius:             1
            smooth:             true
            samples:            32
            spread:             0.5
        }
    }

    // Marca do rumo atual, no topo da bússola
    QGCColoredImage {
        id:                         pointerHeading
        width:                      headingContainer.width / 5
        height:                     width
        anchors.horizontalCenter:   headingContainer.horizontalCenter
        anchors.bottom:             headingContainer.top
        anchors.bottomMargin:       -toolsMargin * 0.5
        color:                      hudPaleGreen
        source:                     "/qmlimages/rollPointer.svg"
        rotation:                   180
        smooth:                     true
        layer.enabled:              true
        layer.smooth:               true
        layer.effect: DropShadow {
            color:              "black"
            horizontalOffset:   0
            verticalOffset:     0
            radius:             1
            smooth:             true
            samples:            32
            spread:             0.5
        }
    }

    // Setas na borda da bússola: waypoint (amarela), home (roxa) e vento (azul).
    // A orientação vem só de rotation: no app anterior o transform Rotation
    // extra nunca valeu (ReferenceError em angle_fixed, ângulo 0); aplicá-lo
    // giraria as setas mais angleFixed graus.
    Repeater {
        model: [
            { color: hudYellow,     target: "waypoint" },
            { color: hudPalePurple, target: "home" },
            { color: hudPaleBlue,   target: "wind" }
        ]

        QGCColoredImage {
            width:          headingContainer.width / 7
            height:         width
            color:          modelData.color
            source:         "/qmlimages/rollPointer.svg"
            rotation:       angleFixed + 90
            smooth:         true
            layer.enabled:  true
            layer.smooth:   true

            property real centerX:      headingContainer.x + headingContainer.width / 2
            property real centerY:      headingContainer.y + headingContainer.height / 2
            property real innerRadius:  headingContainer.width * 0.40
            property real headingActual: activeVehicle ? activeVehicle.heading.rawValue : 0
            property real bearing: {
                if (!activeVehicle) {
                    return 0
                }
                switch (modelData.target) {
                case "waypoint":    return activeVehicle.headingToNextWP.value
                case "home":        return activeVehicle.headingToHome.value
                default:            return activeVehicle.wind.direction.rawValue
                }
            }
            // Ângulo relativo ao disco da bússola
            property real angleFixed:   bearing - headingActual - 90
            property real angleRad:     angleFixed * Math.PI / 180

            x: centerX + innerRadius * Math.cos(angleRad) - width / 2
            y: centerY + innerRadius * Math.sin(angleRad) - height / 2

            layer.effect: DropShadow {
                color:              "black"
                horizontalOffset:   0
                verticalOffset:     0
                radius:             1
                smooth:             true
                samples:            32
                spread:             0.5
            }
        }
    }

    // Rumo atual
    Rectangle {
        id:                         headingValueBox
        width:                      ScreenTools.defaultFontPixelWidth * 6
        height:                     ScreenTools.defaultFontPixelHeight
        anchors.horizontalCenter:   pointerHeading.horizontalCenter
        anchors.verticalCenter:     pointerHeading.verticalCenter
        color:                      "black"
        border.color:               hudPaleGreen
        border.width:               1

        Text {
            anchors.centerIn:   parent
            text:               activeVehicle ? activeVehicle.heading.rawValue.toFixed(0).padStart(3, '0') + "°" : ""
            color:              hudPaleGreen
            font.pixelSize:     ScreenTools.defaultFontPixelWidth * 2
            font.bold:          true
        }
    }

    // Rumo para o próximo waypoint
    Rectangle {
        width:                  ScreenTools.defaultFontPixelWidth * 10
        height:                 ScreenTools.defaultFontPixelHeight
        anchors.right:          pointerHeading.left
        anchors.rightMargin:    toolsMargin
        anchors.verticalCenter: pointerHeading.verticalCenter
        color:                  "black"
        border.color:           hudPaleGreen
        border.width:           1

        Text {
            anchors.centerIn:   parent
            text:               activeVehicle ? " WP: " + activeVehicle.headingToNextWP.rawValue.toFixed(0).padStart(3, '0') + "°" : ""
            color:              hudYellow
            font.pixelSize:     ScreenTools.defaultFontPixelWidth * 2
            font.bold:          true
        }
    }

    // Rumo para o home
    Rectangle {
        width:                  ScreenTools.defaultFontPixelWidth * 10
        height:                 ScreenTools.defaultFontPixelHeight
        anchors.left:           pointerHeading.right
        anchors.leftMargin:     toolsMargin
        anchors.verticalCenter: pointerHeading.verticalCenter
        color:                  "black"
        border.color:           hudPaleGreen
        border.width:           1

        Text {
            anchors.centerIn:   parent
            text:               activeVehicle ? " HM: " + activeVehicle.headingToHome.rawValue.toFixed(0).padStart(3, '0') + "°" : ""
            color:              hudPalePurple
            font.pixelSize:     ScreenTools.defaultFontPixelWidth * 2
            font.bold:          true
        }
    }

    // Direção do vento
    Rectangle {
        width:              ScreenTools.defaultFontPixelWidth * 9
        height:             ScreenTools.defaultFontPixelHeight
        anchors.top:        headingContainer.bottom
        anchors.topMargin:  toolsMargin * 0.5
        anchors.right:      headingContainer.horizontalCenter
        color:              "black"
        border.color:       hudPaleGreen
        border.width:       1

        Text {
            anchors.centerIn:   parent
            color:              hudPaleBlue
            font.pixelSize:     ScreenTools.defaultFontPixelWidth * 1.8
            font.bold:          true
            text:               activeVehicle ? "WND " + activeVehicle.wind.direction.rawValue.toFixed(0).padStart(3, '0') + "°" : ""
        }
    }

    // Velocidade do vento
    Rectangle {
        width:              ScreenTools.defaultFontPixelWidth * 9
        height:             ScreenTools.defaultFontPixelHeight
        anchors.top:        headingContainer.bottom
        anchors.topMargin:  toolsMargin * 0.5
        anchors.left:       headingContainer.horizontalCenter
        color:              "black"
        border.color:       hudPaleGreen
        border.width:       1

        Text {
            anchors.centerIn:   parent
            color:              hudPaleBlue
            font.pixelSize:     ScreenTools.defaultFontPixelWidth * 2
            font.bold:          true
            text:               activeVehicle ? activeVehicle.wind.speed.rawValue.toFixed(1) + " m/s" : ""
        }
    }

    //-- Fita de velocidade do ar (à esquerda)
    Item {
        id:                     airspeedTape
        width:                  parent.width / 10
        height:                 parent.height * 2 / 3
        anchors.verticalCenter: parent.verticalCenter
        anchors.right:          crosshairCentral.left
        anchors.rightMargin:    toolsMargin * 20
        clip:                   true

        property real currentValue:                 activeVehicle ? -activeVehicle.airSpeed.rawValue.toFixed(2) : 0
        property real lineSpacing:                  height / 10
        readonly property int  totalLines:          80      // 190 para baixo, de 5 em 5
        readonly property real unitsPerLineSpacing: 5
        readonly property real pixelPerUnit:        lineSpacing / unitsPerLineSpacing
        property real scrollOffsetY:                -1 * currentValue * pixelPerUnit

        Rectangle {
            anchors.fill:   parent
            color:          hudGrey
            border.color:   hudPaleGreen
            border.width:   2
        }

        Repeater {
            model: airspeedTape.totalLines

            delegate: Item {
                width:      parent.width
                height:     airspeedTape.lineSpacing
                y:          ((index - 0.5) * airspeedTape.lineSpacing) + airspeedTape.scrollOffsetY + centerOffset
                visible:    y + height >= 0 && y <= airspeedTape.height

                property int angle: 190 - index * 5
                readonly property real indexZero:       190 / 5
                readonly property real centerOffset:    airspeedTape.height / 2 - (indexZero * airspeedTape.lineSpacing)

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    height:                 2
                    width:                  angle % 10 === 0 ? parent.width * 0.5 : parent.width * 0.25
                    color:                  hudPaleGreen
                }

                Text {
                    visible:                angle % 10 === 0
                    text:                   angle.toFixed(0)
                    color:                  hudPaleGreen
                    font.pixelSize:         androidBuild ? 15 : ScreenTools.defaultFontPixelWidth * 2
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold:              true
                    anchors.left:           parent.left
                    anchors.leftMargin:     parent.width * 0.55
                    z:                      parent.z + 20
                }
            }
        }

        QGCColoredImage {
            id:                     airspeedPointer
            width:                  parent.width * 0.5
            height:                 width
            anchors.verticalCenter: parent.verticalCenter
            color:                  hudPaleGreen
            z:                      10
            source:                 "/qmlimages/rollPointer.svg"
            rotation:               270
            smooth:                 false
        }

        Rectangle {
            id:                     airspeedValueBox
            width:                  ScreenTools.defaultFontPixelWidth * (androidBuild ? 5 : 8)
            height:                 ScreenTools.defaultFontPixelHeight
            anchors.left:           airspeedPointer.right
            anchors.leftMargin:     -toolsMargin * 3
            anchors.verticalCenter: parent.verticalCenter
            color:                  "black"
            border.color:           hudPaleGreen
            border.width:           1
            z:                      airspeedPointer.z + 1
        }

        Text {
            text:               activeVehicle ? activeVehicle.airSpeed.rawValue.toFixed(1).padStart(3, '0') : ""
            color:              hudPaleGreen
            font.pixelSize:     ScreenTools.defaultFontPixelWidth * 2
            font.bold:          true
            anchors.centerIn:   airspeedValueBox
            z:                  parent.z + 20
        }
    }

    // Faixas de velocidade ao lado da fita: estol (vermelho), segura (verde),
    // até a máxima (amarelo), acima da máxima (vermelho)
    Item {
        id:             speedColorBar
        width:          airspeedTape.width * 0.1
        anchors.top:    airspeedTape.top
        anchors.bottom: airspeedTape.bottom
        anchors.left:   airspeedTape.right
        clip:           true

        function yFor(v) {
            return airspeedTape.height / 2 - (v * airspeedTape.pixelPerUnit) + airspeedTape.scrollOffsetY
        }

        Repeater {
            model: [
                { v1: -vSeguraMin,  v2: vSeguraMin, color: "red" },
                { v1: vSeguraMin,   v2: vSeguraMax, color: "green" },
                { v1: vSeguraMax,   v2: vMax,       color: "yellow" },
                { v1: vMax,         v2: 80,         color: "red" }
            ]

            Rectangle {
                width:          speedColorBar.width
                y:              speedColorBar.yFor(modelData.v2)
                height:         Math.abs(modelData.v2 - modelData.v1) * airspeedTape.pixelPerUnit
                color:          modelData.color
                opacity:        0.75
                border.width:   1
                border.color:   hudPaleGreen
            }
        }
    }

    // Velocidade em relação ao solo
    Item {
        anchors.top:    airspeedTape.bottom
        anchors.left:   airspeedTape.left
        width:          airspeedTape.width
        height:         ScreenTools.defaultFontPixelHeight * 1.2
        clip:           true

        Rectangle {
            id:                 groundSpeedValueBox
            anchors.fill:       parent
            anchors.topMargin:  -2
            color:              "black"
            border.width:       2
            border.color:       hudPaleGreen
        }

        Text {
            text:               activeVehicle ? "GS: " + activeVehicle.groundSpeed.rawValue.toFixed(1).padStart(3, '0') : ""
            color:              hudPaleGreen
            font.pixelSize:     ScreenTools.defaultFontPixelWidth * (androidBuild ? 1.5 : 2)
            font.bold:          true
            anchors.centerIn:   groundSpeedValueBox
            z:                  parent.z + 20
        }
    }

    //-- Fita de altitude relativa (à direita)
    Item {
        id:                     altitudeTape
        width:                  parent.width / 10
        height:                 parent.height * 2 / 3
        anchors.verticalCenter: parent.verticalCenter
        anchors.left:           crosshairCentral.right
        anchors.leftMargin:     toolsMargin * 20
        clip:                   true

        property real currentValue:                 activeVehicle ? -activeVehicle.altitudeRelative.rawValue.toFixed(1) : 0
        property real lineSpacing:                  height / 6
        readonly property int  totalLines:          41      // 200 a -200, de 10 em 10
        readonly property int  zeroIndex:           20
        readonly property real unitsPerLineSpacing: 10
        readonly property real pixelPerUnit:        lineSpacing / unitsPerLineSpacing
        property real scrollOffsetY:                -1 * currentValue * pixelPerUnit
        // Põe a linha do zero no centro
        readonly property real centerOffset:        (height / 2) - (zeroIndex * lineSpacing)

        Rectangle {
            anchors.fill:   parent
            color:          hudGrey
            border.color:   hudPaleGreen
            border.width:   2
        }

        Repeater {
            model: altitudeTape.totalLines

            delegate: Item {
                width:      parent.width
                height:     altitudeTape.lineSpacing
                y:          ((index - 0.5) * altitudeTape.lineSpacing) + altitudeTape.scrollOffsetY + altitudeTape.centerOffset
                visible:    y + height >= 0 && y <= altitudeTape.height

                property int altitudeScale: 200 - index * 10

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right:          parent.right
                    height:                 2
                    width:                  altitudeScale % 10 === 0 ? parent.width * 0.5 : parent.width * 0.25
                    color:                  hudPaleGreen
                }

                Text {
                    visible:                altitudeScale % 10 === 0
                    text:                   altitudeScale.toFixed(0)
                    color:                  hudPaleGreen
                    font.pixelSize:         androidBuild ? 14 : ScreenTools.defaultFontPixelWidth * 2
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold:              true
                    anchors.right:          parent.right
                    anchors.rightMargin:    parent.width * 0.55
                    z:                      parent.z + 20
                }
            }
        }

        QGCColoredImage {
            id:                     altitudePointer
            width:                  parent.width * 0.5
            height:                 width
            anchors.verticalCenter: parent.verticalCenter
            anchors.right:          parent.right
            color:                  hudPaleGreen
            z:                      10
            source:                 "/qmlimages/rollPointer.svg"
            rotation:               90
            smooth:                 false
        }

        Rectangle {
            id:                     altitudeValueBox
            width:                  ScreenTools.defaultFontPixelWidth * (androidBuild ? 5 : 8)
            height:                 ScreenTools.defaultFontPixelHeight
            anchors.right:          altitudePointer.left
            anchors.rightMargin:    -toolsMargin * 3
            anchors.verticalCenter: parent.verticalCenter
            color:                  "black"
            border.color:           hudPaleGreen
            border.width:           1
            z:                      altitudePointer.z + 1
        }

        Text {
            text:               activeVehicle ? activeVehicle.altitudeRelative.rawValue.toFixed(1).padStart(3, '0') : ""
            color:              hudPaleGreen
            font.pixelSize:     ScreenTools.defaultFontPixelWidth * (androidBuild ? 1.5 : 2)
            font.bold:          true
            anchors.centerIn:   altitudeValueBox
            z:                  parent.z + 20
        }
    }

    // Distância do LIDAR
    Item {
        anchors.top:    altitudeTape.bottom
        anchors.left:   altitudeTape.left
        width:          altitudeTape.width
        height:         ScreenTools.defaultFontPixelHeight * 1.2
        clip:           true

        Rectangle {
            id:                 lidarValueBox
            anchors.fill:       parent
            anchors.topMargin:  -2
            color:              "black"
            border.width:       2
            border.color:       hudPaleGreen
        }

        Text {
            text:               activeVehicle ? "LD: " + activeVehicle.rangeFinderDist.value.toFixed(1).padStart(3, '0') : ""
            color:              hudPaleGreen
            font.pixelSize:     ScreenTools.defaultFontPixelWidth * (androidBuild ? 1.5 : 2)
            font.bold:          true
            anchors.centerIn:   lidarValueBox
            z:                  parent.z + 20
        }
    }

    //-- Fita de velocidade vertical (à direita da altitude)
    Item {
        id:                     climbTape
        width:                  altitudeTape.width * 0.85
        height:                 altitudeTape.height * 0.85
        anchors.verticalCenter: parent.verticalCenter
        anchors.left:           altitudeTape.right
        clip:                   true

        property real currentValue:                 activeVehicle ? -activeVehicle.climbRate.rawValue.toFixed(2) : 0
        readonly property real speedStep:           0.5
        property real lineSpacing:                  height / 10
        readonly property int  totalLines:          81      // 20 a -20 m/s, de 0,5 em 0,5
        readonly property int  zeroIndex:           40
        readonly property real unitsPerLineSpacing: speedStep
        readonly property real pixelPerUnit:        lineSpacing / unitsPerLineSpacing
        property real scrollOffsetY:                -1 * currentValue * pixelPerUnit
        readonly property real centerOffset:        (height / 2) - (zeroIndex * lineSpacing)

        Rectangle {
            anchors.fill:       parent
            anchors.leftMargin: -2
            color:              hudGrey
            border.color:       hudPaleGreen
            border.width:       2
        }

        Repeater {
            model: climbTape.totalLines

            delegate: Item {
                width:      parent.width
                height:     climbTape.lineSpacing
                y:          ((index - 0.5) * climbTape.lineSpacing) + climbTape.scrollOffsetY + climbTape.centerOffset
                visible:    y + height >= 0 && y <= climbTape.height

                property real verticalScale: 20 - index * climbTape.speedStep

                // Linha longa a cada 5 m/s, média a cada 1 m/s, curta a cada 0,5 m/s
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right:          parent.right
                    height:                 2
                    width:                  isMultipleOfFive ? parent.width * 0.7 : (isMultipleOfOne ? parent.width * 0.5 : parent.width * 0.3)
                    color:                  hudPaleGreen

                    property bool isMultipleOfFive: (verticalScale * 10) % 50 === 0
                    property bool isMultipleOfOne:  (verticalScale * 10) % 10 === 0 && !isMultipleOfFive
                }

                Text {
                    visible:                verticalScale % 1 === 0
                    text:                   verticalScale.toFixed(0)
                    color:                  hudPaleGreen
                    font.pixelSize:         androidBuild ? 15 : ScreenTools.defaultFontPixelWidth * 2
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold:              true
                    anchors.left:           parent.left
                    anchors.leftMargin:     toolsMargin
                    z:                      parent.z + 20
                }
            }
        }

        QGCColoredImage {
            id:                     climbPointer
            width:                  parent.width * 0.5
            height:                 width
            anchors.verticalCenter: parent.verticalCenter
            anchors.right:          parent.right
            color:                  hudPaleGreen
            z:                      10
            source:                 "/qmlimages/rollPointer.svg"
            rotation:               90
            smooth:                 false
        }

        Rectangle {
            id:                     climbValueBox
            width:                  ScreenTools.defaultFontPixelWidth * (androidBuild ? 5 : 7)
            height:                 ScreenTools.defaultFontPixelHeight
            anchors.right:          climbPointer.left
            anchors.rightMargin:    -toolsMargin * 3
            anchors.verticalCenter: parent.verticalCenter
            color:                  "black"
            border.color:           hudPaleGreen
            border.width:           1
            z:                      climbPointer.z + 1
        }

        Text {
            text:               activeVehicle ? activeVehicle.climbRate.rawValue.toFixed(1).padStart(3, '0') : ""
            color:              hudPaleGreen
            font.pixelSize:     ScreenTools.defaultFontPixelWidth * (androidBuild ? 1.5 : 2)
            font.bold:          true
            anchors.centerIn:   climbValueBox
            z:                  parent.z + 20
        }
    }
}
