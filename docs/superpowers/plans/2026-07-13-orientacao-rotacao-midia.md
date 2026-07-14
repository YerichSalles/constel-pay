# Orientação da tela e rotação da mídia — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** O operador declara a orientação da tela do totem (em pé/deitada) e o preview do diálogo Ajustar simula essa orientação; cada mídia ganha rotação 0°/90°/180°/270° aplicada antes do enquadramento.

**Architecture:** `OrientacaoTela` vira campo do `TemaPersonalizado` (canal que a aba e o diálogo já usam); `rotacaoGraus` vira campo persistido da mídia. O player unifica a renderização em `FittedBox → RotatedBox → mídia intrínseca` — o `RotatedBox` gira o layout, então 90°/270° trocam a razão de aspecto e o fit enquadra certo sem conta extra. O diálogo ganha botão "Girar 90°" que cicla e um `AspectRatio` que segue a orientação.

**Tech Stack:** Flutter, Riverpod (`StateNotifier`), Freezed + json_serializable, `SharedPreferences`, `video_player`.

Spec: `docs/superpowers/specs/2026-07-13-orientacao-rotacao-midia-design.md`

## Global Constraints

- Idioma de toda string visível ao usuário: **pt-BR**. Pastas/nomes de código em pt-BR.
- Nenhum arquivo de código acima de **600 linhas**. Comentário só para regra não óbvia. Sem código morto, import não usado, print ou TODO.
- Nenhuma dependência nova no `pubspec.yaml`.
- **Campos novos NUNCA `required` nos modelos JSON** (`ModeloTemaPersonalizado`, `ModeloMidia`): tema/playlist já gravados não têm as chaves; `required` faria o `fromJson` lançar, o `catch` dos repositórios engoliria e o tema/playlist da loja voltaria ao padrão sem aviso. Enum com `@JsonKey(unknownEnumValue: ...)`.
- Codegen (`dart run build_runner build --delete-conflicting-outputs`) roda nas Tasks 1 e 2 (únicas que alteram classe `@freezed`). Nesta máquina o codegen **rebaixa o `pubspec.lock`** e suja `windows/flutter/generated_*`. Depois de rodar: `git checkout -- pubspec.lock windows/flutter/generated_plugin_registrant.cc windows/flutter/generated_plugins.cmake`. Commits com `git add` explícito; nunca `git add -A`; conferir com `git show --stat HEAD`.
- Commits **sem** `Co-Authored-By`.
- Validação ao fim de cada task: `dart format .`, `flutter analyze`, `flutter test` (~262 testes).
- Se `flutter test` sujar `windows/flutter/generated_*`, restaurar antes do commit (mesmo comando acima).

---

### Task 1: `OrientacaoTela` no tema (codegen)

**Files:**
- Modify: `lib/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart`
- Modify: `lib/funcionalidades/configuracoes/dados/modelos/modelo_tema_personalizado.dart`
- Test: `test/funcionalidades/configuracoes/repositorios_locais_test.dart`
- Gerados (commitar junto): `tema_personalizado.freezed.dart`, `modelo_tema_personalizado.freezed.dart`, `modelo_tema_personalizado.g.dart`

**Interfaces:**
- Consumes: nada novo.
- Produces: `enum OrientacaoTela { vertical, horizontal }` em `tema_personalizado.dart`; campo `OrientacaoTela orientacaoTela` (default `vertical`) em `TemaPersonalizado` e `ModeloTemaPersonalizado`.

- [ ] **Step 1: Escrever os testes que falham**

Em `test/funcionalidades/configuracoes/repositorios_locais_test.dart`, dentro do grupo que testa o tema (junto de `'salva e recupera o tema'`), acrescentar:

```dart
    test('a orientacao da tela sobrevive ao round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio =
          RepositorioTemaImpl(await SharedPreferences.getInstance());
      const tema = TemaPersonalizado(orientacaoTela: OrientacaoTela.horizontal);
      await repositorio.salvar(tema);
      expect(
          (await repositorio.obter()).orientacaoTela, OrientacaoTela.horizontal);
    });
```

E no teste existente `'tema gravado antes da faixa continua carregando'`, acrescentar depois dos `expect` atuais:

```dart
      expect(tema.orientacaoTela, OrientacaoTela.vertical,
          reason: 'tema legado sem o campo carrega com o padrao em pe');
```

(Ajustar a instanciação do repositório ao padrão que o arquivo já usa — ler o `setUp`/helpers existentes antes.)

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/repositorios_locais_test.dart`
Expected: FAIL (erro de compilação: `OrientacaoTela` não existe)

- [ ] **Step 3: Acrescentar o enum e o campo à entidade**

Em `tema_personalizado.dart`, acima da classe:

```dart
/// Orientacao fisica da tela onde o app roda; o preview do dialogo Ajustar
/// simula esta orientacao.
enum OrientacaoTela { vertical, horizontal }
```

E no factory, depois de `String? logoPath,`:

```dart
    @Default(OrientacaoTela.vertical) OrientacaoTela orientacaoTela,
```

- [ ] **Step 4: Espelhar no modelo**

Em `modelo_tema_personalizado.dart`, no factory, depois de `String? logoPath,`:

```dart
    @Default(OrientacaoTela.vertical)
    @JsonKey(unknownEnumValue: OrientacaoTela.vertical)
    OrientacaoTela orientacaoTela,
```

O arquivo precisa do `// ignore_for_file: invalid_annotation_target` no topo se ainda não tiver (mesma razão do `modelo_midia.dart`: `@JsonKey` em parâmetro de construtor freezed). E os conversores ganham o campo:

```dart
        // em deEntidade:
        orientacaoTela: entidade.orientacaoTela,
        // em paraEntidade:
        orientacaoTela: orientacaoTela,
```

- [ ] **Step 5: Rodar o codegen e restaurar o lock**

```bash
dart run build_runner build --delete-conflicting-outputs
git checkout -- pubspec.lock windows/flutter/generated_plugin_registrant.cc windows/flutter/generated_plugins.cmake
```

- [ ] **Step 6: Rodar os testes**

Run: `flutter test test/funcionalidades/configuracoes/repositorios_locais_test.dart`
Expected: PASS (inclusive o legado estendido)

- [ ] **Step 7: Validar e commitar (git add explícito)**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart lib/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.freezed.dart lib/funcionalidades/configuracoes/dados/modelos/modelo_tema_personalizado.dart lib/funcionalidades/configuracoes/dados/modelos/modelo_tema_personalizado.freezed.dart lib/funcionalidades/configuracoes/dados/modelos/modelo_tema_personalizado.g.dart test/funcionalidades/configuracoes/repositorios_locais_test.dart
git commit -m "feat: orientacao da tela do totem no tema personalizado"
git show --stat HEAD
```

Conferir: nem `pubspec.lock` nem `windows/flutter/generated_*` no commit.

---

### Task 2: `rotacaoGraus` na mídia + `resolverQuartosDeVolta` (codegen)

**Files:**
- Modify: `lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart`
- Modify: `lib/funcionalidades/propaganda/dados/modelos/modelo_midia.dart`
- Modify: `lib/funcionalidades/propaganda/apresentacao/ajuste_tela.dart`
- Test: `test/funcionalidades/propaganda/ajuste_tela_test.dart`
- Test: `test/funcionalidades/propaganda/repositorio_propaganda_test.dart`
- Gerados (commitar junto): `midia_propaganda.freezed.dart`, `modelo_midia.freezed.dart`, `modelo_midia.g.dart`

**Interfaces:**
- Consumes: nada novo.
- Produces: campo `int rotacaoGraus` (default `0`) em `MidiaPropaganda` e `ModeloMidia`; `int resolverQuartosDeVolta(int rotacaoGraus)` em `ajuste_tela.dart`.

- [ ] **Step 1: Escrever os testes que falham**

Em `test/funcionalidades/propaganda/ajuste_tela_test.dart`, acrescentar ao `main()`:

```dart
  test('graus legitimos viram quartos de volta', () {
    expect(resolverQuartosDeVolta(0), 0);
    expect(resolverQuartosDeVolta(90), 1);
    expect(resolverQuartosDeVolta(180), 2);
    expect(resolverQuartosDeVolta(270), 3);
  });

  test('graus adulterados sao normalizados, nunca estouram', () {
    expect(resolverQuartosDeVolta(45), 0);
    expect(resolverQuartosDeVolta(100), 1);
    expect(resolverQuartosDeVolta(-90), 3);
    expect(resolverQuartosDeVolta(360), 0);
    expect(resolverQuartosDeVolta(999), 3);
  });
```

Em `test/funcionalidades/propaganda/repositorio_propaganda_test.dart`, acrescentar ao `main()`:

```dart
  test('a rotacao escolhida sobrevive ao round-trip', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio =
        RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: '/m/a.png',
          ordem: 1,
          rotacaoGraus: 90),
    ]);
    expect((await repositorio.obterTodas()).single.rotacaoGraus, 90);
  });
```

E estender dois testes existentes:
- `'midia nova nasce com fundo borrado, ancora central e zoom 100'`: acrescentar `expect(midia.rotacaoGraus, 0);`
- `'playlist gravada antes do campo ajuste continua carregando'`: acrescentar `expect(midias.single.rotacaoGraus, 0);`

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/propaganda/`
Expected: FAIL (`resolverQuartosDeVolta` e `rotacaoGraus` não existem)

- [ ] **Step 3: Implementar**

Em `midia_propaganda.dart`, no factory, depois de `@Default(100) int zoomPercentual,`:

```dart
    @Default(0) int rotacaoGraus,
```

Em `modelo_midia.dart`, no factory, depois de `@Default(100) int zoomPercentual,`:

```dart
    @Default(0) int rotacaoGraus,
```

E nos conversores `deEntidade`/`paraEntidade`, o campo `rotacaoGraus` espelhado (mesmo padrão dos vizinhos).

Em `ajuste_tela.dart`, depois de `resolverEscala`:

```dart
/// Converte os graus da midia em quartos de volta para o RotatedBox. JSON
/// adulterado (45, -90, 999) cai no quarto de volta valido abaixo; nunca
/// estoura.
int resolverQuartosDeVolta(int rotacaoGraus) =>
    ((rotacaoGraus % 360) + 360) % 360 ~/ 90;
```

- [ ] **Step 4: Codegen + restaurar lock**

```bash
dart run build_runner build --delete-conflicting-outputs
git checkout -- pubspec.lock windows/flutter/generated_plugin_registrant.cc windows/flutter/generated_plugins.cmake
```

- [ ] **Step 5: Rodar os testes**

Run: `flutter test test/funcionalidades/propaganda/`
Expected: PASS

- [ ] **Step 6: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart lib/funcionalidades/propaganda/dominio/entidades/midia_propaganda.freezed.dart lib/funcionalidades/propaganda/dados/modelos/modelo_midia.dart lib/funcionalidades/propaganda/dados/modelos/modelo_midia.freezed.dart lib/funcionalidades/propaganda/dados/modelos/modelo_midia.g.dart lib/funcionalidades/propaganda/apresentacao/ajuste_tela.dart test/funcionalidades/propaganda/ajuste_tela_test.dart test/funcionalidades/propaganda/repositorio_propaganda_test.dart
git commit -m "feat: rotacao em graus persistida por midia da propaganda"
git show --stat HEAD
```

---

### Task 3: Player — `FittedBox → RotatedBox` unificado

A imagem nítida deixa de usar `Image.file(fit:)` e passa pelo mesmo caminho do vídeo: `FittedBox(fit, âncora, clip) → RotatedBox → mídia intrínseca`. A key `midia-nitida` (e o `fit`/`alignment` que os testes leem) migra para o `FittedBox`. O fundo borrado gira junto.

**Files:**
- Modify: `lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart`
- Test: `test/funcionalidades/propaganda/player_propaganda_test.dart`

**Interfaces:**
- Consumes: `resolverQuartosDeVolta`, campo `rotacaoGraus` (Task 2).
- Produces: contrato de teste novo — `find.byKey(ValueKey('midia-nitida'))` devolve um `FittedBox` (não mais `Image`); dentro de cada camada (nítida e borrada) existe um `RotatedBox` com `quarterTurns == resolverQuartosDeVolta(rotacaoGraus)`.

- [ ] **Step 1: Atualizar helpers e escrever os testes que falham**

Em `test/funcionalidades/propaganda/player_propaganda_test.dart`:

`midiaCom` ganha o parâmetro de rotação:

```dart
  MidiaPropaganda midiaCom(
    AjusteMidia ajuste,
    String caminho, {
    FundoMidia fundo = FundoMidia.borrado,
    AncoraMidia ancora = AncoraMidia.centro,
    int zoomPercentual = 100,
    int rotacaoGraus = 0,
  }) =>
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: caminho,
          ordem: 1,
          ajuste: ajuste,
          fundo: fundo,
          ancora: ancora,
          zoomPercentual: zoomPercentual,
          rotacaoGraus: rotacaoGraus);
```

`fitAplicado` passa a ler o `FittedBox`:

```dart
  BoxFit? fitAplicado(WidgetTester tester) => tester
      .widget<FittedBox>(find.byKey(const ValueKey('midia-nitida')))
      .fit;
```

No teste `'preencher aplica ancora e zoom; demais modos nao escalam'`, trocar a leitura do alignment da imagem:

```dart
    final nitida =
        tester.widget<FittedBox>(find.byKey(const ValueKey('midia-nitida')));
    expect(nitida.alignment, Alignment.topCenter,
        reason: 'a ancora diz qual parte da midia sobrevive ao corte');
```

(o restante do teste — Transform único com escala 1.4 e alignment topCenter — fica igual).

Acrescentar ao `main()`:

```dart
  testWidgets('rotacao gira a midia e o fundo borrado juntos', (tester) async {
    await montar(
        tester,
        midiaCom(AjusteMidia.automatico, caminhoImagem, rotacaoGraus: 90),
        const Size(90, 160));
    await tester.pump();
    final rotacoes = tester.widgetList<RotatedBox>(find.descendant(
        of: find.byType(PlayerPropaganda),
        matching: find.byType(RotatedBox)));
    expect(rotacoes, hasLength(2),
        reason: 'camada nitida e fundo borrado giram juntos');
    for (final rotacao in rotacoes) {
      expect(rotacao.quarterTurns, 1);
    }
  });

  testWidgets('sem rotacao, quarterTurns fica em zero', (tester) async {
    await montar(
        tester,
        midiaCom(AjusteMidia.automatico, caminhoImagem,
            fundo: FundoMidia.cor),
        const Size(90, 160));
    await tester.pump();
    final rotacao = tester.widget<RotatedBox>(find.descendant(
        of: find.byType(PlayerPropaganda),
        matching: find.byType(RotatedBox)));
    expect(rotacao.quarterTurns, 0);
  });
```

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/propaganda/player_propaganda_test.dart`
Expected: FAIL (`midia-nitida` ainda é `Image`; nenhum `RotatedBox`)

- [ ] **Step 3: Implementar no player**

Em `player_propaganda.dart`:

Substituir `_conteudo` inteiro por:

```dart
  Widget _conteudo() {
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) return const SizedBox.expand();
    final ajuste = widget.midia.ajuste;
    final fit = resolverBoxFit(ajuste);
    final alinhamento = ajuste == AjusteMidia.preencher
        ? resolverAlinhamento(widget.midia.ancora)
        : Alignment.center;
    final Widget midia;
    if (widget.midia.tipo == TipoMidia.imagem) {
      midia = Image.file(arquivo);
    } else {
      final video = _video;
      if (video == null || !video.value.isInitialized) {
        return const SizedBox.expand();
      }
      midia = SizedBox(
        width: video.value.size.width,
        height: video.value.size.height,
        child: VideoPlayer(video),
      );
    }
    // A rotacao acontece antes do fit: o RotatedBox gira o layout e o
    // FittedBox enquadra a midia ja girada com a razao certa.
    final Widget conteudo = FittedBox(
      key: const ValueKey('midia-nitida'),
      fit: fit,
      alignment: alinhamento,
      clipBehavior: Clip.hardEdge,
      child: RotatedBox(
        quarterTurns: resolverQuartosDeVolta(widget.midia.rotacaoGraus),
        child: midia,
      ),
    );
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
```

No `_fundoBorrado`, ramo da imagem, substituir o `child` do `ImageFiltered` por:

```dart
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: RotatedBox(
              quarterTurns: resolverQuartosDeVolta(widget.midia.rotacaoGraus),
              child: Image.file(File(widget.midia.caminho)),
            ),
          ),
```

E no ramo do vídeo, embrulhar o `SizedBox` interno do `FittedBox` existente:

```dart
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: RotatedBox(
                      quarterTurns:
                          resolverQuartosDeVolta(widget.midia.rotacaoGraus),
                      child: SizedBox(
                        width: video.value.size.width,
                        height: video.value.size.height,
                        child: VideoPlayer(video),
                      ),
                    ),
                  ),
```

- [ ] **Step 4: Rodar os testes**

Run: `flutter test test/funcionalidades/propaganda/`
Expected: PASS. Se algum teste antigo falhar por `tester.widget<Image>`, é a migração do contrato — trocar para `FittedBox` conforme o Step 1.

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart test/funcionalidades/propaganda/player_propaganda_test.dart
git commit -m "feat: player gira a midia antes do enquadramento"
```

---

### Task 4: Fiação da rotação — controlador, `aoSalvar` e aba (sem UI nova)

A assinatura de `definirEnquadramento` e do `aoSalvar` ganham `rotacaoGraus` **required**; o diálogo guarda `_rotacao` no estado local e o Salvar o devolve. O botão Girar vem na Task 5 — aqui `_rotacao` só nasce do `widget.midia` e volta intacto.

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_midias.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart`
- Test: `test/funcionalidades/configuracoes/controlador_midias_test.dart`
- Test: `test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart`

**Interfaces:**
- Consumes: `rotacaoGraus` (Task 2), `resolverQuartosDeVolta`.
- Produces:
  - `Future<void> definirEnquadramento(String id, {required AjusteMidia ajuste, required FundoMidia fundo, required AncoraMidia ancora, required int zoomPercentual, required int rotacaoGraus})`
  - `aoSalvar` do diálogo com o 5º parâmetro `required int rotacaoGraus`
  - Estado local `_rotacao` no diálogo, sempre normalizado para 0/90/180/270.

- [ ] **Step 1: Atualizar os testes (falharão)**

Em `controlador_midias_test.dart`, no teste `'definirEnquadramento persiste modo, fundo, ancora e zoom'`: acrescentar `rotacaoGraus: 90` à chamada e os expects `expect(midia.rotacaoGraus, 90);` / `expect(salva.rotacaoGraus, 90);`.

Em `dialogo_ajuste_midia_test.dart`:
- O typedef ganha o campo:

```dart
typedef EnquadramentoSalvo = ({
  AjusteMidia ajuste,
  FundoMidia fundo,
  AncoraMidia ancora,
  int zoomPercentual,
  int rotacaoGraus,
});
```

- No helper `abrir`, o closure de `aoSalvar` ganha `required int rotacaoGraus` na assinatura e `rotacaoGraus: rotacaoGraus` no record.
- No teste `'salvar devolve o enquadramento editado'`, acrescentar `expect(salvo!.rotacaoGraus, 0);` (rotação ainda não editável — volta como veio).

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/`
Expected: FAIL (assinaturas sem `rotacaoGraus`)

- [ ] **Step 3: Implementar a fiação**

`controlador_midias.dart` — `definirEnquadramento` ganha `required int rotacaoGraus` e o `copyWith` ganha `rotacaoGraus: rotacaoGraus`.

`dialogo_ajuste_midia.dart`:
- Assinatura do `aoSalvar` (no widget) ganha `required int rotacaoGraus,`.
- No state:

```dart
  // Normalizado ja na entrada: estado local so conhece 0/90/180/270.
  late int _rotacao =
      resolverQuartosDeVolta(widget.midia.rotacaoGraus) * 90;
```

- `_midiaPreview` ganha `rotacaoGraus: _rotacao`.
- O `onPressed` do Salvar ganha `rotacaoGraus: _rotacao`.

`aba_propaganda.dart` — o closure em `_abrirAjuste` ganha `required int rotacaoGraus,` e repassa `rotacaoGraus: rotacaoGraus` ao `definirEnquadramento`.

- [ ] **Step 4: Rodar os testes**

Run: `flutter test test/funcionalidades/configuracoes/`
Expected: PASS

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_midias.dart lib/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart test/funcionalidades/configuracoes/controlador_midias_test.dart test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart
git commit -m "feat: rotacao da midia atravessa dialogo, controlador e persistencia"
```

---

### Task 5: Diálogo — botão "Girar 90°", preview com orientação, resumo com rotação

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart` (passa `orientacao`)
- Test: `test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart`

**Interfaces:**
- Consumes: `OrientacaoTela` (Task 1), `_rotacao` (Task 4).
- Produces: `DialogoAjusteMidia` com `required OrientacaoTela orientacao`; botão com texto `'Girar 90°'`; `resumoEnquadramento` com sufixo ` · girada N°` quando rotação ≠ 0.

- [ ] **Step 1: Atualizar os testes (falharão)**

Em `dialogo_ajuste_midia_test.dart`:

- Import novo: `import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';`
- Helper `abrir` ganha parâmetro `OrientacaoTela orientacao = OrientacaoTela.vertical` e o construtor do diálogo recebe `orientacao: orientacao`.
- Acrescentar ao `main()`:

```dart
  testWidgets('girar cicla 90 em 90 e o preview acompanha', (tester) async {
    EnquadramentoSalvo? salvo;
    await abrir(tester, midiaImagem, aoSalvar: (s) => salvo = s);
    await tester.tap(find.text('Girar 90°'));
    await tester.pump();
    var player =
        tester.widget<PlayerPropaganda>(find.byType(PlayerPropaganda));
    expect(player.midia.rotacaoGraus, 90);

    await tester.tap(find.text('Girar 90°'));
    await tester.tap(find.text('Girar 90°'));
    await tester.tap(find.text('Girar 90°'));
    await tester.pump();
    player = tester.widget<PlayerPropaganda>(find.byType(PlayerPropaganda));
    expect(player.midia.rotacaoGraus, 0, reason: '4 toques dao a volta');

    await tester.tap(find.text('Girar 90°'));
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(salvo!.rotacaoGraus, 90);
    await drenar(tester);
  });

  testWidgets('preview segue a orientacao da tela', (tester) async {
    await abrir(tester, midiaImagem);
    var aspecto = tester.widget<AspectRatio>(find.descendant(
        of: find.byType(DialogoAjusteMidia),
        matching: find.byType(AspectRatio)));
    expect(aspecto.aspectRatio, closeTo(9 / 16, 0.001));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await drenar(tester);

    await abrir(tester, midiaImagem,
        orientacao: OrientacaoTela.horizontal);
    aspecto = tester.widget<AspectRatio>(find.descendant(
        of: find.byType(DialogoAjusteMidia),
        matching: find.byType(AspectRatio)));
    expect(aspecto.aspectRatio, closeTo(16 / 9, 0.001));
    await drenar(tester);
  });
```

- No teste `'resumo do enquadramento por modo'`, acrescentar:

```dart
    expect(
        resumoEnquadramento(midiaImagem.copyWith(rotacaoGraus: 90)),
        'Automático · fundo borrado · girada 90°');
    expect(
        resumoEnquadramento(midiaImagem.copyWith(
            ajuste: AjusteMidia.esticar, rotacaoGraus: 270)),
        'Esticar (distorce) · girada 270°');
```

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart`
Expected: FAIL (`orientacao` não existe; botão não existe; resumo sem sufixo)

- [ ] **Step 3: Implementar**

Em `dialogo_ajuste_midia.dart`:

Import novo:

```dart
import '../../dominio/entidades/tema_personalizado.dart';
```

`resumoEnquadramento` ganha o sufixo — renomear o corpo atual para `_resumoBase` e embrulhar:

```dart
/// Resumo curto do enquadramento, exibido no card da midia.
String resumoEnquadramento(MidiaPropaganda midia) {
  final base = _resumoBase(midia);
  final rotacao = resolverQuartosDeVolta(midia.rotacaoGraus) * 90;
  return rotacao == 0 ? base : '$base · girada $rotacao°';
}

String _resumoBase(MidiaPropaganda midia) {
  // corpo atual do switch, inalterado
}
```

Widget: campo novo (com doc) e construtor:

```dart
  /// Orientacao da tela do totem: o preview simula esta razao de aspecto.
  final OrientacaoTela orientacao;
```

Preview — substituir o bloco `Center > SizedBox(height: 220) > AspectRatio(9/16)` por:

```dart
              Center(
                child: SizedBox(
                  width: widget.orientacao == OrientacaoTela.horizontal
                      ? 300
                      : null,
                  height: widget.orientacao == OrientacaoTela.horizontal
                      ? null
                      : 220,
                  child: AspectRatio(
                    aspectRatio:
                        widget.orientacao == OrientacaoTela.horizontal
                            ? 16 / 9
                            : 9 / 16,
                    child: ClipRRect(
                      // ... conteudo atual inalterado ...
                    ),
                  ),
                ),
              ),
```

Botão Girar — logo depois do `SeletorAjusteMidia(...)`:

```dart
              const SizedBox(height: 4),
              Row(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact),
                    onPressed: () =>
                        setState(() => _rotacao = (_rotacao + 90) % 360),
                    icon: const Icon(Icons.rotate_90_degrees_cw, size: 16),
                    label: const Text('Girar 90°',
                        style: TextStyle(fontSize: 11.5)),
                  ),
                  if (_rotacao != 0) ...[
                    const SizedBox(width: 4),
                    _rotulo('Girada: $_rotacao°'),
                  ],
                ],
              ),
```

Em `aba_propaganda.dart`, `_abrirAjuste` passa a orientação (o `tema` já é lido ali):

```dart
      builder: (_) => DialogoAjusteMidia(
        midia: midia,
        corTema: corTema,
        orientacao: tema.orientacaoTela,
        aoSalvar: ...
```

- [ ] **Step 4: Rodar os testes**

Run: `flutter test test/funcionalidades/configuracoes/`
Expected: PASS (o teste do slider com `ensureVisible` continua passando — o botão novo só empurra o conteúdo)

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart
git commit -m "feat: girar a midia no dialogo e preview na orientacao da tela"
```

---

### Task 6: Aba Propaganda — seletor "Tela do totem" e ajuda dinâmica

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart`
- Test: `test/funcionalidades/configuracoes/aba_propaganda_test.dart`

**Interfaces:**
- Consumes: `provedorTema` / `ControladorTema.atualizar` (existentes), `OrientacaoTela` (Task 1).
- Produces: seletor persistente no topo da aba; texto de ajuda que muda com a orientação.

- [ ] **Step 1: Escrever os testes que falham**

Em `aba_propaganda_test.dart`, acrescentar ao `main()` (seguindo o padrão de `ProviderScope` + `provedorSharedPreferences` dos testes vizinhos):

```dart
  testWidgets('seletor de orientacao persiste no tema e muda a ajuda',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: AbaPropaganda())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('1080 x 1920'), findsOneWidget,
        reason: 'em pe por padrao');

    await tester.tap(find.text('Deitada'));
    await tester.pump();

    expect(find.textContaining('1920 x 1080'), findsOneWidget,
        reason: 'a ajuda acompanha a orientacao');
    final salvo =
        await RepositorioTemaImpl(preferencias).obter();
    expect(salvo.orientacaoTela, OrientacaoTela.horizontal,
        reason: 'a escolha persiste no tema');
  });
```

Imports novos no teste:

```dart
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_tema_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
```

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/aba_propaganda_test.dart`
Expected: FAIL (`'Deitada'` não existe)

- [ ] **Step 3: Implementar na aba**

Em `aba_propaganda.dart`, no `build`, ler o tema e montar o seletor + ajuda dinâmica. O `build` vira:

```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(provedorMidias);
    final tema = ref.watch(provedorTema);
    final deitada = tema.orientacaoTela == OrientacaoTela.horizontal;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Tela do totem:',
                style: TextStyle(
                    fontSize: 11.5, color: CoresApp.textoSecundario)),
            SegmentedButton<OrientacaoTela>(
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: const [
                ButtonSegment(
                    value: OrientacaoTela.vertical, label: Text('Em pé')),
                ButtonSegment(
                    value: OrientacaoTela.horizontal, label: Text('Deitada')),
              ],
              selected: {tema.orientacaoTela},
              onSelectionChanged: (selecao) => ref
                  .read(provedorTema.notifier)
                  .atualizar(tema.copyWith(orientacaoTela: selecao.single)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Ideal: mídia ${deitada ? 'deitada (paisagem), 1920 x 1080' : 'em pé (retrato), 1080 x 1920'} px. '
          'Vídeos em MP4 com codec H.264, 30 fps e no máximo 6 Mbps. GIF é '
          'aceito e roda em loop até a duração acabar. No ajuste Automático a '
          'mídia aparece inteira, sem corte: a sobra vira um fundo borrado da '
          'própria imagem (vídeos usam a cor primária do tema). Toque em '
          '"Ajustar…" para trocar o modo, o fundo da sobra, o corte, o zoom '
          'e o giro.',
          style:
              const TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
        ),
        // ... resto do build inalterado (SizedBox(14), EstadoVazio/cards, botões)
      ],
    );
  }
```

Import novo (se ainda não houver): `import '../../dominio/entidades/tema_personalizado.dart';`

- [ ] **Step 4: Rodar os testes**

Run: `flutter test test/funcionalidades/configuracoes/`
Expected: PASS — inclusive o teste de 480px (o `Wrap` quebra linha em vez de estourar).

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart test/funcionalidades/configuracoes/aba_propaganda_test.dart
git commit -m "feat: seletor de orientacao da tela na aba Propaganda"
```

---

### Task 7: Validação final e review de branch

**Files:** nenhum código novo.

- [ ] **Step 1: Suíte completa**

```bash
dart format .
flutter analyze
flutter test
```

Expected: 0 issues, todos os testes passando.

- [ ] **Step 2: Revisão adversarial do CLAUDE.md**

Checklist: overflow (aba em 480px com o seletor novo, diálogo com o botão Girar), estados sem tratamento, arquivos > 600 linhas (`dialogo_ajuste_midia.dart` cresceu — conferir), texto pt-BR, código morto.

- [ ] **Step 3: Review final de branch + relatório**

Review whole-branch do range desta feature; relatório no formato do CLAUDE.md com arquivos alterados, comandos, resultados e pendências.
