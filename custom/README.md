# Global Drones QGroundControl: uma base, cinco produtos

Este repositório gera os aplicativos GD25, GD30, GD60, GD70 e GD150 a partir de
uma única árvore.

```
src/, libs/, resources/ ...   QGroundControl modificado pela SiYi (commit 583c15a).
                              É a "base": só recebe patches pequenos, iguais para
                              todos os produtos.
custom/                       Tudo que a Global Drones acrescenta.
  custom.pri                  Seleção da variante, identidade, versão, módulos.
  src/                        C++ comum (plugin, telemetria, RC Override, checklist...)
  qml/                        QML comum: substituições de arquivos da base e
                              componentes GD compartilhados (GD.Controls).
  res/                        Imagens, ícones e JSON comuns.
  qrc/                        Arquivos .qrc dos recursos comuns.
  android/                    Manifesto e ícones Android comuns.
  variants/<variante>/        O que é só daquele produto:
    variant.pri               identidade, versão, recursos ligados
    variant.qrc               QMLs e imagens só deste produto
    telemetry.cc              nomes NAMED_VALUE_FLOAT -> fatos deste produto
    qml/, res/                arquivos referenciados pelo variant.qrc
```

O histórico de cada produto antes da unificação está nas branches `archive/gd25`,
`archive/gd25-srt` (branch GitHub GD25_desenvolvimento), `archive/gd30`,
`archive/gd60`, `archive/gd70` e `archive/gd150`.

## Compilar

Uma pasta de build por variante. A preparação recusa reaproveitar a pasta de
outra variante.

```
qmake <fonte>/qgroundcontrol.pro GD_VARIANT=gd60 "GST_ROOT=C:/Program Files/gstreamer/1.0/msvc_x86_64"
jom (ou nmake / make)
```

`GD_VARIANT` é obrigatório: gd25, gd30, gd60, gd70 ou gd150. No Qt Creator,
coloque `GD_VARIANT=gd60` em "Additional arguments" do passo qmake.

Não passe `CONFIG+=StableBuild`. Todos os APKs já instalados foram gerados como
build "Daily", e o QGC usa o nome `<aplicativo> Daily` para o arquivo de
configurações (`QGroundControl Daily.ini`, `GD60_QGC Daily.ini`). Um build
Stable leria outro arquivo e o tablet perderia as configurações.

## Como um arquivo da base é substituído

O `GDCorePlugin` instala um interceptador de URLs no motor QML
(`GDUrlInterceptor`). Para cada recurso `qrc:/<caminho>` pedido pela base:

1. se existir `qrc:/gdv/<caminho>` (recurso da variante), ele é usado;
2. senão, se existir `qrc:/gdc/<caminho>` (comum a todos), ele é usado;
3. senão, fica o original da base.

O caminho é o caminho **no qrc** (o alias), não o caminho do arquivo no disco.
Exemplos:

| Original na base | Substituto comum | Substituto da variante |
|---|---|---|
| `qrc:/qml/QGroundControl/FlightDisplay/FlyView.qml` | `/gdc/qml/QGroundControl/FlightDisplay/FlyView.qml` | `/gdv/qml/QGroundControl/FlightDisplay/FlyView.qml` |
| `qrc:/qml/MainRootWindow.qml` | `/gdc/qml/MainRootWindow.qml` | `/gdv/qml/MainRootWindow.qml` |
| `qrc:/toolbar/BatteryIndicator.qml` | `/gdc/toolbar/BatteryIndicator.qml` | `/gdv/toolbar/BatteryIndicator.qml` |
| `qrc:/res/QGCLogoFull` (imagem) | `/gdc/res/QGCLogoFull` | `/gdv/res/QGCLogoFull` |

No .qrc, isso fica assim (arquivo em `custom/qml/FlightDisplay/FlyView.qml`):

```xml
<qresource prefix="/gdc">
    <file alias="qml/QGroundControl/FlightDisplay/FlyView.qml">../qml/FlightDisplay/FlyView.qml</file>
</qresource>
```

Um arquivo substituto que cita um vizinho por caminho relativo continua
funcionando: o interceptador volta ao caminho lógico e procura de novo
(variante, comum, base).

Recursos **novos** (que não existem na base) não precisam de prefixo especial:
imagens novas vão direto no prefixo que o QML já usa, por exemplo
`/qmlimages/GasCan.svg`, desde que o nome não exista na base.

Só QML e imagens carregadas pelo QML passam pelo interceptador. Código C++ da
base que precisa mudar recebe um patch pequeno em `src/`, igual para todos.

## Componentes comuns (import GD.Controls 1.0)

Ficam em `custom/qml/GD/Controls/` e são usados pelos FlyViews de todos os
produtos. Assim SRT/lista de streams e RC Override têm uma única implementação.

| Componente | O que faz |
|---|---|
| `GDStreamSelector` | Mostra o stream atual (alias/IP) e troca de câmera na fonte "Streams List" |
| `GDGimbalPitchIndicator` | Ângulo de pitch do gimbal (`_GD_GimbalPitch`) |
| `GDCrosshair` | Mira central (ação "Aim" da barra lateral) |
| `GDRcOverrideControl` | Botão + confirmação do RC Override. Some sozinho nos produtos sem RC Override. Posição pelo pai; `popupWidth`/`popupHeight`; saída `overrideActive` |
| `GDBreachAlert` | Alerta de violação das 3 zonas da geofence (0 = volume de voo, 1 = contingência, 2 = ground risk buffer). Só vale com exatamente 3 polígonos. Entradas `vehicle`, `geoFenceController` |

## Tipos QML de um produto só (import GD.Variant 1.0)

Componentes que só existem em um produto (painéis de telemetria, HUD do GD60...)
ficam em `custom/variants/<v>/qml/GD/Variant/`, com um `qmldir` próprio da
variante registrado no `variant.qrc` com prefixo `/qml` e alias `GD/Variant/...`.
Como cada build inclui só o `variant.qrc` do seu produto, `import GD.Variant 1.0`
sempre resolve para os tipos do produto sendo compilado.

O FlyView comum (usado por GD25, GD70 e GD150) espera de `GD.Variant` os tipos
`FlyViewBottomViewArea` (propriedades `toolsMargin`, `_androidBuild`) e
`FlyViewLateralViewArea` (propriedade `activeVehicle`). GD30 e GD60 substituem o
FlyView inteiro e definem seus próprios tipos: o GD30 `FlyViewBottomDataArea` e
`FlyViewLateralDataArea`; o GD60 `PilotHud`, `FlyViewLateralViewArea` e `RpmDial`.
Os painéis calculam a própria telemetria a partir do veículo ativo.

## API C++ disponível no QML

`QGroundControl.corePlugin` (GDCorePlugin):

| Propriedade | Tipo | |
|---|---|---|
| `gdProduct` | string | "GD25", "GD30", ... |
| `gdVersion` | string | versão do produto (variant.pri) |
| `gdRcOverride` | bool | o produto tem RC Override |
| `gdAndroid` | bool | build Android |
| `gdSettings.externalChecklistEnabled` | Fact (bool) | checklist externo ligado (padrão: desligado) |

Singletons:

| Import | Objeto | |
|---|---|---|
| `import GD.RcOverride 1.0` | `GDRcOverride` | `start()`, `stop()`, `running`, `lastError`. Existe em todos os builds; `available` é falso e `start()` recusa nos produtos sem RC Override. Para sozinho quando o veículo ativo muda, é removido ou fica 30 s seguidos sem comunicação (motivo em `lastError`). Ao parar, e ao fechar o app, pede ao UniRC7 o fim do envio dos canais (SDK SiYi 0x42, frequência 0) |
| `import PreFlightChecklist.Object 1.0` | `PreFlightChecklist` | app externo de checklist (Android) |
| `import GD.Fence 1.0` | `GDFence` | `loadKMLwithSpacing(mapPolygon, arquivo, margemMetros)`: zona de voo a partir de KML/SHP com margem |

Fatos GD do veículo (`_activeVehicle.<nome>`, todos `Fact*`): `distanceToNextWP`,
`rangeFinderDist`, `flightTimeCustom` (o mesmo fato de `flightTime`),
`gd60_Sensor1..3`, `gd30_remainsecs`, `gd60_ECU1_CTP1/2`, `gd60_ECU2_CTP1/2`,
`gd60_RPM_M1/M2`, `_GD_RPM1..6`, `_GD_GeneratorRPM`, `_GD_GimbalPitch/Yaw/Roll`,
além de `escStatus.temperatureFirst..Fourth`. São preenchidos por
`custom/src/telemetry/GDTelemetry.cc` (mensagens padrão) e pelo `telemetry.cc`
de cada variante (NAMED_VALUE_FLOAT). Os nomes vêm dos produtos antigos e foram
mantidos para não reescrever o QML.

O `FlyViewWidgetLayer` comum aceita `visible_custom_telemetry` ("+Info"),
`crosshair_visible` ("Aim"), `visible_cam_control` ("Cam"), `showCrosshairAction`
e `showCamControlAction`. A posição do instrumento de atitude/bússola vem do
`FlightDisplayViewWidgets` de cada produto.

## Decisões de produto

| Tema | Decisão |
|---|---|
| RC Override | Só GD25, GD30 e GD60. GD70 e GD150 não têm (nem botão, nem código ligado). Botão embaixo, no centro (no GD60, no painel lateral). Para sozinho após 30 s sem link |
| Checklist externo | Em todos, desligado por padrão; liga em Configurações > Geral (Android). Ligado, bloqueia armar pelo app (inclusive Force Arm) |
| Ações guiadas | Escondidas em todos (Ir para / Orbitar / ROI pelo mapa, Iniciar/Pausar missão, botões Arm/Disarm da barra superior). Um substituto comum do GuidedActionsController desliga todas de uma vez. Arma-se pelo rádio |
| Alerta das 3 zonas | Em todos, componente comum `GDBreachAlert` |
| Painel de câmera SiYi | Oculto até tocar em "Cam" na barra lateral, em todos |
| Barra de telemetria "+Info" | Comum (`/gdc` TelemetryValuesBar), sem os ícones de modo que não faziam nada |
| Tempo de voo | Tempo voando: conta enquanto o veículo está no ar e armado, acumula os trechos no ar e zera ao armar (a distância voada também) |
| Nomes NAMED_VALUE_FLOAT | Mantidos por produto em `variants/<v>/telemetry.cc` |
| Ordem das baterias | Mantida por produto |
| HUD de pitch/roll | Só GD60 |
| Joystick virtual | Oculto e sempre desligado |
| Barra superior | Por produto: os drones não têm os mesmos sensores |
| Nome do app / package | Mantidos, para não zerar configurações nem instalar app paralelo |

## Versões

`GD_VERSION` e `GD_BUILD` ficam no `variant.pri` de cada produto. O versionCode
Android é calculado a partir deles (formato do QGC: 66MIPPDDD em arm64) e
precisa sempre crescer em relação ao APK instalado nos tablets. Ao publicar,
suba `GD_VERSION` ou `GD_BUILD` do produto.
