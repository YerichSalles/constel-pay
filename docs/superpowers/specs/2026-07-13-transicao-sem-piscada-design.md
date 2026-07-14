# Transição sem piscada na propaganda (double-buffer)

Data: 2026-07-13

Substitui a estratégia de loop da correção `caae310` ("video unico repete em
loop nativo") para a **tela do totem**. O `emLoop` do player continua existindo
para o preview do diálogo Ajustar.

## Problema

A troca de mídia pisca a cor de fundo:

1. **Entre mídias**: a página recria o `PlayerPropaganda` via key a cada
   avanço; o `initialize()` do vídeo novo é lento (Media Foundation via
   `video_player_win` no Windows) e, no intervalo, `_conteudo()` devolve
   `SizedBox.expand()` — a tela fica na cor primária.
2. **Vídeo único**: o `setLooping(true)` do `video_player_win` não é gapless —
   no fim ele faz seek-para-zero e recomeça, com frames de gap. A piscada
   continua mesmo sem recriação.

Conclusão: nesta plataforma não existe transição suave sem **pré-carregar a
próxima mídia antes de trocar**.

## Objetivo

Nenhum frame de cor de fundo entre mídias. O atual segura o último frame até o
próximo estar pronto; a troca é um swap atômico.

Fora de escopo: crossfade/animações de transição, pré-carga de mais de uma
mídia à frente, mudanças no gate do fundo borrado de vídeo.

## Decisões

### 1. `PlayerPropaganda` ganha modo de preparo

Dois parâmetros novos:

```dart
/// Falso enquanto o player e o "proximo" da fila: prepara a midia (decode,
/// initialize) sem tocar nem agendar avanco.
final bool ativo;            // default true

/// Dispara uma unica vez, quando a midia esta tao pronta quanto vai ficar:
/// video inicializado, imagem decodificada — ou falha que vai pintar a cor
/// de fundo. E o sinal de que a troca pode acontecer sem piscar.
final VoidCallback? aoPreparado;   // default null
```

Regras:

- **Inativo** nunca agenda timer nem dá `play()`; vídeo faz `initialize()` e
  fica pausado no frame zero; imagem dispara o decode
  (`FileImage(...).resolve` + listener — o `ImageStream` volta, agora como
  sinal de prontidão, não como medição).
- `aoPreparado` dispara **sempre**, inclusive nas falhas (arquivo ausente,
  initialize com erro, imagem corrompida): "pronto" significa "não vou ficar
  mais pronto que isso". Sem esse contrato, uma mídia quebrada travaria a fila
  no último frame para sempre.
- **Ativação** (`ativo` false→true em `didUpdateWidget`): vídeo pronto →
  `play()`; vídeo que falhou → timer de 1s (fluxo de erro atual); vídeo ainda
  inicializando → o `then` do initialize dá o play (lê `widget.ativo` na
  hora); imagem → agenda o timer de duração; arquivo ausente → timer de 1s.
- Falha de initialize passa a **descartar o controller** (`_video = null`) e
  marcar `_falhou`, para a ativação saber que deve avançar como erro.
- `emLoop` continua: o preview do diálogo o usa. A página **deixa de usá-lo**.

### 2. `TrocadorPropaganda` — dois slots fixos

Novo componente (`propaganda/apresentacao/componentes/trocador_propaganda.dart`)
entre a página e o player:

```dart
TrocadorPropaganda({
  required int indice,               // posicao absoluta (cresce sempre)
  required MidiaPropaganda midiaAtual,
  required MidiaPropaganda midiaSeguinte,
  required Color corFundo,
  required VoidCallback aoAvancar,
})
```

Renderiza um `Stack` com **dois slots em posição fixa** (par e ímpar — sem
reordenação e sem re-parenting, para o Element do player sobreviver ao swap):

- Cada slot embrulha um `PlayerPropaganda` num `Offstage`.
- O player de cada slot tem `key: ValueKey('exibicao-N')`, onde N é o índice
  absoluto daquela exibição. O slot do índice atual fica visível e `ativo`;
  o do índice seguinte fica offstage, inativo, com `aoPreparado` ligado.
- **Swap** = o controlador avança o índice → rebuild: o slot que era seguinte
  mantém a key (`exibicao-N+1`) e só muda `ativo` para true — o Flutter
  preserva o State (vídeo já inicializado dá play instantâneo). O outro slot
  recebe key nova (`exibicao-N+2`) → player antigo é descartado e um novo
  nasce invisível, preparando a exibição seguinte.
- Índice absoluto (e não id) identifica exibições porque, com mídia única,
  atual e seguinte têm o mesmo id — são duas exibições distintas do mesmo
  arquivo, cada uma com seu controller. É isso que faz o loop de 1 vídeo não
  piscar: o recomeço é um swap para um segundo controller já inicializado.

Lógica de troca (estado interno do trocador):

- `_aoTerminarAtual`: se o seguinte já sinalizou pronto → `aoAvancar()`;
  senão marca `_aguardandoSeguinte` e o atual congela no último frame (a
  textura do vídeo terminado permanece; imagem é estática).
- `_aoPrepararSeguinte`: marca pronto; se estava aguardando → `aoAvancar()`.
- `didUpdateWidget` com índice novo: reseta os dois flags.

### 3. Página e estado

- `EstadoPropaganda` ganha `midiaSeguinte`:
  `midias.isEmpty ? null : midias[(indice + 1) % midias.length]`.
- `pagina_propaganda.dart` troca o `PlayerPropaganda` (e sua key por índice,
  e o `emLoop`) pelo `TrocadorPropaganda` sem key. `aoAvancar` continua
  chamando `avancar()` do controlador.
- `avancar()`/índice crescente não mudam.

## Erros e casos de borda

- **Arquivo ausente/corrompido no seguinte**: `aoPreparado` dispara mesmo
  assim; o swap acontece; o player quebrado pinta a cor de fundo por 1s e
  avança (fluxo de erro atual, agora confinado a mídias realmente quebradas).
- **Playlist com 1 mídia**: atual e seguinte são a mesma mídia em exibições
  distintas — dois controllers alternando, swap sem gap.
- **Playlist vazia**: página nem monta o trocador (comportamento atual).
- **Custo**: até 2 controllers de vídeo vivos ao mesmo tempo (padrão de
  players de sinage; memória aceitável no totem).
- **Timers em teste**: cada ciclo agenda o timer do novo atual; testes
  desmontam a árvore (`pumpWidget(SizedBox())`) antes de terminar para
  cancelar o timer pendente do ciclo em andamento.

## Componentes

| Arquivo | Mudança |
| --- | --- |
| `propaganda/apresentacao/componentes/player_propaganda.dart` | +`ativo`, +`aoPreparado`, `_comecar`, `_falhou`, decode-signal de imagem |
| `propaganda/apresentacao/componentes/trocador_propaganda.dart` | **novo** — slots fixos, swap por índice |
| `propaganda/apresentacao/controladores/controlador_propaganda.dart` | +getter `midiaSeguinte` |
| `propaganda/apresentacao/paginas/pagina_propaganda.dart` | usa o trocador; some a key por índice e o `emLoop` |

## Testes (TDD — escritos antes)

- **player**: inativo não agenda timer (imagem real, pump além da duração sem
  `aoTerminar`); `aoPreparado` dispara para imagem existente, para arquivo
  ausente e para vídeo com falha de initialize (em teste o plugin falha —
  serve de fixture de erro); ativação agenda timer/avança erro.
- **trocador**: monta 2 players (ativo visível + seguinte offstage inativo);
  fim do atual com seguinte pronto → `aoAvancar` 1x; rebuild com índice+1 →
  o State do player que era seguinte é **o mesmo objeto** (identidade
  preservada = sem recriação = sem piscada) e está ativo; com mídia única
  (atual == seguinte) o ciclo funciona igual.
- **estado**: `midiaSeguinte` com 0, 1 e 3 mídias (wrap circular).
- **página**: monta o trocador com atual/seguinte certos; testes antigos que
  contavam 1 `PlayerPropaganda` passam a lidar com 2 (filtrar por `ativo`);
  somem os testes de `emLoop` da página (o do preview do diálogo fica).

## Validação

```bash
dart format .
flutter analyze
flutter test
```

Mais validação manual no totem/PC: 1 vídeo em loop e playlist com 2 vídeos,
observando a transição.
