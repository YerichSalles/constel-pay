# Enquadramento da mídia de propaganda — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** O modo automático nunca corta a mídia; a sobra vira fundo borrado da própria mídia; o modo preencher ganha âncora do corte e zoom, configurados num diálogo com preview ao vivo.

**Architecture:** Funções puras em `ajuste_tela.dart` traduzem modo→`BoxFit`, âncora→`Alignment` e zoom→escala. `MidiaPropaganda`/`ModeloMidia` ganham `fundo`, `ancora` e `zoomPercentual` (com `@Default` — obrigatório para não apagar playlist legada). O `PlayerPropaganda` perde a medição de razão e ganha a camada de fundo borrado (Stack). O card da aba Propaganda perde o dropdown e ganha resumo + botão "Ajustar…" que abre o novo `DialogoAjusteMidia` com preview usando o próprio player.

**Tech Stack:** Flutter, Riverpod (`StateNotifier`), Freezed + json_serializable, `SharedPreferences`, `video_player`, `ImageFiltered`/`ui.ImageFilter.blur`.

Spec: `docs/superpowers/specs/2026-07-13-enquadramento-midia-propaganda-design.md`

## Global Constraints

- Idioma de toda string visível ao usuário: **pt-BR**.
- Pastas e nomes de código em pt-BR. Não criar pastas em inglês (`core`, `features`, `shared`).
- Nenhum arquivo de código acima de **600 linhas**.
- Comentário só quando explicar regra não óbvia. Sem código morto, sem import não usado, sem `print`, sem TODO.
- Nenhuma dependência nova no `pubspec.yaml`.
- **Os campos novos NUNCA podem ser `required` em `ModeloMidia`.** Playlist já gravada no `SharedPreferences` não tem as chaves; campo obrigatório faz o `fromJson` lançar, o `catch` em `repositorio_propaganda_impl.dart:26` engole e devolve `const []` — a playlist da loja some sem aviso.
- Codegen (`dart run build_runner build --delete-conflicting-outputs`) roda **só na Task 2** (única que altera classe `@freezed`). Nesta máquina o codegen dispara `pub get` que **rebaixa o `pubspec.lock`** e suja `windows/flutter/generated_*`. Commits sempre com `git add` explícito dos arquivos citados; **nunca** `git add -A`; conferir com `git show --stat HEAD` que `pubspec.lock` e `windows/flutter/generated_*` ficaram de fora.
- Commits **sem** `Co-Authored-By`.
- Validação ao fim de cada tarefa: `dart format .`, `flutter analyze`, `flutter test`.
- **Gate do vídeo:** fundo borrado em vídeo custa GPU por frame. Fica atrás da constante `fundoBorradoLiberadoParaVideo = false` até a medição em profile build provar 60fps no totem (Task 7). Enquanto `false`, vídeo cai na cor do tema e a UI esconde a opção.

---

### Task 1: `automatico` nunca corta — funções puras e poda da medição do player

O coração da correção: `resolverBoxFit` vira função de um argumento (a razão de aspecto sai da assinatura), nascem `resolverAlinhamento`, `resolverEscala`, `modoDeixaSobra` e `fundoEfetivo`, e o player perde todo o maquinário de medição (`_razaoMidia`, `ImageStream`, `_razaoDe`, espera-antes-de-pintar) — deleção intencional aprovada na spec.

**Files:**
- Modify: `lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart` (só acrescenta 2 enums; campos ficam para a Task 2, então **sem** codegen aqui)
- Modify: `lib/funcionalidades/propaganda/apresentacao/ajuste_tela.dart` (reescrita completa)
- Modify: `lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart` (poda da medição)
- Test: `test/funcionalidades/propaganda/ajuste_tela_test.dart` (reescrita completa)
- Test: `test/funcionalidades/propaganda/player_propaganda_test.dart` (testes de automático)

**Interfaces:**
- Consumes: `enum AjusteMidia`, `enum TipoMidia` (existentes em `midia_propaganda.dart`).
- Produces (tudo em `ajuste_tela.dart`, exceto os enums):
  - `enum FundoMidia { borrado, cor }` e `enum AncoraMidia { topoEsquerda, topo, topoDireita, esquerda, centro, direita, baseEsquerda, base, baseDireita }` em `midia_propaganda.dart`
  - `const int zoomMinimo = 100;` / `const int zoomMaximo = 300;`
  - `const bool fundoBorradoLiberadoParaVideo = false;`
  - `BoxFit resolverBoxFit(AjusteMidia ajuste)`
  - `Alignment resolverAlinhamento(AncoraMidia ancora)`
  - `double resolverEscala(int zoomPercentual)`
  - `bool modoDeixaSobra(AjusteMidia ajuste)`
  - `FundoMidia fundoEfetivo({required TipoMidia tipo, required FundoMidia fundo})`
  - Some: `aproveitamentoMinimoParaPreencher` e os parâmetros `razaoMidia`/`razaoTela`.

- [ ] **Step 1: Acrescentar os enums à entidade**

Em `lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart`, logo abaixo do `enum AjusteMidia`:

```dart
/// Como a midia se acomoda na tela da propaganda.
enum AjusteMidia { automatico, preencher, encaixar, esticar }

/// O que pinta a sobra quando a midia nao cobre a tela toda.
enum FundoMidia { borrado, cor }

/// Qual parte da midia sobrevive ao corte do modo preencher (grade 3x3).
enum AncoraMidia {
  topoEsquerda,
  topo,
  topoDireita,
  esquerda,
  centro,
  direita,
  baseEsquerda,
  base,
  baseDireita,
}
```

- [ ] **Step 2: Reescrever o teste de `ajuste_tela` (falhará)**

Substituir todo o conteúdo de `test/funcionalidades/propaganda/ajuste_tela_test.dart` por:

```dart
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/ajuste_tela.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('automatico nunca corta: contain incondicional', () {
    // Antes, midia com razao proxima da tela levava cover e perdia ate 25%
    // da peca. Agora nao existe razao que produza corte no automatico.
    expect(resolverBoxFit(AjusteMidia.automatico), BoxFit.contain);
  });

  test('modos explicitos seguem valendo', () {
    expect(resolverBoxFit(AjusteMidia.preencher), BoxFit.cover);
    expect(resolverBoxFit(AjusteMidia.encaixar), BoxFit.contain);
    expect(resolverBoxFit(AjusteMidia.esticar), BoxFit.fill);
  });

  test('cada ancora mapeia para o Alignment correspondente', () {
    const esperados = {
      AncoraMidia.topoEsquerda: Alignment.topLeft,
      AncoraMidia.topo: Alignment.topCenter,
      AncoraMidia.topoDireita: Alignment.topRight,
      AncoraMidia.esquerda: Alignment.centerLeft,
      AncoraMidia.centro: Alignment.center,
      AncoraMidia.direita: Alignment.centerRight,
      AncoraMidia.baseEsquerda: Alignment.bottomLeft,
      AncoraMidia.base: Alignment.bottomCenter,
      AncoraMidia.baseDireita: Alignment.bottomRight,
    };
    expect(esperados, hasLength(AncoraMidia.values.length),
        reason: 'toda ancora nova precisa entrar neste mapa');
    for (final entrada in esperados.entries) {
      expect(resolverAlinhamento(entrada.key), entrada.value,
          reason: '${entrada.key}');
    }
  });

  test('zoom converte percentual em escala', () {
    expect(resolverEscala(100), 1.0);
    expect(resolverEscala(150), 1.5);
    expect(resolverEscala(300), 3.0);
  });

  test('zoom fora da faixa e corrigido, nao estoura', () {
    expect(resolverEscala(40), 1.0);
    expect(resolverEscala(999), 3.0);
    expect(resolverEscala(-5), 1.0);
  });

  test('so automatico e encaixar deixam sobra', () {
    expect(modoDeixaSobra(AjusteMidia.automatico), isTrue);
    expect(modoDeixaSobra(AjusteMidia.encaixar), isTrue);
    expect(modoDeixaSobra(AjusteMidia.preencher), isFalse);
    expect(modoDeixaSobra(AjusteMidia.esticar), isFalse);
  });

  test('video cai para cor enquanto o gate do fundo borrado nao libera', () {
    // Flipar fundoBorradoLiberadoParaVideo exige a medicao de 60fps em
    // profile build (spec, secao Performance). Ao flipar, atualize junto.
    expect(fundoBorradoLiberadoParaVideo, isFalse);
    expect(fundoEfetivo(tipo: TipoMidia.video, fundo: FundoMidia.borrado),
        FundoMidia.cor);
    expect(fundoEfetivo(tipo: TipoMidia.video, fundo: FundoMidia.cor),
        FundoMidia.cor);
    expect(fundoEfetivo(tipo: TipoMidia.imagem, fundo: FundoMidia.borrado),
        FundoMidia.borrado);
  });
}
```

- [ ] **Step 3: Rodar o teste para vê-lo falhar**

Run: `flutter test test/funcionalidades/propaganda/ajuste_tela_test.dart`
Expected: FAIL (erro de compilação: `resolverBoxFit` ainda exige `razaoMidia`/`razaoTela`; `resolverAlinhamento` etc. não existem)

- [ ] **Step 4: Reescrever `ajuste_tela.dart`**

Substituir todo o conteúdo de `lib/funcionalidades/propaganda/apresentacao/ajuste_tela.dart` por:

```dart
import 'package:flutter/painting.dart';

import '../dominio/entidades/midia_propaganda.dart';

/// Faixa valida do zoom do modo preencher, em percentual.
const int zoomMinimo = 100;
const int zoomMaximo = 300;

/// Borrar video custa GPU a cada frame. So libera depois que a medicao em
/// profile build provar 60fps no totem (gate da spec de enquadramento);
/// enquanto false, video cai na cor do tema e a UI esconde a opcao.
const bool fundoBorradoLiberadoParaVideo = false;

/// Traduz o modo escolhido pelo operador no `BoxFit` que o player aplica.
/// O automatico nunca corta: encaixa sempre, e a sobra vira fundo borrado.
BoxFit resolverBoxFit(AjusteMidia ajuste) {
  switch (ajuste) {
    case AjusteMidia.preencher:
      return BoxFit.cover;
    case AjusteMidia.encaixar:
    case AjusteMidia.automatico:
      return BoxFit.contain;
    case AjusteMidia.esticar:
      return BoxFit.fill;
  }
}

/// Qual parte da midia sobrevive ao corte do modo preencher.
Alignment resolverAlinhamento(AncoraMidia ancora) {
  switch (ancora) {
    case AncoraMidia.topoEsquerda:
      return Alignment.topLeft;
    case AncoraMidia.topo:
      return Alignment.topCenter;
    case AncoraMidia.topoDireita:
      return Alignment.topRight;
    case AncoraMidia.esquerda:
      return Alignment.centerLeft;
    case AncoraMidia.centro:
      return Alignment.center;
    case AncoraMidia.direita:
      return Alignment.centerRight;
    case AncoraMidia.baseEsquerda:
      return Alignment.bottomLeft;
    case AncoraMidia.base:
      return Alignment.bottomCenter;
    case AncoraMidia.baseDireita:
      return Alignment.bottomRight;
  }
}

/// Converte o zoom percentual em escala. O clamp corrige JSON adulterado em
/// vez de estourar.
double resolverEscala(int zoomPercentual) =>
    zoomPercentual.clamp(zoomMinimo, zoomMaximo) / 100;

/// So automatico e encaixar deixam sobra; preencher e esticar cobrem tudo.
bool modoDeixaSobra(AjusteMidia ajuste) =>
    ajuste == AjusteMidia.automatico || ajuste == AjusteMidia.encaixar;

/// Fundo que o player realmente pinta, respeitando o gate do video.
FundoMidia fundoEfetivo({required TipoMidia tipo, required FundoMidia fundo}) =>
    tipo == TipoMidia.video && !fundoBorradoLiberadoParaVideo
        ? FundoMidia.cor
        : fundo;
```

- [ ] **Step 5: Podar a medição do player**

Substituir todo o conteúdo de `lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart` por (somem `_razaoMidia`, `_fluxoImagem`, `_ouvinteImagem`, `_medirImagem`, `_razaoDe`, o `LayoutBuilder` e a espera-antes-de-pintar):

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../dominio/entidades/midia_propaganda.dart';
import '../ajuste_tela.dart';

class PlayerPropaganda extends StatefulWidget {
  const PlayerPropaganda({
    super.key,
    required this.midia,
    required this.corFundo,
    required this.aoTerminar,
  });

  final MidiaPropaganda midia;

  /// Pinta a sobra do modo encaixar (quando o fundo e cor) e o intervalo em
  /// que a midia ainda esta carregando. Vem da cor primaria do tema da loja.
  final Color corFundo;

  final VoidCallback aoTerminar;

  @override
  State<PlayerPropaganda> createState() => _PlayerPropagandaState();
}

class _PlayerPropagandaState extends State<PlayerPropaganda> {
  Timer? _temporizador;
  VideoPlayerController? _video;
  bool _terminado = false;

  @override
  void initState() {
    super.initState();
    _preparar();
  }

  @override
  void didUpdateWidget(covariant PlayerPropaganda anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.midia.id != widget.midia.id) {
      _limpar();
      _preparar();
    }
  }

  /// O listener do video dispara varias vezes no fim da reproducao; sem esta
  /// guarda a playlist pularia midias.
  void _terminar() {
    if (_terminado) return;
    _terminado = true;
    widget.aoTerminar();
  }

  void _preparar() {
    _terminado = false;
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) {
      _temporizador = Timer(const Duration(seconds: 1), _terminar);
      return;
    }
    if (widget.midia.tipo == TipoMidia.imagem) {
      _temporizador =
          Timer(Duration(seconds: widget.midia.duracaoSegundos), _terminar);
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
      controlador.play();
    }).catchError((Object _) {
      // Arquivo corrompido ou codec nao suportado: segue para a proxima midia
      // em vez de deixar a tela parada.
      if (mounted) _temporizador = Timer(const Duration(seconds: 1), _terminar);
    });
  }

  void _aoAtualizarVideo() {
    final valor = _video?.value;
    if (valor == null) return;
    if (valor.hasError) {
      _terminar();
      return;
    }
    if (valor.isInitialized &&
        valor.duration > Duration.zero &&
        valor.position >= valor.duration) {
      _terminar();
    }
  }

  void _limpar() {
    _temporizador?.cancel();
    _temporizador = null;
    _video?.removeListener(_aoAtualizarVideo);
    _video?.dispose();
    _video = null;
  }

  @override
  void dispose() {
    _limpar();
    super.dispose();
  }

  Widget _conteudo(BoxFit fit) {
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) return const SizedBox.expand();
    if (widget.midia.tipo == TipoMidia.imagem) {
      return Image.file(arquivo,
          fit: fit, width: double.infinity, height: double.infinity);
    }
    final video = _video;
    if (video == null || !video.value.isInitialized) {
      return const SizedBox.expand();
    }
    return FittedBox(
      fit: fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: video.value.size.width,
        height: video.value.size.height,
        child: VideoPlayer(video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.corFundo,
      child: SizedBox.expand(
        child: _conteudo(resolverBoxFit(widget.midia.ajuste)),
      ),
    );
  }
}
```

- [ ] **Step 6: Atualizar os testes de automático do player**

Em `test/funcionalidades/propaganda/player_propaganda_test.dart`, **remover** os dois testes `'automatico encaixa imagem quadrada em tela retrato'` e `'automatico preenche imagem quadrada em tela quadrada'` e colocar no lugar (sem `runAsync`: não há mais medição para esperar):

```dart
  testWidgets('automatico nunca corta, qualquer que seja a tela',
      (tester) async {
    // Tela quadrada com imagem quadrada dava cover; agora tudo e contain.
    await montar(tester, midiaCom(AjusteMidia.automatico, caminhoImagem),
        const Size(120, 120));
    await tester.pump();
    expect(fitAplicado(tester), BoxFit.contain);

    await montar(tester, midiaCom(AjusteMidia.automatico, caminhoImagem),
        const Size(90, 160));
    await tester.pump();
    expect(fitAplicado(tester), BoxFit.contain);
  });
```

- [ ] **Step 7: Rodar os testes**

Run: `flutter test test/funcionalidades/propaganda/`
Expected: PASS (todos)

- [ ] **Step 8: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart lib/funcionalidades/propaganda/apresentacao/ajuste_tela.dart lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart test/funcionalidades/propaganda/ajuste_tela_test.dart test/funcionalidades/propaganda/player_propaganda_test.dart
git commit -m "feat: ajuste automatico nunca corta a midia da propaganda"
```

---

### Task 2: Campos `fundo`, `ancora` e `zoomPercentual` no modelo (codegen)

**Files:**
- Modify: `lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart`
- Modify: `lib/funcionalidades/propaganda/dados/modelos/modelo_midia.dart`
- Test: `test/funcionalidades/propaganda/repositorio_propaganda_test.dart`
- Gerados (commitar junto): `midia_propaganda.freezed.dart`, `modelo_midia.freezed.dart`, `modelo_midia.g.dart`

**Interfaces:**
- Consumes: `FundoMidia`, `AncoraMidia` (Task 1).
- Produces: `MidiaPropaganda` e `ModeloMidia` com `FundoMidia fundo` (default `borrado`), `AncoraMidia ancora` (default `centro`), `int zoomPercentual` (default `100`) — todos `@Default`, enums com `@JsonKey(unknownEnumValue: ...)`.

- [ ] **Step 1: Escrever os testes que falham**

Em `test/funcionalidades/propaganda/repositorio_propaganda_test.dart`, acrescentar ao `main()`:

```dart
  test('o enquadramento escolhido sobrevive ao round-trip', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio =
        RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: '/m/a.png',
          ordem: 1,
          fundo: FundoMidia.cor,
          ancora: AncoraMidia.topo,
          zoomPercentual: 140),
    ]);
    final midia = (await repositorio.obterTodas()).single;
    expect(midia.fundo, FundoMidia.cor);
    expect(midia.ancora, AncoraMidia.topo);
    expect(midia.zoomPercentual, 140);
  });

  test('midia nova nasce com fundo borrado, ancora central e zoom 100', () {
    const midia = MidiaPropaganda(
        id: 'a', tipo: TipoMidia.imagem, caminho: '/m/a.png', ordem: 1);
    expect(midia.fundo, FundoMidia.borrado);
    expect(midia.ancora, AncoraMidia.centro);
    expect(midia.zoomPercentual, 100);
  });
```

E **estender** o teste existente `'playlist gravada antes do campo ajuste continua carregando'` com estas linhas depois dos `expect` atuais:

```dart
    expect(midias.single.fundo, FundoMidia.borrado);
    expect(midias.single.ancora, AncoraMidia.centro);
    expect(midias.single.zoomPercentual, 100);
```

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/propaganda/repositorio_propaganda_test.dart`
Expected: FAIL (erro de compilação: `fundo` não é parâmetro de `MidiaPropaganda`)

- [ ] **Step 3: Acrescentar os campos à entidade**

Em `midia_propaganda.dart`, o factory vira:

```dart
  const factory MidiaPropaganda({
    required String id,
    required TipoMidia tipo,
    required String caminho,
    @Default(8) int duracaoSegundos,
    @Default(AjusteMidia.automatico) AjusteMidia ajuste,
    @Default(FundoMidia.borrado) FundoMidia fundo,
    @Default(AncoraMidia.centro) AncoraMidia ancora,
    @Default(100) int zoomPercentual,
    required int ordem,
    @Default(true) bool ativo,
  }) = _MidiaPropaganda;
```

- [ ] **Step 4: Espelhar no modelo**

Em `modelo_midia.dart`, o factory vira (novos campos logo após `ajuste`, seguindo o mesmo padrão de `@Default` + `@JsonKey`):

```dart
  const factory ModeloMidia({
    required String id,
    required TipoMidia tipo,
    required String caminho,
    required int duracaoSegundos,
    @Default(AjusteMidia.automatico)
    @JsonKey(unknownEnumValue: AjusteMidia.automatico)
    AjusteMidia ajuste,
    @Default(FundoMidia.borrado)
    @JsonKey(unknownEnumValue: FundoMidia.borrado)
    FundoMidia fundo,
    @Default(AncoraMidia.centro)
    @JsonKey(unknownEnumValue: AncoraMidia.centro)
    AncoraMidia ancora,
    @Default(100) int zoomPercentual,
    required int ordem,
    required bool ativo,
  }) = _ModeloMidia;
```

E os dois conversores ganham os campos:

```dart
  factory ModeloMidia.deEntidade(MidiaPropaganda entidade) => ModeloMidia(
        id: entidade.id,
        tipo: entidade.tipo,
        caminho: entidade.caminho,
        duracaoSegundos: entidade.duracaoSegundos,
        ajuste: entidade.ajuste,
        fundo: entidade.fundo,
        ancora: entidade.ancora,
        zoomPercentual: entidade.zoomPercentual,
        ordem: entidade.ordem,
        ativo: entidade.ativo,
      );

  MidiaPropaganda paraEntidade() => MidiaPropaganda(
        id: id,
        tipo: tipo,
        caminho: caminho,
        duracaoSegundos: duracaoSegundos,
        ajuste: ajuste,
        fundo: fundo,
        ancora: ancora,
        zoomPercentual: zoomPercentual,
        ordem: ordem,
        ativo: ativo,
      );
```

- [ ] **Step 5: Rodar o codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: sucesso; `git status` mostrará também `pubspec.lock` e `windows/flutter/generated_*` sujos — **não** commitá-los. Restaurar o lock:

```bash
git checkout -- pubspec.lock windows/flutter/generated_plugin_registrant.cc windows/flutter/generated_plugins.cmake
```

- [ ] **Step 6: Rodar os testes**

Run: `flutter test test/funcionalidades/propaganda/repositorio_propaganda_test.dart`
Expected: PASS (inclusive o teste legado estendido)

- [ ] **Step 7: Validar e commitar (git add explícito)**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.freezed.dart lib/funcionalidades/propaganda/dados/modelos/modelo_midia.dart lib/funcionalidades/propaganda/dados/modelos/modelo_midia.freezed.dart lib/funcionalidades/propaganda/dados/modelos/modelo_midia.g.dart test/funcionalidades/propaganda/repositorio_propaganda_test.dart
git commit -m "feat: persistir fundo, ancora e zoom de cada midia da propaganda"
git show --stat HEAD
```

Conferir no `git show --stat HEAD`: nem `pubspec.lock` nem `windows/flutter/generated_*` podem aparecer.

---

### Task 3: Player — fundo borrado, âncora e zoom

**Files:**
- Modify: `lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart`
- Test: `test/funcionalidades/propaganda/player_propaganda_test.dart`

**Interfaces:**
- Consumes: `resolverBoxFit`, `resolverAlinhamento`, `resolverEscala`, `modoDeixaSobra`, `fundoEfetivo` (Task 1); campos `fundo`/`ancora`/`zoomPercentual` (Task 2).
- Produces (contratos que os testes e o preview do diálogo usam):
  - Camada borrada com `key: ValueKey('fundo-borrado')`, presente só quando `modoDeixaSobra(ajuste)` e `fundoEfetivo(...) == FundoMidia.borrado` e a mídia está pronta.
  - Conteúdo nítido com `key: ValueKey('midia-nitida')`.
  - `Transform.scale` + `ClipRect` só quando `ajuste == preencher`.

- [ ] **Step 1: Atualizar o helper e escrever os testes que falham**

Em `test/funcionalidades/propaganda/player_propaganda_test.dart`:

Trocar `midiaCom` e `fitAplicado` por:

```dart
  MidiaPropaganda midiaCom(
    AjusteMidia ajuste,
    String caminho, {
    FundoMidia fundo = FundoMidia.borrado,
    AncoraMidia ancora = AncoraMidia.centro,
    int zoomPercentual = 100,
  }) =>
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: caminho,
          ordem: 1,
          ajuste: ajuste,
          fundo: fundo,
          ancora: ancora,
          zoomPercentual: zoomPercentual);

  BoxFit? fitAplicado(WidgetTester tester) => tester
      .widget<Image>(find.byKey(const ValueKey('midia-nitida')))
      .fit;
```

Acrescentar ao `main()`:

```dart
  testWidgets('sobra com fundo borrado ganha a camada desfocada da midia',
      (tester) async {
    await montar(tester, midiaCom(AjusteMidia.automatico, caminhoImagem),
        const Size(90, 160));
    await tester.pump();
    expect(find.byKey(const ValueKey('fundo-borrado')), findsOneWidget);
    expect(
        find.descendant(
            of: find.byKey(const ValueKey('fundo-borrado')),
            matching: find.byType(ImageFiltered)),
        findsOneWidget,
        reason: 'a camada de fundo precisa estar de fato desfocada');
  });

  testWidgets('fundo=cor mantem a tarja chapada, sem camada borrada',
      (tester) async {
    await montar(
        tester,
        midiaCom(AjusteMidia.automatico, caminhoImagem,
            fundo: FundoMidia.cor),
        const Size(90, 160));
    await tester.pump();
    expect(find.byKey(const ValueKey('fundo-borrado')), findsNothing);
  });

  testWidgets('preencher nao tem sobra: sem camada borrada mesmo com '
      'fundo=borrado', (tester) async {
    await montar(tester, midiaCom(AjusteMidia.preencher, caminhoImagem),
        const Size(90, 160));
    await tester.pump();
    expect(find.byKey(const ValueKey('fundo-borrado')), findsNothing);
  });

  testWidgets('preencher aplica ancora e zoom; demais modos nao escalam',
      (tester) async {
    await montar(
        tester,
        midiaCom(AjusteMidia.preencher, caminhoImagem,
            ancora: AncoraMidia.topo, zoomPercentual: 140),
        const Size(90, 160));
    await tester.pump();
    final imagem =
        tester.widget<Image>(find.byKey(const ValueKey('midia-nitida')));
    expect(imagem.alignment, Alignment.topCenter,
        reason: 'a ancora diz qual parte da midia sobrevive ao corte');
    final transformes = tester.widgetList<Transform>(find.descendant(
        of: find.byType(PlayerPropaganda), matching: find.byType(Transform)));
    expect(transformes, hasLength(1));
    expect(transformes.single.transform.getMaxScaleOnAxis(),
        closeTo(1.4, 0.001));
    expect(transformes.single.alignment, Alignment.topCenter,
        reason: 'o zoom amplia a partir da ancora, nao do centro');

    await montar(tester, midiaCom(AjusteMidia.automatico, caminhoImagem),
        const Size(90, 160));
    await tester.pump();
    expect(
        find.descendant(
            of: find.byType(PlayerPropaganda),
            matching: find.byType(Transform)),
        findsNothing,
        reason: 'zoom so existe no preencher');
  });
```

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/propaganda/player_propaganda_test.dart`
Expected: FAIL (`ValueKey('midia-nitida')` não encontrado)

- [ ] **Step 3: Implementar as camadas no player**

Em `player_propaganda.dart`:

Acrescentar o import no topo (junto dos demais):

```dart
import 'dart:ui' as ui;
```

Acrescentar as constantes acima da classe `PlayerPropaganda`:

```dart
/// Sigma suficiente para descaracterizar a borda sem custo excessivo.
const double _sigmaFundoBorrado = 24;

/// O fundo do video e pintado reduzido por este fator e ampliado de volta:
/// o blur roda numa textura 16x menor, cortando o custo por frame.
const double _reducaoFundoVideo = 4;
```

No `_PlayerPropagandaState`, acrescentar o getter e os dois métodos:

```dart
  bool get _mostraFundoBorrado {
    if (!modoDeixaSobra(widget.midia.ajuste)) return false;
    final fundo =
        fundoEfetivo(tipo: widget.midia.tipo, fundo: widget.midia.fundo);
    if (fundo != FundoMidia.borrado) return false;
    // Sem midia pronta nao ha o que borrar: fica na cor de fundo.
    if (widget.midia.tipo == TipoMidia.imagem) {
      return File(widget.midia.caminho).existsSync();
    }
    return _video?.value.isInitialized ?? false;
  }

  Widget _fundoBorrado() {
    if (widget.midia.tipo == TipoMidia.imagem) {
      // Estatico: o RepaintBoundary rasteriza o blur uma vez e reaproveita.
      return RepaintBoundary(
        key: const ValueKey('fundo-borrado'),
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
              sigmaX: _sigmaFundoBorrado,
              sigmaY: _sigmaFundoBorrado,
              tileMode: ui.TileMode.clamp),
          child: Image.file(File(widget.midia.caminho),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity),
        ),
      );
    }
    final video = _video!;
    // Mesma textura do video nitido (nenhum segundo decoder): a copia e
    // pintada reduzida, borrada em baixa resolucao e ampliada de volta.
    return LayoutBuilder(
      key: const ValueKey('fundo-borrado'),
      builder: (context, restricoes) {
        final caixa = restricoes.biggest;
        return ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Transform.scale(
              scale: _reducaoFundoVideo,
              child: SizedBox(
                width: caixa.width / _reducaoFundoVideo,
                height: caixa.height / _reducaoFundoVideo,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                      sigmaX: _sigmaFundoBorrado / _reducaoFundoVideo,
                      sigmaY: _sigmaFundoBorrado / _reducaoFundoVideo,
                      tileMode: ui.TileMode.clamp),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: video.value.size.width,
                      height: video.value.size.height,
                      child: VideoPlayer(video),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
```

Substituir `_conteudo` e `build` por:

```dart
  Widget _conteudo() {
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) return const SizedBox.expand();
    final ajuste = widget.midia.ajuste;
    final fit = resolverBoxFit(ajuste);
    final alinhamento = ajuste == AjusteMidia.preencher
        ? resolverAlinhamento(widget.midia.ancora)
        : Alignment.center;
    final Widget conteudo;
    if (widget.midia.tipo == TipoMidia.imagem) {
      conteudo = Image.file(arquivo,
          key: const ValueKey('midia-nitida'),
          fit: fit,
          alignment: alinhamento,
          width: double.infinity,
          height: double.infinity);
    } else {
      final video = _video;
      if (video == null || !video.value.isInitialized) {
        return const SizedBox.expand();
      }
      conteudo = FittedBox(
        key: const ValueKey('midia-nitida'),
        fit: fit,
        alignment: alinhamento,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: video.value.size.width,
          height: video.value.size.height,
          child: VideoPlayer(video),
        ),
      );
    }
    if (ajuste != AjusteMidia.preencher) return conteudo;
    // Zoom so existe no preencher: amplia a partir da ancora e corta a sobra.
    return ClipRect(
      child: Transform.scale(
        scale: resolverEscala(widget.midia.zoomPercentual),
        alignment: alinhamento,
        child: conteudo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.corFundo,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_mostraFundoBorrado) _fundoBorrado(),
          _conteudo(),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar os testes**

Run: `flutter test test/funcionalidades/propaganda/`
Expected: PASS. Atenção: se algum teste antigo quebrar por achar dois `Image`, é porque ainda usa `find.byType(Image)` — trocar pelo `find.byKey(const ValueKey('midia-nitida'))`.

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart test/funcionalidades/propaganda/player_propaganda_test.dart
git commit -m "feat: fundo borrado da sobra e ancora com zoom no preencher"
```

---

### Task 4: `definirEnquadramento` no controlador

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_midias.dart`
- Test: `test/funcionalidades/configuracoes/controlador_midias_test.dart`

**Interfaces:**
- Consumes: campos novos de `MidiaPropaganda` (Task 2).
- Produces: `Future<void> definirEnquadramento(String id, {required AjusteMidia ajuste, required FundoMidia fundo, required AncoraMidia ancora, required int zoomPercentual})`. O `definirAjuste` existente **fica** até a Task 6 (a aba ainda o chama); some lá.

- [ ] **Step 1: Escrever o teste que falha**

Acrescentar ao `main()` de `controlador_midias_test.dart`:

```dart
  test('definirEnquadramento persiste modo, fundo, ancora e zoom', () async {
    await controlador.adicionarArquivos(['/m/a.png']);
    final id = controlador.state.midias.single.id;
    await controlador.definirEnquadramento(id,
        ajuste: AjusteMidia.preencher,
        fundo: FundoMidia.cor,
        ancora: AncoraMidia.baseDireita,
        zoomPercentual: 180);
    final midia = controlador.state.midias.single;
    expect(midia.ajuste, AjusteMidia.preencher);
    expect(midia.fundo, FundoMidia.cor);
    expect(midia.ancora, AncoraMidia.baseDireita);
    expect(midia.zoomPercentual, 180);
    final salva = (await repositorio.obterTodas()).single;
    expect(salva.ajuste, AjusteMidia.preencher);
    expect(salva.fundo, FundoMidia.cor);
    expect(salva.ancora, AncoraMidia.baseDireita);
    expect(salva.zoomPercentual, 180);
  });
```

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/controlador_midias_test.dart`
Expected: FAIL (método não existe)

- [ ] **Step 3: Implementar**

Em `controlador_midias.dart`, logo abaixo de `definirAjuste`:

```dart
  /// Persiste o enquadramento completo escolhido no dialogo Ajustar.
  Future<void> definirEnquadramento(
    String id, {
    required AjusteMidia ajuste,
    required FundoMidia fundo,
    required AncoraMidia ancora,
    required int zoomPercentual,
  }) async {
    await _persistir([
      for (final midia in state.midias)
        midia.id == id
            ? midia.copyWith(
                ajuste: ajuste,
                fundo: fundo,
                ancora: ancora,
                zoomPercentual: zoomPercentual)
            : midia,
    ]);
  }
```

- [ ] **Step 4: Rodar os testes**

Run: `flutter test test/funcionalidades/configuracoes/controlador_midias_test.dart`
Expected: PASS

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_midias.dart test/funcionalidades/configuracoes/controlador_midias_test.dart
git commit -m "feat: definirEnquadramento persiste o ajuste completo da midia"
```

---

### Task 5: Diálogo "Ajustar mídia" com preview ao vivo

**Files:**
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart`
- Test: `test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart`

**Interfaces:**
- Consumes: `PlayerPropaganda` (preview), `SeletorAjusteMidia` (dropdown de modo), funções puras da Task 1, `MidiaPropaganda.copyWith`.
- Produces:
  - `class DialogoAjusteMidia extends StatefulWidget` com `{required MidiaPropaganda midia, required Color corTema, required void Function({required AjusteMidia ajuste, required FundoMidia fundo, required AncoraMidia ancora, required int zoomPercentual}) aoSalvar}`. Estado local; só "Salvar" chama `aoSalvar` (e fecha); "Cancelar" só fecha.
  - `static const Map<AncoraMidia, String> DialogoAjusteMidia.rotulosAncora`.
  - `String resumoEnquadramento(MidiaPropaganda midia)` (função top-level no mesmo arquivo; a Task 6 usa no card).
  - Células da grade de âncora com `key: ValueKey('ancora-<nome>')` (ex.: `ancora-topo`).

- [ ] **Step 1: Escrever os testes que falham**

Criar `test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/seletor_ajuste_midia.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef EnquadramentoSalvo = ({
  AjusteMidia ajuste,
  FundoMidia fundo,
  AncoraMidia ancora,
  int zoomPercentual,
});

void main() {
  const midiaImagem = MidiaPropaganda(
      id: 'a', tipo: TipoMidia.imagem, caminho: '/m/inexistente.png', ordem: 1);
  const midiaVideo = MidiaPropaganda(
      id: 'v', tipo: TipoMidia.video, caminho: '/m/inexistente.mp4', ordem: 1);

  Future<void> abrir(
    WidgetTester tester,
    MidiaPropaganda midia, {
    void Function(EnquadramentoSalvo salvo)? aoSalvar,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => DialogoAjusteMidia(
                  midia: midia,
                  corTema: const Color(0xFF5E52D6),
                  aoSalvar: ({
                    required AjusteMidia ajuste,
                    required FundoMidia fundo,
                    required AncoraMidia ancora,
                    required int zoomPercentual,
                  }) =>
                      aoSalvar?.call((
                    ajuste: ajuste,
                    fundo: fundo,
                    ancora: ancora,
                    zoomPercentual: zoomPercentual,
                  )),
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  /// A midia inexistente agenda o temporizador de 1s do player; drena antes
  /// do fim do teste.
  Future<void> drenar(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 2));

  Future<void> escolherModo(WidgetTester tester, String rotulo) async {
    await tester.tap(find.byType(DropdownButton<AjusteMidia>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(rotulo).last);
    await tester.pumpAndSettle();
  }

  testWidgets('preview usa o mesmo player da tela real', (tester) async {
    await abrir(tester, midiaImagem);
    expect(find.byType(PlayerPropaganda), findsOneWidget);
    await drenar(tester);
  });

  testWidgets('cancelar fecha sem salvar', (tester) async {
    EnquadramentoSalvo? salvo;
    await abrir(tester, midiaImagem, aoSalvar: (s) => salvo = s);
    await escolherModo(tester, 'Preencher (corta)');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(salvo, isNull);
    expect(find.byType(DialogoAjusteMidia), findsNothing);
    await drenar(tester);
  });

  testWidgets('salvar devolve o enquadramento editado', (tester) async {
    EnquadramentoSalvo? salvo;
    await abrir(tester, midiaImagem, aoSalvar: (s) => salvo = s);
    await escolherModo(tester, 'Preencher (corta)');
    await tester.tap(find.byKey(const ValueKey('ancora-topo')));
    await tester.pump();
    // Arrasta o slider ate a ponta direita: zoom maximo, deterministico.
    await tester.drag(find.byType(Slider), const Offset(400, 0));
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(salvo, isNotNull);
    expect(salvo!.ajuste, AjusteMidia.preencher);
    expect(salvo!.ancora, AncoraMidia.topo);
    expect(salvo!.zoomPercentual, zoomMaximo);
    expect(find.byType(DialogoAjusteMidia), findsNothing);
    await drenar(tester);
  });

  testWidgets('controles de corte so aparecem no preencher; fundo so onde '
      'ha sobra', (tester) async {
    await abrir(tester, midiaImagem);
    // automatico: fundo sim, corte nao.
    expect(find.byType(SegmentedButton<FundoMidia>), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
    expect(find.byKey(const ValueKey('ancora-topo')), findsNothing);

    await escolherModo(tester, 'Preencher (corta)');
    expect(find.byType(SegmentedButton<FundoMidia>), findsNothing);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byKey(const ValueKey('ancora-topo')), findsOneWidget);
    await drenar(tester);
  });

  testWidgets('video nao oferece fundo enquanto o gate nao libera',
      (tester) async {
    await abrir(tester, midiaVideo);
    expect(find.byType(SegmentedButton<FundoMidia>), findsNothing);
    await drenar(tester);
  });

  test('toda ancora tem rotulo em pt-BR', () {
    for (final ancora in AncoraMidia.values) {
      expect(DialogoAjusteMidia.rotulosAncora[ancora], isNotNull,
          reason: 'sem rotulo para $ancora');
    }
  });

  test('resumo do enquadramento por modo', () {
    expect(resumoEnquadramento(midiaImagem), 'Automático · fundo borrado');
    expect(
        resumoEnquadramento(
            midiaImagem.copyWith(fundo: FundoMidia.cor)),
        'Automático · fundo na cor do tema');
    expect(resumoEnquadramento(midiaVideo), 'Automático · fundo na cor do tema',
        reason: 'video segue o gate: o resumo nao pode prometer blur');
    expect(
        resumoEnquadramento(midiaImagem.copyWith(
            ajuste: AjusteMidia.preencher,
            ancora: AncoraMidia.topo,
            zoomPercentual: 140)),
        'Preencher (corta) · topo · 140%');
    expect(resumoEnquadramento(midiaImagem.copyWith(ajuste: AjusteMidia.esticar)),
        'Esticar (distorce)');
  });
}
```

O import de `ajuste_tela.dart` é necessário no teste por causa de `zoomMaximo`:

```dart
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/ajuste_tela.dart';
```

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart`
Expected: FAIL (arquivo `dialogo_ajuste_midia.dart` não existe)

- [ ] **Step 3: Implementar o diálogo**

Criar `lib/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../propaganda/apresentacao/ajuste_tela.dart';
import '../../../propaganda/apresentacao/componentes/player_propaganda.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';
import 'seletor_ajuste_midia.dart';

/// Resumo curto do enquadramento, exibido no card da midia.
String resumoEnquadramento(MidiaPropaganda midia) {
  final modo = SeletorAjusteMidia.rotulos[midia.ajuste] ?? '';
  switch (midia.ajuste) {
    case AjusteMidia.automatico:
    case AjusteMidia.encaixar:
      final fundo = fundoEfetivo(tipo: midia.tipo, fundo: midia.fundo);
      final rotuloFundo =
          fundo == FundoMidia.borrado ? 'borrado' : 'na cor do tema';
      return '$modo · fundo $rotuloFundo';
    case AjusteMidia.preencher:
      final ancora =
          DialogoAjusteMidia.rotulosAncora[midia.ancora]!.toLowerCase();
      final zoom = midia.zoomPercentual.clamp(zoomMinimo, zoomMaximo);
      return '$modo · $ancora · $zoom%';
    case AjusteMidia.esticar:
      return modo;
  }
}

class DialogoAjusteMidia extends StatefulWidget {
  const DialogoAjusteMidia({
    super.key,
    required this.midia,
    required this.corTema,
    required this.aoSalvar,
  });

  final MidiaPropaganda midia;

  /// Cor primaria do tema da loja: o preview pinta o mesmo fundo do totem.
  final Color corTema;

  final void Function({
    required AjusteMidia ajuste,
    required FundoMidia fundo,
    required AncoraMidia ancora,
    required int zoomPercentual,
  }) aoSalvar;

  static const Map<AncoraMidia, String> rotulosAncora = {
    AncoraMidia.topoEsquerda: 'Topo à esquerda',
    AncoraMidia.topo: 'Topo',
    AncoraMidia.topoDireita: 'Topo à direita',
    AncoraMidia.esquerda: 'Esquerda',
    AncoraMidia.centro: 'Centro',
    AncoraMidia.direita: 'Direita',
    AncoraMidia.baseEsquerda: 'Base à esquerda',
    AncoraMidia.base: 'Base',
    AncoraMidia.baseDireita: 'Base à direita',
  };

  @override
  State<DialogoAjusteMidia> createState() => _DialogoAjusteMidiaState();
}

class _DialogoAjusteMidiaState extends State<DialogoAjusteMidia> {
  late AjusteMidia _ajuste = widget.midia.ajuste;
  late FundoMidia _fundo = widget.midia.fundo;
  late AncoraMidia _ancora = widget.midia.ancora;
  late int _zoom =
      widget.midia.zoomPercentual.clamp(zoomMinimo, zoomMaximo);

  bool get _mostraFundo =>
      modoDeixaSobra(_ajuste) &&
      (widget.midia.tipo != TipoMidia.video || fundoBorradoLiberadoParaVideo);

  bool get _mostraCorte => _ajuste == AjusteMidia.preencher;

  /// O id nao muda, entao o player nao reinicia a midia a cada tecla: so
  /// re-renderiza com o enquadramento novo.
  MidiaPropaganda get _midiaPreview => widget.midia.copyWith(
      ajuste: _ajuste, fundo: _fundo, ancora: _ancora, zoomPercentual: _zoom);

  Widget _rotulo(String texto) => Text(texto,
      style:
          const TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario));

  Widget _gradeAncoras() {
    const linhas = [
      [AncoraMidia.topoEsquerda, AncoraMidia.topo, AncoraMidia.topoDireita],
      [AncoraMidia.esquerda, AncoraMidia.centro, AncoraMidia.direita],
      [AncoraMidia.baseEsquerda, AncoraMidia.base, AncoraMidia.baseDireita],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final linha in linhas)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final ancora in linha)
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Tooltip(
                    message: DialogoAjusteMidia.rotulosAncora[ancora]!,
                    child: InkWell(
                      key: ValueKey('ancora-${ancora.name}'),
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _ancora = ancora),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              _ancora == ancora ? CoresApp.lilasClaro : null,
                          border: Border.all(
                            color: _ancora == ancora
                                ? CoresApp.primariaPadrao
                                : CoresApp.bordaCard,
                            width: _ancora == ancora ? 2 : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Ajustar mídia',
          style: TextStyle(fontWeight: FontWeight.w800)),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: 220,
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      // Mesmo player da tela real: o que aparece aqui e o que
                      // o totem vai pintar.
                      child: PlayerPropaganda(
                        midia: _midiaPreview,
                        corFundo: widget.corTema,
                        aoTerminar: () {},
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SeletorAjusteMidia(
                valor: _ajuste,
                aoMudar: (ajuste) => setState(() => _ajuste = ajuste),
              ),
              if (_mostraFundo) ...[
                const SizedBox(height: 10),
                _rotulo('Fundo da sobra'),
                const SizedBox(height: 6),
                SegmentedButton<FundoMidia>(
                  segments: const [
                    ButtonSegment(
                        value: FundoMidia.borrado, label: Text('Borrado')),
                    ButtonSegment(
                        value: FundoMidia.cor, label: Text('Cor do tema')),
                  ],
                  selected: {_fundo},
                  onSelectionChanged: (selecao) =>
                      setState(() => _fundo = selecao.single),
                ),
              ],
              if (_mostraCorte) ...[
                const SizedBox(height: 10),
                _rotulo('Corte a partir de'),
                const SizedBox(height: 6),
                Center(child: _gradeAncoras()),
                const SizedBox(height: 10),
                _rotulo('Zoom: $_zoom%'),
                Slider(
                  value: _zoom.toDouble(),
                  min: zoomMinimo.toDouble(),
                  max: zoomMaximo.toDouble(),
                  divisions: (zoomMaximo - zoomMinimo) ~/ 5,
                  label: '$_zoom%',
                  onChanged: (valor) => setState(() => _zoom = valor.round()),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            widget.aoSalvar(
                ajuste: _ajuste,
                fundo: _fundo,
                ancora: _ancora,
                zoomPercentual: _zoom);
            Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Rodar os testes**

Run: `flutter test test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart`
Expected: PASS

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart
git commit -m "feat: dialogo Ajustar midia com preview ao vivo do enquadramento"
```

---

### Task 6: Card da aba Propaganda — resumo + "Ajustar…", texto de ajuda novo

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_midias.dart` (remove `definirAjuste`, agora sem chamador)
- Test: `test/funcionalidades/configuracoes/aba_propaganda_test.dart`
- Test: `test/funcionalidades/configuracoes/controlador_midias_test.dart` (remove o teste de `definirAjuste`)

**Interfaces:**
- Consumes: `DialogoAjusteMidia`, `resumoEnquadramento` (Task 5), `definirEnquadramento` (Task 4), `provedorTema` (`aplicativo/injecao.dart`), `TemaConstel.corDeHex` (`aplicativo/tema/tema_constel.dart`).
- Produces: card sem dropdown, com resumo textual + `TextButton` "Ajustar…". `SeletorAjusteMidia` continua existindo (vive dentro do diálogo).

- [ ] **Step 1: Atualizar os testes (falharão)**

Em `test/funcionalidades/configuracoes/aba_propaganda_test.dart`:

No teste `'card de midia com Duracao e Ajuste nao estoura em janela estreita'`, trocar:

```dart
    expect(find.byType(SeletorAjusteMidia), findsOneWidget,
        reason: 'o card precisa renderizar de fato para o teste provar algo '
            'sobre overflow');
```

por:

```dart
    expect(find.text('Ajustar…'), findsOneWidget,
        reason: 'o card precisa renderizar de fato para o teste provar algo '
            'sobre overflow');
```

E acrescentar ao `main()`:

```dart
  testWidgets('card mostra o resumo do enquadramento e abre o dialogo',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioPropagandaImpl(preferencias);
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
        id: 'a',
        tipo: TipoMidia.imagem,
        caminho: '/midias/oferta.png',
        ordem: 1,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: AbaPropaganda())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Automático · fundo borrado'), findsOneWidget);
    expect(find.byType(DropdownButton<AjusteMidia>), findsNothing,
        reason: 'o dropdown saiu do card e mora no dialogo');

    await tester.tap(find.text('Ajustar…'));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoAjusteMidia), findsOneWidget);

    // Fecha e drena o temporizador de 1s do preview (midia inexistente).
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
  });
```

Imports novos no teste:

```dart
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart';
```

(O import de `seletor_ajuste_midia.dart` continua: os testes do seletor permanecem válidos, o widget agora vive no diálogo.)

Em `test/funcionalidades/configuracoes/controlador_midias_test.dart`, **remover** o teste `'definirAjuste atualiza o estado e persiste'` (o método some; `definirEnquadramento` já está coberto).

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/aba_propaganda_test.dart`
Expected: FAIL (`'Ajustar…'` não existe; resumo não existe)

- [ ] **Step 3: Reescrever o card e o texto de ajuda**

Em `aba_propaganda.dart`:

Trocar o import de `seletor_ajuste_midia.dart` por:

```dart
import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import 'dialogo_ajuste_midia.dart';
```

(Manter os demais imports; `injecao.dart` pode já estar importado — não duplicar.)

Acrescentar o método na classe `AbaPropaganda`:

```dart
  void _abrirAjuste(
      BuildContext context, WidgetRef ref, MidiaPropaganda midia) {
    final tema = ref.read(provedorTema);
    final corTema = TemaConstel.corDeHex(
        tema.corPrimaria, Theme.of(context).colorScheme.primary);
    final controlador = ref.read(provedorMidias.notifier);
    showDialog<void>(
      context: context,
      builder: (_) => DialogoAjusteMidia(
        midia: midia,
        corTema: corTema,
        aoSalvar: ({
          required AjusteMidia ajuste,
          required FundoMidia fundo,
          required AncoraMidia ancora,
          required int zoomPercentual,
        }) =>
            controlador.definirEnquadramento(midia.id,
                ajuste: ajuste,
                fundo: fundo,
                ancora: ancora,
                zoomPercentual: zoomPercentual),
      ),
    );
  }
```

No `_cardMidia`, substituir o filho `SeletorAjusteMidia(...)` do `Wrap` por:

```dart
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(resumoEnquadramento(midia),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  color: CoresApp.textoSecundario)),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8)),
                          onPressed: () => _abrirAjuste(context, ref, midia),
                          child: const Text('Ajustar…',
                              style: TextStyle(fontSize: 11.5)),
                        ),
                      ],
                    ),
```

Substituir o texto de ajuda no topo do `build` (o atual afirma que o Automático "preenche quando o formato é parecido" — virou mentira):

```dart
        const Text(
          'Ideal: mídia em pé (retrato), 1080 x 1920 px. Vídeos em MP4 com '
          'codec H.264, 30 fps e no máximo 6 Mbps. GIF é aceito e roda em '
          'loop até a duração acabar. No ajuste Automático a mídia aparece '
          'inteira, sem corte: a sobra vira um fundo borrado da própria '
          'imagem (vídeos usam a cor primária do tema). Toque em "Ajustar…" '
          'para trocar o modo, o fundo da sobra, o corte e o zoom.',
          style: TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
        ),
```

Em `controlador_midias.dart`, **remover** o método `definirAjuste` inteiro (ficou sem chamador; `definirEnquadramento` o substitui).

- [ ] **Step 4: Rodar os testes**

Run: `flutter test test/funcionalidades/configuracoes/`
Expected: PASS (inclusive o teste de 480px, agora com o card folgado)

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_midias.dart test/funcionalidades/configuracoes/aba_propaganda_test.dart test/funcionalidades/configuracoes/controlador_midias_test.dart
git commit -m "feat: card da midia resume o enquadramento e abre o dialogo Ajustar"
```

---

### Task 7: Validação final e gate de performance do vídeo

**Files:** nenhum código novo; medição e relatório.

- [ ] **Step 1: Suíte completa**

```bash
dart format .
flutter analyze
flutter test
```

Expected: 0 issues, todos os testes passando.

- [ ] **Step 2: Revisão adversarial do CLAUDE.md**

Percorrer o checklist (tela não pedida? overflow? URL hardcoded? estado sem tratamento? arquivo >600 linhas? — atenção ao `player_propaganda.dart` e ao `dialogo_ajuste_midia.dart`).

- [ ] **Step 3: Gate de medição do vídeo (manual — precisa do totem)**

O fundo borrado de vídeo está **desligado** (`fundoBorradoLiberadoParaVideo = false` em `ajuste_tela.dart`): vídeo cai na cor do tema e a UI esconde a opção. Para liberar:

1. Flipar a constante para `true` numa cópia local.
2. `flutter run --profile` no hardware do totem, com um vídeo 1080p na playlist em modo automático.
3. Comparar o custo de frame (DevTools → Performance) contra o baseline com `FundoMidia.cor`.
4. **60fps sem frames perdidos** → commitar o flip + atualizar o teste `'video cai para cor enquanto o gate do fundo borrado nao libera'` + registrar os números no relatório.
5. Caso contrário → constante fica `false`; registrar os números. A UI já esconde a opção, nada mais a fazer.

Sem acesso ao hardware nesta sessão: a constante fica `false` (vídeo com fundo em cor sólida — comportamento atual preservado) e a medição fica registrada como pendência real no relatório.

- [ ] **Step 4: Relatório final**

Listar arquivos alterados, comandos executados e resultados, pendências (medição do vídeo) e riscos, no formato do CLAUDE.md.
