# Consumo do Cartão (Atendimento da Loja) — Design

> Data: 2026-07-10

## Objetivo

Criar as **estruturas de dados** que leem o consumo real de um cartão/mesa na API
da **loja/local** (`:3001`), substituindo futuramente o `FonteLeituraMock` da
feature `leitura_cartao`. Esta etapa entrega **entidade + mapper + fonte** fiéis
ao endpoint; **não** reescreve o fluxo do chat nem a UI.

## Endpoint

```
GET /api/venda/atendimento/colecao?classe=1600&situacao=20&referencia=01
Authorization: Bearer <jwt da loja>
```

- `classe=1600` e `situacao=20` são **fixos** (atendimento de consumo em aberto).
- `referencia` é **dinâmico** (o identificador da mesa/cartão, ex.: `"01"`).
- Resposta: **array** de atendimentos. **Array vazio = não há consumo** para a
  referência (não é erro). Um ou mais itens = há consumo.

Cada atendimento traz tudo junto: dados da mesa, `atendimentoComandas[]`,
`atendimentoItens[]` (cada item referencia sua comanda por `comandaId`) e os
valores já computados (`subtotal`, `servico`, `total`, `pago`, `saldo`).

## Escopo

**Dentro:**
- Entidades novas fiéis à API: `Atendimento`, `ComandaAtendimento`, `ItemAtendimento`.
- Mapper `RespostaConsumoAtendimento` (JSON cru → entidades, tolerante a campos ausentes).
- Fonte `FonteConsumoAtendimento` (chama o endpoint, devolve `Resultado<List<Atendimento>>`).
- Constantes de rota/parâmetros.
- Ajuste mínimo no `ClienteApi.get` para aceitar query params.

**Fora (etapas seguintes):**
- Adaptador `Atendimento` → `Mesa`/`CartaoConsumo` e religação do fluxo do chat.
- Pré-venda (o `POST` que registra o pagamento) — aguardando log.
- Definição de qual base (`urlBaseAtiva` vs `urlNuvemAtiva`) o cliente autenticado
  da loja usa — ver "Pendências".

## Arquitetura (Opção A — modelo fiel à API)

Entidades próprias da API, sem os campos de UI inventados pelo mock
(`emoji`, `pessoa`, `resumo`). Quando o fluxo for religado, um adaptador fino
converte `Atendimento` nos modelos que a UI já usa. Isso mantém o modelo da API
limpo e respeita a regra do projeto de "extrair apenas os campos usados".

```
UI (etapa futura) -> Adaptador -> Atendimento (esta spec) <- Mapper <- Fonte <- ClienteApi -> API loja
```

Arquivos:
- `lib/funcionalidades/leitura_cartao/dominio/entidades/atendimento.dart`
- `lib/funcionalidades/leitura_cartao/dados/modelos/resposta_consumo_atendimento.dart`
- `lib/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_consumo_atendimento.dart`
- `lib/nucleo/constantes/constantes_app.dart` (constantes)
- `lib/nucleo/configuracao/cliente_api.dart` (query params no `get`)

## Entidades

`freezed` **sem** `json_serializable` — não são persistidas; o mapper faz o parse.
As três ficam em `atendimento.dart` (bem abaixo de 600 linhas).

### `Atendimento`

| Campo | Tipo | Origem na API | Observação |
|---|---|---|---|
| `id` | String | `id` | |
| `codigo` | String | `codigo` | |
| `nome` | String | `nome` | ex.: "Mesa 01" |
| `referencia` | String | `referencia` | ex.: "01" |
| `situacao` | int | `situacao` | 20 = em aberto |
| `inicio` | DateTime? | `inicio` | abertura; nulo se ausente/inválido |
| `conclusao` | DateTime? | `conclusao` | nulo = aberto |
| `subtotalCentavos` | int | `subtotal` | reais→centavos |
| `servicoCentavos` | int | `servico` | reais→centavos |
| `servicoPercentual` | num | `servicoPercentual` | percentual, não é dinheiro |
| `descontoCentavos` | int | `desconto` | reais→centavos |
| `totalCentavos` | int | `total` | reais→centavos |
| `pagoCentavos` | int | `pago` | reais→centavos |
| `saldoCentavos` | int | `saldo` | **valor devido** |
| `sessaoId` | String | `sessao.id` | provável chave da pré-venda |
| `sessaoCodigo` | String | `sessao.codigo` | |
| `comandas` | List\<ComandaAtendimento\> | `atendimentoComandas[]` | default `[]` |
| `itens` | List\<ItemAtendimento\> | `atendimentoItens[]` | default `[]` |

### `ComandaAtendimento`

| Campo | Tipo | Origem | Observação |
|---|---|---|---|
| `id` | String | `id` | usado para agrupar itens |
| `codigo` | String | `codigo` | ex.: "0010450" |
| `numero` | int | `numero` | ex.: 10450 |
| `situacao` | int | `situacao` | |

### `ItemAtendimento`

| Campo | Tipo | Origem | Observação |
|---|---|---|---|
| `id` | String | `id` | |
| `sequencial` | int | `sequencial` | |
| `nome` | String | `item.nome` | ex.: "Batom Garoto" |
| `codigo` | String | `item.codigo` | ex.: "105265" |
| `quantidade` | num | `quantidade` | pode ser fracionado |
| `medida` | String | `medida` | ex.: "UN" |
| `valorCentavos` | int | `valor` | unitário, reais→centavos |
| `subtotalCentavos` | int | `subtotal` | reais→centavos |
| `totalCentavos` | int | `total` | reais→centavos |
| `comandaId` | String | `comandaId` | liga o item à comanda |
| `comandaCodigo` | String | `comandaCodigo` | |

**Ignorados** (YAGNI): `atendimentoResumos`, `atendimentoAgrupamentos` (visões
agregadas redundantes), `parceiro`, `preco`, `corretor`, `vendedor`, `modalidade`,
`localizador`, `estabelecimento`, `usuario`, `estabelecimentoDepartamento`,
`estabelecimentoAmbiente`, `promocao`, campos de produção/montagem, etc.

## Regras de dinheiro

- A API entrega valores em **reais como `double`**. Converter cada campo para
  centavos com `(valor * 100).round()`. O `.round()` corrige artefatos de ponto
  flutuante (ex.: `5.390000000000001 * 100` → `539`).
- **Nunca** recalcular totais em `double`. Confiar nos campos já computados pela
  API (`saldo`, `total`, `subtotal`, ...); cada um é convertido independentemente.
- Helper no mapper: `int _centavos(dynamic v) => (((v as num?) ?? 0) * 100).round();`

## Mapper `RespostaConsumoAtendimento`

`abstract final class` com:
- `static List<Atendimento> paraLista(List<dynamic> json)` — mapeia cada elemento;
  lista vazia → `[]`.
- Privado `_atendimento(Map<String,dynamic>)` — monta a entidade.
- Helpers `_centavos(dynamic)` e `_data(dynamic) -> DateTime?`
  (`v is String ? DateTime.tryParse(v) : null`).
- Tolerante: sub-objetos ausentes viram `const {}`/`const []`, strings ausentes
  viram `''`, números ausentes viram `0`. Nunca lança em campo faltante.

## Fonte `FonteConsumoAtendimento`

```dart
class FonteConsumoAtendimento {
  FonteConsumoAtendimento(this._clienteApi);
  final ClienteApi _clienteApi;

  Future<Resultado<List<Atendimento>>> consultar({required String referencia}) async {
    final resposta = await _clienteApi.get(
      ConstantesApp.caminhoColecaoAtendimento,
      parametros: {
        'classe': ConstantesApp.classeAtendimentoConsumo,   // 1600
        'situacao': ConstantesApp.situacaoAtendimentoAberto, // 20
        'referencia': referencia,
      },
    );
    try {
      return switch (resposta) {
        Sucesso(:final valor) => Sucesso(
            RespostaConsumoAtendimento.paraLista(
                (valor.data as List<dynamic>?) ?? const [])),
        Erro(:final falha) => Erro(falha),
      };
    } catch (_) {
      return const Erro(FalhaServidor('Resposta de consumo inválida.'));
    }
  }
}
```

## Constantes (`ConstantesApp`)

```dart
static const String caminhoColecaoAtendimento = 'venda/atendimento/colecao';
static const int classeAtendimentoConsumo = 1600;
static const int situacaoAtendimentoAberto = 20;
```

## `ClienteApi.get` — ajuste mínimo

Adicionar parâmetro opcional (retrocompatível):

```dart
Future<Resultado<Response<dynamic>>> get(
  String caminho, {
  Map<String, dynamic>? parametros,
}) async {
  try {
    return Sucesso(await _dio.get<dynamic>(caminho, queryParameters: parametros));
  } on DioException catch (excecao) {
    return Erro(mapearFalha(excecao));
  }
}
```

Chamadas existentes (que passam só o caminho) continuam funcionando.

## Autenticação

A fonte recebe um `ClienteApi` **autenticado** por injeção (o interceptor de token
que já existe). Não há stack de auth novo nesta etapa. Qual base esse cliente usa
(`urlNuvemAtiva` vs `urlBaseAtiva`) fica como decisão de integração — ver
"Pendências". A fonte é testada isoladamente com um `HttpClientAdapter` falso, então
essa decisão não bloqueia esta spec.

## Segurança / logging

- O `ClienteApi` já loga apenas `método + caminho` (nunca headers/corpo/token) —
  mantido.
- Nenhum dado sensível novo é persistido. As entidades ficam em memória.

## Estados / erros

- **200 + array com itens** → `Sucesso(List<Atendimento>)`.
- **200 + array vazio** → `Sucesso(<Atendimento>[])` (sem consumo).
- **Erro HTTP / timeout / rede** → `Erro(Falha)` (mapeado pelo `ClienteApi`).
- **Corpo inesperado** (não-lista) → `Erro(FalhaServidor)`.

## Plano de testes

`test/funcionalidades/leitura_cartao/`

1. **`resposta_consumo_atendimento_test.dart`** (mapper — principal):
   - Payload real (do log) → confere `id`, `nome`, `referencia`, `saldoCentavos == 539`,
     `servicoCentavos == 49`, `totalCentavos == 539`, `subtotalCentavos == 490`.
   - Conversão de dinheiro arredonda certo (`4.9 → 490`, `5.390000000000001 → 539`).
   - `comandas.length == 1`, `comandas.first.numero == 10450`.
   - `itens.length == 1`, `itens.first.nome == 'Batom Garoto'`,
     `itens.first.valorCentavos == 490`, `itens.first.comandaId` liga à comanda.
   - Array vazio → `[]`.
   - Tolerância: atendimento sem `atendimentoComandas`/`atendimentoItens`/`sessao`
     → listas vazias e strings vazias, sem lançar.
2. **`fonte_consumo_atendimento_test.dart`** (fonte, com `HttpClientAdapter` falso,
   no padrão do `fonte_autenticacao_nuvem_test`):
   - 200 com array → `Sucesso` com a lista parseada.
   - 200 com `[]` → `Sucesso([])`.
   - 401/erro → `Erro`.
   - Verifica que os query params enviados são `classe=1600`, `situacao=20`,
     `referencia=<valor>`.

## Constraints do projeto

- Flutter `>=3.22.0`, Dart `>=3.4.0 <4.0.0`. Pacote: `constel_pay`.
- pt-BR em mensagens visíveis. `Resultado<T>`/`Falha` para retornos; sem exceção
  vazando das fontes.
- `freezed` para entidades. Codegen: `dart run build_runner build --delete-conflicting-outputs`.
- Arquivos < 600–700 linhas.

## Pendências / próximos passos

1. **Base do cliente autenticado da loja:** confirmar se o consumo (`:3001`) usa
   `urlNuvemAtiva` ou `urlBaseAtiva` ao religar na injeção. Decisão de integração,
   fora desta spec.
2. **Adaptador + fluxo do chat:** converter `Atendimento` em `Mesa`/`CartaoConsumo`
   e substituir o mock — próxima spec.
3. **Pré-venda (POST):** aguardando o log do endpoint de registro do pagamento.
4. **Login da nuvem (`:3000`):** validar a resposta real contra o `SessaoNuvem`
   (o commit `62670af` foi baseado no login da loja `:3001`); pendência à parte,
   não afeta esta spec.
