import QtQuick 2.12

// Alerta de violação das zonas de voo (geofence em 3 zonas), em todos os
// produtos. Regra do GD30 (910ba6b): só vale com EXATAMENTE 3 polígonos na
// geofence; com outro número não verifica nem mostra nada.
//
//   Polígono 0 (borda verde):    fora dele -> "Invasão do Volume de Contingência!" (amarelo)
//   Polígono 1 (borda amarela):  fora dele -> "Invasão do Volume de Ground Risk Buffer!" (laranja)
//   Polígono 2 (borda vermelha): fora dele -> "Saída do Volume de Ground Risk Buffer!" (vermelho)
//
// O nível é o maior índice de polígono que não contém o veículo, como no GD30.
// Depois de um alerta, outro do mesmo nível ou menor só após o cooldown (10 s);
// um nível mais alto aparece na hora. O alerta fica até o toque nele ou até o
// veículo voltar para dentro das 3 zonas (passado o cooldown).
//
// Por que não reaparece a "caixa preta" (fd12186, 'Attempt to fix black box
// bug', que desligou o alerta na linha GD25):
// - O FlyView antigo lia a coordenada do texto do Qt com split('  ') (dois
//   espaços); o Qt separa o hemisfério com um espaço, então S/W viravam
//   positivos. No Brasil o veículo nunca ficava dentro de nenhuma zona e, com
//   3 polígonos, o nível era sempre 2.
// - O nível 2 não tinha texto nem cor: o Popup abria com cor "" (= #000000,
//   preto opaco) e texto vazio, a cada 10 s, no topo ao centro.
// Aqui: latitude/longitude numéricas (sem texto), projeção plana local em
// volta do veículo (sem dobra no equador), texto e cor para os 3 níveis, e um
// Rectangle comum no lugar do Popup: some junto com o Fly View, não fica na
// camada de overlay da janela e só recebe toque na própria área.
//
// Quem instancia define a posição (anchors) e o z, e liga vehicle e
// geoFenceController. Não ligue visible por fora: o componente se mostra
// sozinho (use active para desligar).
Item {
    id: _root

    /// Veículo ativo (null: nada é verificado)
    property var    vehicle
    /// GeoFenceController do Fly View (PlanMasterController.geoFenceController)
    property var    geoFenceController
    /// false: não verifica e esconde o alerta
    property bool   active:         true
    /// Intervalo entre verificações (ms)
    property int    checkInterval:  500
    /// Tempo mínimo entre alertas do mesmo nível ou menor (ms)
    property int    cooldown:       10000

    /// Nível atual: -1 dentro das 3 zonas ou verificação inativa; 0, 1 ou 2
    readonly property int   breachLevel:    _level
    /// Alerta na tela
    readonly property bool  alertShown:     _shown

    // Tamanho do GD30: 1/4 da largura do pai, 100 px de altura (cresce se o
    // texto quebrar em mais linhas)
    width:      parent ? parent.width / 4 : 0
    height:     Math.max(100, label.implicitHeight + 20)
    visible:    _shown

    readonly property var _alertTexts: [
        "Invasão do Volume de Contingência!",
        "Invasão do Volume de Ground Risk Buffer!",
        "Saída do Volume de Ground Risk Buffer!"
    ]
    readonly property var _alertColors: [ "yellow", "orange", "red" ]

    property bool   _androidBuild:  Qt.platform.os === "android" || Qt.platform.os === "ios"
    property int    _level:         -1
    property int    _alertLevel:    -1      // nível do alerta mostrado (vale durante o cooldown)
    property bool   _shown:         false
    property bool   _canCheck:      active && !!vehicle && !!geoFenceController
                                    && !!geoFenceController.polygons && geoFenceController.polygons.count === 3

    on_CanCheckChanged: {
        if (!_canCheck) {
            _reset()
        }
    }
    onVehicleChanged: _reset()

    function _reset() {
        cooldownTimer.stop()
        _level = -1
        _alertLevel = -1
        _shown = false
    }

    // Coordenada em plano local (graus, longitude corrigida pelo cosseno da
    // latitude) com o veículo na origem
    function _toLocal(coord, lat0, lon0, cosLat0) {
        var dLon = coord.longitude - lon0
        if (dLon > 180) {
            dLon -= 360
        } else if (dLon < -180) {
            dLon += 360
        }
        return { x: dLon * cosLat0, y: coord.latitude - lat0 }
    }

    // Ponto no polígono (cruzamento de raio a partir da origem, sentido +x).
    // null: polígono com menos de 3 vértices.
    function _containsVehicle(path, lat0, lon0, cosLat0) {
        var n = path ? path.length : 0
        if (n < 3) {
            return null
        }
        var inside = false
        var prev = _toLocal(path[n - 1], lat0, lon0, cosLat0)
        for (var j = 0; j < n; j++) {
            var cur = _toLocal(path[j], lat0, lon0, cosLat0)
            if ((cur.y > 0) !== (prev.y > 0)) {
                var xCross = cur.x + (prev.x - cur.x) * (0 - cur.y) / (prev.y - cur.y)
                if (xCross > 0) {
                    inside = !inside
                }
            }
            prev = cur
        }
        return inside
    }

    // -1: dentro das 3 zonas, posição inválida ou zona com menos de 3 vértices
    function _computeLevel() {
        var coord = vehicle.coordinate
        if (!coord || !coord.isValid) {
            return -1
        }
        var lat0 = coord.latitude
        var lon0 = coord.longitude
        var cosLat0 = Math.cos(lat0 * Math.PI / 180)
        var polygons = geoFenceController.polygons
        var level = -1
        for (var i = 0; i < polygons.count; i++) {
            var inside = _containsVehicle(polygons.get(i).path, lat0, lon0, cosLat0)
            if (inside === null) {
                return -1
            }
            if (!inside) {
                level = i
            }
        }
        return level
    }

    function _check() {
        var level = -1
        try {
            level = _computeLevel()
        } catch (e) {
            console.warn("GDBreachAlert:", e)
            level = -1
        }
        _level = level
        if (level >= 0) {
            if (!cooldownTimer.running || level > _alertLevel) {
                _alertLevel = level
                _shown = true
                cooldownTimer.restart()
            }
        } else if (_shown && !cooldownTimer.running) {
            _shown = false
            _alertLevel = -1
        }
    }

    Timer {
        id:                 checkTimer
        interval:           _root.checkInterval
        running:            _root._canCheck
        repeat:             true
        triggeredOnStart:   true
        onTriggered:        _root._check()
    }

    Timer {
        id:         cooldownTimer
        interval:   _root.cooldown
        repeat:     false
    }

    Rectangle {
        anchors.fill:   parent
        color:          _alertLevel >= 0 ? _alertColors[_alertLevel] : "transparent"
        border.color:   "black"
        border.width:   1

        Text {
            id:                     label
            anchors.centerIn:       parent
            width:                  parent.width - 20
            horizontalAlignment:    Text.AlignHCenter
            wrapMode:               Text.WordWrap
            text:                   _alertLevel >= 0 ? _alertTexts[_alertLevel] : ""
            color:                  "black"
            font.bold:              true
            font.pixelSize:         _androidBuild ? 16 : 20
        }

        // Toque fecha o alerta; se a violação continuar, volta após o cooldown
        MouseArea {
            anchors.fill:   parent
            onClicked:      _root._shown = false
        }
    }
}
