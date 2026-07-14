# Zoom reduzido e âncoras visíveis — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Zoom do modo preencher desce até 50% (sobra pintada pelo fundo borrado/cor da mídia) e a grade de âncoras usa a cor primária do tema em vez de cores fixas.

**Architecture:** `zoomMinimo` vira 50; `modoDeixaSobra` ganha o zoom como parâmetro (preencher com zoom < 100 passa a deixar sobra); player e diálogo repassam o zoom. A grade de âncoras troca as cores hardcoded por `widget.corTema` com transparências.

**Tech Stack:** Flutter, mesmos padrões dos planos anteriores.

Spec: `docs/superpowers/specs/2026-07-13-zoom-reduzido-ancoras-visiveis-design.md`

## Global Constraints

- pt-BR em strings visíveis e nomes; arquivos < 600 linhas; comentário só para regra não óbvia; sem código morto.
- Nenhuma dependência nova; **sem codegen** (nenhuma classe `@freezed` muda).
- Commits **sem** `Co-Authored-By` — mensagem é EXATAMENTE a linha única do passo de commit; conferir com `git log -1 --format=%B` e corrigir com `--amend` se um trailer aparecer.
- Se `flutter test` sujar `windows/flutter/generated_*` ou `pubspec.lock`: `git checkout -- pubspec.lock windows/flutter/generated_plugin_registrant.cc windows/flutter/generated_plugins.cmake` antes do commit. `git add` explícito, nunca `-A`.
- Validação ao fim de cada task: `dart format .`, `flutter analyze`, `flutter test` (~271 testes).

---

### Task 1: Regra pura + player — zoom 50 e sobra no preencher

**Files:**
- Modify: `lib/funcionalidades/propaganda/apresentacao/ajuste_tela.dart`
- Modify: `lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart` (só o call site de `modoDeixaSobra` — a UI reativa é a Task 2)
- Test: `test/funcionalidades/propaganda/ajuste_tela_test.dart`
- Test: `test/funcionalidades/propaganda/player_propaganda_test.dart`

**Interfaces:**
- Produces: `const int zoomMinimo = 50;` e `bool modoDeixaSobra(AjusteMidia ajuste, int zoomPercentual)` (assinatura nova — o parâmetro é obrigatório e posicional).
- Consumers atualizados nesta task: player (`_mostraFundoBorrado`) e diálogo (`_mostraFundo`, passa `_zoom`).

- [ ] **Step 1: Atualizar os testes de `ajuste_tela` (falharão)**

Em `test/funcionalidades/propaganda/ajuste_tela_test.dart`:

Substituir o teste `'zoom converte percentual em escala'` e o de clamp por:

```dart
  test('zoom converte percentual em escala', () {
    expect(resolverEscala(50), 0.5);
    expect(resolverEscala(100), 1.0);
    expect(resolverEscala(150), 1.5);
    expect(resolverEscala(300), 3.0);
  });

  test('zoom fora da faixa e corrigido, nao estoura', () {
    expect(resolverEscala(40), 0.5);
    expect(resolverEscala(999), 3.0);
    expect(resolverEscala(-5), 0.5);
  });
```

Substituir o teste `'so automatico e encaixar deixam sobra'` por:

```dart
  test('automatico e encaixar deixam sobra com qualquer zoom', () {
    expect(modoDeixaSobra(AjusteMidia.automatico, 100), isTrue);
    expect(modoDeixaSobra(AjusteMidia.encaixar, 300), isTrue);
  });

  test('preencher deixa sobra so quando o zoom encolhe', () {
    expect(modoDeixaSobra(AjusteMidia.preencher, 80), isTrue);
    expect(modoDeixaSobra(AjusteMidia.preencher, 100), isFalse);
    expect(modoDeixaSobra(AjusteMidia.preencher, 300), isFalse);
    expect(modoDeixaSobra(AjusteMidia.preencher, 30), isTrue,
        reason: 'abaixo da faixa clampa em 50, que ainda e sobra');
  });

  test('esticar nunca deixa sobra', () {
    expect(modoDeixaSobra(AjusteMidia.esticar, 80), isFalse);
  });
```

- [ ] **Step 2: Novo teste do player (falhará)**

Em `test/funcionalidades/propaganda/player_propaganda_test.dart`, acrescentar ao `main()`:

```dart
  testWidgets('preencher com zoom reduzido ganha sobra com fundo borrado',
      (tester) async {
    await montar(
        tester,
        midiaCom(AjusteMidia.preencher, caminhoImagem, zoomPercentual: 80),
        const Size(90, 160));
    await tester.pump();
    expect(find.byKey(const ValueKey('fundo-borrado')), findsOneWidget,
        reason: 'zoom < 100 encolhe a midia: a moldura precisa de fundo');
    final transformes = tester.widgetList<Transform>(find.descendant(
        of: find.byType(PlayerPropaganda), matching: find.byType(Transform)));
    expect(transformes, hasLength(1));
    expect(transformes.single.transform.getMaxScaleOnAxis(),
        closeTo(0.8, 0.001));
  });
```

O teste existente `'preencher nao tem sobra: sem camada borrada mesmo com fundo=borrado'` continua valendo (zoom default 100) — não mexer.

- [ ] **Step 3: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/propaganda/`
Expected: FAIL (assinatura de `modoDeixaSobra`, `resolverEscala(40)` ainda devolve 1.0)

- [ ] **Step 4: Implementar**

Em `ajuste_tela.dart`:

```dart
/// Faixa valida do zoom do modo preencher, em percentual.
const int zoomMinimo = 50;
const int zoomMaximo = 300;
```

E substituir `modoDeixaSobra` por:

```dart
/// So ha o que pintar atras da midia quando ela nao cobre a tela: nos modos
/// automatico e encaixar sempre, e no preencher quando o zoom encolhe.
bool modoDeixaSobra(AjusteMidia ajuste, int zoomPercentual) {
  switch (ajuste) {
    case AjusteMidia.automatico:
    case AjusteMidia.encaixar:
      return true;
    case AjusteMidia.preencher:
      return zoomPercentual.clamp(zoomMinimo, zoomMaximo) < 100;
    case AjusteMidia.esticar:
      return false;
  }
}
```

Em `player_propaganda.dart`, no `_mostraFundoBorrado`:

```dart
    if (!modoDeixaSobra(widget.midia.ajuste, widget.midia.zoomPercentual)) {
      return false;
    }
```

Em `dialogo_ajuste_midia.dart`, no `_mostraFundo`:

```dart
  bool get _mostraFundo =>
      modoDeixaSobra(_ajuste, _zoom) &&
      (widget.midia.tipo != TipoMidia.video || fundoBorradoLiberadoParaVideo);
```

- [ ] **Step 5: Rodar os testes**

Run: `flutter test test/funcionalidades/propaganda/ test/funcionalidades/configuracoes/`
Expected: PASS

- [ ] **Step 6: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/propaganda/apresentacao/ajuste_tela.dart lib/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart lib/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart test/funcionalidades/propaganda/ajuste_tela_test.dart test/funcionalidades/propaganda/player_propaganda_test.dart
git commit -m "feat: zoom do preencher desce a 50% e a sobra ganha fundo"
git log -1 --format=%B
```

---

### Task 2: Diálogo — controle de fundo reativo ao zoom e grade de âncoras na cor do tema

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart`
- Test: `test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart`

**Interfaces:**
- Consumes: `modoDeixaSobra(_ajuste, _zoom)` já ligado na Task 1; `widget.corTema` existente.
- Produces: grade de âncoras com `corTema` (selecionada: borda cheia 2px + fill alpha .18; demais: borda alpha .45, sem fill).

- [ ] **Step 1: Escrever os testes que falham**

Em `test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart`, acrescentar ao `main()` (a `corTema` usada pelo helper `abrir` é `const Color(0xFF5E52D6)`):

```dart
  testWidgets('no preencher, o controle de fundo aparece quando o zoom '
      'encolhe', (tester) async {
    await abrir(tester, midiaImagem);
    await escolherModo(tester, 'Preencher (corta)');
    expect(find.byType(SegmentedButton<FundoMidia>), findsNothing,
        reason: 'zoom 100 cobre a tela: nao ha sobra para configurar');

    await tester.ensureVisible(find.byType(Slider));
    await tester.pumpAndSettle();
    // Toca perto do inicio do trilho: o valor salta para baixo de 100%.
    final trilho = tester.getTopLeft(find.byType(Slider));
    final centroY = tester.getCenter(find.byType(Slider)).dy;
    await tester.tapAt(Offset(trilho.dx + 30, centroY));
    await tester.pump();
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, lessThan(100));
    expect(slider.value, greaterThanOrEqualTo(50));
    expect(find.byType(SegmentedButton<FundoMidia>), findsOneWidget,
        reason: 'com sobra, o operador escolhe o fundo');
    await drenar(tester);
  });

  testWidgets('grade de ancoras usa a cor do tema', (tester) async {
    const corTema = Color(0xFF5E52D6);
    await abrir(tester, midiaImagem);
    await escolherModo(tester, 'Preencher (corta)');

    BoxDecoration decoracaoDe(String chave) {
      final container = tester.widget<Container>(find.descendant(
        of: find.byKey(ValueKey(chave)),
        matching: find.byType(Container),
      ));
      return container.decoration! as BoxDecoration;
    }

    final selecionada = decoracaoDe('ancora-centro');
    expect(selecionada.border!.top.color, corTema,
        reason: 'selecionada marca com a cor primaria da loja');
    expect(selecionada.color, corTema.withValues(alpha: .18));

    final vizinha = decoracaoDe('ancora-topo');
    expect(vizinha.border!.top.color, corTema.withValues(alpha: .45),
        reason: 'as demais celulas ficam visiveis em qualquer tema');
    expect(vizinha.color, isNull);
    await drenar(tester);
  });
```

- [ ] **Step 2: Rodar para ver falhar**

Run: `flutter test test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart`
Expected: FAIL (controle de fundo não aparece com zoom < 100 só se a Task 1 não ligou `_zoom` — nesse caso já passa; a grade ainda usa lilás — falha garantida no segundo teste)

- [ ] **Step 3: Implementar a grade temável**

Em `dialogo_ajuste_midia.dart`, no `_gradeAncoras`, substituir a `decoration` da célula por:

```dart
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _ancora == ancora
                              ? widget.corTema.withValues(alpha: .18)
                              : null,
                          border: Border.all(
                            color: _ancora == ancora
                                ? widget.corTema
                                : widget.corTema.withValues(alpha: .45),
                            width: _ancora == ancora ? 2 : 1,
                          ),
                        ),
                      ),
```

Conferir depois: se `CoresApp` ficou sem uso no arquivo (o `_rotulo` ainda usa `textoSecundario` — deve continuar), não remover o import; se o analyzer apontar import sem uso, remover.

- [ ] **Step 4: Rodar os testes**

Run: `flutter test test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart`
Expected: PASS (todos, inclusive os antigos do slider/girar)

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart test/funcionalidades/configuracoes/dialogo_ajuste_midia_test.dart
git commit -m "fix: grade de ancoras na cor do tema e fundo reativo ao zoom"
git log -1 --format=%B
```

---

### Task 3: Validação final e review

- [ ] `dart format .` / `flutter analyze` / `flutter test` — tudo verde.
- [ ] Checklist adversarial do CLAUDE.md (overflow no diálogo, contraste, código morto).
- [ ] Review de branch do range desta feature; relatório no formato do CLAUDE.md.
