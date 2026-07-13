# Ajuste de tela da propaganda — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cada mídia da propaganda ganha um modo de ajuste de tela escolhido pelo operador (com padrão automático que acerta sozinho), e GIF passa a ser uma mídia aceita.

**Architecture:** Um enum `AjusteMidia` persistido junto de cada mídia; uma função pura `resolverBoxFit` que traduz o modo (mais as razões de aspecto da mídia e da tela) num `BoxFit`; o `PlayerPropaganda` mede a mídia, consulta a função e pinta a cor primária do tema atrás dela. A UI ganha um dropdown por mídia na aba Propaganda.

**Tech Stack:** Flutter, Riverpod (`StateNotifier`), Freezed + json_serializable, `SharedPreferences`, `video_player`.

Spec: `docs/superpowers/specs/2026-07-13-ajuste-tela-propaganda-design.md`

## Global Constraints

- Idioma de toda string visível ao usuário: **pt-BR**.
- Pastas e nomes de código em pt-BR. Não criar pastas em inglês (`core`, `features`, `shared`).
- Nenhum arquivo de código acima de **600 linhas**.
- Comentário só quando explicar regra não óbvia. Sem código morto, sem import não usado, sem `print`, sem TODO.
- Estado simples via o padrão já adotado (`StateNotifier` do Riverpod). Não introduzir BLoC.
- Nenhuma dependência nova no `pubspec.yaml`. GIF é animado nativamente pelo `Image.file`.
- Após alterar código gerado por Freezed, rodar: `dart run build_runner build --delete-conflicting-outputs`
- Validação ao fim de cada tarefa: `dart format .`, `flutter analyze`, `flutter test`.
- **O campo `ajuste` NUNCA pode ser `required` em `ModeloMidia`.** As playlists já gravadas no `SharedPreferences` não têm essa chave; um campo obrigatório faria o `fromJson` lançar, o `catch` em `repositorio_propaganda_impl.dart:26` engoliria a exceção e devolveria `const []`, apagando a playlist da loja sem aviso.

---

### Task 1: Enum `AjusteMidia` e a função `resolverBoxFit`

A regra de decisão isolada numa função pura, sem widget e sem estado, para ser testada direto.

**Files:**
- Modify: `lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart` (só acrescenta o enum; não mexe no `@freezed`, então **não** precisa de codegen nesta tarefa)
- Create: `lib/funcionalidades/propaganda/apresentacao/ajuste_tela.dart`
- Test: `test/funcionalidades/propaganda/ajuste_tela_test.dart`

**Interfaces:**
- Consumes: nada.
- Produces:
  - `enum AjusteMidia { automatico, preencher, encaixar, esticar }` em `midia_propaganda.dart`
  - `const double aproveitamentoMinimoParaPreencher = 0.75;`
  - `BoxFit resolverBoxFit({required AjusteMidia ajuste, required double? razaoMidia, required double razaoTela})`

- [ ] **Step 1: Acrescentar o enum à entidade**

Em `lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart`, logo abaixo do `enum TipoMidia`:

```dart
enum TipoMidia { imagem, video }

/// Como a midia se acomoda na tela da propaganda.
enum AjusteMidia { automatico, preencher, encaixar, esticar }
```

- [ ] **Step 2: Escrever o teste que falha**

Criar `test/funcionalidades/propaganda/ajuste_tela_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/ajuste_tela.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Tela do totem em pe: 9:16 = 0,5625.
  const razaoRetrato = 9 / 16;

  BoxFit fit(AjusteMidia ajuste, double? razaoMidia,
          [double razaoTela = razaoRetrato]) =>
      resolverBoxFit(
          ajuste: ajuste, razaoMidia: razaoMidia, razaoTela: razaoTela);

  test('modos explicitos ignoram as razoes', () {
    expect(fit(AjusteMidia.preencher, 16 / 9), BoxFit.cover);
    expect(fit(AjusteMidia.encaixar, 9 / 16), BoxFit.contain);
    expect(fit(AjusteMidia.esticar, 16 / 9), BoxFit.fill);
    expect(fit(AjusteMidia.preencher, null), BoxFit.cover);
  });

  test('automatico preenche quando a midia acompanha a tela', () {
    expect(fit(AjusteMidia.automatico, 9 / 16), BoxFit.cover); // 1,00
    expect(fit(AjusteMidia.automatico, 3 / 4), BoxFit.cover); // 0,75: no limite
  });

  test('automatico encaixa quando o corte destruiria a midia', () {
    expect(fit(AjusteMidia.automatico, 1), BoxFit.contain); // 0,56
    expect(fit(AjusteMidia.automatico, 16 / 9), BoxFit.contain); // 0,32
  });

  test('automatico tambem decide com a tela deitada', () {
    const razaoPaisagem = 16 / 9;
    expect(fit(AjusteMidia.automatico, 16 / 9, razaoPaisagem), BoxFit.cover);
    expect(fit(AjusteMidia.automatico, 9 / 16, razaoPaisagem), BoxFit.contain);
  });

  test('automatico nao corta o que ainda nao mediu', () {
    expect(fit(AjusteMidia.automatico, null), BoxFit.contain);
  });

  test('automatico trata razao invalida como desconhecida', () {
    expect(fit(AjusteMidia.automatico, 0), BoxFit.contain);
    expect(fit(AjusteMidia.automatico, -1), BoxFit.contain);
    expect(fit(AjusteMidia.automatico, double.nan), BoxFit.contain);
    expect(fit(AjusteMidia.automatico, 9 / 16, 0), BoxFit.contain);
  });
}
```

- [ ] **Step 3: Rodar o teste e confirmar que falha**

```bash
flutter test test/funcionalidades/propaganda/ajuste_tela_test.dart
```

Esperado: falha de compilação, `Error: Couldn't resolve the package 'constel_pay/funcionalidades/propaganda/apresentacao/ajuste_tela.dart'` ou `resolverBoxFit isn't defined`.

- [ ] **Step 4: Implementar**

Criar `lib/funcionalidades/propaganda/apresentacao/ajuste_tela.dart`:

```dart
import 'package:flutter/painting.dart';

import '../dominio/entidades/midia_propaganda.dart';

/// Fracao minima da midia que precisa sobreviver ao corte do `cover` para que o
/// modo automatico prefira preencher a tela em vez de encaixar com tarjas.
const double aproveitamentoMinimoParaPreencher = 0.75;

/// Traduz o modo escolhido pelo operador no `BoxFit` que o player aplica.
///
/// [razaoMidia] e nulo enquanto as dimensoes da midia nao foram medidas (video
/// inicializando, imagem decodificando). Nesse caso o modo automatico nunca
/// corta: so decide preencher depois de saber o que estaria cortando.
BoxFit resolverBoxFit({
  required AjusteMidia ajuste,
  required double? razaoMidia,
  required double razaoTela,
}) {
  switch (ajuste) {
    case AjusteMidia.preencher:
      return BoxFit.cover;
    case AjusteMidia.encaixar:
      return BoxFit.contain;
    case AjusteMidia.esticar:
      return BoxFit.fill;
    case AjusteMidia.automatico:
      if (razaoMidia == null ||
          !razaoMidia.isFinite ||
          razaoMidia <= 0 ||
          !razaoTela.isFinite ||
          razaoTela <= 0) {
        return BoxFit.contain;
      }
      final maior = razaoMidia > razaoTela ? razaoMidia : razaoTela;
      final menor = razaoMidia > razaoTela ? razaoTela : razaoMidia;
      return menor / maior >= aproveitamentoMinimoParaPreencher
          ? BoxFit.cover
          : BoxFit.contain;
  }
}
```

- [ ] **Step 5: Rodar o teste e confirmar que passa**

```bash
flutter test test/funcionalidades/propaganda/ajuste_tela_test.dart
```

Esperado: `All tests passed!` (6 testes).

- [ ] **Step 6: Validar e commitar**

```bash
dart format .
flutter analyze
git add lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart lib/funcionalidades/propaganda/apresentacao/ajuste_tela.dart test/funcionalidades/propaganda/ajuste_tela_test.dart
git commit -m "feat: regra de ajuste de tela da midia de propaganda"
```

---

### Task 2: Persistir o campo `ajuste`

O campo entra na entidade e no modelo. É aqui que mora o risco de apagar a playlist da loja.

**Files:**
- Modify: `lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart`
- Modify: `lib/funcionalidades/propaganda/dados/modelos/modelo_midia.dart`
- Test: `test/funcionalidades/propaganda/repositorio_propaganda_test.dart`

**Interfaces:**
- Consumes: `AjusteMidia` (Task 1).
- Produces: `MidiaPropaganda.ajuste` (`AjusteMidia`, padrão `AjusteMidia.automatico`), disponível via `copyWith(ajuste: ...)`.

- [ ] **Step 1: Escrever os testes que falham**

Acrescentar ao fim do `main()` de `test/funcionalidades/propaganda/repositorio_propaganda_test.dart` (manter os três testes que já existem):

```dart
  test('o ajuste escolhido sobrevive ao round-trip', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio =
        RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.video,
          caminho: '/m/a.mp4',
          ordem: 1,
          ajuste: AjusteMidia.encaixar),
    ]);
    expect((await repositorio.obterTodas()).single.ajuste, AjusteMidia.encaixar);
  });

  test('midia nova nasce com ajuste automatico', () {
    const midia =
        MidiaPropaganda(id: 'a', tipo: TipoMidia.imagem, caminho: '/m/a.png', ordem: 1);
    expect(midia.ajuste, AjusteMidia.automatico);
  });

  test('playlist gravada antes do campo ajuste continua carregando', () async {
    // Se `ajuste` virar um campo obrigatorio do ModeloMidia, o fromJson lanca
    // aqui, o catch do repositorio engole o erro e devolve lista vazia: a
    // playlist da loja sumiria sem aviso nenhum na atualizacao.
    SharedPreferences.setMockInitialValues({
      'midias_propaganda': '[{"id":"a","tipo":"imagem","caminho":"/m/a.png",'
          '"duracaoSegundos":8,"ordem":1,"ativo":true}]',
    });
    final repositorio =
        RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    final midias = await repositorio.obterTodas();
    expect(midias, hasLength(1), reason: 'a playlist antiga nao pode ser perdida');
    expect(midias.single.ajuste, AjusteMidia.automatico);
  });
```

- [ ] **Step 2: Rodar e confirmar que falha**

```bash
flutter test test/funcionalidades/propaganda/repositorio_propaganda_test.dart
```

Esperado: falha de compilação, `No named parameter with the name 'ajuste'`.

- [ ] **Step 3: Acrescentar o campo à entidade**

Em `lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart`:

```dart
@freezed
class MidiaPropaganda with _$MidiaPropaganda {
  const factory MidiaPropaganda({
    required String id,
    required TipoMidia tipo,
    required String caminho,
    @Default(8) int duracaoSegundos,
    @Default(AjusteMidia.automatico) AjusteMidia ajuste,
    required int ordem,
    @Default(true) bool ativo,
  }) = _MidiaPropaganda;
}
```

- [ ] **Step 4: Acrescentar o campo ao modelo**

Em `lib/funcionalidades/propaganda/dados/modelos/modelo_midia.dart`, o `factory`, o `deEntidade` e o `paraEntidade`. O `@Default` é obrigatório (ver Global Constraints); o `unknownEnumValue` protege o caminho simétrico, uma versão futura gravando um modo que esta build não conhece:

```dart
  const factory ModeloMidia({
    required String id,
    required TipoMidia tipo,
    required String caminho,
    required int duracaoSegundos,
    @Default(AjusteMidia.automatico)
    @JsonKey(unknownEnumValue: AjusteMidia.automatico)
    AjusteMidia ajuste,
    required int ordem,
    required bool ativo,
  }) = _ModeloMidia;

  factory ModeloMidia.fromJson(Map<String, dynamic> json) =>
      _$ModeloMidiaFromJson(json);

  factory ModeloMidia.deEntidade(MidiaPropaganda entidade) => ModeloMidia(
        id: entidade.id,
        tipo: entidade.tipo,
        caminho: entidade.caminho,
        duracaoSegundos: entidade.duracaoSegundos,
        ajuste: entidade.ajuste,
        ordem: entidade.ordem,
        ativo: entidade.ativo,
      );

  MidiaPropaganda paraEntidade() => MidiaPropaganda(
        id: id,
        tipo: tipo,
        caminho: caminho,
        duracaoSegundos: duracaoSegundos,
        ajuste: ajuste,
        ordem: ordem,
        ativo: ativo,
      );
```

- [ ] **Step 5: Rodar o codegen**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Esperado: `Succeeded after ...`, com `midia_propaganda.freezed.dart`, `modelo_midia.freezed.dart` e `modelo_midia.g.dart` regravados.

- [ ] **Step 6: Rodar os testes e confirmar que passam**

```bash
flutter test test/funcionalidades/propaganda/repositorio_propaganda_test.dart
```

Esperado: `All tests passed!` (6 testes). O teste da playlist antiga é o que importa: se ele falhar com `hasLength(1)` recebendo `0`, o `@Default` não foi aplicado e a migração está apagando dados.

- [ ] **Step 7: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/propaganda test/funcionalidades/propaganda/repositorio_propaganda_test.dart
git commit -m "feat: persistir o modo de ajuste de cada midia da propaganda"
```

---

### Task 3: Player aplica o ajuste e pinta a cor de fundo

**Files:**
- Modify: `lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart`
- Modify: `lib/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart:210-216`
- Test: `test/funcionalidades/propaganda/player_propaganda_test.dart` (novo)

**Interfaces:**
- Consumes: `resolverBoxFit` e `AjusteMidia` (Task 1); `MidiaPropaganda.ajuste` (Task 2).
- Produces: `PlayerPropaganda({required MidiaPropaganda midia, required Color corFundo, required VoidCallback aoTerminar})` — o parâmetro `corFundo` é novo e obrigatório.

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/funcionalidades/propaganda/player_propaganda_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// PNG 1x1 valido: razao de aspecto 1,0.
const _png1x1 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8'
    'BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
const _corFundo = Color(0xFF123456);

void main() {
  late Directory temporaria;
  late String caminhoImagem;

  setUp(() async {
    temporaria = await Directory.systemTemp.createTemp('player_propaganda');
    caminhoImagem = '${temporaria.path}${Platform.pathSeparator}a.png';
    await File(caminhoImagem).writeAsBytes(base64Decode(_png1x1));
  });

  tearDown(() async {
    imageCache.clear();
    await temporaria.delete(recursive: true);
  });

  MidiaPropaganda midiaCom(AjusteMidia ajuste, String caminho) =>
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: caminho,
          ordem: 1,
          ajuste: ajuste);

  Future<void> montar(WidgetTester tester, MidiaPropaganda midia, Size tela) {
    return tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox(
          width: tela.width,
          height: tela.height,
          child: PlayerPropaganda(
              midia: midia, corFundo: _corFundo, aoTerminar: () {}),
        ),
      ),
    ));
  }

  BoxFit? fitAplicado(WidgetTester tester) =>
      tester.widget<Image>(find.byType(Image)).fit;

  testWidgets('modos explicitos aplicam o BoxFit sem precisar medir a imagem',
      (tester) async {
    const tela = Size(90, 160);
    final esperados = {
      AjusteMidia.preencher: BoxFit.cover,
      AjusteMidia.encaixar: BoxFit.contain,
      AjusteMidia.esticar: BoxFit.fill,
    };
    for (final entrada in esperados.entries) {
      await montar(tester, midiaCom(entrada.key, caminhoImagem), tela);
      await tester.pump();
      expect(fitAplicado(tester), entrada.value, reason: '${entrada.key}');
    }
  });

  testWidgets('automatico encaixa imagem quadrada em tela retrato',
      (tester) async {
    await tester.runAsync(() async {
      await montar(tester, midiaCom(AjusteMidia.automatico, caminhoImagem),
          const Size(90, 160));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    });
    expect(fitAplicado(tester), BoxFit.contain);
  });

  testWidgets('automatico preenche imagem quadrada em tela quadrada',
      (tester) async {
    await tester.runAsync(() async {
      await montar(tester, midiaCom(AjusteMidia.automatico, caminhoImagem),
          const Size(120, 120));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    });
    expect(fitAplicado(tester), BoxFit.cover);
  });

  testWidgets('arquivo ausente mostra a cor de fundo, nao preto',
      (tester) async {
    await montar(
        tester,
        midiaCom(AjusteMidia.preencher,
            '${temporaria.path}${Platform.pathSeparator}sumiu.png'),
        const Size(90, 160));
    await tester.pump();
    expect(find.byType(Image), findsNothing);
    final fundo = tester
        .widgetList<ColoredBox>(find.descendant(
          of: find.byType(PlayerPropaganda),
          matching: find.byType(ColoredBox),
        ))
        .first;
    expect(fundo.color, _corFundo);
    // Deixa o temporizador de 1s do arquivo ausente disparar antes do teardown.
    await tester.pump(const Duration(seconds: 2));
  });
}
```

- [ ] **Step 2: Rodar e confirmar que falha**

```bash
flutter test test/funcionalidades/propaganda/player_propaganda_test.dart
```

Esperado: falha de compilação, `No named parameter with the name 'corFundo'`.

- [ ] **Step 3: Reescrever o player**

Substituir o conteúdo de `lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart` por:

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

  /// Pinta as tarjas do modo encaixar e o intervalo em que a midia ainda esta
  /// carregando. Vem da cor primaria do tema da loja.
  final Color corFundo;

  final VoidCallback aoTerminar;

  @override
  State<PlayerPropaganda> createState() => _PlayerPropagandaState();
}

class _PlayerPropagandaState extends State<PlayerPropaganda> {
  Timer? _temporizador;
  VideoPlayerController? _video;
  ImageStream? _fluxoImagem;
  ImageStreamListener? _ouvinteImagem;
  double? _razaoMidia;
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
      _medirImagem(arquivo);
      return;
    }
    final controlador = VideoPlayerController.file(arquivo);
    _video = controlador;
    controlador.addListener(_aoAtualizarVideo);
    controlador.initialize().then((_) {
      if (!mounted) return;
      setState(() => _razaoMidia = _razaoDe(controlador.value.size));
      controlador.play();
    }).catchError((Object _) {
      // Arquivo corrompido ou codec nao suportado: segue para a proxima midia
      // em vez de deixar a tela parada.
      if (mounted) _temporizador = Timer(const Duration(seconds: 1), _terminar);
    });
  }

  double? _razaoDe(Size tamanho) =>
      tamanho.height > 0 ? tamanho.width / tamanho.height : null;

  /// GIF e imagem parada nao expoem as dimensoes de forma sincrona: o modo
  /// automatico so consegue decidir o enquadramento depois que o decodificador
  /// devolve o primeiro frame.
  void _medirImagem(File arquivo) {
    final fluxo = FileImage(arquivo).resolve(ImageConfiguration.empty);
    final ouvinte = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        setState(() => _razaoMidia = _razaoDe(Size(
            info.image.width.toDouble(), info.image.height.toDouble())));
      },
      onError: (Object _, StackTrace? __) {
        // Imagem corrompida: nao ha o que enquadrar. A tela fica na cor de fundo
        // e o temporizador de duracao avanca a playlist normalmente.
      },
    );
    _fluxoImagem = fluxo;
    _ouvinteImagem = ouvinte;
    fluxo.addListener(ouvinte);
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
    final fluxo = _fluxoImagem;
    final ouvinte = _ouvinteImagem;
    if (fluxo != null && ouvinte != null) fluxo.removeListener(ouvinte);
    _fluxoImagem = null;
    _ouvinteImagem = null;
    _razaoMidia = null;
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
      // No modo automatico o enquadramento depende das dimensoes da imagem:
      // pintar antes de medi-las trocaria o enquadramento na cara do cliente.
      if (widget.midia.ajuste == AjusteMidia.automatico && _razaoMidia == null) {
        return const SizedBox.expand();
      }
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
      // LayoutBuilder, e nao MediaQuery: o preview da aba Propaganda roda numa
      // caixa e nao em tela cheia, entao a razao da tela precisa vir da caixa.
      child: LayoutBuilder(
        builder: (context, restricoes) {
          final tamanho = restricoes.biggest;
          return _conteudo(resolverBoxFit(
            ajuste: widget.midia.ajuste,
            razaoMidia: _razaoMidia,
            razaoTela: _razaoDe(tamanho) ?? 0,
          ));
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Passar a cor primária na página**

Em `lib/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart`, no `PlayerPropaganda` dentro do `Stack` (a variável `primaria` já existe alguns linhas acima, em `pagina_propaganda.dart:198`):

```dart
          PlayerPropaganda(
            // A chave inclui o indice: repetir a mesma midia recria o player e
            // reinicia a reproducao do zero.
            key: ValueKey('${estado.indice}_${estado.midiaAtual!.id}'),
            midia: estado.midiaAtual!,
            corFundo: primaria,
            aoTerminar: () => ref.read(provedorPropaganda.notifier).avancar(),
          ),
```

- [ ] **Step 5: Rodar os testes e confirmar que passam**

```bash
flutter test test/funcionalidades/propaganda/
```

Esperado: `All tests passed!`. Se aparecer `A Timer is still pending even after the widget tree was disposed`, algum caminho de `_preparar` criou um `Timer` que o `_limpar` não cancelou — conferir que o `dispose` chama `_limpar`.

- [ ] **Step 6: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/propaganda test/funcionalidades/propaganda/player_propaganda_test.dart
git commit -m "feat: player enquadra a midia conforme o ajuste e usa a cor do tema no fundo"
```

---

### Task 4: GIF aceito e `definirAjuste` no controlador

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_midias.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart:42-51`
- Test: `test/funcionalidades/configuracoes/controlador_midias_test.dart`

**Interfaces:**
- Consumes: `AjusteMidia` e `MidiaPropaganda.ajuste` (Tasks 1 e 2).
- Produces: `Future<void> ControladorMidias.definirAjuste(String id, AjusteMidia ajuste)`.

- [ ] **Step 1: Escrever o teste que falha**

Acrescentar ao fim do `main()` de `test/funcionalidades/configuracoes/controlador_midias_test.dart` (manter os quatro testes que já existem):

```dart
  test('gif entra como imagem animada, com ajuste automatico', () async {
    await controlador.adicionarArquivos(['/m/oferta.gif']);
    final midia = controlador.state.midias.single;
    expect(midia.tipo, TipoMidia.imagem);
    expect(midia.ajuste, AjusteMidia.automatico);
  });

  test('definirAjuste atualiza o estado e persiste', () async {
    await controlador.adicionarArquivos(['/m/a.png']);
    final id = controlador.state.midias.single.id;
    await controlador.definirAjuste(id, AjusteMidia.esticar);
    expect(controlador.state.midias.single.ajuste, AjusteMidia.esticar);
    expect((await repositorio.obterTodas()).single.ajuste, AjusteMidia.esticar);
  });
```

- [ ] **Step 2: Rodar e confirmar que falha**

```bash
flutter test test/funcionalidades/configuracoes/controlador_midias_test.dart
```

Esperado: falha de compilação, `The method 'definirAjuste' isn't defined`.

- [ ] **Step 3: Implementar `definirAjuste`**

Em `lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_midias.dart`, logo abaixo de `definirDuracao`:

```dart
  Future<void> definirAjuste(String id, AjusteMidia ajuste) async {
    await _persistir([
      for (final midia in state.midias)
        midia.id == id ? midia.copyWith(ajuste: ajuste) : midia,
    ]);
  }
```

Nada muda em `_extensoesVideo`: `gif` não está lá e por isso já cai em `TipoMidia.imagem`, que é exatamente o comportamento desejado.

- [ ] **Step 4: Liberar o GIF no seletor de arquivos**

Em `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart`, no `allowedExtensions` do `_adicionar`:

```dart
      allowedExtensions: const [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'gif',
        'mp4',
        'mov',
        'webm',
        'mkv'
      ],
```

- [ ] **Step 5: Rodar os testes e confirmar que passam**

```bash
flutter test test/funcionalidades/configuracoes/controlador_midias_test.dart
```

Esperado: `All tests passed!` (6 testes).

- [ ] **Step 6: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/configuracoes test/funcionalidades/configuracoes/controlador_midias_test.dart
git commit -m "feat: aceitar GIF na playlist e permitir escolher o ajuste da midia"
```

---

### Task 5: Seletor de ajuste na aba Propaganda

**Files:**
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/seletor_ajuste_midia.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart` (o `_cardMidia` e o texto de ajuda em `aba_propaganda.dart:174-179`)
- Test: `test/funcionalidades/configuracoes/aba_propaganda_test.dart` (novo)

**Interfaces:**
- Consumes: `AjusteMidia` (Task 1), `ControladorMidias.definirAjuste` (Task 4).
- Produces: `SeletorAjusteMidia({required AjusteMidia valor, required void Function(AjusteMidia) aoMudar})` e o mapa público `SeletorAjusteMidia.rotulos`.

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/funcionalidades/configuracoes/aba_propaganda_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/seletor_ajuste_midia.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('seletor mostra o modo atual e devolve o modo escolhido',
      (tester) async {
    AjusteMidia? escolhido;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SeletorAjusteMidia(
          valor: AjusteMidia.automatico,
          aoMudar: (ajuste) => escolhido = ajuste,
        ),
      ),
    ));
    expect(find.text('Automático'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<AjusteMidia>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Encaixar (tarja)').last);
    await tester.pumpAndSettle();

    expect(escolhido, AjusteMidia.encaixar);
  });

  test('todo modo de ajuste tem rotulo em pt-BR', () {
    for (final ajuste in AjusteMidia.values) {
      expect(SeletorAjusteMidia.rotulos[ajuste], isNotNull,
          reason: 'sem rotulo para $ajuste');
    }
  });
}
```

- [ ] **Step 2: Rodar e confirmar que falha**

```bash
flutter test test/funcionalidades/configuracoes/aba_propaganda_test.dart
```

Esperado: falha de compilação, `Couldn't resolve the package ... seletor_ajuste_midia.dart`.

- [ ] **Step 3: Criar o seletor**

Criar `lib/funcionalidades/configuracoes/apresentacao/componentes/seletor_ajuste_midia.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';

class SeletorAjusteMidia extends StatelessWidget {
  const SeletorAjusteMidia({
    super.key,
    required this.valor,
    required this.aoMudar,
  });

  final AjusteMidia valor;
  final void Function(AjusteMidia ajuste) aoMudar;

  static const Map<AjusteMidia, String> rotulos = {
    AjusteMidia.automatico: 'Automático',
    AjusteMidia.preencher: 'Preencher (corta)',
    AjusteMidia.encaixar: 'Encaixar (tarja)',
    AjusteMidia.esticar: 'Esticar (distorce)',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Ajuste:',
            style: TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario)),
        const SizedBox(width: 6),
        DropdownButtonHideUnderline(
          child: DropdownButton<AjusteMidia>(
            value: valor,
            isDense: true,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: CoresApp.textoPrincipal,
            ),
            items: [
              for (final entrada in rotulos.entries)
                DropdownMenuItem<AjusteMidia>(
                  value: entrada.key,
                  child: Text(entrada.value),
                ),
            ],
            onChanged: (novo) {
              if (novo != null) aoMudar(novo);
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Rodar os testes e confirmar que passam**

```bash
flutter test test/funcionalidades/configuracoes/aba_propaganda_test.dart
```

Esperado: `All tests passed!` (2 testes).

- [ ] **Step 5: Plugar o seletor no card da mídia**

Em `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart`, importar o seletor:

```dart
import 'seletor_ajuste_midia.dart';
```

E, dentro do `_cardMidia`, trocar o `if (midia.tipo == TipoMidia.imagem) Row(...)` que hoje segura só a duração por um `Wrap` que acomoda duração e ajuste sem estourar a largura do card (vídeo não tem duração configurável, então lá só aparece o ajuste):

```dart
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  children: [
                    if (midia.tipo == TipoMidia.imagem)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Duração:',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: CoresApp.textoSecundario)),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 44,
                            child: TextFormField(
                              initialValue: '${midia.duracaoSegundos}',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 6)),
                              onFieldSubmitted: (valor) =>
                                  controlador.definirDuracao(
                                      midia.id,
                                      int.tryParse(valor) ??
                                          midia.duracaoSegundos),
                            ),
                          ),
                          const Text(' s',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: CoresApp.textoSecundario)),
                        ],
                      ),
                    SeletorAjusteMidia(
                      valor: midia.ajuste,
                      aoMudar: (ajuste) =>
                          controlador.definirAjuste(midia.id, ajuste),
                    ),
                  ],
                ),
```

- [ ] **Step 6: Reescrever o texto de ajuda**

O texto atual (`aba_propaganda.dart:174-179`) afirma que a mídia sempre preenche a tela e pode ser cortada. Isso deixa de ser verdade. Substituir por:

```dart
        const Text(
          'Ideal: mídia em pé (retrato), 1080 x 1920 px. Vídeos em MP4 com '
          'codec H.264, 30 fps e no máximo 6 Mbps. GIF é aceito e roda em loop '
          'até a duração acabar. O Ajuste decide como cada mídia ocupa a tela: '
          'no Automático, o app preenche quando o formato é parecido com o da '
          'tela e encaixa (com tarja na cor primária) quando cortaria demais.',
          style: TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
        ),
```

- [ ] **Step 7: Validar tudo e commitar**

```bash
dart format .
flutter analyze
flutter test
```

Esperado: `flutter analyze` sem issues; `flutter test` com toda a suíte passando (~221 testes).

```bash
git add lib/funcionalidades/configuracoes test/funcionalidades/configuracoes/aba_propaganda_test.dart
git commit -m "feat: escolher o ajuste de tela de cada midia na aba Propaganda"
```

- [ ] **Step 8: Conferir na mão**

Rodar o app, ir em Configurações → Propaganda, adicionar um vídeo 16:9 e um GIF, e usar o botão "Visualizar":

- o vídeo 16:9 deve aparecer inteiro, com tarja na cor primária (Automático escolheu encaixar);
- trocar o ajuste dele para "Preencher (corta)" e reabrir o preview: deve encher a tela e cortar;
- o GIF deve animar e trocar de mídia quando a duração acabar;
- entre uma mídia e outra não deve piscar preto.

---

## Revisão do plano contra o spec

- Enum `AjusteMidia` com os 4 modos → Task 1.
- Regra do automático com limite 0,75 em constante nomeada → Task 1.
- `razaoMidia` nula ou inválida → `contain` → Task 1, Step 2 e 4.
- Campo `ajuste` com `@Default` e `unknownEnumValue`; playlist legada preservada → Task 2.
- Tarja na cor primária; fim do flash preto → Task 3.
- `LayoutBuilder` em vez de `MediaQuery` por causa do preview → Task 3.
- Medição da razão: `aspectRatio` do vídeo e `ImageStream` da imagem, com o listener removido no `_limpar` → Task 3.
- GIF como `TipoMidia.imagem`, sem dependência nova → Task 4.
- `definirAjuste` no controlador → Task 4.
- Seletor no padrão do `seletor_fonte.dart`; texto de ajuda reescrito → Task 5.
- Testes: `resolverBoxFit` (Task 1), repositório e JSON legado (Task 2), player nos 4 modos e cor de fundo (Task 3), controlador e GIF (Task 4), seletor (Task 5).

Fora de escopo, conforme o spec: recorte manual, edição de mídia no app, playlist por horário, detecção da duração real do GIF.
