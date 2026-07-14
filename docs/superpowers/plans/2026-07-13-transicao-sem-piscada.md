# Transição sem piscada — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Nenhum frame de cor de fundo entre mídias da propaganda: o próximo player pré-carrega invisível e a troca é um swap atômico; o atual congela no último frame se o próximo ainda não estiver pronto.

**Architecture:** `PlayerPropaganda` ganha modo de preparo (`ativo: false` + `aoPreparado`); novo `TrocadorPropaganda` mantém dois slots fixos (par/ímpar, sem re-parenting) com players identificados por índice absoluto de exibição — o swap preserva o State do que era "seguinte". A página troca o player pelo trocador.

**Tech Stack:** Flutter, `video_player`/`video_player_win`, padrões do projeto.

Spec: `docs/superpowers/specs/2026-07-13-transicao-sem-piscada-design.md`

## Global Constraints

- pt-BR; arquivos < 600 linhas; comentário só para regra não óbvia; sem código morto.
- Nenhuma dependência nova; **sem codegen**.
- Commits **sem** `Co-Authored-By` — mensagem é EXATAMENTE a linha única do passo de commit; conferir `git log -1 --format=%B`, corrigir com `--amend` se aparecer trailer.
- Se `flutter test` sujar `windows/flutter/generated_*` ou `pubspec.lock`: `git checkout -- pubspec.lock windows/flutter/generated_plugin_registrant.cc windows/flutter/generated_plugins.cmake` antes do commit. `git add` explícito.
- Validação ao fim de cada task: `dart format .`, `flutter analyze`, `flutter test` (~277 testes).
- **Contrato central**: `aoPreparado` dispara SEMPRE (sucesso ou falha) e uma única vez por exibição — sem isso, mídia quebrada trava a fila no último frame.
- **Timers em teste**: ciclos do trocador agendam timer no novo atual; todo teste que roda um ciclo desmonta a árvore no fim (`await tester.pumpWidget(const SizedBox());`) para cancelar o timer pendente.

---

### Task 1: `PlayerPropaganda` — modo de preparo (`ativo` + `aoPreparado`)

**Files:**
- Modify: `lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart`
- Test: `test/funcionalidades/propaganda/player_propaganda_test.dart`

**Interfaces:**
- Consumes: nada novo.
- Produces: `PlayerPropaganda({..., bool ativo = true, VoidCallback? aoPreparado})`. Inativo: prepara sem tocar/agendar. Ativação via `didUpdateWidget`. `aoPreparado` dispara sempre, uma vez.

- [ ] **Step 1: Escrever os testes que falham**

Em `test/funcionalidades/propaganda/player_propaganda_test.dart`, o helper `montar` ganha parâmetros opcionais (manter o default igual ao atual):

```dart
  Future<void> montar(
    WidgetTester tester,
    MidiaPropaganda midia,
    Size tela, {
    bool ativo = true,
    VoidCallback? aoPreparado,
    VoidCallback? aoTerminar,
  }) {
    return tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox(
          width: tela.width,
          height: tela.height,
          child: PlayerPropaganda(
              midia: midia,
              corFundo: _corFundo,
              ativo: ativo,
              aoPreparado: aoPreparado,
              aoTerminar: aoTerminar ?? () {}),
        ),
      ),
    ));
  }
```

E acrescentar ao `main()`:

```dart
  testWidgets('inativo prepara a imagem sem agendar o avanco', (tester) async {
    var preparou = false;
    var terminou = false;
    await tester.runAsync(() async {
      await montar(
        tester,
        midiaCom(AjusteMidia.automatico, caminhoImagem),
        const Size(90, 160),
        ativo: false,
        aoPreparado: () => preparou = true,
        aoTerminar: () => terminou = true,
      );
      await tester.pump();
      // Da tempo do decode assincrono do FileImage terminar.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    });
    expect(preparou, isTrue,
        reason: 'imagem decodificada e o sinal de que a troca pode ocorrer');
    // Bem alem da duracao padrao (8s): inativo nao tem temporizador.
    await tester.pump(const Duration(seconds: 20));
    expect(terminou, isFalse,
        reason: 'player inativo nunca avanca a playlist');
  });

  testWidgets('arquivo ausente sinaliza preparado mesmo assim', (tester) async {
    var preparou = false;
    await montar(
      tester,
      midiaCom(AjusteMidia.automatico,
          '${temporaria.path}${Platform.pathSeparator}sumiu.png'),
      const Size(90, 160),
      ativo: false,
      aoPreparado: () => preparou = true,
    );
    await tester.pump();
    expect(preparou, isTrue,
        reason: 'falha tambem e "pronto": sem isso a fila travaria');
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('ativar o player inativo agenda o avanco', (tester) async {
    var terminou = false;
    await montar(
      tester,
      midiaCom(AjusteMidia.automatico, caminhoImagem)
          .copyWith(duracaoSegundos: 1),
      const Size(90, 160),
      ativo: false,
      aoTerminar: () => terminou = true,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(terminou, isFalse);

    await montar(
      tester,
      midiaCom(AjusteMidia.automatico, caminhoImagem)
          .copyWith(duracaoSegundos: 1),
      const Size(90, 160),
      ativo: true,
      aoTerminar: () => terminou = true,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(terminou, isTrue,
        reason: 'ao virar ativo, o timer de duracao entra em cena');
  });
```

Nota: o terceiro teste ativa por REMONTAGEM com as mesmas props exceto `ativo` — o `montar` reusa a mesma árvore (`MaterialApp > Center > SizedBox > Player` sem key), então o Flutter atualiza o widget existente e `didUpdateWidget` roda com `ativo` false→true. É exatamente o caminho que o trocador usa.

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/propaganda/player_propaganda_test.dart`
Expected: FAIL (`ativo`/`aoPreparado` não existem)

- [ ] **Step 3: Implementar no player**

Em `player_propaganda.dart`:

Construtor e campos (substituir o bloco atual do construtor):

```dart
  const PlayerPropaganda({
    super.key,
    required this.midia,
    required this.corFundo,
    required this.aoTerminar,
    this.emLoop = false,
    this.ativo = true,
    this.aoPreparado,
  });
```

Campos novos (junto de `emLoop`):

```dart
  /// Falso enquanto o player e o "proximo" da fila: prepara a midia (decode,
  /// initialize) sem tocar nem agendar avanco. O trocador vira a chave quando
  /// chega a vez.
  final bool ativo;

  /// Dispara uma unica vez, quando a midia esta tao pronta quanto vai ficar:
  /// video inicializado, imagem decodificada — ou falha que vai pintar a cor
  /// de fundo. E o sinal de que a troca pode acontecer sem piscar.
  final VoidCallback? aoPreparado;
```

No `_PlayerPropagandaState`, campos novos:

```dart
  ImageStream? _fluxoImagem;
  ImageStreamListener? _ouvinteImagem;
  bool _preparado = false;
  bool _falhou = false;
```

Substituir `_preparar` por:

```dart
  void _preparar() {
    _terminado = false;
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) {
      if (widget.ativo) _agendarAvancoDeErro();
      _sinalizarPreparado();
      return;
    }
    if (widget.midia.tipo == TipoMidia.imagem) {
      if (widget.ativo) _agendarTimerDaImagem();
      _decodificarImagem(arquivo);
      return;
    }
    final controlador = VideoPlayerController.file(arquivo);
    _video = controlador;
    controlador.addListener(_aoAtualizarVideo);
    controlador.initialize().then((_) {
      if (!mounted) return;
      // O tamanho do video so existe depois do initialize: este rebuild
      // troca o SizedBox vazio pela textura.
      setState(() {});
      controlador.setLooping(widget.emLoop);
      if (widget.ativo) controlador.play();
      _sinalizarPreparado();
    }).catchError((Object _) {
      // Arquivo corrompido ou codec nao suportado: descarta o controller e
      // avanca como erro — na vez deste player, nao antes.
      if (!mounted) return;
      _video?.removeListener(_aoAtualizarVideo);
      _video?.dispose();
      _video = null;
      _falhou = true;
      if (widget.ativo) _agendarAvancoDeErro();
      _sinalizarPreparado();
    });
  }

  void _agendarAvancoDeErro() {
    _temporizador = Timer(const Duration(seconds: 1), _terminar);
  }

  void _agendarTimerDaImagem() {
    _temporizador =
        Timer(Duration(seconds: widget.midia.duracaoSegundos), _terminar);
  }

  /// O decode do primeiro frame e o "pronto" da imagem (e povoa o cache: na
  /// vez dela, pinta sem atraso). Erro tambem sinaliza — a cor de fundo cobre.
  void _decodificarImagem(File arquivo) {
    final fluxo = FileImage(arquivo).resolve(ImageConfiguration.empty);
    final ouvinte = ImageStreamListener(
      (_, __) => _sinalizarPreparado(),
      onError: (Object _, StackTrace? __) => _sinalizarPreparado(),
    );
    _fluxoImagem = fluxo;
    _ouvinteImagem = ouvinte;
    fluxo.addListener(ouvinte);
  }

  void _sinalizarPreparado() {
    if (_preparado) return;
    _preparado = true;
    widget.aoPreparado?.call();
  }

  /// Chegou a vez deste player: o que estava so preparado passa a rodar.
  void _comecar() {
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) {
      _agendarAvancoDeErro();
      return;
    }
    if (widget.midia.tipo == TipoMidia.imagem) {
      _agendarTimerDaImagem();
      return;
    }
    final video = _video;
    if (video != null && video.value.isInitialized) {
      video.play();
    } else if (_falhou) {
      _agendarAvancoDeErro();
    }
    // Se o initialize ainda esta em andamento, o proprio then da o play:
    // ele le widget.ativo na hora em que termina.
  }
```

Substituir `didUpdateWidget` por:

```dart
  @override
  void didUpdateWidget(covariant PlayerPropaganda anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.midia.id != widget.midia.id) {
      _limpar();
      _preparar();
      return;
    }
    if (!anterior.ativo && widget.ativo) _comecar();
  }
```

Substituir `_limpar` por (cancela também o stream da imagem e reseta flags):

```dart
  void _limpar() {
    _temporizador?.cancel();
    _temporizador = null;
    final fluxo = _fluxoImagem;
    final ouvinte = _ouvinteImagem;
    if (fluxo != null && ouvinte != null) fluxo.removeListener(ouvinte);
    _fluxoImagem = null;
    _ouvinteImagem = null;
    _preparado = false;
    _falhou = false;
    _video?.removeListener(_aoAtualizarVideo);
    _video?.dispose();
    _video = null;
  }
```

- [ ] **Step 4: Rodar os testes**

Run: `flutter test test/funcionalidades/propaganda/`
Expected: PASS (os antigos continuam: `ativo` default true reproduz o comportamento atual)

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart test/funcionalidades/propaganda/player_propaganda_test.dart
git commit -m "feat: player da propaganda ganha modo de preparo sem reproducao"
git log -1 --format=%B
```

---

### Task 2: `midiaSeguinte` no estado + `TrocadorPropaganda`

**Files:**
- Modify: `lib/funcionalidades/propaganda/apresentacao/controladores/controlador_propaganda.dart`
- Create: `lib/funcionalidades/propaganda/apresentacao/componentes/trocador_propaganda.dart`
- Test: `test/funcionalidades/propaganda/trocador_propaganda_test.dart` (novo)
- Test: `test/funcionalidades/propaganda/propaganda_test.dart` (só o getter)

**Interfaces:**
- Consumes: `PlayerPropaganda` com `ativo`/`aoPreparado` (Task 1).
- Produces:
  - `MidiaPropaganda? get midiaSeguinte` em `EstadoPropaganda`: `midias.isEmpty ? null : midias[(indice + 1) % midias.length]`.
  - `TrocadorPropaganda({required int indice, required MidiaPropaganda midiaAtual, required MidiaPropaganda midiaSeguinte, required Color corFundo, required VoidCallback aoAvancar})` — dois slots fixos; players com `key: ValueKey('exibicao-N')`.

- [ ] **Step 1: Escrever os testes que falham**

No `main()` de `test/funcionalidades/propaganda/propaganda_test.dart`, junto do teste do controlador:

```dart
  test('midiaSeguinte aponta a proxima exibicao, circular', () {
    const a = MidiaPropaganda(
        id: 'a', tipo: TipoMidia.imagem, caminho: '/m/a.png', ordem: 1);
    const b = MidiaPropaganda(
        id: 'b', tipo: TipoMidia.imagem, caminho: '/m/b.png', ordem: 2);
    expect(const EstadoPropaganda().midiaSeguinte, isNull);
    expect(const EstadoPropaganda(midias: [a]).midiaSeguinte, a,
        reason: 'midia unica: a proxima exibicao e ela mesma');
    expect(const EstadoPropaganda(midias: [a, b], indice: 0).midiaSeguinte, b);
    expect(const EstadoPropaganda(midias: [a, b], indice: 1).midiaSeguinte, a);
  });
```

Criar `test/funcionalidades/propaganda/trocador_propaganda_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/trocador_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _png1x1 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8'
    'BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

void main() {
  late Directory temporaria;
  late String caminhoA;
  late String caminhoB;

  setUp(() async {
    temporaria = await Directory.systemTemp.createTemp('trocador');
    caminhoA = '${temporaria.path}${Platform.pathSeparator}a.png';
    caminhoB = '${temporaria.path}${Platform.pathSeparator}b.png';
    await File(caminhoA).writeAsBytes(base64Decode(_png1x1));
    await File(caminhoB).writeAsBytes(base64Decode(_png1x1));
  });

  tearDown(() async {
    imageCache.clear();
    await temporaria.delete(recursive: true);
  });

  MidiaPropaganda imagem(String id, String caminho) => MidiaPropaganda(
      id: id,
      tipo: TipoMidia.imagem,
      caminho: caminho,
      duracaoSegundos: 1,
      ordem: 1);

  Future<void> montar(
    WidgetTester tester, {
    required int indice,
    required MidiaPropaganda atual,
    required MidiaPropaganda seguinte,
    required VoidCallback aoAvancar,
  }) {
    return tester.pumpWidget(MaterialApp(
      home: TrocadorPropaganda(
        indice: indice,
        midiaAtual: atual,
        midiaSeguinte: seguinte,
        corFundo: const Color(0xFF123456),
        aoAvancar: aoAvancar,
      ),
    ));
  }

  PlayerPropaganda playerAtivo(WidgetTester tester) => tester
      .widgetList<PlayerPropaganda>(find.byType(PlayerPropaganda))
      .singleWhere((p) => p.ativo);

  testWidgets('mantem o atual visivel e o seguinte preparando offstage',
      (tester) async {
    final a = imagem('a', caminhoA);
    final b = imagem('b', caminhoB);
    await montar(tester,
        indice: 0, atual: a, seguinte: b, aoAvancar: () {});
    await tester.pump();

    final players =
        tester.widgetList<PlayerPropaganda>(find.byType(PlayerPropaganda));
    expect(players, hasLength(2));
    expect(playerAtivo(tester).midia.id, 'a');
    final seguinte = players.singleWhere((p) => !p.ativo);
    expect(seguinte.midia.id, 'b');
    expect(seguinte.aoPreparado, isNotNull,
        reason: 'o seguinte precisa avisar quando estiver pronto');

    // O timer de 1s do atual fica pendente: desmonta para cancelar.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('fim do atual com seguinte pronto avanca uma vez',
      (tester) async {
    var avancos = 0;
    final a = imagem('a', caminhoA);
    final b = imagem('b', caminhoB);
    await tester.runAsync(() async {
      await montar(tester,
          indice: 0, atual: a, seguinte: b, aoAvancar: () => avancos++);
      await tester.pump();
      // Decode assincrono do seguinte termina (aoPreparado dispara).
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    });
    await tester.pump(const Duration(seconds: 1)); // duracao do atual
    expect(avancos, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('no swap, o player que era seguinte sobrevive (mesmo State)',
      (tester) async {
    final a = imagem('a', caminhoA);
    final b = imagem('b', caminhoB);
    await tester.runAsync(() async {
      await montar(tester,
          indice: 0, atual: a, seguinte: b, aoAvancar: () {});
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    });
    final estadoSeguinteAntes = tester.state(find.byWidgetPredicate(
        (w) => w is PlayerPropaganda && !w.ativo && w.midia.id == 'b'));

    // Simula o controlador avancando: mesmo trocador, indice novo.
    await tester.runAsync(() async {
      await montar(tester,
          indice: 1, atual: b, seguinte: a, aoAvancar: () {});
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    });
    final estadoAtivoDepois = tester.state(find.byWidgetPredicate(
        (w) => w is PlayerPropaganda && w.ativo && w.midia.id == 'b'));

    expect(identical(estadoSeguinteAntes, estadoAtivoDepois), isTrue,
        reason: 'recriar o player na troca e exatamente a piscada que o '
            'trocador existe para eliminar');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('midia unica: atual e seguinte sao exibicoes distintas dela',
      (tester) async {
    var avancos = 0;
    final a = imagem('a', caminhoA);
    await tester.runAsync(() async {
      await montar(tester,
          indice: 0, atual: a, seguinte: a, aoAvancar: () => avancos++);
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    });
    final players =
        tester.widgetList<PlayerPropaganda>(find.byType(PlayerPropaganda));
    expect(players, hasLength(2),
        reason: 'duas exibicoes do mesmo arquivo, cada uma com seu player');
    await tester.pump(const Duration(seconds: 1));
    expect(avancos, 1);
    await tester.pumpWidget(const SizedBox());
  });
}
```

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/propaganda/trocador_propaganda_test.dart test/funcionalidades/propaganda/propaganda_test.dart`
Expected: FAIL (`midiaSeguinte` e `TrocadorPropaganda` não existem)

- [ ] **Step 3: Implementar o getter**

Em `controlador_propaganda.dart`, no `EstadoPropaganda`, abaixo de `midiaAtual`:

```dart
  /// Proxima exibicao da fila (circular): e o que o trocador pre-carrega.
  /// Com midia unica, e a propria midia — outra exibicao, outro player.
  MidiaPropaganda? get midiaSeguinte =>
      midias.isEmpty ? null : midias[(indice + 1) % midias.length];
```

- [ ] **Step 4: Implementar o trocador**

Criar `lib/funcionalidades/propaganda/apresentacao/componentes/trocador_propaganda.dart`:

```dart
import 'package:flutter/material.dart';

import '../../dominio/entidades/midia_propaganda.dart';
import 'player_propaganda.dart';

/// Mantem dois players: o atual, tocando, e o seguinte, preparando invisivel.
/// A troca so acontece quando o seguinte avisa que esta pronto — ate la o
/// atual segura o ultimo frame. E o que impede a cor de fundo de piscar
/// entre midias (o initialize de video e lento e o loop do backend nao e
/// gapless).
class TrocadorPropaganda extends StatefulWidget {
  const TrocadorPropaganda({
    super.key,
    required this.indice,
    required this.midiaAtual,
    required this.midiaSeguinte,
    required this.corFundo,
    required this.aoAvancar,
  });

  /// Posicao absoluta na playlist (cresce sempre). Identifica a exibicao:
  /// com midia unica, atual e seguinte tem o mesmo id mas sao exibicoes
  /// distintas, cada uma com seu player.
  final int indice;

  final MidiaPropaganda midiaAtual;
  final MidiaPropaganda midiaSeguinte;
  final Color corFundo;

  /// Chamado quando o atual terminou E o seguinte esta pronto. O controlador
  /// avanca o indice e o rebuild faz o swap: o slot do seguinte mantem a key
  /// e so vira ativo — o player nao e recriado.
  final VoidCallback aoAvancar;

  @override
  State<TrocadorPropaganda> createState() => _TrocadorPropagandaState();
}

class _TrocadorPropagandaState extends State<TrocadorPropaganda> {
  bool _seguintePronto = false;
  bool _aguardandoSeguinte = false;

  @override
  void didUpdateWidget(covariant TrocadorPropaganda anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.indice != widget.indice) {
      // Swap consumado: quem era seguinte virou atual; o novo seguinte
      // comeca a preparar do zero.
      _seguintePronto = false;
      _aguardandoSeguinte = false;
    }
  }

  void _aoTerminarAtual() {
    if (_seguintePronto) {
      widget.aoAvancar();
    } else {
      // Segura no ultimo frame do atual ate o seguinte sinalizar.
      _aguardandoSeguinte = true;
    }
  }

  void _aoPrepararSeguinte() {
    _seguintePronto = true;
    if (_aguardandoSeguinte) {
      _aguardandoSeguinte = false;
      widget.aoAvancar();
    }
  }

  Widget _slot(int indiceExibicao, MidiaPropaganda midia) {
    final ativo = indiceExibicao == widget.indice;
    return Offstage(
      offstage: !ativo,
      child: PlayerPropaganda(
        // A key por exibicao faz o slot reciclado (indice + 2) nascer como
        // player novo, e o slot promovido manter o State de quando preparava.
        key: ValueKey('exibicao-$indiceExibicao'),
        midia: midia,
        corFundo: widget.corFundo,
        ativo: ativo,
        aoPreparado: ativo ? null : _aoPrepararSeguinte,
        aoTerminar: ativo ? _aoTerminarAtual : _ignorarFim,
      ),
    );
  }

  static void _ignorarFim() {}

  @override
  Widget build(BuildContext context) {
    final atual = widget.indice;
    final seguinte = atual + 1;
    // Slots em posicao fixa (par embaixo, impar em cima — irrelevante, o
    // offstage nao pinta): sem reordenacao nem re-parenting, o Element do
    // player sobrevive ao swap.
    final exibicaoPar = atual.isEven ? atual : seguinte;
    final exibicaoImpar = atual.isOdd ? atual : seguinte;
    return Stack(
      fit: StackFit.expand,
      children: [
        _slot(exibicaoPar,
            exibicaoPar == atual ? widget.midiaAtual : widget.midiaSeguinte),
        _slot(exibicaoImpar,
            exibicaoImpar == atual ? widget.midiaAtual : widget.midiaSeguinte),
      ],
    );
  }
}
```

- [ ] **Step 5: Rodar os testes**

Run: `flutter test test/funcionalidades/propaganda/`
Expected: PASS

- [ ] **Step 6: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/propaganda/apresentacao/controladores/controlador_propaganda.dart lib/funcionalidades/propaganda/apresentacao/componentes/trocador_propaganda.dart test/funcionalidades/propaganda/trocador_propaganda_test.dart test/funcionalidades/propaganda/propaganda_test.dart
git commit -m "feat: trocador de propaganda pre-carrega a proxima midia"
git log -1 --format=%B
```

---

### Task 3: Página usa o trocador

**Files:**
- Modify: `lib/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart`
- Test: `test/funcionalidades/propaganda/propaganda_test.dart`

**Interfaces:**
- Consumes: `TrocadorPropaganda` (Task 2), `midiaSeguinte` (Task 2).
- Produces: página sem key-por-índice e sem `emLoop`; trocador persistente.

- [ ] **Step 1: Atualizar os testes (falharão)**

Em `test/funcionalidades/propaganda/propaganda_test.dart`:

No teste `'com midia, o player e a faixa coexistem...'`:
- trocar `expect(find.byType(PlayerPropaganda), findsOneWidget);` por:

```dart
    expect(find.byType(TrocadorPropaganda), findsOneWidget);
    expect(find.byType(PlayerPropaganda), findsNWidgets(2),
        reason: 'atual tocando + seguinte preparando');
```

- trocar a leitura do player por (só o ativo interessa):

```dart
    final player = tester
        .widgetList<PlayerPropaganda>(find.byType(PlayerPropaganda))
        .singleWhere((p) => p.ativo);
```

- **remover** o `expect(player.emLoop, isTrue, ...)` (o loop de mídia única agora é responsabilidade do trocador).
- antes do `tap` final, desmontar não dá (o teste navega) — em vez disso, manter o `pump(seconds: 1)` existente e, como o avanço agora agenda o timer da exibição seguinte, acrescentar logo após o `expect(find.text('CHAT')...)` final:

```dart
    // O trocador saiu de cena na navegacao; nada mais pendente.
```

  (Se o teste falhar por timer pendente, drenar com mais um `await tester.pump(const Duration(seconds: 1));` antes do tap.)

**Remover** o teste `'com mais de uma midia, o player nao entra em loop'` inteiro (testava o `emLoop` da página, que deixou de existir; a cobertura da troca vive em `trocador_propaganda_test.dart`).

Import novo no teste:

```dart
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/trocador_propaganda.dart';
```

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/propaganda/propaganda_test.dart`
Expected: FAIL (página ainda monta `PlayerPropaganda` único)

- [ ] **Step 3: Implementar na página**

Em `pagina_propaganda.dart`, substituir o ramo do player por:

```dart
    } else {
      fundo = TrocadorPropaganda(
        indice: estado.indice,
        midiaAtual: estado.midiaAtual!,
        midiaSeguinte: estado.midiaSeguinte!,
        corFundo: primaria,
        aoAvancar: () => ref.read(provedorPropaganda.notifier).avancar(),
      );
    }
```

Trocar o import de `player_propaganda.dart` por `trocador_propaganda.dart` (a página não referencia mais o player diretamente).

- [ ] **Step 4: Rodar os testes**

Run: `flutter test`
Expected: PASS (suíte inteira)

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart test/funcionalidades/propaganda/propaganda_test.dart
git commit -m "feat: tela de propaganda troca de midia sem piscar"
git log -1 --format=%B
```

---

### Task 4: Validação final e review

- [ ] `dart format .` / `flutter analyze` / `flutter test` — tudo verde.
- [ ] Checklist adversarial do CLAUDE.md (timers vazando, dispose dos 2 controllers, arquivos < 600 linhas — atenção ao player, que cresceu).
- [ ] Review de branch do range desta feature; relatório com a pendência de validação manual (transição real de vídeo no Windows — testes de widget não exercitam o backend Media Foundation).
