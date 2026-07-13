# Faixa de pagamento temável

Data: 2026-07-13

## Problema

A chamada para pagar aparece hoje de duas formas diferentes, nenhuma delas
configurável:

- sem propaganda cadastrada, um `BotaoPrimario` "Toque para pagar" preso dentro
  de um card branco (`pagina_propaganda.dart:177`);
- com propaganda rodando, uma pílula preta translúcida "👆 Toque na tela para
  pagar" flutuando sobre a mídia (`pagina_propaganda.dart:217-238`).

As duas ignoram o tema da loja: a pílula é preta fixa e o botão usa a cor de
botões, não uma cor pensada para a chamada. O operador não tem como ajustar
nenhuma delas.

## Objetivo

Uma faixa única no rodapé, igual nas duas telas, obedecendo ao tema e
configurável na aba Aparência: cor de fundo, cor do texto e a própria frase. A
tela inteira continua clicável.

Fora de escopo: animação da faixa, faixa no topo, mais de uma faixa, frase por
mídia, agendamento de frase.

## Decisões

### O que sai da tela

Some o `BotaoPrimario`. Some a pílula preta. Some o card branco inteiro da tela
de chamada — o título "Pague sua conta sem chamar o garçom", os três passos
(📷 Escaneie / 💳 Pague / ✅ Pronto) e o selo "🔒 Pagamento seguro ·
Autoatendimento". O helper `_passo()` (`pagina_propaganda.dart:53-87`) fica sem
uso e é removido junto.

A tela de chamada passa a ser: gradiente da cor primária, logo, nome do
restaurante, faixa no rodapé. A tela com propaganda passa a ser: mídia, faixa no
rodapé. A mesma faixa nas duas.

**Isto quebra um teste existente.** `propaganda_test.dart:59` afirma
`find.text('Escaneie')`, e os três passos deixam de existir. O teste é
atualizado no mesmo passo em que o card sai, não depois.

### Campos novos no tema

Em `TemaPersonalizado` e em `ModeloTemaPersonalizado`:

```dart
String? corFaixa,                          // null = herda a cor primaria
@Default('#FFFFFF') String corTextoFaixa,
@Default('Toque para pagar') String textoFaixa,
```

`corFaixa` é **nullable de propósito**. `null` significa "usa a cor primária
atual": a faixa acompanha a primária sozinha enquanto o operador não escolher
uma cor própria para ela, e para de acompanhar no instante em que ele escolher.
Isso dá a herança sem precisar de uma flag "herdar sim/não" separada, que seria
um segundo estado a manter em sincronia. "Restaurar padrão original", que já
existe (`aba_aparencia.dart:47`), volta o campo a `null` e portanto à herança.

`corTextoFaixa` e `textoFaixa` não herdam nada: branco e "Toque para pagar" são
padrões estáticos e bons.

Dois getters na entidade, para a regra não se duplicar entre a tela e o preview
da Aparência:

```dart
String get corFaixaEfetiva => corFaixa ?? corPrimaria;
String get textoFaixaEfetivo =>
    textoFaixa.trim().isEmpty ? 'Toque para pagar' : textoFaixa;
```

O segundo é uma trava de segurança: se o operador apagar o campo, um totem de
pagamento ficaria com uma faixa muda, sem chamada nenhuma. Cai no padrão em vez
disso. Um totem sem chamada para pagar é um defeito, não uma preferência.

Adicionar getters a uma classe Freezed exige o construtor privado
`const TemaPersonalizado._();`, que a classe hoje não tem.

### Migração

Temas já salvos no `SharedPreferences` não têm as três chaves. `String? corFaixa`
sem `@Default` desserializa como `null`; os outros dois caem no `@Default`. É o
mesmo mecanismo que preservou a playlist na feature anterior, e o
`modelo_tema_personalizado.dart:17` já carrega o precedente:
`// Campos novos: temas ja salvos nao os possuem, por isso tem padrao.`

Um campo `required` aqui faria o `fromJson` lançar e o tema da loja voltar ao
padrão sem aviso.

### A faixa

`lib/compartilhado/widgets/faixa_pagamento.dart`, widget puro de apresentação:

```dart
FaixaPagamento({
  required String texto,
  required Color corFundo,
  required Color corTexto,
  required String fonte,
})
```

Recebe primitivos, **não** a entidade `TemaPersonalizado`: `compartilhado/` não
pode depender de `funcionalidades/` sem inverter a camada. Quem resolve a
herança e converte hex em `Color` é quem chama.

**Sem callback de toque.** O `GestureDetector` de `pagina_propaganda.dart:246` já
embrulha a tela inteira com `HitTestBehavior.opaque`, e a faixa mora dentro dele
— tocar nela já paga. Um gesto próprio na faixa seria duplicação, e no preview
da Aparência a faixa precisa ser inerte de qualquer forma.

Largura total, colada no rodapé, com `SafeArea(top: false)` para não ficar sob a
barra de gestos do sistema.

### Contraste

O operador pode escolher fundo branco com texto branco e cegar a chamada de
pagamento do totem. O `CLAUDE.md` exige "garantir contraste adequado".

`lib/nucleo/utils/contraste.dart`: função pura de razão de contraste WCAG 2.x
sobre duas `Color`, sem dependência nova. A aba Aparência mostra um aviso quando
a combinação escolhida fica abaixo de 4,5:1 (o mínimo WCAG AA para texto normal;
o texto da faixa é grande, mas 4,5 é a margem segura para um totem visto de
longe e sob luz de teto).

O aviso não bloqueia: avisa e deixa aplicar. Bloquear tiraria do operador uma
decisão que pode ser legítima em um caso que não previmos.

### Aparência

Três controles novos, reusando o `SeletorCor` que já existe:

- `SeletorCor` "Cor da faixa de pagamento", alimentado por `corFaixaEfetiva` —
  mostra a cor herdada até o operador escolher uma própria;
- `SeletorCor` "Cor do texto da faixa";
- `TextFormField` "Texto da faixa", com o padrão como `hintText`.

O `TextFormField` precisa de um `TextEditingController` no `State` (o padrão
`_rascunho` + `setState` da aba reconstrói a cada tecla e um campo sem
controlador perderia a posição do cursor). `_restaurar()` tem que zerar o texto
do controlador junto com o rascunho — senão o campo continua mostrando a frase
antiga depois de restaurar.

A `FaixaPagamento` real entra na caixa de Pré-visualização que a aba já tem
(`aba_aparencia.dart:121-178`), abaixo do card e do botão de exemplo.

## Componentes

| Arquivo | Responsabilidade |
| --- | --- |
| `nucleo/utils/contraste.dart` (novo) | Razão de contraste WCAG entre duas cores. Pura. |
| `compartilhado/widgets/faixa_pagamento.dart` (novo) | Desenhar a faixa. Sem estado, sem gesto, sem tema. |
| `configuracoes/dominio/entidades/tema_personalizado.dart` | 3 campos + 2 getters efetivos. |
| `configuracoes/dados/modelos/modelo_tema_personalizado.dart` | Serialização dos 3 campos. |
| `propaganda/apresentacao/paginas/pagina_propaganda.dart` | Usar a faixa nas 2 telas; remover card, botão, pílula e `_passo()`. |
| `configuracoes/apresentacao/componentes/aba_aparencia.dart` | 3 controles + faixa no preview + aviso de contraste. |

## Fluxo

```text
aba_aparencia (SeletorCor / TextFormField)
  -> _rascunho: TemaPersonalizado
  -> ControladorTema.atualizar -> repositorio -> SharedPreferences

pagina_propaganda
  -> le o tema
  -> resolve corFaixaEfetiva / textoFaixaEfetivo, converte hex em Color
  -> FaixaPagamento (dentro do GestureDetector que ja cobre a tela)
```

## Erros e casos de borda

- **Texto vazio ou só espaços**: `textoFaixaEfetivo` cai em "Toque para pagar".
- **Hex inválido**: `TemaConstel.corDeHex(hex, reserva)`, que a base já usa, tem
  cor de reserva. A faixa passa a primária como reserva.
- **Contraste ruim**: avisa na Aparência, não bloqueia.
- **Tema salvo antes destes campos**: `corFaixa` vira `null` (herda), os outros
  caem no `@Default`. O tema da loja não pode ser perdido.
- **Frase longa**: a faixa quebra em até 2 linhas e reduz com `TextOverflow`
  antes de estourar a largura. Uma frase gigante não pode causar overflow.

## Testes

- `contraste.dart`: preto/branco = 21:1; branco/branco = 1:1; um par conhecido no
  limiar de 4,5.
- `TemaPersonalizado`: `corFaixaEfetiva` herda quando `corFaixa` é `null` e para
  de herdar quando não é; `textoFaixaEfetivo` com vazio, com espaços e com texto.
- `ModeloTemaPersonalizado`: round-trip dos 3 campos; JSON legado sem as 3 chaves
  carrega — e **não** volta ao tema padrão.
- `FaixaPagamento`: renderiza o texto, o fundo e a cor do texto recebidos; frase
  longa não estoura a largura.
- `pagina_propaganda`: a faixa aparece nas duas telas (com e sem mídia); tocar em
  qualquer ponto da tela navega para `/chat`; os três passos e o botão **não**
  existem mais.

## Validação

```bash
dart format .
flutter analyze
flutter test
```
