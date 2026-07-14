# Reorganização da aba Propaganda — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganizar as subabas "Conteúdo da tela" e "Barra superior" da aba Propaganda seguindo exatamente o padrão visual das abas Comunicação e Aparência, sem alterar funcionalidades.

**Architecture:** Toda a mudança é de apresentação, dentro de `lib/funcionalidades/configuracoes/apresentacao/componentes/`. O card `SecaoConfiguracoes` ganha um slot `acao` no cabeçalho (para o interruptor) e `filho` opcional. Os três editores de formato (carrossel/letreiro/parceiro) deixam de se embrulhar no próprio card e passam a ser conteúdo do card "Formato de exibição", com cabeçalhos internos "Configure o …". Nenhum controlador, entidade ou repositório muda.

**Tech Stack:** Flutter ≥ 3.22, Dart ≥ 3.4, Riverpod, flutter_test. Sem codegen (nenhum arquivo freezed é tocado — NÃO rodar build_runner; nesta máquina ele rebaixa o pubspec.lock).

## Global Constraints

- Diretório de trabalho de todos os comandos: `D:\constel-pay-main\constel-pay-main` (raiz do git é a pasta aninhada).
- Branch de trabalho: `feat/reorganiza-aba-propaganda`, criado a partir de `feat/sessao-2026-07-14` (as telas de propaganda vivem só nesse branch).
- Commits SEM linha `Co-Authored-By` (regra do repo).
- Nenhum arquivo de código pode passar de 600 linhas.
- Todos os textos visíveis em pt-BR.
- Não alterar regras de negócio, controladores, entidades, repositórios, nem remover opções.
- Não criar padrões visuais novos: reutilizar `SecaoConfiguracoes`, `BotaoPrimario`, `BotaoSecundario`, `EstadoVazio`, `CartaoFormatoPublicidade`, container lilás (`CoresApp.lilasClaro`, raio 12, padding 12 — mesmo padrão do bloco "Estilo visual" do `EditorLetreiro`), bordas `CoresApp.bordaCard`, raios 16/18.
- Antes de cada commit: `dart format .`, `flutter analyze` e os testes indicados na task devem passar. NUNCA commitar o `pubspec.lock` se ele aparecer modificado.
- O working tree tem `windows/flutter/generated_plugin_registrant.cc` e `generated_plugins.cmake` modificados — NÃO incluí-los em nenhum commit (são gerados; deixar como estão).
- Testes Flutter: cuidado com `skipOffstage` (ListView desmonta filhos fora do viewport — os testes existentes usam superfícies altas via `tester.view.physicalSize`) e com `runAsync` + timers (drenar timers antes do fim do teste).

---

### Task 0: Branch de trabalho

**Files:** nenhum.

- [ ] **Step 1: Criar o branch**

```bash
cd "D:\constel-pay-main\constel-pay-main"
git checkout feat/sessao-2026-07-14
git checkout -b feat/reorganiza-aba-propaganda
```

Expected: `Switched to a new branch 'feat/reorganiza-aba-propaganda'`.

---

### Task 1: `SecaoConfiguracoes` com `acao` no cabeçalho e `filho` opcional

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/secao_configuracoes.dart`
- Test (create): `test/funcionalidades/configuracoes/secao_configuracoes_test.dart`

**Interfaces:**
- Consumes: nada novo.
- Produces: `SecaoConfiguracoes({required String titulo, String? descricao, Widget? acao, Widget? filho})`. `acao` é renderizada à direita do bloco título/descrição, na mesma linha do cabeçalho; `filho` agora é opcional (card só-cabeçalho é válido). Chamadas existentes com `filho:` nomeado continuam compilando sem mudança.

- [ ] **Step 1: Escrever os testes que falham**

Criar `test/funcionalidades/configuracoes/secao_configuracoes_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/secao_configuracoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget filho) => MaterialApp(home: Scaffold(body: filho));

void main() {
  testWidgets('mostra titulo, descricao e filho', (tester) async {
    await tester.pumpWidget(_app(const SecaoConfiguracoes(
      titulo: 'Título',
      descricao: 'Descrição curta.',
      filho: Text('conteúdo'),
    )));
    expect(find.text('Título'), findsOneWidget);
    expect(find.text('Descrição curta.'), findsOneWidget);
    expect(find.text('conteúdo'), findsOneWidget);
  });

  testWidgets('acao fica no cabecalho, a direita do titulo', (tester) async {
    await tester.pumpWidget(_app(SecaoConfiguracoes(
      titulo: 'Título',
      descricao: 'Descrição.',
      acao: Switch(value: true, onChanged: (_) {}),
    )));
    expect(find.byType(Switch), findsOneWidget);
    final titulo = tester.getCenter(find.text('Título'));
    final acao = tester.getCenter(find.byType(Switch));
    expect(acao.dx, greaterThan(titulo.dx),
        reason: 'a acao fica alinhada a direita do cabecalho');
  });

  testWidgets('card so com cabecalho (sem filho) monta sem erro',
      (tester) async {
    await tester
        .pumpWidget(_app(const SecaoConfiguracoes(titulo: 'Só cabeçalho')));
    expect(find.text('Só cabeçalho'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cabecalho com acao nao estoura em largura estreita',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(SecaoConfiguracoes(
      titulo: 'Publicidade na barra superior',
      descricao: 'Descrição longa o bastante para quebrar em mais de uma '
          'linha em uma janela bem estreita.',
      acao: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(
            child: Text('Exibir publicidade na barra',
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Switch(value: false, onChanged: (_) {}),
        ],
      ),
    )));
    expect(tester.takeException(), isNull,
        reason: 'o cabecalho precisa ceder espaco em vez de estourar');
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

```bash
flutter test test/funcionalidades/configuracoes/secao_configuracoes_test.dart
```

Expected: FAIL — `acao` e `filho` opcional não existem ainda (erro de compilação "No named parameter with the name 'acao'").

- [ ] **Step 3: Implementar**

Substituir o conteúdo de `secao_configuracoes.dart` por:

```dart
import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';

/// Card de grupo das abas de Configurações: título, descrição curta opcional,
/// ação opcional no cabeçalho (ex.: interruptor) e o conteúdo do grupo, com o
/// mesmo acabamento dos cards do app.
class SecaoConfiguracoes extends StatelessWidget {
  const SecaoConfiguracoes({
    super.key,
    required this.titulo,
    this.descricao,
    this.acao,
    this.filho,
  });

  final String titulo;
  final String? descricao;

  /// Widget alinhado à direita do cabeçalho, na mesma linha do título.
  final Widget? acao;

  /// Conteúdo do card; opcional para cards só de cabeçalho (título + ação).
  final Widget? filho;

  @override
  Widget build(BuildContext context) {
    final cabecalho = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        if (descricao != null) ...[
          const SizedBox(height: 2),
          Text(
            descricao!,
            style: const TextStyle(
                fontSize: 11.5, color: CoresApp.textoSecundario),
          ),
        ],
      ],
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CoresApp.bordaCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (acao == null)
            cabecalho
          else
            Row(
              children: [
                Expanded(child: cabecalho),
                const SizedBox(width: 12),
                Flexible(child: acao!),
              ],
            ),
          if (filho != null) ...[
            const SizedBox(height: 14),
            filho!,
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

```bash
flutter test test/funcionalidades/configuracoes/secao_configuracoes_test.dart
flutter analyze
```

Expected: PASS; analyze sem erros novos.

- [ ] **Step 5: Commit**

```bash
dart format lib/funcionalidades/configuracoes/apresentacao/componentes/secao_configuracoes.dart test/funcionalidades/configuracoes/secao_configuracoes_test.dart
git add lib/funcionalidades/configuracoes/apresentacao/componentes/secao_configuracoes.dart test/funcionalidades/configuracoes/secao_configuracoes_test.dart
git commit -m "feat: SecaoConfiguracoes com acao no cabecalho e filho opcional"
```

---

### Task 2: Reorganizar a subaba "Conteúdo da tela"

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/secao_conteudo_tela.dart` (só o método `build`; `_adicionar`, `_abrirAjuste`, `_nomeAmigavel` e `_cardMidia` ficam intactos)
- Test (modify): `test/funcionalidades/configuracoes/aba_propaganda_test.dart`

**Interfaces:**
- Consumes: `SecaoConfiguracoes` (Task 1, sem `acao` aqui), `CoresApp.lilasClaro`, `BotaoPrimario`, `BotaoSecundario`, `EstadoVazio` — todos já importados no arquivo.
- Produces: nada consumido por outras tasks.

Mudanças (espelham o spec):
1. Descrição do cabeçalho vira o texto do spec: `'Configure as imagens, GIFs e vídeos exibidos enquanto o terminal aguarda um atendimento.'` (antes: "…estiver aguardando um atendimento.").
2. Subtítulo `'Orientação da mídia'` (13/w800 — mesmo estilo dos subtítulos "Banners"/"Mensagens" dos editores) substitui o rótulo inline `'Tela do totem:'`; o `SegmentedButton` Em pé/Deitada fica logo abaixo, inalterado.
3. As orientações do formato vão para um bloco informativo discreto: `Container` com `CoresApp.lilasClaro`, raio 12, padding 12 (mesmo tratamento do bloco "Estilo visual" do `EditorLetreiro`), com `Key('bloco_orientacoes')`. Os textos atuais são preservados literalmente (os testes existentes dependem de `'Formato indicado para terminais verticais.'` e `textContaining('1080 x 1920')`).
4. Subtítulo `'Mídias'` (13/w800) antes da lista de cards. Cards e ações inalterados.

- [ ] **Step 1: Escrever o teste que falha**

Adicionar ao final do `main()` de `test/funcionalidades/configuracoes/aba_propaganda_test.dart`:

```dart
  testWidgets(
      'Conteudo da tela usa a nova hierarquia: orientacao, bloco informativo '
      'e lista de midias', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: SecaoConteudoTela())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
        find.text('Configure as imagens, GIFs e vídeos exibidos enquanto o '
            'terminal aguarda um atendimento.'),
        findsOneWidget,
        reason: 'descricao do cabecalho segue o texto definido');
    expect(find.text('Orientação da mídia'), findsOneWidget);
    expect(find.text('Tela do totem:'), findsNothing,
        reason: 'o rotulo antigo saiu; a orientacao virou subtitulo');
    expect(find.byKey(const Key('bloco_orientacoes')), findsOneWidget,
        reason: 'as recomendacoes moram num bloco informativo discreto');
    expect(find.text('Mídias'), findsOneWidget,
        reason: 'a lista de midias ganha subtitulo proprio');
  });
```

- [ ] **Step 2: Rodar e ver falhar**

```bash
flutter test test/funcionalidades/configuracoes/aba_propaganda_test.dart
```

Expected: FAIL no teste novo ('Orientação da mídia' não encontrado); os demais passam.

- [ ] **Step 3: Implementar**

Em `secao_conteudo_tela.dart`, substituir o método `build` inteiro por:

```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(provedorMidias);
    final tema = ref.watch(provedorTema);
    final deitada = tema.orientacaoTela == OrientacaoTela.horizontal;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SecaoConfiguracoes(
          titulo: 'Conteúdo da tela',
          descricao: 'Configure as imagens, GIFs e vídeos exibidos enquanto '
              'o terminal aguarda um atendimento.',
          filho: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Orientação da mídia',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              SegmentedButton<OrientacaoTela>(
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: const [
                  ButtonSegment(
                      value: OrientacaoTela.vertical, label: Text('Em pé')),
                  ButtonSegment(
                      value: OrientacaoTela.horizontal,
                      label: Text('Deitada')),
                ],
                selected: {tema.orientacaoTela},
                onSelectionChanged: (selecao) => ref
                    .read(provedorTema.notifier)
                    .atualizar(tema.copyWith(orientacaoTela: selecao.single)),
              ),
              const SizedBox(height: 12),
              // Bloco informativo discreto com as recomendações do formato,
              // no mesmo tratamento do bloco "Estilo visual" do letreiro.
              Container(
                key: const Key('bloco_orientacoes'),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CoresApp.lilasClaro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deitada
                          ? 'Formato indicado para terminais horizontais.'
                          : 'Formato indicado para terminais verticais.',
                      style: const TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ideal: mídia ${deitada ? 'deitada (paisagem), 1920 x 1080' : 'em pé (retrato), 1080 x 1920'} px. '
                      'Vídeos em MP4 com codec H.264, 30 fps e no máximo 6 Mbps. GIF é '
                      'aceito e roda em loop até a duração acabar. No ajuste Automático a '
                      'mídia aparece inteira, sem corte: a sobra vira um fundo borrado da '
                      'própria imagem (vídeos usam a cor primária do tema). Toque em '
                      '"Ajustar…" para trocar o modo, o fundo da sobra, o corte, o zoom '
                      'e o giro.',
                      style: const TextStyle(
                          fontSize: 11.5, color: CoresApp.textoSecundario),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Mídias',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (estado.midias.isEmpty && !estado.carregando)
                const EstadoVazio(
                  emoji: '🎬',
                  titulo: 'Nenhuma mídia configurada',
                  mensagem:
                      'Sem mídias, a tela de espera mostra a logo, o nome '
                      'do restaurante e a faixa de pagamento.',
                )
              else
                ...estado.midias.asMap().entries.map((entrada) =>
                    _cardMidia(context, ref, entrada.value, entrada.key + 1)),
              const SizedBox(height: 12),
              BotaoPrimario(
                  rotulo: '+ Adicionar mídia',
                  aoTocar: () => _adicionar(context, ref)),
              const SizedBox(height: 10),
              BotaoSecundario(
                rotulo: 'Visualizar sequência',
                aoTocar: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const PaginaPropaganda(preview: true)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
```

Nota: nenhum import novo é necessário (todos já existem no arquivo).

- [ ] **Step 4: Rodar e ver passar**

```bash
flutter test test/funcionalidades/configuracoes/aba_propaganda_test.dart
flutter analyze
```

Expected: PASS em todos (incluindo os testes antigos de orientação/overflow, que dependem dos textos preservados).

- [ ] **Step 5: Commit**

```bash
dart format lib/funcionalidades/configuracoes/apresentacao/componentes/secao_conteudo_tela.dart test/funcionalidades/configuracoes/aba_propaganda_test.dart
git add lib/funcionalidades/configuracoes/apresentacao/componentes/secao_conteudo_tela.dart test/funcionalidades/configuracoes/aba_propaganda_test.dart
git commit -m "feat: reorganiza Conteudo da tela com bloco informativo e subtitulos"
```

---

### Task 3: Editores sem card próprio, dentro do card "Formato de exibição"

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/editor_carrossel.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/editor_letreiro.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/editor_parceiro.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/secao_barra_superior.dart` (`_secaoFormatos` e `build`)
- Test (modify): `test/funcionalidades/configuracoes/editores_publicidade_test.dart`
- Test (modify): `test/funcionalidades/configuracoes/secao_barra_superior_test.dart`

**Interfaces:**
- Consumes: construtores dos 3 editores (inalterados — mesmos parâmetros e callbacks).
- Produces: cada editor agora retorna uma `Column` com cabeçalho interno (subtítulo 13/w800 + descrição 11.5 secundária) em vez de um `SecaoConfiguracoes`. Cabeçalhos: `'Configure o carrossel'`, `'Configure o letreiro'`, `'Configure o espaço fixo'` (evita repetir o nome do formato já mostrado nos cards 1A/1B/1C). `_secaoFormatos` passa a renderizar o editor logo abaixo dos cards, no mesmo card.

- [ ] **Step 1: Atualizar os testes (falham primeiro)**

Em `editores_publicidade_test.dart`:

a) No grupo `EditorCarrossel`, substituir o teste `'titulo e descricao propria da secao sao exibidos'` por:

```dart
    testWidgets('cabecalho interno usa Configure o carrossel', (tester) async {
      await tester.pumpWidget(montar());
      expect(find.text('Configure o carrossel'), findsOneWidget);
      expect(find.text('Carrossel de banners'), findsNothing,
          reason: 'o nome do formato ja aparece no card 1A; nao repete');
      expect(
          find.text(
              'Alterne automaticamente campanhas dentro da barra superior.'),
          findsOneWidget);
    });
```

b) No grupo `EditorLetreiro`, no teste `'titulo, descricao e vazio mostram Nenhum conteúdo configurado.'`, trocar:

```dart
      expect(find.text('Letreiro de mensagens'), findsOneWidget);
```

por:

```dart
      expect(find.text('Configure o letreiro'), findsOneWidget);
      expect(find.text('Letreiro de mensagens'), findsNothing,
          reason: 'o nome do formato ja aparece no card 1B; nao repete');
```

c) No grupo `EditorParceiro`, no teste `'sem midia mostra Nenhum conteúdo configurado. e CTA Alterar mídia'`, trocar:

```dart
      expect(find.text('Espaço fixo de parceiro'), findsOneWidget);
```

por:

```dart
      expect(find.text('Configure o espaço fixo'), findsOneWidget);
      expect(find.text('Espaço fixo de parceiro'), findsNothing,
          reason: 'o nome do formato ja aparece no card 1C; nao repete');
```

d) Ainda no grupo `EditorCarrossel`, estender o teste `'dica de tamanho e aviso de 5 banners estao presentes'` com (pedido do usuário: dicas de tamanho visíveis na tela — ele gera as artes a partir delas):

```dart
      expect(
          find.text(
              'Formatos aceitos: JPG, PNG, WebP e GIF (o GIF anima em loop).'),
          findsOneWidget);
      expect(find.byKey(const Key('dicas_banners')), findsOneWidget,
          reason: 'dicas moram num bloco informativo discreto');
```

Em `secao_barra_superior_test.dart`, no teste `'monta com defaults…'`, substituir:

```dart
    // 'Carrossel de banners' aparece no card do formato E no título do
    // editor selecionado.
    expect(find.text('Carrossel de banners'), findsWidgets);
```

por:

```dart
    // 'Carrossel de banners' aparece só no card 1A; o editor usa o
    // cabeçalho interno 'Configure o carrossel'.
    expect(find.text('Carrossel de banners'), findsOneWidget);
    expect(find.text('Configure o carrossel'), findsOneWidget);
```

- [ ] **Step 2: Rodar e ver falhar**

```bash
flutter test test/funcionalidades/configuracoes/editores_publicidade_test.dart test/funcionalidades/configuracoes/secao_barra_superior_test.dart
```

Expected: FAIL nos testes editados ('Configure o carrossel' etc. não existem ainda).

- [ ] **Step 3: Implementar os editores**

Padrão de cabeçalho interno (repetir em cada editor; o import de `secao_configuracoes.dart` sai dos 3 arquivos):

Em **`editor_carrossel.dart`**, substituir o `return SecaoConfiguracoes(...)` do `build` — mantendo TODO o conteúdo atual da `Column` interna — por:

```dart
  @override
  Widget build(BuildContext context) {
    final banners = publicidade.banners;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configure o carrossel',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        const Text(
          'Alterne automaticamente campanhas dentro da barra superior.',
          style:
              TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _dropdown<int>(
              rotulo: 'Tempo entre banners',
              valor: publicidade.intervaloSegundos,
              opcoes: intervalosCarrossel,
              rotuloDe: (v) => '$v segundos',
              aoMudar: aoDefinirIntervalo,
            ),
            _dropdown<TransicaoCarrossel>(
              rotulo: 'Transição',
              valor: publicidade.transicao,
              opcoes: TransicaoCarrossel.values,
              rotuloDe: (v) => _rotulosTransicao[v]!,
              aoMudar: aoDefinirTransicao,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Banners',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 8),
        if (banners.isEmpty)
          const EstadoVazio(
              emoji: '🖼️', titulo: 'Nenhum conteúdo configurado.')
        else
          ...banners
              .asMap()
              .entries
              .map((entrada) => _cardBanner(entrada.value, entrada.key + 1)),
        const SizedBox(height: 8),
        // Dicas de geração da arte num bloco informativo discreto (mesmo
        // padrão do bloco de orientações do Conteúdo da tela).
        Container(
          key: const Key('dicas_banners'),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CoresApp.lilasClaro,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _rotulo('Recomendado: 384 × 192 px, proporção 2:1.'),
              const SizedBox(height: 4),
              _rotulo(
                  'Formatos aceitos: JPG, PNG, WebP e GIF (o GIF anima em loop).'),
              const SizedBox(height: 4),
              _rotulo(
                  'Recomendamos até 5 banners ativos para manter uma rotação rápida.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        BotaoSecundario(
            rotulo: '+ Adicionar banner', aoTocar: aoAdicionarBanners),
      ],
    );
  }
```

Remover o import `import 'secao_configuracoes.dart';`.

Em **`editor_letreiro.dart`**, mesma cirurgia no `build`: trocar o `return SecaoConfiguracoes(titulo: 'Letreiro de mensagens', descricao: 'Crie avisos…', filho: Column(...))` por uma `Column` com o cabeçalho interno no topo e o conteúdo atual em seguida:

```dart
  @override
  Widget build(BuildContext context) {
    final corSecundaria =
        TemaConstel.corDeHex(tema.corSecundaria, CoresApp.secundariaPadrao);
    final mensagens = publicidade.mensagens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configure o letreiro',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        const Text(
          'Crie avisos e divulgações sem precisar produzir imagens.',
          style:
              TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
        ),
        const SizedBox(height: 12),
        const Text('Mensagens',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        // ... daqui para baixo o conteúdo atual da Column permanece
        // idêntico (lista, + Adicionar mensagem, Velocidade/Separador,
        // _estiloVisual()).
      ],
    );
  }
```

(Manter literalmente todo o restante dos filhos atuais da `Column` — de `const SizedBox(height: 8)` após 'Mensagens' até `_estiloVisual()`.) Remover o import `import 'secao_configuracoes.dart';`.

Em **`editor_parceiro.dart`**, trocar o `return SecaoConfiguracoes(titulo: 'Espaço fixo de parceiro', …)` por:

```dart
  @override
  Widget build(BuildContext context) {
    final midia = publicidade.midiaParceiro;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configure o espaço fixo',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        const Text(
          'Exiba uma única publicidade continuamente durante o atendimento.',
          style:
              TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
        ),
        const SizedBox(height: 12),
        // ... conteúdo atual do filho permanece idêntico nesta task:
        // 'Publicidade atual', EstadoVazio/preview, nome do arquivo,
        // recomendação e Wrap de ações (a Task 4 refina este miolo).
      ],
    );
  }
```

Remover o import `import 'secao_configuracoes.dart';`.

- [ ] **Step 4: Integrar no card "Formato de exibição"**

Em `secao_barra_superior.dart`:

a) `_secaoFormatos` ganha os parâmetros do editor e o renderiza abaixo dos cards:

```dart
  Widget _secaoFormatos(PublicidadeBarra publicidade, TemaPersonalizado tema,
      ControladorPublicidade controlador) {
    final cartoes = [
      // ... os 3 CartaoFormatoPublicidade atuais, sem mudança ...
    ];
    return SecaoConfiguracoes(
      titulo: 'Formato de exibição',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, restricoes) {
              // ... exatamente o LayoutBuilder atual (empilha < 560px) ...
            },
          ),
          const SizedBox(height: 16),
          // Configuração do formato selecionado, na mesma sequência visual
          // dos cards (sem card separado nem título repetido).
          _editorAtual(publicidade, tema, controlador),
        ],
      ),
    );
  }
```

b) No `build`, a lista `secoes` perde a entrada separada do editor:

```dart
              final secoes = [
                _secaoToggle(publicidade, controlador),
                const SizedBox(height: 16),
                _secaoFormatos(publicidade, tema, controlador),
              ];
```

- [ ] **Step 5: Rodar e ver passar**

```bash
flutter test test/funcionalidades/configuracoes/editores_publicidade_test.dart test/funcionalidades/configuracoes/secao_barra_superior_test.dart
flutter analyze
```

Expected: PASS em todos; analyze limpo.

- [ ] **Step 6: Commit**

```bash
dart format lib/funcionalidades/configuracoes/apresentacao/componentes test/funcionalidades/configuracoes
git add lib/funcionalidades/configuracoes/apresentacao/componentes/editor_carrossel.dart lib/funcionalidades/configuracoes/apresentacao/componentes/editor_letreiro.dart lib/funcionalidades/configuracoes/apresentacao/componentes/editor_parceiro.dart lib/funcionalidades/configuracoes/apresentacao/componentes/secao_barra_superior.dart test/funcionalidades/configuracoes/editores_publicidade_test.dart test/funcionalidades/configuracoes/secao_barra_superior_test.dart
git commit -m "feat: configuracao do formato na mesma sequencia do card Formato de exibicao"
```

---

### Task 4: Informações úteis da mídia do parceiro

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/editor_parceiro.dart`
- Test (modify): `test/funcionalidades/configuracoes/editores_publicidade_test.dart`

**Interfaces:**
- Consumes: `EditorParceiro` da Task 3; `BotaoPrimario` (novo import: `../../../../compartilhado/widgets/botao_primario.dart`).
- Produces: linha principal `'{GIF carregado|Imagem carregada}[ • L × A px]'` (dimensões aparecem quando o arquivo decodifica); nome do arquivo vira texto secundário (10.5, `CoresApp.textoSecundario`) com `Tooltip` do próprio nome; ações viram `BotaoPrimario('Alterar mídia', expandido: false)` + `TextButton('Ajustar…')` + `TextButton` destrutivo `'Remover mídia'`. O rótulo interno `'Publicidade atual'` sai (redundante com o cabeçalho da Task 3).

- [ ] **Step 1: Atualizar/adicionar testes (falham primeiro)**

No grupo `EditorParceiro` de `editores_publicidade_test.dart`, substituir o teste `'com midia mostra previa e botoes Alterar/Ajustar/Remover'` por estes dois (adicionar `import 'dart:io';` no topo do arquivo):

```dart
    testWidgets(
        'com midia prioriza tipo carregado; nome do arquivo vira texto '
        'secundario com tooltip', (tester) async {
      var alterar = false, remover = false, ajustar = false;
      const midia = MidiaPropaganda(
          id: 'p1',
          tipo: TipoMidia.imagem,
          caminho: '/p/parceiro.png',
          ordem: 0);
      await tester.pumpWidget(_app(EditorParceiro(
        publicidade: const PublicidadeBarra(midiaParceiro: midia),
        aoAlterarMidia: () => alterar = true,
        aoRemoverMidia: () => remover = true,
        aoAjustarMidia: () => ajustar = true,
      )));
      expect(find.text('Nenhum conteúdo configurado.'), findsNothing);
      // Arquivo inexistente: sem dimensões, mas o tipo aparece na frente.
      expect(find.text('Imagem carregada'), findsOneWidget);
      expect(find.text('parceiro.png'), findsOneWidget);
      expect(find.byTooltip('parceiro.png'), findsOneWidget,
          reason: 'o nome completo fica disponivel em tooltip');
      expect(find.text('Recomendado: 1040 × 128 px.'), findsOneWidget);
      await tester.tap(find.text('Alterar mídia'));
      expect(alterar, isTrue);
      await tester.tap(find.text('Ajustar…'));
      expect(ajustar, isTrue);
      await tester.tap(find.text('Remover mídia'));
      expect(remover, isTrue);
    });

    testWidgets('midia GIF e rotulada como GIF carregado, com as dimensoes '
        'reais do arquivo', (tester) async {
      // PNG 1x1 transparente serviria, mas o rótulo segue a EXTENSÃO .gif —
      // o widget não valida o conteúdo, então um PNG com nome .gif basta
      // para exercitar rótulo + decodificação juntos.
      const bytesPng1x1 = <int>[
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00,
        0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,
        0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89,
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63,
        0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4,
        0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60,
        0x82,
      ];
      final dir = Directory.systemTemp.createTempSync('parceiro_teste');
      addTearDown(() => dir.deleteSync(recursive: true));
      final arquivo = File('${dir.path}/anuncio.gif')
        ..writeAsBytesSync(bytesPng1x1);

      final midia = MidiaPropaganda(
          id: 'p1', tipo: TipoMidia.imagem, caminho: arquivo.path, ordem: 0);
      await tester.runAsync(() async {
        await tester.pumpWidget(_app(EditorParceiro(
          publicidade: PublicidadeBarra(midiaParceiro: midia),
          aoAlterarMidia: () {},
          aoRemoverMidia: () {},
          aoAjustarMidia: () {},
        )));
        // Deixa o FileImage ler e decodificar o arquivo de verdade.
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      expect(find.text('GIF carregado • 1 × 1 px'), findsOneWidget);
    });
```

Além disso, estender o teste existente `'sem midia mostra Nenhum conteúdo configurado. e CTA Alterar mídia'` com (pedido do usuário: dicas visíveis antes de adicionar):

```dart
      expect(find.byKey(const Key('dicas_parceiro')), findsOneWidget,
          reason: 'dicas de tamanho visiveis antes mesmo de adicionar');
      expect(find.text('Recomendado: 1040 × 128 px.'), findsOneWidget);
      expect(
          find.text('Formatos aceitos: JPG, PNG, WebP e GIF '
              '(o GIF anima em loop contínuo).'),
          findsOneWidget);
```

- [ ] **Step 2: Rodar e ver falhar**

```bash
flutter test test/funcionalidades/configuracoes/editores_publicidade_test.dart
```

Expected: FAIL nos 2 testes do parceiro ('Imagem carregada' não existe).

- [ ] **Step 3: Implementar**

Substituir o conteúdo de `editor_parceiro.dart` por:

```dart
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/feedback/estado_vazio.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../propaganda/dominio/entidades/publicidade_barra.dart';

/// Editor do formato "Espaço fixo de parceiro" (1C). Controlado: recebe o
/// rascunho da publicidade + callbacks, sem estado próprio de domínio.
/// Diferente do carrossel/letreiro: nunca mostra lista, ordenação, tempo ou
/// indicadores — só a mídia única do parceiro.
class EditorParceiro extends StatelessWidget {
  const EditorParceiro({
    super.key,
    required this.publicidade,
    required this.aoAlterarMidia,
    required this.aoRemoverMidia,
    required this.aoAjustarMidia,
  });

  final PublicidadeBarra publicidade;
  final VoidCallback aoAlterarMidia;
  final VoidCallback aoRemoverMidia;
  final VoidCallback aoAjustarMidia;

  Widget _rotulo(String texto) => Text(texto,
      style: const TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario));

  @override
  Widget build(BuildContext context) {
    final midia = publicidade.midiaParceiro;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configure o espaço fixo',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        const Text(
          'Exiba uma única publicidade continuamente durante o atendimento.',
          style: TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
        ),
        const SizedBox(height: 12),
        // Dicas de geração da arte sempre visíveis — inclusive antes de
        // adicionar a mídia, que é quando o operador produz o arquivo.
        Container(
          key: const Key('dicas_parceiro'),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CoresApp.lilasClaro,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _rotulo('Recomendado: 1040 × 128 px.'),
              const SizedBox(height: 4),
              _rotulo('Formatos aceitos: JPG, PNG, WebP e GIF '
                  '(o GIF anima em loop contínuo).'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (midia == null)
          EstadoVazio(
            emoji: '🎯',
            titulo: 'Nenhum conteúdo configurado.',
            acao: BotaoSecundario(
                rotulo: 'Alterar mídia',
                aoTocar: aoAlterarMidia,
                expandido: false),
          )
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1040 / 128,
              child: Image.file(
                File(midia.caminho),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: CoresApp.lilasClaro,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _InfoMidiaParceiro(caminho: midia.caminho),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BotaoPrimario(
                  rotulo: 'Alterar mídia',
                  aoTocar: aoAlterarMidia,
                  expandido: false),
              TextButton(
                onPressed: aoAjustarMidia,
                child: const Text('Ajustar…'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: CoresApp.erro),
                onPressed: aoRemoverMidia,
                child: const Text('Remover mídia'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Linha de informações da mídia do parceiro: prioriza o que é útil ao
/// operador ("GIF carregado • 1040 × 128 px") e rebaixa o nome técnico do
/// arquivo a texto secundário com tooltip. As dimensões são resolvidas do
/// próprio arquivo; se ele não decodificar, a linha fica só com o tipo.
class _InfoMidiaParceiro extends StatefulWidget {
  const _InfoMidiaParceiro({required this.caminho});

  final String caminho;

  @override
  State<_InfoMidiaParceiro> createState() => _InfoMidiaParceiroState();
}

class _InfoMidiaParceiroState extends State<_InfoMidiaParceiro> {
  Size? _dimensoes;
  ImageStream? _stream;
  ImageStreamListener? _ouvinte;

  @override
  void initState() {
    super.initState();
    _resolver();
  }

  @override
  void didUpdateWidget(covariant _InfoMidiaParceiro antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.caminho != widget.caminho) {
      _pararDeOuvir();
      setState(() => _dimensoes = null);
      _resolver();
    }
  }

  void _resolver() {
    final stream =
        FileImage(File(widget.caminho)).resolve(ImageConfiguration.empty);
    final ouvinte = ImageStreamListener(
      (info, _) {
        if (mounted) {
          setState(() => _dimensoes = Size(
              info.image.width.toDouble(), info.image.height.toDouble()));
        }
        info.dispose();
      },
      // Arquivo ausente ou inválido: sem dimensões, sem erro na tela (a
      // prévia acima já mostra o placeholder de imagem quebrada).
      onError: (_, __) {},
    );
    stream.addListener(ouvinte);
    _stream = stream;
    _ouvinte = ouvinte;
  }

  void _pararDeOuvir() {
    final ouvinte = _ouvinte;
    if (ouvinte != null) _stream?.removeListener(ouvinte);
    _stream = null;
    _ouvinte = null;
  }

  @override
  void dispose() {
    _pararDeOuvir();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nomeArquivo = widget.caminho.split(RegExp(r'[\\/]')).last;
    final ehGif = widget.caminho.toLowerCase().endsWith('.gif');
    final tipo = ehGif ? 'GIF carregado' : 'Imagem carregada';
    final dimensoes = _dimensoes;
    final principal = dimensoes == null
        ? tipo
        : '$tipo • ${dimensoes.width.round()} × ${dimensoes.height.round()} px';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(principal,
            style:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Tooltip(
          message: nomeArquivo,
          child: Text(nomeArquivo,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 10.5, color: CoresApp.textoSecundario)),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

```bash
flutter test test/funcionalidades/configuracoes/editores_publicidade_test.dart test/funcionalidades/configuracoes/secao_barra_superior_test.dart
flutter analyze
```

Expected: PASS. Se o teste das dimensões reais ficar instável nesta máquina (decodificação depende de I/O real via `runAsync`), aumentar o delay para 600 ms; se ainda instável, remover só esse teste e registrar a pendência no commit.

- [ ] **Step 5: Commit**

```bash
dart format lib/funcionalidades/configuracoes/apresentacao/componentes/editor_parceiro.dart test/funcionalidades/configuracoes/editores_publicidade_test.dart
git add lib/funcionalidades/configuracoes/apresentacao/componentes/editor_parceiro.dart test/funcionalidades/configuracoes/editores_publicidade_test.dart
git commit -m "feat: midia do parceiro prioriza tipo e dimensoes sobre o nome do arquivo"
```

---

### Task 5: Interruptor no cabeçalho e texto da prévia

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/secao_barra_superior.dart` (`_secaoToggle`)
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/previa_publicidade.dart` (só a string da descrição)
- Test (modify): `test/funcionalidades/configuracoes/secao_barra_superior_test.dart`

**Interfaces:**
- Consumes: `SecaoConfiguracoes.acao` (Task 1).
- Produces: interruptor com `Key('interruptor_publicidade')` no cabeçalho do card "Publicidade na barra superior"; rótulo `'Exibir publicidade na barra'` continua tocável (os testes tocam nesse texto). Descrição da prévia vira `'Veja como a publicidade será exibida na barra superior durante o atendimento.'`.

- [ ] **Step 1: Atualizar o teste (falha primeiro)**

Em `secao_barra_superior_test.dart`, no teste `'monta com defaults…'`, substituir:

```dart
    final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(toggle.value, isFalse);
```

por:

```dart
    final toggle = tester
        .widget<Switch>(find.byKey(const Key('interruptor_publicidade')));
    expect(toggle.value, isFalse);
    expect(find.byType(SwitchListTile), findsNothing,
        reason: 'o interruptor mora no cabecalho do card, nao num bloco '
            'proprio');
```

e remover o import de `SwitchListTile`? Não há import dedicado — `SwitchListTile` vem de material; nada a remover. Adicionar também, no mesmo teste:

```dart
    expect(
        find.text('Veja como a publicidade será exibida na barra superior '
            'durante o atendimento.'),
        findsOneWidget);
```

- [ ] **Step 2: Rodar e ver falhar**

```bash
flutter test test/funcionalidades/configuracoes/secao_barra_superior_test.dart
```

Expected: FAIL ('interruptor_publicidade' não existe).

- [ ] **Step 3: Implementar**

Em `secao_barra_superior.dart`, substituir `_secaoToggle` por:

```dart
  Widget _secaoToggle(
      PublicidadeBarra publicidade, ControladorPublicidade controlador) {
    return SecaoConfiguracoes(
      titulo: 'Publicidade na barra superior',
      descricao:
          'Exiba campanhas, eventos, avisos, marcas ou parceiros durante o '
          'atendimento.',
      // O interruptor mora no cabeçalho para o card não virar um bloco
      // inteiro só para um switch.
      acao: MergeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => controlador.alternarAtiva(!publicidade.ativa),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Flexible(
                child: Text(
                  'Exibir publicidade na barra',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11.5, color: CoresApp.textoSecundario),
                ),
              ),
              Switch(
                key: const Key('interruptor_publicidade'),
                value: publicidade.ativa,
                onChanged: controlador.alternarAtiva,
              ),
            ],
          ),
        ),
      ),
    );
  }
```

Adicionar o import (se ainda não existir no arquivo):

```dart
import '../../../../aplicativo/tema/cores_app.dart';
```

Em `previa_publicidade.dart`, trocar:

```dart
      descricao:
          'Veja como a publicidade aparece na barra superior durante o atendimento.',
```

por:

```dart
      descricao: 'Veja como a publicidade será exibida na barra superior '
          'durante o atendimento.',
```

- [ ] **Step 4: Rodar e ver passar**

```bash
flutter test test/funcionalidades/configuracoes/secao_barra_superior_test.dart
flutter analyze
```

Expected: PASS em todos — inclusive os testes que tocam `find.text('Exibir publicidade na barra')` (o rótulo agora dispara o `GestureDetector`) e os de largura 480/1200 (sem overflow: título usa `Expanded`, ação usa `Flexible`).

- [ ] **Step 5: Commit**

```bash
dart format lib/funcionalidades/configuracoes/apresentacao/componentes/secao_barra_superior.dart lib/funcionalidades/configuracoes/apresentacao/componentes/previa_publicidade.dart test/funcionalidades/configuracoes/secao_barra_superior_test.dart
git add lib/funcionalidades/configuracoes/apresentacao/componentes/secao_barra_superior.dart lib/funcionalidades/configuracoes/apresentacao/componentes/previa_publicidade.dart test/funcionalidades/configuracoes/secao_barra_superior_test.dart
git commit -m "feat: interruptor da publicidade no cabecalho do card"
```

---

### Task 6: Validação final e revisão adversarial

**Files:** nenhum novo (correções pontuais se a validação apontar algo).

- [ ] **Step 1: Formatação e análise completas**

```bash
cd "D:\constel-pay-main\constel-pay-main"
dart format .
flutter analyze
```

Expected: `No issues found!`. Se `dart format` tocar arquivos fora do escopo desta entrega, NÃO commitá-los.

- [ ] **Step 2: Suíte completa**

```bash
flutter test
```

Expected: todos os testes passam (a suíte inteira, não só configurações — `barra_superior_test.dart` e `conteudo_publicidade_test.dart` dependem indiretamente da publicidade).

- [ ] **Step 3: Conferir limites de tamanho**

```bash
wc -l lib/funcionalidades/configuracoes/apresentacao/componentes/secao_barra_superior.dart lib/funcionalidades/configuracoes/apresentacao/componentes/secao_conteudo_tela.dart lib/funcionalidades/configuracoes/apresentacao/componentes/editor_parceiro.dart
```

Expected: todos < 600 linhas.

- [ ] **Step 4: Revisão adversarial (checklist do CLAUDE.md)**

Verificar e corrigir antes de encerrar:
- Nenhuma tela/fluxo novo criado; nenhuma funcionalidade ou opção removida (contar: orientação, duração, ajustar, mover, ativar, excluir, adicionar, visualizar; toggle, 3 formatos, editores completos, prévia, reproduzir, aplicar/descartar).
- Nenhum texto visível fora do pt-BR; nenhum overflow nos tamanhos 320/480/800/1200 (cobertos por testes).
- `pubspec.lock` intacto (`git status` não pode listá-lo).
- `windows/flutter/*` gerados NÃO commitados.
- Sem import morto (os 3 editores perderam `secao_configuracoes.dart`), sem TODO, sem print.

- [ ] **Step 5: Commit final (se houve correções) e resumo**

Se a validação exigiu ajustes: `git add` apenas dos arquivos corrigidos + `git commit -m "fix: ajustes da validacao final da aba Propaganda"`. Relatar no formato do CLAUDE.md (arquivos alterados, comandos executados, resultados, pendências).

---

## Self-Review (executada na escrita do plano)

- **Cobertura do spec:** cabeçalho/descrição de Conteúdo da tela → Task 2; orientação como controle segmentado → Task 2 (mantido); bloco informativo discreto → Task 2; lista de mídias → já conforme (mantida); ações da seção → já conforme (mantidas); duas colunas com prévia fixa → já existente (mantida); interruptor no cabeçalho → Task 5; cards 1A/1B/1C com borda/check/identificador → já existentes (mantidos); config imediatamente abaixo dos cards sem repetir nomes → Task 3; parceiro com "Configure o espaço fixo" + tipo/dimensões/tooltip + ações principal/secundária/destrutiva + confirmação de remoção → Tasks 3–4 (confirmação já existe em `_confirmarRemocao`); prévia com título/descrição/simulação/Reproduzir e atualização ao vivo → já existente, só o texto muda (Task 5).
- **"Reduzir textos excessivos" nos cards de formato:** os textos atuais já são curtos (1 linha de descrição + 1 de complemento); nenhum corte adicional para não mexer em copy aprovada.
- **Tipos consistentes:** `acao`/`filho` de `SecaoConfiguracoes` usados nas Tasks 2/3/5 conforme definidos na Task 1; assinaturas dos editores não mudam.
- **Sem placeholders:** os trechos "conteúdo atual permanece idêntico" apontam exatamente o intervalo preservado do arquivo lido — não são trabalho a inventar, são instrução de NÃO mudar.
