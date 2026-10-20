import QtQuick 2.12

// GD60: mostrador de RPM em arco do painel lateral (rotores e motores
// horizontais). Arco cinza de fundo, preenchimento verde até o valor e ponteiro
// vermelho saindo do centro. O valor entre minValue e maxValue (limitado a essa
// faixa) vai de startAngle a endAngle, em radianos.
//
// Repinta a cada 36 ms com o ângulo suavizado, como no app anterior (cf577b2:
// sem cintilação na gravação de tela).
Item {
    id: _root

    property real value:            0
    property real minValue:         0
    property real maxValue:         5000
    property real startAngle:       0
    property real endAngle:         Math.PI / 2
    property bool anticlockwise:    false

    function _valueToAngle(v) {
        var clamped = Math.min(Math.max(v, minValue), maxValue)
        var ratio = (clamped - minValue) / (maxValue - minValue)
        return startAngle + ratio * (endAngle - startAngle)
    }

    Canvas {
        id:             dialCanvas
        anchors.fill:   parent
        renderTarget:   Canvas.Image
        renderStrategy: Canvas.Cooperative

        property real angle: _root.startAngle

        Behavior on angle {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)
            var radius = Math.min(width, height) / 2.5
            var centerX = width / 2
            var centerY = height / 2

            // Arco de fundo
            ctx.strokeStyle = "gray"
            ctx.lineWidth = 8
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, _root.startAngle, _root.endAngle, _root.anticlockwise)
            ctx.stroke()

            // Preenchimento até o valor atual
            ctx.strokeStyle = "green"
            ctx.lineWidth = 8
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, _root.startAngle, angle, _root.anticlockwise)
            ctx.stroke()

            // Ponteiro do centro até a borda do arco
            ctx.strokeStyle = "red"
            ctx.lineWidth = 2
            ctx.beginPath()
            ctx.moveTo(centerX, centerY)
            ctx.lineTo(centerX + radius * Math.cos(angle), centerY + radius * Math.sin(angle))
            ctx.stroke()
        }
    }

    Timer {
        interval:   36
        running:    true
        repeat:     true
        onTriggered: {
            dialCanvas.requestPaint()
            dialCanvas.angle = _root._valueToAngle(_root.value)
        }
    }
}
