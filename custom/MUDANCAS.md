# O que muda na versão unificada (GD25, GD30, GD60, GD70, GD150)

Os 5 apps de solo (QGroundControl 4.2 da SiYi) agora saem de um único repositório, com uma variante por produto (ver `custom/README.md`). O código antigo de cada produto está nas branches `archive/gd25`, `archive/gd25-srt`, `archive/gd30`, `archive/gd60`, `archive/gd70` e `archive/gd150`. Este documento lista o que piloto e testador vão notar.

| | GD25 | GD30 | GD60 | GD70 | GD150 |
|---|---|---|---|---|---|
| Versão nova | 2.3.4 | 1.0.1 | 1.0.1 | 0.1.1 | 0.1.1 |
| Menu do app antigo | 2.3.3 (SRT: "GD25_SRT 2.3.3_SRT") | 1.0.0 | "GD60_SRT 1.0.0_SRT" | 0.1.0 | "GD25 - Versão 0.1" (nome errado) |

O nome do app, o package Android e o arquivo de configurações não mudaram. O APK novo atualiza o app instalado e mantém as configurações (exceção: app de teste SRT do GD25, ver abaixo). **O build tem que continuar "Daily". Nunca use `CONFIG+=StableBuild`**: o Stable lê outro arquivo de configurações, e o tablet parece ter perdido tudo.

---

## 1. Mudanças em todos os produtos

### Android 12 (alvo 31) e acesso a arquivos
- O app agora é feito para o Android 12 (API 31). Antes era 28, e o Android avisava na instalação que o app foi feito para uma versão antiga.
- **Na primeira abertura**, o app avisa e abre a tela "Acesso a todos os arquivos" do Android: ligue para este app e volte. Sem isso o app funciona, mas não salva logs, missões nem parâmetros. O aviso volta a cada abertura enquanto o acesso não for liberado.
- Os arquivos continuam no mesmo lugar de antes (`/storage/emulated/0/<nome do app> Daily/`).
- Se um dia o app usar link Bluetooth, o Android 12 pede a permissão de "Dispositivos próximos".

### Vídeo, SRT e troca de câmera
- Novas fontes em Configurações > Geral > Vídeo: **SRT Video Stream** (campo "SRT URL") e **Streams List**. A Streams List é a lista "Video Streams" com o botão "+ Add Camera", e cada câmera tem tipo RTSP, SRT, TCP, MPEG-TS, UDP h.264 ou UDP h.265.
- O seletor de câmera do Fly View fica no canto superior direito e mostra o apelido ou o IP. Ele só aparece com a fonte **Streams List**, o vídeo ligado e pelo menos uma câmera na lista. Tocar no ícone passa para a próxima câmera.
- Migração na primeira abertura: a lista antiga vira câmeras RTSP. Se a fonte era "RTSP Video Stream" e a URL em uso está na lista, a fonte muda sozinha para Streams List, já com essa câmera selecionada.
- **Quem continua em RTSP** tem vídeo, mas não tem o botão de troca nem campo para editar a URL (o campo já era oculto). Para trocar de câmera, mude a Fonte para **Streams List** em Configurações > Geral > Vídeo, confira as câmeras e toque no ícone de câmera no Fly View. Logo depois de cadastrar, nenhuma câmera fica selecionada e o seletor mostra "Sem câmeras" até esse primeiro toque.
- Remover da lista a câmera selecionada para o vídeo. Os campos aceitam IP puro ou URL completa.
- O controle da câmera SiYi (zoom, foto) segue sozinho o IP do vídeo principal, inclusive com SRT.
- O tempo limite padrão do vídeo passou de 2 s para 5 s.
- Ao lado do seletor aparece o indicador de pitch do gimbal, com qualquer fonte de vídeo, exceto no GD60. Os ícones de câmera agora aparecem: antes apontavam para imagens que não existiam.
- Nova linha "SiYi TX IP" em Configurações, que aceita só IPv4.

### Tempo de voo e distância
- **O tempo de voo agora é o tempo no ar.** Zera ao armar, conta só com o drone armado e voando, pausa no pouso e soma as decolagens feitas sem desarmar. Antes, GD25, GD70 e GD150 contavam com o gerador ligado, e GD30 e GD60 mostravam o tempo desde que a controladora ligou.
- A distância voada também zera ao armar. Antes ela nunca zerava.
- Se o app conectar com o drone já armado no ar, o tempo conta a partir da conexão.

### Ações guiadas e armar
- As ações guiadas foram escondidas de vez: tocar no mapa não abre mais Go to / Orbit / ROI, tocar num waypoint não faz nada e o painel Multi-Vehicle (2 ou mais veículos) não tem mais Start Mission e Pause.
- O popup de status da barra superior (toque em "Ready To Fly", "Armed"...) não tem mais o botão Arm/Disarm/Force Arm, que nunca funcionou. **Arma-se pelo rádio.**
- Continuam funcionando: a troca de modo de voo, o "Resume Mission" no fim da missão e o Arm/RTL/Take control por veículo no painel Multi-Vehicle.

### Checklist pré-voo externo
- Existe em todos os produtos e vem **desligado**. Para ligar (só no Android): Configurações > Geral > seção **Global Drones** > "Exigir checklist pré-voo externo".
- Ligado, o botão "Pre-Flight Checklist" aparece no menu de ferramentas (logo no canto superior esquerdo) e abre o app GDPreFlightChecklist. O botão só vira "Finalizar Operação" quando o app devolve o checklist aprovado. Cancelar ou reprovar mantém o botão como estava.
- Ligado e sem checklist aprovado, **o app** recusa armar, inclusive com Force Arm, e mostra "Checklist pré-operacional não foi liberado...". **Armar pelo rádio não é bloqueado.**
- O checklist aprovado vale até "Finalizar Operação" ou até o veículo trocar ou desconectar.

### Alerta das 3 zonas (geofence)
- Ativo em todos, mas só quando a geofence tem **exatamente 3 polígonos**, nesta ordem: 0 = volume de voo, 1 = contingência, 2 = ground risk buffer. Círculos e polígonos de exclusão são ignorados.

| Drone fora do polígono | Mensagem | Cor |
|---|---|---|
| 0 | Invasão do Volume de Contingência! | amarelo |
| 1 | Invasão do Volume de Ground Risk Buffer! | laranja |
| 2 | Saída do Volume de Ground Risk Buffer! (novo) | vermelho |

- O alerta fica no topo, ao centro. A posição é verificada a cada 0,5 s e o mesmo alerta volta no máximo a cada 10 s; um nível mais grave aparece na hora. Some com um toque nele ou sozinho quando o drone volta para dentro das 3 zonas.
- Agora funciona no hemisfério sul. O código antigo perdia o sinal S/W das coordenadas e mostrava uma caixa preta vazia a cada 10 s.

### Fly View e configurações
- Barra lateral: Plan, **+Info** (barra de telemetria), **Aim** (mira vermelha no centro) e **Cam** (painel da câmera SiYi). Os botões não mostram se estão ligados.
- O painel da câmera SiYi fica oculto até tocar em "Cam". A caixa de zoom só aparece por 5 s depois de mudar o zoom.
- Barra "+Info": sem os ícones de modo inferior/lateral, que não faziam nada; fica à esquerda do instrumento de atitude, com os avisos de foto e zoom acima dela.
- O seletor de valores do "+Info" lista os dados GD de todos os produtos, que ficam em 0 quando o drone não os envia.
- O joystick virtual foi removido: a opção sumiu das Configurações e fica sempre desligada.
- A trilha do drone no mapa guarda só os últimos 500 pontos.
- "Load Flight Zones": a margem aceita decimal ("2,5" ou "2.5"). Antes, 2,5 virava 2.
- Novos padrões, que só valem se o usuário nunca mexeu na opção: "Keep map centered on vehicle" ligado (antes só no GD60) e log de telemetria salvo (antes desligado no GD30 e no GD60).
- O menu de ferramentas mostra "QGroundControl GDxx - Versão x.y.z".

### RC Override (GD25, GD30 e GD60)
- O botão fica embaixo, ao centro (no GD60, no painel lateral): verde "Override RC" ou vermelho "Stop Override", com confirmação SIM/NÃO.
- Se não consegue ligar (sem veículo, porta UDP 19857 ocupada), a confirmação mostra "ATENÇÃO: <motivo>". Antes o app fingia que tinha ligado.
- Ao parar, libera os canais na hora e pede ao UniRC7 que pare de enviar. Isso também acontece ao trocar ou remover o veículo e ao fechar o app.
- **O override para sozinho após 30 s sem comunicação com o drone** (na prática, 33 a 35 s depois do último heartbeat) e mostra "RC Override desligado: sem comunicação com o veículo por 30 s". Se o link voltar antes, o override continua.
- Acabou o estado cinza "Active by:n". Ele dependia de uma detecção pelo firmware 255, que nunca existiu. O botão mostra só o estado deste tablet.
- GD70 e GD150 não têm RC Override, nem o botão.

---

## 2. Por produto

### GD25
O GD25 junta a linha principal (`archive/gd25`, que tinha o checklist) com a linha SRT (`archive/gd25-srt`, que tinha SRT, lista de câmeras e câmera pelo SDK).
- **Tablets com o app de teste "GD 25 QGC DEV_SRT"** (package `...qgroundcontrol.srt`): o APK novo atualiza o app principal "GD 25 QGC DEV", não o SRT. O app SRT continua instalado à parte, e a lista de câmeras e os links dele não passam para o novo. Cadastre de novo e depois desinstale o SRT.
- Checklist externo: antes estava sempre ligado (botão e trava); agora vem desligado. Ligue se a operação exigir.
- O tempo de voo não começa mais em ~8 min.
- Painel da câmera: antes aparecia de início, e "Cam" escondia os widgets SiYi; agora fica oculto até "Cam".
- O alerta das 3 zonas volta (estava desligado desde fd12186).
- O indicador de pitch do gimbal não some mais quando a fonte não é Streams List.
- Logo depois de conectar, até chegarem as 3 baterias, "Generator Current" e a gasolina mostram o rótulo vazio e 0%. Antes dava erro.
- Ficou como era: barra superior (tensão por bateria com ícone branco, RSSI %, NET_SCORE, RC_SCORE, toque no link troca de link, sem logo ArduPilot); painéis com Est. Time = 7200 s × % de gasolina; ordem das baterias 0 bateria, 1 gasolina, 2 gerador; caixa °C/RPM do motor a cada 2 toques.

### GD30
- Ganha SRT e Streams List. O receptor de vídeo mudou (correção de tela preta do GD60 e outro decodificador para TCP/MPEG-TS): teste o RTSP.
- RC Override: o botão saiu do topo e foi para baixo, ao centro. Ao parar, libera os canais na hora (antes o ArduPilot segurava os últimos valores até RC_OVERRIDE_TIME) e para sozinho ao desconectar o drone (antes havia risco de travar o app).
- Alerta das 3 zonas: antes estava ativo, mas quebrado no Brasil (caixa preta vazia a cada 10 s; amarelo e laranja nunca apareciam). Agora funciona e tem o nível vermelho.
- Novidades: Aim e Cam (o painel da câmera antes nunca aparecia) e o indicador de pitch do gimbal. A caixa de zoom só aparece depois de mudar o zoom (antes ficava sempre visível).
- Tempo de voo: antes era o tempo desde que a controladora ligou.
- Checklist externo disponível pela primeira vez, desligado.
- Sem veículo, os painéis mostram "--"; ao desconectar, voltam a 0 em vez de congelar.
- O popup do "Load Flight Zones" mudou: tamanho proporcional, rótulo "(m)" e padrão 5.
- Ficou como era: layout (painéis inferior e lateral, "+Info" visível desde o início, instrumento no canto inferior direito); Est. Time de REMAIN_SECS; T1, T2 e RPM do DLE; barra superior (bateria por id, RSSI %, logo e status do transmissor SiYi).

### GD60
- O nome no menu perde o "_SRT".
- O seletor de câmera, antes sempre visível (mesmo com RTSP/SRT, mostrando "Sem câmeras"), agora só aparece com Streams List e lista preenchida.
- Ganha o alerta das 3 zonas, que nunca aparecia. Ocupa 30% da largura e cobre o arco de roll do HUD enquanto está na tela.
- Saíram popups invisíveis (gerador e geofence) que reabriam a cada 10 s e engoliam toques no topo central da tela.
- Novidades: Aim (mira vermelha, separada do símbolo verde do HUD) e Cam (painel da câmera, antes sempre oculto). A caixa de zoom só aparece depois de mudar o zoom.
- Barra superior: o tanque de gasolina (id 3) passa a mostrar o % por média móvel. Antes ficava vazio.
- HUD: os textos WP e HM ficam centralizados. Sem veículo ou ao desconectar, HUD e painel ficam vazios em vez de congelar.
- Checklist: o botão antigo existia, mas não fazia nada. Agora funciona quando a opção está ligada.
- Tempo de voo: antes era o tempo desde que a controladora ligou.
- Ficou como era: HUD do piloto e painel lateral (RPM, motores horizontais, ECUs, ESCs), com a área principal em 70%; RC Override no painel lateral, com o seletor de câmera acima; sem indicador de pitch do gimbal; quadro cinza de avisos e marca ArduPilot ocultos; bateria por id (2 gerador, 3 gasolina); configurações em "GD60_QGC Daily.ini".

### GD70
- Sem RC Override. Antes só o botão estava escondido; o código continuava ativo.
- Est. Time (painel lateral) agora usa o % da gasolina (instância 2). Antes usava, por erro, o da bateria.
- FlightDist (painel inferior) zera a cada vez que arma. Antes acumulava.
- Barra superior: o tanque sem dado mostra "NaN" em vez de "NaNL". Os ícones RC_SCORE/NET_SCORE continuam desligados.
- O painel da câmera, que nunca aparecia, agora abre com "Cam". O seletor antigo, que gravava a URL RTSP, virou o seletor da Streams List.
- O alerta das 3 zonas volta.
- O receptor de vídeo mudou: teste o RTSP.
- O nome sob o ícone deve passar de "GD_70_QGC_DEV" para "GD70_QGC_DEV" (só visual).
- Ficou como era: ordem das baterias 0 gerador, 1 bateria, 2 gasolina; grade de tensões, correntes, FlightDist e GS; termômetro por T_Motor; caixa °C/RPM a cada 2 toques; Alt. Rel; 1 nova tentativa na carga de parâmetros.

### GD150
- O botão Override RC foi removido.
- A trava do checklist estava sempre ativa, com o botão escondido. Agora segue a configuração, que vem desligada.
- A barra "+Info" fica à esquerda do instrumento, não mais por cima dele.
- O alerta das 3 zonas volta. O receptor de vídeo mudou: teste o RTSP.
- Ficou como era: painéis inferior e lateral (iguais pixel a pixel no teste), com consumo "105 A" fixo, GPM, barras de RPM até 3500 e instrumento no painel direito; barra superior (bateria branca sem texto, RC%/NET/RC score, troca de link por toque); painel da câmera pelo "Cam".

---

## 3. Roteiro de teste no tablet

Até agora só houve build Windows com drone simulado. Nada foi testado em tablet, rádio ou drone real.

### Antes de instalar
- [ ] O APK foi gerado com o GStreamer Android em `src/VideoReceiver/gstreamer-1.0-android-universal-1.18.6/`. Sem ele o build avisa "Skipping support for video streaming" e o app fica sem vídeo.
- [ ] Fotografe as configurações e as telas do app antigo com o drone ligado: links, fonte de vídeo, câmeras, painéis e barra superior.

### Todos os produtos
- [ ] Instalar por cima, sem desinstalar: não aparece um segundo ícone e o menu mostra o nome e a versão novos.
- [ ] A instalação não mostra mais o aviso de "versão antiga do Android". Na primeira abertura aparece a tela "Acesso a todos os arquivos": liberar e voltar ao app.
- [ ] Depois de liberar: salvar uma missão, gravar log de telemetria (voo curto ou conexão) e conferir os arquivos em `/storage/emulated/0/<app> Daily/` (Missions, Telemetry...).
- [ ] Rádio/link por USB (se usado): conectar e aceitar a permissão USB sem o app fechar.
- [ ] As configurações continuam (links, fonte de vídeo, câmeras, unidades, mapas offline).
- [ ] O logo do canto superior esquerdo aparece e abre o menu de ferramentas.
- [ ] O vídeo RTSP continua como estava. Se a fonte mudou sozinha para Streams List, a câmera certa está selecionada.
- [ ] Streams List com 2 ou mais câmeras (incluir uma SRT, se houver): trocar pelo ícone, conferir o apelido, remover a câmera ativa (o vídeo para).
- [ ] A fonte "SRT Video Stream" funciona.
- [ ] Depois de trocar de câmera, zoom e foto pelo "Cam" funcionam na câmera certa.
- [ ] O pitch do gimbal acompanha o gimbal (não no GD60). O heading do gimbal confere com o gimbal virado de lado.
- [ ] Tempo de voo: 00:00:00 no chão, zera ao armar, conta só no ar, pausa no pouso e soma numa nova decolagem sem desarmar. A distância zera ao armar.
- [ ] Painéis e barra superior iguais ao app antigo, item por item: baterias, gasolina, gerador, temperaturas, RPM, GPS, RSSI e Est. Time.
- [ ] O popup de status não tem o botão Arm. Armar e desarmar pelo rádio funciona.
- [ ] Tocar no mapa ou num waypoint não abre nada.
- [ ] Checklist desligado: não há botão e o drone arma pelo rádio.
- [ ] Checklist ligado: o botão aparece no menu e o app abre; cancelar mantém "Pre-Flight Checklist"; aprovar vira "Finalizar Operação", que volta ao início; armar pelo rádio continua possível; sem o app instalado, o QGC não fecha.
- [ ] Alerta das zonas, com 3 zonas carregadas por "Load Flight Zones" no local: dentro, nada; fora do polígono 0, 1 e 2, amarelo, laranja e vermelho; um toque fecha e voltar para dentro faz sumir.
- [ ] Com 1, 2 ou 4 polígonos, nenhum alerta aparece. Nunca aparece a caixa preta, e o tablet não fica lento.
- [ ] "+Info" liga e desliga (sem os ícones de modo), "Aim" mostra a mira e "Cam" abre o painel SiYi.
- [ ] Em Configurações > Geral não há opção de joystick virtual e existe a seção Global Drones.
- [ ] "Load Flight Zones" aceita a margem "2,5".

### RC Override (GD25, GD30 e GD60): na bancada, sem hélices
- [ ] Override RC > SIM: o botão fica vermelho e o drone responde aos sticks do UniRC7.
- [ ] Stop Override: o botão fica verde e o drone volta na hora ao controle normal.
- [ ] Ligar de novo logo em seguida funciona (o UniRC7 volta a enviar).
- [ ] Cortar o link de telemetria com o override ligado: em 30 a 35 s aparece a mensagem e o botão fica verde.
- [ ] Religar o link antes de 30 s: o override continua.
- [ ] Fechar o app com o override ligado: o drone é liberado. Desconectar o drone: o botão volta a "Override RC".
- [ ] Se der para capturar (Wireshark ou log do rádio): o UniRC7 para de mandar UDP para o tablet depois do Stop.

### Por produto
- [ ] **GD25**: nos tablets com o app SRT, o app novo foi instalado sobre o principal (recadastrar as câmeras e desinstalar o SRT). Barra superior com tensões, RSSI, NET_SCORE e RC_SCORE. Com o "+Info" ligado, o botão de override não cobre a barra.
- [ ] **GD30**: o botão de override não cobre a barra "+Info" (sempre visível) na resolução do tablet. Vídeo RTSP sem tela preta nem atraso. O pitch do gimbal mostra o ângulo real. Est. Time, T1/T2 e RPM do DLE. Qual instância é bateria, gasolina e gerador no painel e na barra.
- [ ] **GD60**: HUD e painel lateral iguais ao app antigo; seletor de câmera acima do override; alerta das zonas legível sobre o HUD; "Cam" e "Aim" não atrapalham as fitas; gasolina (id 3) em %; marca ArduPilot oculta.
- [ ] **GD70**: sem botão de override; Est. Time pela gasolina; FlightDist zera ao armar; ordem das baterias confere com o drone; parâmetros carregam completos; vídeo RTSP; nome sob o ícone.
- [ ] **GD150**: sem botão de override; "+Info" ao lado do instrumento; GPM, consumo, RPM e GPS iguais ao app antigo; a caixa de RSSI do RC abre por toque no tablet; vídeo RTSP.

---

## 4. Pendências conhecidas

| Produtos | Pendência |
|---|---|
| todos | **PC de build sem o SDK GStreamer Android:** os APKs gerados aqui não têm vídeo, então o vídeo no Android não foi testado. |
| todos | Nada foi testado em tablet nem com drone real. |
| todos | "Load Flight Zones" encolhe o polígono em direção ao centro em vez de recuar cada lado; em zonas alongadas ou côncavas a margem não é a pedida (segurança). |
| todos | Alerta das zonas: confirmar o texto e a cor do nível vermelho e o desempenho com zonas de ~50 pontos por lado. |
| todos | O botão de transição VTOL continua no popup de status, sem efeito. Só importa se algum produto for VTOL. |
| todos | No PC, botões de joystick físico ainda podem armar e desarmar, sem passar pelo bloqueio. |
| todos | O painel Multi-Vehicle (2 ou mais veículos) ainda tem Arm, RTL e Take control por veículo. |
| todos | "Low Latency Mode" não tem efeito (buffer fixo de 200 ms): esconder ou corrigir? |
| todos | Streams List: nada é selecionado sozinho depois de cadastrar, e quem ficou em RTSP não consegue editar a URL. |
| todos | Um stream de vídeo anunciado pelo drone (MAVLink) pode substituir a Streams List. |
| todos | "SiYi TX IP" não é salvo (some ao reiniciar). A sugestão é .12, mas o UniRC7 está em .20. |
| todos | Checklist: não há aviso na tela quando o app não está instalado ou volta cancelado; a integração com o app não foi testada em tablet. |
| todos | Os botões +Info, Aim e Cam não indicam se estão ligados. |
| GD25, GD70, GD150 | O ícone de bateria da barra é sempre branco: a cor por tensão (47/42 V) nunca funcionou. Ligar? Com quais limites? No GD70 mediria o gerador. |
| GD25, GD70 | A caixa °C/RPM do motor abre a cada 2 toques. Passar para 1? |
| GD25, GD60, GD70, GD150 | Tocar no link só passa para o próximo, sem menu; com 3 ou mais links não dá para escolher um. |
| GD25, GD30, GD70, GD150 | "Hor. Speed" mostra a velocidade do ar, não a de solo. |
| GD30, GD150 | O rótulo "PDOP" mostra o tipo de fix do GPS. |
| GD25, GD30, GD60 | O RSSI aparece "255%" quando o rádio não informa (visto no teste de PC). |
| GD25, GD70, GD150 | A conversão dos ângulos do gimbal mudou para a convenção MAVLink: validar o heading com yaw ≠ 0. |
| GD25, GD70, GD150 | O texto "📸 Photo Captured" aparece durante a gravação. Era para ser indicador de REC? |
| GD30, GD60 | O gimbal publica GIMBAL_DEVICE_ATTITUDE_STATUS? No GD30 o pitch fica em 0°; o GD60 não tem indicador. |
| GD30, GD60 | O 2º stream da câmera MAVLink é tratado como térmico só em GD25, GD70 e GD150. GD30 e GD60 precisam? |
| GD25, GD30, GD60 | UniRC7 com IP e portas fixos (192.168.144.20:19856, local 19857). Não há novo pedido se o rádio reiniciar, e o SET_MESSAGE_INTERVAL não é desfeito. |
| GD25, GD30, GD60 | Se o Android matar o app (fechar pelos recentes) com o override ligado, o UniRC7 continua enviando até o app abrir de novo. |
| GD25, GD30, GD60 | Com 2 ou mais links, um link morto mantém "sem comunicação", e o override para em 30 s mesmo com outro link funcionando. |
| GD25, GD30 | O botão de override pode cobrir a borda esquerda da barra "+Info" quando ela fica larga. |
| GD30 | As baterias divergem: o painel usa o índice (0 gerador, 1 gasolina, 2 bateria) e a barra usa o id (0 bateria, 1 gerador, 2 gasolina). Qual está certo? |
| GD30 | Sem tensão, o painel mostra "0NaN%" e "NaNL". O termômetro é sempre branco: colorir por T1/T2? |
| GD30 | Temp1 e DLE_RPM gravam o mesmo campo "RPM". O firmware ainda envia Temp1? |
| GD60 | Confirmar os ids 2 = gerador e 3 = tanque. Sem tensão, mostra "NaN". |
| GD60 | O alerta das zonas cobre o arco de roll, e o painel "Cam" encosta na fita de velocidade. |
| GD70 | Confirmar a ordem 0 gerador, 1 bateria, 2 gasolina, o Est. Time = 7200 s × % de gasolina e o tanque fixo de 5000 mL. |
| GD70 | FlightDist agora zera a cada armar. Pode ficar assim? |
| GD70 | Voltar o ícone do motor vermelho com o gerador parado (desligado em 6ea08a9) e os ícones RC_SCORE/NET_SCORE? |
| GD70 | Nome sob o ícone: "GD_70_QGC_DEV" ou "GD70_QGC_DEV"? |
| GD150 | O GPM sempre aparece "x.0" (valor inteiro), e TempICE e VazaoGMin gravam o mesmo campo. Qual é a unidade? |
| GD150 | Consumo "105 A" fixo, escala de 3500 rpm, bateria sem texto na barra e caixa de RSSI que abre por hover. |
