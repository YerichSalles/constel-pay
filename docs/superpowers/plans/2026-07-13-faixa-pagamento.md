# Faixa de pagamento temável — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Substituir o botão fixo e a pílula preta da tela de espera por uma faixa única no rodapé, obedecendo ao tema e configurável na aba Aparência (cor de fundo, cor do texto e a frase).

**Architecture:** Três campos novos no `TemaPersonalizado` (`corFaixa` nullable = herda a primária, `corTextoFaixa`, `textoFaixa`), com getters "efetivos" que resolvem herança e campo vazio num lugar só. Um widget puro `FaixaPagamento` sem gesto próprio, porque a página já embrulha a tela inteira num `GestureDetector`. Uma função pura de contraste WCAG alimenta um aviso na Aparência.

**Tech Stack:** Flutter, Riverpod (`StateNotifier`), Freezed + json_serializable, `SharedPreferences`.

Spec: `docs/superpowers/specs/2026-07-13-faixa-pagamento-design.md`

## Global Constraints

- Idioma de toda string visível ao usuário: **pt-BR**, com acentuação correta.
- Pastas e nomes de código em pt-BR. Não criar pastas em inglês (`core`, `features`, `shared`).
- Nenhum arquivo de código acima de **600 linhas**.
- Comentário só quando explicar regra não óbvia. Sem código morto, sem import não usado, sem `print`, sem TODO.
- Estado simples via o padrão já adotado (`StateNotifier` do Riverpod). Não introduzir BLoC.
- Nenhuma dependência nova no `pubspec.yaml`.
- Sem overflow, texto cortado ou botão fora da área visível.
- **Não rodar `build_runner` a menos que a tarefa altere uma classe `@freezed`.** Nesta máquina o codegen dispara um `pub get` que rebaixa o `pubspec.lock` (o Flutter local é mais antigo que o que gerou o lock commitado) e reescreve arquivos gerados não relacionados. Se `git status` mostrar `pubspec.lock` ou `windows/flutter/generated_*` modificados, **não** os inclua no commit.
- `TemaConstel.corDeHex(String hex, Color reserva)` é como o projeto converte hex em `Color`, com cor de reserva para hex inválido. Use sempre essa função.
- Validação ao fim de cada tarefa: `dart format .`, `flutter analyze`, `flutter test`.

---

### Task 1: Razão de contraste WCAG

Função pura, isolada, sem dependência das outras tarefas.

**Files:**
- Create: `lib/nucleo/utils/contraste.dart`
- Test: `test/nucleo/utils/contraste_test.dart`

**Interfaces:**
- Consumes: nada.
- Produces:
  - `double razaoDeContraste(Color a, Color b)`
  - `const double contrasteMinimoTexto = 4.5;`

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/nucleo/utils/contraste_test.dart`:

```dart
import 'package:constel_pay/nucleo/utils/contraste.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preto contra branco e o contraste maximo', () {
    expect(razaoDeContraste(Colors.black, Colors.white), closeTo(21, 0.01));
  });

  test('cor contra ela mesma nao tem contraste', () {
    expect(razaoDeContraste(Colors.white, Colors.white), closeTo(1, 0.001));
    expect(razaoDeContraste(Colors.black, Colors.black), closeTo(1, 0.001));
  });

  test('a ordem das cores nao muda a razao', () {
    const roxo = Color(0xFF5E52D6);
    expect(razaoDeContraste(roxo, Colors.white),
        closeTo(razaoDeContraste(Colors.white, roxo), 0.0001));
  });

  test('o padrao do app passa no minimo, branco no branco nao', () {
    // Faixa padrao: texto branco sobre a cor primaria do tema.
    const primaria = Color(0xFF5E52D6);
    expect(razaoDeContraste(primaria, Colors.white),
        greaterThan(contrasteMinimoTexto));
    expect(razaoDeContraste(Colors.white, Colors.white),
        lessThan(contrasteMinimoTexto));
  });
}
```

- [ ] **Step 2: Rodar o teste e confirmar que falha**

```bash
flutter test test/nucleo/utils/contraste_test.dart
```

Esperado: falha de compilação, `Couldn't resolve the package 'constel_pay/nucleo/utils/contraste.dart'`.

- [ ] **Step 3: Implementar**

Criar `lib/nucleo/utils/contraste.dart`. O `Color.computeLuminance()` do Flutter já é exatamente a luminância relativa que a WCAG define — não reimplemente a fórmula dos canais:

```dart
import 'dart:math' as math;
import 'dart:ui';

/// Contraste minimo da WCAG AA para texto normal. Abaixo disso o texto da faixa
/// fica ilegivel no totem.
const double contrasteMinimoTexto = 4.5;

/// Razao de contraste da WCAG entre duas cores: 1,0 quando sao identicas e 21,0
/// entre preto e branco.
double razaoDeContraste(Color a, Color b) {
  final luminanciaA = a.computeLuminance();
  final luminanciaB = b.computeLuminance();
  final maior = math.max(luminanciaA, luminanciaB);
  final menor = math.min(luminanciaA, luminanciaB);
  return (maior + 0.05) / (menor + 0.05);
}
```

- [ ] **Step 4: Rodar o teste e confirmar que passa**

```bash
flutter test test/nucleo/utils/contraste_test.dart
```

Esperado: `All tests passed!` (4 testes).

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/nucleo/utils/contraste.dart test/nucleo/utils/contraste_test.dart
git commit -m "feat: razao de contraste WCAG entre duas cores"
```

---

### Task 2: Campos da faixa no tema

**Files:**
- Modify: `lib/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart`
- Modify: `lib/funcionalidades/configuracoes/dados/modelos/modelo_tema_personalizado.dart`
- Test: `test/funcionalidades/configuracoes/repositorios_locais_test.dart` (o teste do tema já vive lá, por volta da linha 45)

**Interfaces:**
- Consumes: nada.
- Produces:
  - `const String textoFaixaPadrao = 'Toque para pagar';` (top-level em `tema_personalizado.dart`)
  - `TemaPersonalizado.corFaixa` (`String?`), `.corTextoFaixa` (`String`), `.textoFaixa` (`String`)
  - `String get TemaPersonalizado.corFaixaEfetiva`
  - `String get TemaPersonalizado.textoFaixaEfetivo`

- [ ] **Step 1: Escrever os testes que falham**

Acrescentar ao fim do `main()` de `test/funcionalidades/configuracoes/repositorios_locais_test.dart` (manter tudo o que já existe lá):

```dart
  group('faixa de pagamento no tema', () {
    test('a cor da faixa herda a primaria ate ser escolhida', () {
      const herdando = TemaPersonalizado(corPrimaria: '#C0392B');
      expect(herdando.corFaixaEfetiva, '#C0392B');

      const propria =
          TemaPersonalizado(corPrimaria: '#C0392B', corFaixa: '#1B7F3B');
      expect(propria.corFaixaEfetiva, '#1B7F3B');
    });

    test('texto vazio ou so espacos cai no padrao', () {
      expect(const TemaPersonalizado().textoFaixaEfetivo, textoFaixaPadrao);
      expect(const TemaPersonalizado(textoFaixa: '').textoFaixaEfetivo,
          textoFaixaPadrao);
      expect(const TemaPersonalizado(textoFaixa: '   ').textoFaixaEfetivo,
          textoFaixaPadrao);
      expect(const TemaPersonalizado(textoFaixa: 'Pague aqui').textoFaixaEfetivo,
          'Pague aqui');
    });

    test('os campos da faixa sobrevivem ao round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio =
          RepositorioTemaImpl(await SharedPreferences.getInstance());
      const tema = TemaPersonalizado(
        corFaixa: '#1B7F3B',
        corTextoFaixa: '#000000',
        textoFaixa: 'Pague aqui',
      );
      await repositorio.salvar(tema);
      expect(await repositorio.obter(), tema);
    });

    test('tema gravado antes da faixa continua carregando', () async {
      // Se um campo da faixa virar obrigatorio no ModeloTemaPersonalizado, o
      // fromJson lanca e o tema da loja volta ao padrao sem aviso nenhum.
      SharedPreferences.setMockInitialValues({
        'tema_personalizado': '{"corPrimaria":"#C0392B",'
            '"corSecundaria":"#FFD166","corFundo":"#F7F7FB",'
            '"corBotoes":"#C0392B"}',
      });
      final repositorio =
          RepositorioTemaImpl(await SharedPreferences.getInstance());
      final tema = await repositorio.obter();
      expect(tema.corPrimaria, '#C0392B',
          reason: 'o tema da loja nao pode ser perdido');
      expect(tema.corFaixa, isNull);
      expect(tema.corFaixaEfetiva, '#C0392B');
      expect(tema.corTextoFaixa, '#FFFFFF');
      expect(tema.textoFaixa, textoFaixaPadrao);
    });
  });
```

Confira a chave real usada pelo `RepositorioTemaImpl` no `SharedPreferences` e use-a no `setMockInitialValues` (o exemplo acima assume `tema_personalizado`). Se a chave for outra, ajuste — o teste depende disso para exercitar o caminho legado de verdade em vez de passar por acaso lendo um `null`.

- [ ] **Step 2: Rodar e confirmar que falha**

```bash
flutter test test/funcionalidades/configuracoes/repositorios_locais_test.dart
```

Esperado: falha de compilação, `No named parameter with the name 'corFaixa'`.

- [ ] **Step 3: Acrescentar os campos e os getters à entidade**

Em `lib/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart`. Os getters exigem o construtor privado `const TemaPersonalizado._();`, que a classe hoje não tem:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tema_personalizado.freezed.dart';

const String textoFaixaPadrao = 'Toque para pagar';

@freezed
class TemaPersonalizado with _$TemaPersonalizado {
  const TemaPersonalizado._();

  const factory TemaPersonalizado({
    @Default('#5E52D6') String corPrimaria,
    @Default('#FFD166') String corSecundaria,
    @Default('#F7F7FB') String corFundo,
    @Default('#5E52D6') String corBotoes,
    @Default('#2F2B3D') String corTexto,
    String? corFaixa,
    @Default('#FFFFFF') String corTextoFaixa,
    @Default(textoFaixaPadrao) String textoFaixa,
    @Default('Inter') String fonte,
    String? logoPath,
  }) = _TemaPersonalizado;

  /// A faixa acompanha a cor principal ate o operador escolher uma cor propria
  /// para ela. Nulo aqui e o que da a heranca, sem precisar de uma flag
  /// "herdar sim/nao" separada para manter em sincronia.
  String get corFaixaEfetiva => corFaixa ?? corPrimaria;

  /// Um totem sem chamada para pagar e um defeito, nao uma preferencia: campo
  /// vazio cai no padrao.
  String get textoFaixaEfetivo =>
      textoFaixa.trim().isEmpty ? textoFaixaPadrao : textoFaixa;
}
```

- [ ] **Step 4: Acrescentar os campos ao modelo**

Em `lib/funcionalidades/configuracoes/dados/modelos/modelo_tema_personalizado.dart`, no `factory`, no `deEntidade` e no `paraEntidade`. `corFaixa` é `String?` **sem** `@Default`: a ausência da chave no JSON legado tem que virar `null`, que é o que significa "herda a primária".

```dart
  const factory ModeloTemaPersonalizado({
    required String corPrimaria,
    required String corSecundaria,
    required String corFundo,
    required String corBotoes,
    // Campos novos: temas ja salvos nao os possuem, por isso tem padrao.
    @Default('#2F2B3D') String corTexto,
    String? corFaixa,
    @Default('#FFFFFF') String corTextoFaixa,
    @Default(textoFaixaPadrao) String textoFaixa,
    @Default('Inter') String fonte,
    String? logoPath,
  }) = _ModeloTemaPersonalizado;

  factory ModeloTemaPersonalizado.fromJson(Map<String, dynamic> json) =>
      _$ModeloTemaPersonalizadoFromJson(json);

  factory ModeloTemaPersonalizado.deEntidade(TemaPersonalizado entidade) =>
      ModeloTemaPersonalizado(
        corPrimaria: entidade.corPrimaria,
        corSecundaria: entidade.corSecundaria,
        corFundo: entidade.corFundo,
        corBotoes: entidade.corBotoes,
        corTexto: entidade.corTexto,
        corFaixa: entidade.corFaixa,
        corTextoFaixa: entidade.corTextoFaixa,
        textoFaixa: entidade.textoFaixa,
        fonte: entidade.fonte,
        logoPath: entidade.logoPath,
      );

  TemaPersonalizado paraEntidade() => TemaPersonalizado(
        corPrimaria: corPrimaria,
        corSecundaria: corSecundaria,
        corFundo: corFundo,
        corBotoes: corBotoes,
        corTexto: corTexto,
        corFaixa: corFaixa,
        corTextoFaixa: corTextoFaixa,
        textoFaixa: textoFaixa,
        fonte: fonte,
        logoPath: logoPath,
      );
```

- [ ] **Step 5: Rodar o codegen**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Esperado: `Succeeded after ...`, com `tema_personalizado.freezed.dart`, `modelo_tema_personalizado.freezed.dart` e `modelo_tema_personalizado.g.dart` regravados.

Depois disso, rode `git status`. O codegen dispara um `pub get` que provavelmente vai sujar `pubspec.lock` e `windows/flutter/generated_*`. Esses arquivos **não** entram no commit — o `git add` do Step 7 lista só o que interessa.

- [ ] **Step 6: Rodar os testes e confirmar que passam**

```bash
flutter test test/funcionalidades/configuracoes/repositorios_locais_test.dart
```

Esperado: `All tests passed!`. O teste do tema legado é o que importa: se ele falhar com `corPrimaria` valendo `#5E52D6` em vez de `#C0392B`, o `fromJson` lançou e o repositório devolveu o tema padrão — a loja perderia as cores dela na atualização.

- [ ] **Step 7: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart lib/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.freezed.dart lib/funcionalidades/configuracoes/dados/modelos/modelo_tema_personalizado.dart lib/funcionalidades/configuracoes/dados/modelos/modelo_tema_personalizado.freezed.dart lib/funcionalidades/configuracoes/dados/modelos/modelo_tema_personalizado.g.dart test/funcionalidades/configuracoes/repositorios_locais_test.dart
git commit -m "feat: campos da faixa de pagamento no tema personalizado"
```

---

### Task 3: O widget da faixa

**Files:**
- Create: `lib/compartilhado/widgets/faixa_pagamento.dart`
- Test: `test/compartilhado/faixa_pagamento_test.dart`

**Interfaces:**
- Consumes: nada (recebe primitivos, não a entidade do tema).
- Produces: `FaixaPagamento({required String texto, required Color corFundo, required Color corTexto, required String fonte})`

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/compartilhado/faixa_pagamento_test.dart`:

```dart
import 'package:constel_pay/compartilhado/widgets/faixa_pagamento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> montar(WidgetTester tester, String texto, double largura) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: largura,
            child: FaixaPagamento(
              texto: texto,
              corFundo: const Color(0xFF1B7F3B),
              corTexto: const Color(0xFFFFEEDD),
              fonte: 'Inter',
            ),
          ),
        ),
      ),
    ));
  }

  testWidgets('mostra o texto com as cores recebidas', (tester) async {
    await montar(tester, 'Pague aqui', 400);
    final texto = tester.widget<Text>(find.text('Pague aqui'));
    expect(texto.style?.color, const Color(0xFFFFEEDD));

    final fundo = tester
        .widgetList<Container>(find.descendant(
          of: find.byType(FaixaPagamento),
          matching: find.byType(Container),
        ))
        .first;
    expect(fundo.color, const Color(0xFF1B7F3B));
  });

  testWidgets('frase longa nao estoura a largura', (tester) async {
    await montar(
        tester,
        'Toque em qualquer lugar desta tela para pagar a sua conta agora mesmo '
        'sem precisar chamar o garçom da sua mesa',
        300);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Rodar e confirmar que falha**

```bash
flutter test test/compartilhado/faixa_pagamento_test.dart
```

Esperado: falha de compilação, `Couldn't resolve the package 'constel_pay/compartilhado/widgets/faixa_pagamento.dart'`.

- [ ] **Step 3: Implementar**

Criar `lib/compartilhado/widgets/faixa_pagamento.dart`:

```dart
import 'package:flutter/material.dart';

import '../../aplicativo/tema/estilos_texto.dart';

/// Chamada para pagar, no rodape da tela de espera.
///
/// Nao tem gesto proprio: a pagina ja embrulha a tela inteira num
/// GestureDetector opaco e a faixa mora dentro dele, entao tocar nela ja paga.
/// Recebe primitivos em vez do TemaPersonalizado para `compartilhado/` nao
/// passar a depender de `funcionalidades/`.
class FaixaPagamento extends StatelessWidget {
  const FaixaPagamento({
    super.key,
    required this.texto,
    required this.corFundo,
    required this.corTexto,
    required this.fonte,
  });

  final String texto;
  final Color corFundo;
  final Color corTexto;
  final String fonte;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: corFundo,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: EstilosTexto.estilo(
              fonte,
              TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: corTexto,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar o teste e confirmar que passa**

```bash
flutter test test/compartilhado/faixa_pagamento_test.dart
```

Esperado: `All tests passed!` (2 testes), sem nenhum `RenderFlex overflowed` na saída.

- [ ] **Step 5: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/compartilhado/widgets/faixa_pagamento.dart test/compartilhado/faixa_pagamento_test.dart
git commit -m "feat: widget da faixa de pagamento"
```

---

### Task 4: A faixa nas duas telas de espera

Aqui o card branco, o botão, a pílula e o helper `_passo()` saem de cena.

**Files:**
- Modify: `lib/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart`
- Test: `test/funcionalidades/propaganda/propaganda_test.dart`

**Interfaces:**
- Consumes: `FaixaPagamento` (Task 3); `TemaPersonalizado.corFaixaEfetiva`, `.textoFaixaEfetivo`, `.corTextoFaixa`, `.fonte` (Task 2).
- Produces: nada que as outras tarefas consumam.

- [ ] **Step 1: Atualizar o teste existente para o comportamento novo**

Em `test/funcionalidades/propaganda/propaganda_test.dart`, o teste `'sem midias mostra CTA e navega para o chat ao tocar'` afirma hoje `expect(find.text('Escaneie'), findsOneWidget)`. Os três passos deixam de existir. Trocar essa asserção e acrescentar as da faixa:

```dart
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(FaixaPagamento), findsOneWidget);
    expect(find.text('Toque para pagar'), findsOneWidget);
    // O card branco e os tres passos sairam da tela junto com o botao fixo.
    expect(find.text('Escaneie'), findsNothing);
    await tester.tap(find.text('Toque para pagar'));
    await tester.pump();
    await tester.pump();
    expect(find.text('CHAT'), findsOneWidget);
```

E acrescentar o import:

```dart
import 'package:constel_pay/compartilhado/widgets/faixa_pagamento.dart';
```

- [ ] **Step 2: Rodar e confirmar que falha**

```bash
flutter test test/funcionalidades/propaganda/propaganda_test.dart
```

Esperado: falha — `find.byType(FaixaPagamento)` acha zero widgets (a página ainda desenha o botão antigo), e `find.text('Escaneie')` ainda acha um.

- [ ] **Step 3: Enxugar a tela de chamada**

Em `lib/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart`, substituir o `_telaChamada` inteiro (hoje um `Column` com o card branco embaixo) por só o gradiente, a logo e o nome. A faixa **não** entra aqui: ela é composta no `build`, para as duas telas compartilharem a mesma:

```dart
  Widget _telaChamada(Color primaria, String? logoPath) {
    final temLogo = logoPath != null && File(logoPath).existsSync();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaria, primaria.withValues(alpha: .8)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: .25),
                      blurRadius: 40,
                      offset: const Offset(0, 16)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: temLogo
                  ? ImagemLogo(
                      caminho: logoPath,
                      reserva:
                          const Text('🍽️', style: TextStyle(fontSize: 60)),
                    )
                  : const Text('🍽️', style: TextStyle(fontSize: 60)),
            ),
            const SizedBox(height: 20),
            Text(
              _nomeRestaurante,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
```

Apagar o método `_passo(...)` inteiro: ele desenhava os três passos e fica sem nenhuma chamada.

- [ ] **Step 4: Compor a faixa no `build`**

Substituir o `build` por esta versão. Ela unifica os dois casos: o miolo (`fundo`) é a tela de chamada ou o player, e a faixa é a mesma nos dois. Enquanto está carregando não há faixa, para não piscar uma chamada antes de a tela existir:

```dart
  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorPropaganda);
    final tema = ref.watch(provedorTema);
    final primaria = TemaConstel.corDeHex(
        tema.corPrimaria, Theme.of(context).colorScheme.primary);

    final Widget fundo;
    if (estado.carregando) {
      fundo = ColoredBox(color: primaria);
    } else if (estado.midiaAtual == null) {
      fundo = _telaChamada(primaria, tema.logoPath);
    } else {
      fundo = PlayerPropaganda(
        // A chave inclui o indice: repetir a mesma midia recria o player e
        // reinicia a reproducao do zero.
        key: ValueKey('${estado.indice}_${estado.midiaAtual!.id}'),
        midia: estado.midiaAtual!,
        corFundo: primaria,
        aoTerminar: () => ref.read(provedorPropaganda.notifier).avancar(),
      );
    }

    final conteudo = Column(
      children: [
        Expanded(child: SizedBox(width: double.infinity, child: fundo)),
        if (!estado.carregando)
          FaixaPagamento(
            texto: tema.textoFaixaEfetivo,
            corFundo: TemaConstel.corDeHex(tema.corFaixaEfetiva, primaria),
            corTexto: TemaConstel.corDeHex(tema.corTextoFaixa, Colors.white),
            fonte: tema.fonte,
          ),
      ],
    );

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: _prosseguir,
            behavior: HitTestBehavior.opaque,
            child: conteudo,
          ),
          // Botao temporario de acesso as configuracoes.
          if (!widget.preview)
            Positioned(
              top: 12,
              right: 12,
              child: SafeArea(
                child: IconButton(
                  onPressed: _abrirConfiguracoes,
                  tooltip: 'Configuracoes',
                  icon: const Icon(Icons.settings, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: .45),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
```

Ajustar os imports do arquivo: entra `faixa_pagamento.dart`, e saem os que ficaram sem uso — `botao_primario.dart` e `cores_app.dart` só eram usados pelo card branco e pelo `_passo`. Confirme com `flutter analyze` em vez de adivinhar: ele aponta `Unused import`.

- [ ] **Step 5: Rodar os testes e confirmar que passam**

```bash
flutter test test/funcionalidades/propaganda/
```

Esperado: `All tests passed!`, sem `RenderFlex overflowed` na saída.

- [ ] **Step 6: Validar e commitar**

```bash
dart format .
flutter analyze
flutter test
git add lib/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart test/funcionalidades/propaganda/propaganda_test.dart
git commit -m "feat: faixa de pagamento substitui o botao fixo e a pilula da tela de espera"
```

---

### Task 5: Configurar a faixa na aba Aparência

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_aparencia.dart`
- Test: `test/funcionalidades/configuracoes/aba_aparencia_test.dart`

**Interfaces:**
- Consumes: `razaoDeContraste`, `contrasteMinimoTexto` (Task 1); os campos e getters do tema (Task 2); `FaixaPagamento` (Task 3).
- Produces: nada.

**Duas armadilhas nos testes que já existem neste arquivo:**

1. `aba_aparencia_test.dart:37` usa `find.byType(TextFormField).first` para o seletor de cor primária. O `SeletorCor` é feito de `TextFormField`, e você vai acrescentar mais um `TextFormField` (o texto da faixa). Acrescente os controles novos **depois** dos seletores de cor existentes, para que `.first` continue sendo a cor principal.
2. `aba_aparencia_test.dart:42` rola a lista com `tester.drag(listView, const Offset(0, -1000))` para alcançar o botão "Aplicar tema". Você vai deixar a lista mais comprida e 1000 px podem não bastar — o teste passaria a falhar por não achar o botão. Troque a rolagem mágica por `await tester.ensureVisible(find.text('Aplicar tema'));`, que não depende do comprimento da lista.

- [ ] **Step 1: Escrever o teste novo e consertar o antigo**

Em `test/funcionalidades/configuracoes/aba_aparencia_test.dart`, no teste `'Aplicar tema atualiza o provedorTema'`, trocar o bloco da rolagem:

```dart
    // Scroll to ensure button is visible
    final listView = find.byType(ListView);
    await tester.drag(listView, const Offset(0, -1000));
    await tester.pumpAndSettle();
```

por:

```dart
    await tester.ensureVisible(find.text('Aplicar tema'));
    await tester.pumpAndSettle();
```

E acrescentar ao fim do `main()`:

```dart
  testWidgets('a aba avisa quando a faixa fica sem contraste', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: AbaAparencia())),
      ),
    );
    await tester.pump();

    // Padrao: texto branco sobre a cor primaria. Contraste suficiente.
    expect(find.byKey(const Key('aviso_contraste_faixa')), findsNothing);

    await tester.enterText(
        find.byKey(const Key('cor_faixa')), '#FFFFFF');
    await tester.pumpAndSettle();

    // Faixa branca com texto branco: ilegivel no totem.
    expect(find.byKey(const Key('aviso_contraste_faixa')), findsOneWidget);
  });
```

Isso exige que o `SeletorCor` da cor da faixa carregue `key: const Key('cor_faixa')` e que o aviso carregue `key: const Key('aviso_contraste_faixa')`.

- [ ] **Step 2: Rodar e confirmar que falha**

```bash
flutter test test/funcionalidades/configuracoes/aba_aparencia_test.dart
```

Esperado: o teste novo falha em `find.byKey(const Key('cor_faixa'))`, que não acha nada.

- [ ] **Step 3: Controlador do campo de texto**

Em `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_aparencia.dart`, no `_AbaAparenciaState`. O campo de texto precisa de um `TextEditingController`: o padrão `_rascunho` + `setState` da aba reconstrói a cada tecla, e um `TextFormField` sem controlador perderia a posição do cursor a cada letra digitada.

```dart
class _AbaAparenciaState extends ConsumerState<AbaAparencia> {
  TemaPersonalizado? _rascunho;
  late final TextEditingController _controladorTextoFaixa =
      TextEditingController(text: ref.read(provedorTema).textoFaixa);

  @override
  void dispose() {
    _controladorTextoFaixa.dispose();
    super.dispose();
  }

  TemaPersonalizado get _tema => _rascunho ?? ref.read(provedorTema);
```

E o `_restaurar()` tem que zerar o campo junto com o rascunho, senão ele continua mostrando a frase antiga depois de restaurar:

```dart
    if (!confirmado) return;
    setState(() => _rascunho = null);
    _controladorTextoFaixa.text = textoFaixaPadrao;
    await ref.read(provedorTema.notifier).atualizar(const TemaPersonalizado());
```

- [ ] **Step 4: Os três controles novos**

Ainda em `aba_aparencia.dart`, no `build`, calcular as cores da faixa junto das outras (perto de `aba_aparencia.dart:57-62`):

```dart
    final faixaFundo =
        TemaConstel.corDeHex(tema.corFaixaEfetiva, CoresApp.primariaPadrao);
    final faixaTexto = TemaConstel.corDeHex(tema.corTextoFaixa, Colors.white);
    final semContraste =
        razaoDeContraste(faixaFundo, faixaTexto) < contrasteMinimoTexto;
```

E, na `ListView`, **depois** do `SeletorCor` da "Cor do texto" e **antes** do `SeletorFonte` (para o `.first` do teste antigo continuar sendo a cor principal):

```dart
        const SizedBox(height: 18),
        SeletorCor(
          key: const Key('cor_faixa'),
          rotulo: 'Cor da faixa de pagamento',
          valorHex: tema.corFaixaEfetiva,
          aoMudar: (hex) =>
              setState(() => _rascunho = tema.copyWith(corFaixa: hex)),
        ),
        const SizedBox(height: 18),
        SeletorCor(
          rotulo: 'Cor do texto da faixa',
          valorHex: tema.corTextoFaixa,
          aoMudar: (hex) =>
              setState(() => _rascunho = tema.copyWith(corTextoFaixa: hex)),
        ),
        const SizedBox(height: 18),
        const Text('Texto da faixa',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controladorTextoFaixa,
          decoration: const InputDecoration(
            isDense: true,
            hintText: textoFaixaPadrao,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onChanged: (valor) =>
              setState(() => _rascunho = tema.copyWith(textoFaixa: valor)),
        ),
        if (semContraste) ...[
          const SizedBox(height: 10),
          Container(
            key: const Key('aviso_contraste_faixa'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CoresApp.erro.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CoresApp.erro.withValues(alpha: .3)),
            ),
            child: const Text(
              'O texto da faixa está com pouco contraste sobre o fundo '
              'escolhido e pode ficar ilegível no totem.',
              style: TextStyle(fontSize: 11.5, color: CoresApp.erro),
            ),
          ),
        ],
```

Imports novos no topo do arquivo:

```dart
import '../../../../compartilhado/widgets/faixa_pagamento.dart';
import '../../../../nucleo/utils/contraste.dart';
```

- [ ] **Step 5: A faixa na pré-visualização**

Dentro do `Container` da "Pré-visualização" (`aba_aparencia.dart:121-178`), como último filho da `Column` interna, depois do `IgnorePointer` do botão de exemplo:

```dart
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FaixaPagamento(
                  texto: tema.textoFaixaEfetivo,
                  corFundo: faixaFundo,
                  corTexto: faixaTexto,
                  fonte: tema.fonte,
                ),
              ),
```

A `FaixaPagamento` não tem gesto próprio, então ela já é inerte no preview — não precisa de `IgnorePointer`.

- [ ] **Step 6: Rodar os testes e confirmar que passam**

```bash
flutter test test/funcionalidades/configuracoes/aba_aparencia_test.dart
```

Esperado: `All tests passed!` (3 testes), sem `RenderFlex overflowed` na saída.

- [ ] **Step 7: Validar tudo e commitar**

```bash
dart format .
flutter analyze
flutter test
```

Esperado: `flutter analyze` sem issues; toda a suíte passando.

```bash
git add lib/funcionalidades/configuracoes/apresentacao/componentes/aba_aparencia.dart test/funcionalidades/configuracoes/aba_aparencia_test.dart
git commit -m "feat: configurar cor e texto da faixa de pagamento na aba Aparencia"
```

- [ ] **Step 8: Conferir na mão**

Rodar o app e olhar:

- tela de espera **sem** mídia: gradiente, logo, nome, faixa roxa no rodapé com "Toque para pagar". Sem card branco, sem os três passos;
- tela de espera **com** mídia: a mídia e a mesma faixa no rodapé. Sem pílula preta;
- tocar no meio da tela (não na faixa) leva ao chat;
- Configurações → Aparência: trocar a cor principal e ver a faixa do preview acompanhar sozinha; depois escolher uma cor própria pra faixa e ver ela parar de acompanhar;
- pôr faixa branca com texto branco e ver o aviso de contraste aparecer;
- apagar o texto da faixa e ver a chamada cair de volta em "Toque para pagar";
- "Restaurar padrão original" e conferir que o campo de texto volta a "Toque para pagar".

---

## Revisão do plano contra o spec

- `corFaixa` nullable = herança da primária; `corTextoFaixa` e `textoFaixa` com padrão estático → Task 2.
- `corFaixaEfetiva` e `textoFaixaEfetivo` como fonte única da regra → Task 2 (usados nas Tasks 4 e 5).
- Migração: tema legado sem as 3 chaves carrega e não volta ao padrão → Task 2, Step 1 e 6.
- `FaixaPagamento` puro, primitivos, sem gesto próprio, `SafeArea(top: false)`, frase longa sem overflow → Task 3.
- Saem o `BotaoPrimario`, a pílula preta, o card branco, os 3 passos, o selo de seguro e o `_passo()` → Task 4.
- Faixa igual nas duas telas; tela inteira continua clicável → Task 4, Step 4.
- Teste existente que afirmava `find.text('Escaneie')` atualizado no mesmo passo → Task 4, Step 1.
- 3 controles na Aparência + faixa no preview + aviso de contraste que não bloqueia → Task 5.
- Contraste WCAG como função pura → Task 1.
- Hex inválido cai na cor de reserva do `corDeHex` → Tasks 4 e 5.

Fora de escopo, conforme o spec: animação da faixa, faixa no topo, mais de uma faixa, frase por mídia, agendamento de frase.
