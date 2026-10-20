import QtQuick 2.12

// Mira central vermelha, ligada pela ação "Aim" da barra lateral
// (FlyViewWidgetLayer.crosshair_visible). Quem instancia posiciona no centro da
// área principal e controla visible e z. Tamanho padrão: 4% da largura do pai.
//
// Não é o símbolo central do HUD do GD60: aquele faz parte do HUD e fica
// sempre visível.
Item {
    id: _root

    property color  color:      "red"
    property real   lineWidth:  5

    width:  parent ? parent.width * 0.04 : 0
    height: width

    // Linha horizontal
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width:                  parent.width
        height:                 _root.lineWidth
        color:                  _root.color
    }

    // Linha vertical
    Rectangle {
        anchors.horizontalCenter:   parent.horizontalCenter
        width:                      _root.lineWidth
        height:                     parent.height
        color:                      _root.color
    }
}
