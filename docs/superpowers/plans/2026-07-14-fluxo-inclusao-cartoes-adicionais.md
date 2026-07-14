# Fluxo de Inclusão de Cartões Adicionais — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Garantir que o usuário nunca fique sem ação durante a inclusão de cartões/comandas adicionais: sempre poder adicionar outro, tentar de novo, desistir preservando as comandas válidas, ou avançar para o pagamento.

**Architecture:** O fluxo é um chat dirigido por `ControladorFluxoPagamento` (StateNotifier + Riverpod) com etapas explícitas no enum `EtapaFluxo`. Adicionamos 2 etapas novas (`semConsumo`, `erroLeitura`), 2 métodos novos no controlador (`tentarNovamente`, `continuarComCartoes`), e chips de ação por etapa em `AreaAcoes` (rodapé fixo). Nenhum campo novo no estado freezed — só enum e getters na parte manual da classe, então **NÃO rodar build_runner**.

**Tech Stack:** Flutter ≥3.22, Dart ≥3.4, Riverpod (StateNotifier), freezed (sem regeneração), flutter_test.

## Global Constraints

- Root git: `D:\constel-pay-main\constel-pay-main` (a pasta externa é só wrapper). Todos os caminhos abaixo são relativos a esse root.
- Criar branch novo antes de qualquer commit: `git checkout -b fluxo-cartoes-adicionais`. Commits SEM linha `Co-Authored-By` (preferência do usuário).
- **NÃO rodar `dart run build_runner`** — nesta máquina ele rebaixa o `pubspec.lock`. O plano não altera nenhuma classe `@freezed` de forma que exija regeneração (só adiciona valores de enum e getters no corpo manual da classe). Não commitar `pubspec.lock`.
- Idioma pt-BR em todos os textos visíveis; moeda `R$ 0,00` via `FormatadorMoeda`.
- O app nunca recalcula subtotal/serviço/desconto/total — só soma campos vindos da API. Não tocar nos getters de soma.
- Arquivos com menos de 600 linhas (o controlador tem 417; as adições cabem).
- Não alterar: visual do `CardScanner` (câmera), barra superior, splash, tema, telas de pagamento posteriores, cálculos, integração Pix.
- Não alterar os textos exatos definidos neste plano — os testes dependem deles.
- Ao final de cada task: `flutter test <arquivos da task>`; ao final do plano: `dart format .`, `flutter analyze`, `flutter test` completos.
- Testes de controlador usam `atrasoBot: Duration.zero` (padrão do arquivo de teste existente) — sem timers pendentes.

## Desenho do fluxo (referência para todas as tasks)

Etapas e chips no rodapé (`AreaAcoes`):

| Etapa | Situação | Chips (ordem) |
|---|---|---|
| `lendo`, sem cartões | primeira leitura | nenhum (só o scanner na conversa) |
| `lendo`, com cartões | leitura adicional | `Continuar com os cartões já adicionados` (discreto) |
| `aguardandoMaisCartoes` | comanda adicionada / duplicado | `Adicionar outro cartão` (secundário) + `Continuar para pagamento` (primário) |
| `semConsumo` | busca retornou vazio | `Tentar outro cartão` (secundário; primário se não houver cartões) + `Continuar com X cartão(ões) adicionado(s)` (primário, só se houver cartões) |
| `erroLeitura` | falha de API/leitura | `Tentar novamente` (secundário; primário se não houver cartões) + `Continuar com X cartão(ões) adicionado(s)` (primário, só se houver cartões) |

Nota de domínio: a API (`FonteConsumoAtendimento.consultar`) retorna lista vazia tanto para "cartão não existe" quanto para "sem consumo em aberto" — os casos 4 e 5 da spec colapsam na etapa `semConsumo`, com mensagem neutra "Nenhum consumo em aberto". Falhas de rede/servidor/autorização são o caso "erro de leitura" (`erroLeitura`).

Transições novas no controlador:
- `tentarNovamente()`: de `semConsumo`/`erroLeitura` → `lendo` + novo scanner. Preserva tudo.
- `continuarComCartoes()`: de `lendo`/`semConsumo`/`erroLeitura` com `selecionados.isNotEmpty` → `escolhaMetodo` (mesma sequência do `irParaPagamento`, extraída para `_avancarParaEscolhaMetodo()`).
- Duplicado (todos os atendimentos retornados já adicionados): mensagem "Cartão já adicionado" → `aguardandoMaisCartoes` (chips: Adicionar outro / Continuar para pagamento). Nada é duplicado.

---

### Task 1: Estado — novas etapas e rótulo plural

**Files:**
- Modify: `lib/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart`
- Test (create): `test/funcionalidades/chat/estado_fluxo_pagamento_test.dart`

**Interfaces:**
- Produces: valores de enum `EtapaFluxo.semConsumo` e `EtapaFluxo.erroLeitura`; getter `String get rotuloCartoesAdicionados` em `EstadoFluxoPagamento` (ex.: `'1 cartão adicionado'`, `'2 cartões adicionados'` — conta `selecionados`).

- [ ] **Step 0: Criar o branch**

```bash
cd D:\constel-pay-main\constel-pay-main
git checkout -b fluxo-cartoes-adicionais
```

- [ ] **Step 1: Escrever o teste que falha**

Criar `test/funcionalidades/chat/estado_fluxo_pagamento_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/cartao_consumo.dart';
import 'package:flutter_test/flutter_test.dart';

CartaoConsumo _cartao(String id) => CartaoConsumo(
      id: id,
      codigo: '00$id',
      nome: 'Comanda $id',
      pessoa: 'Mesa 1',
      emoji: '🧾',
      resumo: '',
      itens: const [],
      subtotalCentavos: 1000,
      servicoCentavos: 0,
      descontoCentavos: 0,
      totalCentavos: 1000,
      saldoCentavos: 1000,
      selecionado: true,
    );

void main() {
  test('rotuloCartoesAdicionados usa singular com 1 cartao', () {
    final estado = EstadoFluxoPagamento(cartoes: [_cartao('c1')]);
    expect(estado.rotuloCartoesAdicionados, '1 cartão adicionado');
  });

  test('rotuloCartoesAdicionados usa plural com 2 cartoes', () {
    final estado =
        EstadoFluxoPagamento(cartoes: [_cartao('c1'), _cartao('c2')]);
    expect(estado.rotuloCartoesAdicionados, '2 cartões adicionados');
  });

  test('rotuloCartoesAdicionados ignora cartoes pagos', () {
    final estado = EstadoFluxoPagamento(
        cartoes: [_cartao('c1'), _cartao('c2').copyWith(pago: true)]);
    expect(estado.rotuloCartoesAdicionados, '1 cartão adicionado');
  });

  test('enum possui as etapas de saida do modo de inclusao', () {
    expect(EtapaFluxo.values, contains(EtapaFluxo.semConsumo));
    expect(EtapaFluxo.values, contains(EtapaFluxo.erroLeitura));
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/chat/estado_fluxo_pagamento_test.dart`
Expected: FAIL (erro de compilação: `semConsumo`, `erroLeitura` e `rotuloCartoesAdicionados` não existem).

- [ ] **Step 3: Implementar**

Em `estado_fluxo_pagamento.dart`, alterar o enum (adicionar 2 valores após `aguardandoMaisCartoes`):

```dart
enum EtapaFluxo {
  inicial,
  lendo,
  aguardandoMaisCartoes,
  semConsumo,
  erroLeitura,
  escolhaMetodo,
  pixAguardando,
  processando,
  sucessoComRestante,
  sucessoCompleto,
  encerramento,
}
```

E adicionar o getter ao final do corpo da classe `EstadoFluxoPagamento` (após `totalCentavos`):

```dart
  /// Rótulo com plural correto para as ações "Continuar com X cartão(ões)".
  String get rotuloCartoesAdicionados {
    final quantidade = selecionados.length;
    return '$quantidade ${quantidade > 1 ? 'cartões adicionados' : 'cartão adicionado'}';
  }
```

NÃO alterar a factory `const factory EstadoFluxoPagamento({...})` — nenhum campo novo, nenhuma regeneração freezed.

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/funcionalidades/chat/estado_fluxo_pagamento_test.dart`
Expected: PASS (4 testes). Rodar também `flutter test test/funcionalidades/chat/` — os demais continuam verdes (enum só ganhou valores).

- [ ] **Step 5: Commit**

```bash
git add lib/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart test/funcionalidades/chat/estado_fluxo_pagamento_test.dart
git commit -m "feat: etapas semConsumo/erroLeitura e rotulo plural no estado do fluxo"
```

---

### Task 2: Controlador — transições, mensagens e novos métodos

**Files:**
- Modify: `lib/funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart`
- Test (modify): `test/funcionalidades/chat/controlador_fluxo_pagamento_test.dart`

**Interfaces:**
- Consumes: `EtapaFluxo.semConsumo`, `EtapaFluxo.erroLeitura`, `estado.rotuloCartoesAdicionados` (Task 1).
- Produces: `Future<void> tentarNovamente()` e `Future<void> continuarComCartoes()` públicos no `ControladorFluxoPagamento` (usados pela Task 4). Textos exatos de mensagens (usados nos testes de widget): pergunta `'Deseja incluir outro cartão nesta conta?'`; sem consumo `texto: 'Nenhum consumo em aberto'` + `subtexto: 'Não encontramos itens pendentes para o cartão $ref.'`; erro `texto: 'Não foi possível ler o cartão'` + `subtexto: falha.mensagem`; duplicado `texto: 'Cartão já adicionado'` + `subtexto: 'A comanda $ref já está incluída nesta conta.'`; bolha do cliente `'Continuar para pagamento · <subtotal>'`.

- [ ] **Step 1: Atualizar os 2 testes existentes que mudam de comportamento**

Em `test/funcionalidades/chat/controlador_fluxo_pagamento_test.dart`, substituir o teste `'lerComandaDigitada sem consumo mostra aviso e segue lendo'` por:

```dart
  test('lerComandaDigitada sem consumo vai para semConsumo com aviso', () async {
    fonteConsumo.resultado = const Sucesso([]);
    await controlador.iniciar();
    await controlador.lerComandaDigitada('505');
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.semConsumo);
    expect(estado.cartoes, isEmpty);
    expect(estado.mensagens.last.texto, 'Nenhum consumo em aberto');
    expect(estado.mensagens.last.subtexto, contains('505'));
  });
```

E substituir `'lerComandaDigitada com falha mostra a mensagem de erro'` por:

```dart
  test('lerComandaDigitada com falha vai para erroLeitura com a mensagem',
      () async {
    fonteConsumo.resultado = const Erro(FalhaNaoAutorizado());
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.erroLeitura);
    expect(estado.cartoes, isEmpty);
    expect(estado.mensagens.last.texto, 'Não foi possível ler o cartão');
    expect(estado.mensagens.last.subtexto, contains('não autorizado'));
  });
```

- [ ] **Step 2: Adicionar os testes novos (mesmo arquivo, antes do fechamento de `main`)**

```dart
  test('continuarComCartoes durante leitura adicional avanca para metodo',
      () async {
    await controlador.iniciar();
    await controlador.lerCartao();
    await controlador.lerOutroCartao();
    expect(controlador.state.etapa, EtapaFluxo.lendo);
    await controlador.continuarComCartoes();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.escolhaMetodo);
    expect(estado.selecionados, hasLength(1));
    expect(estado.subtotalCentavos, 13600);
    expect(estado.mensagens.any((m) => m.tipo == TipoMensagem.metodos), isTrue);
  });

  test('continuarComCartoes na primeira leitura e ignorado', () async {
    await controlador.iniciar();
    final quantidade = controlador.state.mensagens.length;
    await controlador.continuarComCartoes();
    expect(controlador.state.etapa, EtapaFluxo.lendo);
    expect(controlador.state.mensagens.length, quantidade);
  });

  test('tentarNovamente apos sem consumo volta ao scanner preservando cartoes',
      () async {
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    await controlador.lerOutroCartao();
    fonteConsumo.resultado = const Sucesso([]);
    await controlador.lerComandaDigitada('411');
    expect(controlador.state.etapa, EtapaFluxo.semConsumo);
    expect(controlador.state.cartoes, hasLength(1));
    await controlador.tentarNovamente();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.lendo);
    expect(estado.mensagens.last.tipo, TipoMensagem.scanner);
    expect(estado.selecionados, hasLength(1));
    expect(estado.subtotalCentavos, 4530);
  });

  test('tentarNovamente fora de semConsumo/erroLeitura e ignorado', () async {
    await controlador.iniciar();
    final quantidade = controlador.state.mensagens.length;
    await controlador.tentarNovamente();
    expect(controlador.state.mensagens.length, quantidade);
    expect(controlador.state.etapa, EtapaFluxo.lendo);
  });

  test('continuarComCartoes apos erro preserva comandas e avanca', () async {
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    await controlador.lerOutroCartao();
    fonteConsumo.resultado = const Erro(FalhaNaoAutorizado());
    await controlador.lerComandaDigitada('999');
    expect(controlador.state.etapa, EtapaFluxo.erroLeitura);
    expect(controlador.state.cartoes, hasLength(1));
    await controlador.continuarComCartoes();
    expect(controlador.state.etapa, EtapaFluxo.escolhaMetodo);
    expect(controlador.state.subtotalCentavos, 4530);
  });

  test('duplicado avisa, nao duplica e mantem os totais', () async {
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    final subtotal = controlador.state.subtotalCentavos;
    await controlador.lerOutroCartao();
    await controlador.lerComandaDigitada('502');
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.aguardandoMaisCartoes);
    expect(estado.cartoes, hasLength(1));
    expect(estado.subtotalCentavos, subtotal);
    expect(estado.mensagens.last.texto, 'Cartão já adicionado');
    expect(estado.mensagens.last.subtexto, contains('502'));
  });

  test('erro do leitor simulado esgotado vai para erroLeitura com saida',
      () async {
    await controlador.iniciar();
    await controlador.lerCartao();
    await controlador.lerOutroCartao();
    await controlador.lerCartao();
    await controlador.lerOutroCartao();
    await controlador.lerCartao();
    await controlador.lerOutroCartao();
    await controlador.lerCartao(); // mock esgotado -> falha
    expect(controlador.state.etapa, EtapaFluxo.erroLeitura);
    expect(controlador.state.selecionados, hasLength(3));
    await controlador.continuarComCartoes();
    expect(controlador.state.etapa, EtapaFluxo.escolhaMetodo);
  });
```

Nota: `lerOutroCartao()` guarda apenas `etapa == aguardandoMaisCartoes` — o fluxo do último teste funciona porque após a 3ª leitura a etapa é `aguardandoMaisCartoes` ("Esse foi o último cartão em aberto.").

- [ ] **Step 3: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/chat/controlador_fluxo_pagamento_test.dart`
Expected: FAIL (`continuarComCartoes`/`tentarNovamente` não existem; etapas erradas).

- [ ] **Step 4: Implementar no controlador**

Em `controlador_fluxo_pagamento.dart`:

**4a.** Em `lerCartao()`, trocar a pergunta e o destino do erro:

```dart
      sucesso: (cartao) {
        state = state.copyWith(
          cartoes: [...state.cartoes, cartao.copyWith(selecionado: true)],
          cartoesRestantes: _repositorioLeitura.cartoesRestantes,
        );
        _adicionar(_mensagem(TipoMensagem.leituraCartao,
            dados: {'comandaId': cartao.id}));
        _adicionar(_mensagem(TipoMensagem.texto,
            texto: state.cartoesRestantes > 0
                ? 'Deseja incluir outro cartão nesta conta?'
                : 'Esse foi o último cartão em aberto.'));
        state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
      },
      erro: (falha) {
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: '⚠️',
            texto: 'Não foi possível ler o cartão',
            subtexto: falha.mensagem));
        state = state.copyWith(etapa: EtapaFluxo.erroLeitura);
      },
```

**4b.** Substituir o corpo do `resultado.quando(...)` de `lerComandaDigitada()`:

```dart
    resultado.quando(
      sucesso: (atendimentos) {
        if (atendimentos.isEmpty) {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '🔎',
              texto: 'Nenhum consumo em aberto',
              subtexto:
                  'Não encontramos itens pendentes para o cartão $ref.'));
          state = state.copyWith(etapa: EtapaFluxo.semConsumo);
          return;
        }
        var adicionouNovo = false;
        for (final atendimento in atendimentos) {
          if (state.cartoes.any((c) => c.id == atendimento.id)) continue;
          final cartao = AdaptadorAtendimento.paraCartao(atendimento)
              .copyWith(selecionado: true);
          state = state.copyWith(cartoes: [...state.cartoes, cartao]);
          _adicionar(_mensagem(TipoMensagem.leituraCartao,
              dados: {'comandaId': cartao.id}));
          adicionouNovo = true;
        }
        if (!adicionouNovo) {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '🔁',
              texto: 'Cartão já adicionado',
              subtexto: 'A comanda $ref já está incluída nesta conta.'));
          state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
          return;
        }
        _adicionar(_mensagem(TipoMensagem.texto,
            texto: 'Deseja incluir outro cartão nesta conta?'));
        state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
      },
      erro: (falha) {
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: '⚠️',
            texto: 'Não foi possível ler o cartão',
            subtexto: falha.mensagem));
        state = state.copyWith(etapa: EtapaFluxo.erroLeitura);
      },
    );
```

**4c.** Em `lerOutroCartao()`, atualizar bolha do cliente e texto do bot:

```dart
  Future<void> lerOutroCartao() async {
    if (state.etapa != EtapaFluxo.aguardandoMaisCartoes) return;
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente, texto: 'Adicionar outro cartão'));
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          texto: 'Beleza! Aponte a câmera para o próximo código 👇'));
      _adicionar(_mensagem(TipoMensagem.scanner));
    });
  }
```

**4d.** Adicionar `tentarNovamente()` logo após `lerOutroCartao()`:

```dart
  /// Sai de um aviso (sem consumo / erro de leitura) de volta ao leitor,
  /// preservando todas as comandas já adicionadas.
  Future<void> tentarNovamente() async {
    if (state.etapa != EtapaFluxo.semConsumo &&
        state.etapa != EtapaFluxo.erroLeitura) {
      return;
    }
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente,
        texto: state.etapa == EtapaFluxo.semConsumo
            ? 'Tentar outro cartão'
            : 'Tentar novamente'));
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          texto: 'Beleza! Aponte a câmera para o próximo código 👇'));
      _adicionar(_mensagem(TipoMensagem.scanner));
    });
  }
```

**4e.** Substituir `irParaPagamento()` extraindo a sequência comum, e adicionar `continuarComCartoes()`:

```dart
  Future<void> irParaPagamento() async {
    if (state.etapa != EtapaFluxo.aguardandoMaisCartoes ||
        state.selecionados.isEmpty) {
      return;
    }
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente,
        texto:
            'Continuar para pagamento · ${FormatadorMoeda.formatar(state.subtotalCentavos)}'));
    await _avancarParaEscolhaMetodo();
  }

  /// Desiste da inclusão em andamento e avança usando só as comandas
  /// já adicionadas. Não remove nada e não altera totais.
  Future<void> continuarComCartoes() async {
    const etapasInclusao = [
      EtapaFluxo.lendo,
      EtapaFluxo.semConsumo,
      EtapaFluxo.erroLeitura,
    ];
    if (!etapasInclusao.contains(state.etapa) ||
        state.digitando ||
        state.selecionados.isEmpty) {
      return;
    }
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente,
        texto: 'Continuar com ${state.rotuloCartoesAdicionados}'));
    await _avancarParaEscolhaMetodo();
  }

  Future<void> _avancarParaEscolhaMetodo() async {
    _chaveIdempotencia = _uuid.v4();
    state = state.copyWith(etapa: EtapaFluxo.escolhaMetodo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          emoji: '💳',
          texto:
              'Como você quer pagar ${FormatadorMoeda.formatar(state.totalCentavos)}?',
          subtexto: state.servicoCentavos > 0
              ? 'Inclui ${FormatadorMoeda.formatar(state.servicoCentavos)} de serviço.'
              : null));
      _adicionar(_mensagem(TipoMensagem.metodos));
    });
  }
```

**4f.** Em `pagarRestante()`, alinhar o texto do bot (mesma frase da 4c/4d): trocar `'Beleza! Aponte para o próximo código 👇'` por `'Beleza! Aponte a câmera para o próximo código 👇'`.

- [ ] **Step 5: Rodar e ver passar**

Run: `flutter test test/funcionalidades/chat/controlador_fluxo_pagamento_test.dart`
Expected: PASS (todos, incluindo os pré-existentes — `'não duplica cartão já adicionado'` e `'foto ja carregada...'` continuam válidos porque o caminho duplicado segue em `aguardandoMaisCartoes`).

- [ ] **Step 6: Commit**

```bash
git add lib/funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart test/funcionalidades/chat/controlador_fluxo_pagamento_test.dart
git commit -m "feat: acoes de tentar novamente e continuar com cartoes no fluxo de inclusao"
```

---

### Task 3: ChipAcao — variante discreta

**Files:**
- Modify: `lib/funcionalidades/chat/apresentacao/componentes/chip_acao.dart`
- Test (modify): `test/funcionalidades/chat/componentes_chat_2_test.dart`

**Interfaces:**
- Produces: parâmetro `bool discreto` (default `false`) em `ChipAcao` — sem fundo, sem borda, sem sombra; texto na cor primária. Usado pela Task 4 para a ação de desistência.

- [ ] **Step 1: Escrever o teste que falha**

Em `componentes_chat_2_test.dart`, adicionar dentro de `main` (seguir o padrão dos testes de `ChipAcao` existentes no arquivo):

```dart
  testWidgets('ChipAcao discreto renderiza sem borda e dispara o toque',
      (tester) async {
    var tocado = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChipAcao(
          rotulo: 'Continuar com os cartões já adicionados',
          aoTocar: () => tocado = true,
          discreto: true,
        ),
      ),
    ));
    await tester.tap(find.text('Continuar com os cartões já adicionados'));
    expect(tocado, isTrue);
    final material = tester.widget<Material>(find
        .ancestor(of: find.byType(InkWell), matching: find.byType(Material))
        .first);
    expect(material.color, Colors.transparent);
  });
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/chat/componentes_chat_2_test.dart`
Expected: FAIL (parâmetro `discreto` não existe).

- [ ] **Step 3: Implementar**

Substituir o conteúdo de `chip_acao.dart` por:

```dart
import 'package:flutter/material.dart';

class ChipAcao extends StatelessWidget {
  const ChipAcao(
      {super.key,
      required this.rotulo,
      required this.aoTocar,
      this.primario = false,
      this.discreto = false});

  final String rotulo;
  final VoidCallback aoTocar;
  final bool primario;

  /// Ação de baixa prioridade (ex.: desistir da inclusão): sem fundo,
  /// sem borda e sem sombra, só o texto na cor primária.
  final bool discreto;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Material(
      color: primario
          ? primaria
          : discreto
              ? Colors.transparent
              : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: primario || discreto
                ? null
                : Border.all(
                    color: primaria.withValues(alpha: .4), width: 1.5),
            boxShadow: primario
                ? [
                    BoxShadow(
                        color: primaria.withValues(alpha: .35),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ]
                : null,
          ),
          child: Text(
            rotulo,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: discreto ? FontWeight.w700 : FontWeight.w800,
              color: primario ? Colors.white : primaria,
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/funcionalidades/chat/componentes_chat_2_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/funcionalidades/chat/apresentacao/componentes/chip_acao.dart test/funcionalidades/chat/componentes_chat_2_test.dart
git commit -m "feat: variante discreta do ChipAcao para acoes de desistencia"
```

---

### Task 4: AreaAcoes + PaginaChat — chips por etapa e fiação

(AreaAcoes ganha parâmetros obrigatórios novos, então widget e página mudam na mesma task para o projeto sempre compilar.)

**Files:**
- Modify: `lib/funcionalidades/chat/apresentacao/componentes/area_acoes.dart`
- Modify: `lib/funcionalidades/chat/apresentacao/paginas/pagina_chat.dart` (só a chamada de `AreaAcoes`, ~linha 206)
- Test (create): `test/funcionalidades/chat/area_acoes_test.dart`
- Test (modify): `test/funcionalidades/chat/pagina_chat_test.dart`
- Test (modify): `test/integracao/fluxo_completo_test.dart`

**Interfaces:**
- Consumes: `EtapaFluxo.semConsumo`/`erroLeitura`, `estado.rotuloCartoesAdicionados` (Task 1); `controlador.tentarNovamente`/`continuarComCartoes` (Task 2); `ChipAcao(discreto: true)` (Task 3).
- Produces: `AreaAcoes` com 2 callbacks obrigatórios novos: `required VoidCallback aoTentarNovamente` e `required VoidCallback aoContinuarComCartoes`. Rótulos exatos dos chips: `'Adicionar outro cartão'`, `'Continuar para pagamento'`, `'Tentar outro cartão'`, `'Tentar novamente'`, `'Continuar com os cartões já adicionados'`, `'Continuar com ${estado.rotuloCartoesAdicionados}'`.

- [ ] **Step 1: Escrever os testes de widget que falham**

Criar `test/funcionalidades/chat/area_acoes_test.dart`:

```dart
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/area_acoes.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/cartao_consumo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _cartao = CartaoConsumo(
  id: 'c1',
  codigo: '001',
  nome: 'Comanda 01',
  pessoa: 'Mesa 1',
  emoji: '🧾',
  resumo: '',
  itens: [],
  subtotalCentavos: 1000,
  servicoCentavos: 0,
  descontoCentavos: 0,
  totalCentavos: 1000,
  saldoCentavos: 1000,
  selecionado: true,
);

Widget _montar(EstadoFluxoPagamento estado,
    {VoidCallback? aoTentarNovamente, VoidCallback? aoContinuarComCartoes}) {
  return MaterialApp(
    home: Scaffold(
      body: AreaAcoes(
        estado: estado,
        aoLerOutro: () {},
        aoIrPagamento: () {},
        aoPagarRestante: () {},
        aoEncerrar: () {},
        aoNovaOperacao: () {},
        aoTentarNovamente: aoTentarNovamente ?? () {},
        aoContinuarComCartoes: aoContinuarComCartoes ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('primeira leitura nao mostra acao de desistencia',
      (tester) async {
    await tester
        .pumpWidget(_montar(const EstadoFluxoPagamento(etapa: EtapaFluxo.lendo)));
    expect(
        find.text('Continuar com os cartões já adicionados'), findsNothing);
  });

  testWidgets('leitura adicional mostra acao discreta de desistencia',
      (tester) async {
    var continuou = false;
    await tester.pumpWidget(_montar(
      const EstadoFluxoPagamento(etapa: EtapaFluxo.lendo, cartoes: [_cartao]),
      aoContinuarComCartoes: () => continuou = true,
    ));
    await tester.tap(find.text('Continuar com os cartões já adicionados'));
    expect(continuou, isTrue);
  });

  testWidgets('aguardandoMaisCartoes oferece adicionar outro e continuar',
      (tester) async {
    await tester.pumpWidget(_montar(const EstadoFluxoPagamento(
        etapa: EtapaFluxo.aguardandoMaisCartoes, cartoes: [_cartao])));
    expect(find.text('Adicionar outro cartão'), findsOneWidget);
    expect(find.text('Continuar para pagamento'), findsOneWidget);
  });

  testWidgets('semConsumo com cartao oferece tentar outro e continuar com 1',
      (tester) async {
    var tentou = false;
    await tester.pumpWidget(_montar(
      const EstadoFluxoPagamento(
          etapa: EtapaFluxo.semConsumo, cartoes: [_cartao]),
      aoTentarNovamente: () => tentou = true,
    ));
    expect(find.text('Continuar com 1 cartão adicionado'), findsOneWidget);
    await tester.tap(find.text('Tentar outro cartão'));
    expect(tentou, isTrue);
  });

  testWidgets('semConsumo sem cartoes so oferece tentar outro',
      (tester) async {
    await tester.pumpWidget(
        _montar(const EstadoFluxoPagamento(etapa: EtapaFluxo.semConsumo)));
    expect(find.text('Tentar outro cartão'), findsOneWidget);
    expect(find.textContaining('Continuar com'), findsNothing);
  });

  testWidgets('erroLeitura com cartoes oferece tentar novamente e continuar',
      (tester) async {
    await tester.pumpWidget(_montar(const EstadoFluxoPagamento(
        etapa: EtapaFluxo.erroLeitura,
        cartoes: [_cartao, CartaoConsumo(
          id: 'c2',
          codigo: '002',
          nome: 'Comanda 02',
          pessoa: 'Mesa 2',
          emoji: '🧾',
          resumo: '',
          itens: [],
          subtotalCentavos: 2000,
          servicoCentavos: 0,
          descontoCentavos: 0,
          totalCentavos: 2000,
          saldoCentavos: 2000,
          selecionado: true,
        )])));
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.text('Continuar com 2 cartões adicionados'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/funcionalidades/chat/area_acoes_test.dart`
Expected: FAIL (erro de compilação: `aoTentarNovamente`/`aoContinuarComCartoes` não existem).

- [ ] **Step 3: Implementar AreaAcoes**

Em `area_acoes.dart`:

**3a.** Construtor e campos — adicionar os 2 callbacks:

```dart
  const AreaAcoes({
    super.key,
    required this.estado,
    required this.aoLerOutro,
    required this.aoIrPagamento,
    required this.aoPagarRestante,
    required this.aoEncerrar,
    required this.aoNovaOperacao,
    required this.aoTentarNovamente,
    required this.aoContinuarComCartoes,
  });
```

e, junto aos demais `final VoidCallback`:

```dart
  final VoidCallback aoTentarNovamente;
  final VoidCallback aoContinuarComCartoes;
```

**3b.** Substituir `_chips()` por:

```dart
  List<Widget> _chips() {
    if (estado.digitando) return const [];
    final temCartoes = estado.selecionados.isNotEmpty;
    switch (estado.etapa) {
      case EtapaFluxo.lendo:
        // Só na leitura adicional: na primeira leitura ainda não há como
        // continuar sem localizar uma comanda válida.
        if (!temCartoes) return const [];
        return [
          ChipAcao(
              rotulo: 'Continuar com os cartões já adicionados',
              aoTocar: aoContinuarComCartoes,
              discreto: true),
        ];
      case EtapaFluxo.aguardandoMaisCartoes:
        return [
          // Sempre disponível: com a API real o app não sabe quantas comandas
          // ainda estão abertas na mesa (`cartoesRestantes` só existe no mock).
          ChipAcao(rotulo: 'Adicionar outro cartão', aoTocar: aoLerOutro),
          ChipAcao(
              rotulo: 'Continuar para pagamento',
              aoTocar: aoIrPagamento,
              primario: true),
        ];
      case EtapaFluxo.semConsumo:
      case EtapaFluxo.erroLeitura:
        return [
          ChipAcao(
              rotulo: estado.etapa == EtapaFluxo.semConsumo
                  ? 'Tentar outro cartão'
                  : 'Tentar novamente',
              aoTocar: aoTentarNovamente,
              primario: !temCartoes),
          if (temCartoes)
            ChipAcao(
                rotulo: 'Continuar com ${estado.rotuloCartoesAdicionados}',
                aoTocar: aoContinuarComCartoes,
                primario: true),
        ];
      case EtapaFluxo.sucessoComRestante:
        return [
          ChipAcao(
              rotulo: 'Pagar restante',
              aoTocar: aoPagarRestante,
              primario: true),
          ChipAcao(rotulo: 'Encerrar', aoTocar: aoEncerrar),
        ];
      case EtapaFluxo.sucessoCompleto:
        return [
          ChipAcao(rotulo: 'Encerrar', aoTocar: aoEncerrar, primario: true)
        ];
      case EtapaFluxo.encerramento:
        return [
          ChipAcao(
              rotulo: 'Novo pagamento', aoTocar: aoNovaOperacao, primario: true)
        ];
      default:
        return const [];
    }
  }
```

**3c.** Ampliar `_mostraTotal` para o total nunca "sumir" durante a inclusão adicional (já é protegido por `selecionados.isNotEmpty`):

```dart
  bool get _mostraTotal =>
      const [
        EtapaFluxo.lendo,
        EtapaFluxo.aguardandoMaisCartoes,
        EtapaFluxo.semConsumo,
        EtapaFluxo.erroLeitura,
        EtapaFluxo.escolhaMetodo,
        EtapaFluxo.pixAguardando,
      ].contains(estado.etapa) &&
      estado.selecionados.isNotEmpty;
```

(`_mostraDica` fica como está: em `lendo` sem cartões continua mostrando a dica; com cartões os chips ocupam o lugar.)

**3d.** Em `pagina_chat.dart`, na chamada de `AreaAcoes` (build, ~linha 206), adicionar os 2 callbacks:

```dart
          AreaAcoes(
            estado: estado,
            aoLerOutro: controlador.lerOutroCartao,
            aoIrPagamento: controlador.irParaPagamento,
            aoPagarRestante: controlador.pagarRestante,
            aoEncerrar: controlador.encerrar,
            aoNovaOperacao: () {
              controlador.novaOperacao();
              context.go('/splash');
            },
            aoTentarNovamente: controlador.tentarNovamente,
            aoContinuarComCartoes: controlador.continuarComCartoes,
          ),
```

- [ ] **Step 4: Atualizar os testes de widget existentes (rótulo renomeado)**

Em `test/funcionalidades/chat/pagina_chat_test.dart` linha 55, trocar:

```dart
    await tester.tap(find.textContaining('Ir para o pagamento'));
```

por:

```dart
    await tester.tap(find.textContaining('Continuar para pagamento'));
```

Em `test/integracao/fluxo_completo_test.dart` linha 57, aplicar a mesma troca.

- [ ] **Step 5: Adicionar cenário de desistência ao teste da página**

Em `pagina_chat_test.dart`, adicionar um segundo `testWidgets` dentro de `main` (reaproveitar o mesmo bloco de setup de `ProviderScope`/`GoRouter` do teste existente):

```dart
  testWidgets('desistir da inclusao adicional preserva a comanda e avanca',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final roteador = GoRouter(
      initialLocation: '/chat',
      routes: [
        GoRoute(path: '/chat', builder: (_, __) => const PaginaChat()),
        GoRoute(
            path: '/splash',
            builder: (_, __) => const Scaffold(body: Text('SPLASH'))),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provedorSharedPreferences.overrideWithValue(preferencias),
          provedorAtrasoBot.overrideWithValue(Duration.zero),
          provedorFonteLeituraMock
              .overrideWithValue(FonteLeituraMock(atraso: Duration.zero)),
          provedorFontePagamentoMock
              .overrideWithValue(FontePagamentoMock(atraso: Duration.zero)),
        ],
        child: MaterialApp.router(routerConfig: roteador),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    // primeira leitura: sem ação de desistência disponível
    expect(
        find.text('Continuar com os cartões já adicionados'), findsNothing);
    await tester.tap(find.textContaining('Simular leitura'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.text('Adicionar outro cartão'), findsOneWidget);

    // entra na inclusão adicional e desiste
    await tester.tap(find.text('Adicionar outro cartão'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    await tester.ensureVisible(
        find.text('Continuar com os cartões já adicionados'));
    await tester.tap(find.text('Continuar com os cartões já adicionados'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    // comanda preservada e fluxo na escolha de método
    expect(find.textContaining('Comanda 01'), findsWidgets);
    expect(find.text('Pix'), findsOneWidget);
  });
```

- [ ] **Step 6: Rodar e ver passar**

Run: `flutter test test/funcionalidades/chat/ test/integracao/`
Expected: PASS em todos.

- [ ] **Step 7: Commit**

```bash
git add lib/funcionalidades/chat/apresentacao/componentes/area_acoes.dart lib/funcionalidades/chat/apresentacao/paginas/pagina_chat.dart test/funcionalidades/chat/area_acoes_test.dart test/funcionalidades/chat/pagina_chat_test.dart test/integracao/fluxo_completo_test.dart
git commit -m "feat: chips por etapa na AreaAcoes com saida garantida na inclusao de cartoes"
```

---

### Task 5: Verificação final

**Files:** nenhum novo (só correções que a análise apontar).

- [ ] **Step 1: Formatação e análise estática**

```bash
dart format .
flutter analyze
```

Expected: `flutter analyze` sem erros novos. Se `dart format` alterar arquivos do plano, commitar junto do passo 3.

- [ ] **Step 2: Suíte completa**

```bash
flutter test
```

Expected: PASS total (nenhum teste fora do escopo alterado deve quebrar — os demais grupos não referenciam os textos renomeados).

- [ ] **Step 3: Revisão adversarial (checklist do CLAUDE.md)**

Conferir em especial:
- Nenhuma tela nova criada; só chips/mensagens/etapas no fluxo existente.
- `pubspec.lock` não modificado (`git status` limpo fora dos arquivos do plano).
- Totais nunca recalculados; comandas nunca removidas em nenhum caminho novo.
- Chips no `Wrap` (já responsivo, empilha em telas estreitas); área de toque dos chips ≥ padrão existente.
- Textos pt-BR sem jargão técnico (subtexto de erro usa `falha.mensagem`, que já é amigável).

- [ ] **Step 4: Commit final (se houve ajuste de formatação/análise)**

```bash
git add -A -- ':!pubspec.lock'
git commit -m "chore: formatacao e ajustes de analise no fluxo de cartoes adicionais"
```

---

## Mapeamento spec → tasks (auto-conferência)

1. Pergunta com 2 opções após adicionar → Task 2 (texto) + Task 4 (chips `aguardandoMaisCartoes`).
2. Desistir durante leitura → Task 2 (`continuarComCartoes`) + Task 4 (chip discreto em `lendo`).
3. Primeira vs adicional → derivado de `selecionados.isNotEmpty` (estado de domínio, não texto) — Task 4.
4. Sem consumo → Task 2 (`semConsumo` + mensagem) + Task 4 (chips com plural via `rotuloCartoesAdicionados`, Task 1).
5. Não encontrado → colapsa em `semConsumo` (API não distingue; documentado no desenho).
6. Erro de leitura → Task 2 (`erroLeitura`) + Task 4 (chips).
7. Preservação → nenhum caminho novo remove cartões; testes de preservação nas Tasks 2 e 4.
8. Duplicado → Task 2 (mensagem + `aguardandoMaisCartoes`, sem duplicar).
9. Tom de voz → textos exatos definidos na Task 2.
10. Hierarquia → primário/secundário/discreto nas Tasks 3 e 4.
11-12. Fluxo/estados explícitos → enum `EtapaFluxo` estendido (Task 1).
13. Responsividade → `Wrap` existente; verificado na Task 5.
14. Acessibilidade → chips são `InkWell` com texto (focáveis, rótulo lido); diferenciação por texto além de cor.
15. Não alterar → escopo restrito aos 5 arquivos de lib listados.
16-17. Critérios/testes → cenários 1-10 da spec cobertos pelos testes das Tasks 2 e 4 (cenário 9, erro de leitura, coberto pelos testes de `erroLeitura`).
