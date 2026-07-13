# Ajuste de tela da propaganda (imagem, GIF e vídeo)

Data: 2026-07-13

## Problema

O player de propaganda usa `BoxFit.cover` fixo para imagem e vídeo
(`player_propaganda.dart:110` e `:117`). A mídia sempre preenche a tela e o que
sobra é cortado. Quando o formato da mídia não bate com o da tela, o corte
destrói a peça: um vídeo 16:9 numa tela retrato 9:16 perde cerca de 68% da
imagem, e a loja não tem como corrigir isso pela interface.

GIF nem chega a ser importado: a extensão `gif` está fora da lista do seletor de
arquivos (`aba_propaganda.dart:42-51`).

## Objetivo

Cada mídia da playlist ganha um modo de ajuste escolhido pelo operador, com um
padrão automático que acerta sozinho na maioria dos casos. GIF passa a ser uma
mídia válida.

Fora de escopo: recorte manual (crop) da mídia, edição de mídia dentro do app,
playlist por horário.

## Decisões

### Modos de ajuste

Enum `AjusteMidia` com quatro valores:

| Modo | `BoxFit` | Efeito |
| --- | --- | --- |
| `automatico` (padrão) | `cover` ou `contain` | O app decide pela razão de aspecto |
| `preencher` | `cover` | Preenche a tela, corta as bordas |
| `encaixar` | `contain` | Mídia inteira visível, sobra tarja |
| `esticar` | `fill` | Preenche sem cortar, mas deforma |

### Regra do modo automático

Função pura em `lib/funcionalidades/propaganda/apresentacao/ajuste_tela.dart`:

```dart
BoxFit resolverBoxFit({
  required AjusteMidia ajuste,
  required double? razaoMidia, // null = dimensões ainda não medidas
  required double razaoTela,
})
```

Os três modos explícitos mapeiam direto para `cover`, `contain` e `fill`. O modo
`automatico` calcula quanto da mídia sobreviveria ao corte do `cover`:

```
aproveitamento = min(razaoMidia, razaoTela) / max(razaoMidia, razaoTela)

aproveitamento >= 0.75  ->  BoxFit.cover    (perde no máximo 25%, tolerável)
aproveitamento <  0.75  ->  BoxFit.contain  (o corte destruiria a peça)
```

O limite `0.75` fica numa constante nomeada para calibração posterior.

Resultados em tela retrato 9:16 (razão 0,5625):

| Mídia | Aproveitamento | Decisão |
| --- | --- | --- |
| 9:16 (0,5625) | 1,00 | `cover` |
| 3:4 (0,75) | 0,75 | `cover` |
| 1:1 (1,0) | 0,56 | `contain` |
| 16:9 (1,778) | 0,32 | `contain` |

Quando `razaoMidia` é `null` (vídeo ainda inicializando, imagem ainda
decodificando), o modo `automatico` devolve `contain`. Nunca corta antes de
saber o que está cortando. Na prática esse estado não chega a ser pintado: o
player mostra a cor de fundo até ter as dimensões.

### Cor da tarja

As tarjas do `contain` usam a cor primária do tema, já configurável na aba
Aparência. Custo zero de render e a mídia parece emoldurada de propósito, não
sobrando.

A cor entra no `PlayerPropaganda` como parâmetro `corFundo`, vindo da
`primaria` que `pagina_propaganda.dart:198` já calcula. O player continua sem
depender de Riverpod, o que mantém o widget test simples.

Efeito colateral desejado: o player hoje pinta `Colors.black` enquanto o vídeo
carrega (`player_propaganda.dart:106` e `:114`). Passa a pintar `corFundo`, o
que elimina o flash preto entre mídias.

### Persistência e migração

`ajuste` entra em `MidiaPropaganda` e em `ModeloMidia` como
`@Default(AjusteMidia.automatico)`, com
`@JsonKey(unknownEnumValue: AjusteMidia.automatico)`.

O `@Default` não é conveniência, é obrigatório. Todos os campos de `ModeloMidia`
são hoje `required`. As mídias já gravadas no `SharedPreferences` não têm a
chave `ajuste`. Um campo `required` faria o `fromJson` lançar, o `catch` em
`repositorio_propaganda_impl.dart:26` engoliria a exceção e devolveria
`const []`: **a playlist da loja seria apagada sem nenhum aviso**. O
`unknownEnumValue` protege o caminho simétrico, uma versão futura gravando um
modo que esta build não conhece.

Mídia já cadastrada é `cover` hoje e passa a ser `automatico`. Para mídia 9:16
em tela 9:16 nada muda. Para um vídeo 16:9 hoje cortado a 32%, passa a encaixar.
É correção, não regressão.

### GIF

`gif` entra em `allowedExtensions` no seletor de arquivos e é classificado como
`TipoMidia.imagem` — `_extensoesVideo` em `controlador_midias.dart:27` não muda.
`Image.file` anima GIF nativamente, sem dependência nova. O GIF roda em loop até
o timer de `duracaoSegundos` estourar, usando o mesmo campo de duração que a
imagem parada já tem.

Não haverá detecção da duração real do GIF. Exigiria decodificar os frames na
importação e o operador já controla a duração pelo card.

## Componentes

### `propaganda/apresentacao/ajuste_tela.dart` (novo)

Só a função `resolverBoxFit` e a constante do limite. Sem widget, sem estado.

### `propaganda/apresentacao/componentes/player_propaganda.dart` (alterado)

Ganha os parâmetros `ajuste` (via `widget.midia.ajuste`) e `corFundo`. Envolve o
conteúdo num `ColoredBox(color: corFundo)`.

Usa `LayoutBuilder` para obter a razão da tela, não `MediaQuery`: o preview da
aba Propaganda roda numa caixa, não em tela cheia, e `MediaQuery` daria a razão
errada ali.

A razão da mídia vem de duas fontes:

- vídeo: `_video.value.aspectRatio`, já disponível depois do `initialize()`;
- imagem e GIF: resolver o `ImageStream` para ler largura e altura, seguindo o
  mesmo padrão assíncrono que o vídeo já usa. O listener precisa ser removido no
  `_limpar()`, junto com os outros recursos.

O `FittedBox` do caminho de vídeo já aceita `cover`, `contain` e `fill`, então
basta trocar o `fit`. O caminho de imagem idem, via `Image.file(fit: ...)`.

### `configuracoes/apresentacao/componentes/seletor_ajuste_midia.dart` (novo)

Dropdown compacto dos quatro modos, seguindo o padrão visual de
`seletor_fonte.dart`. Rótulos em pt-BR: "Automático", "Preencher (corta)",
"Encaixar (tarja)", "Esticar (distorce)".

### `configuracoes/apresentacao/componentes/aba_propaganda.dart` (alterado)

O card de cada mídia recebe o seletor de ajuste, abaixo do nome do arquivo. Em
imagem e GIF ele convive com o campo de duração; em vídeo aparece sozinho.

O texto de ajuda no topo (`aba_propaganda.dart:174-179`) afirma hoje que a mídia
sempre preenche a tela e pode ser cortada. Deixa de ser verdade e precisa ser
reescrito, mencionando o ajuste por mídia e o GIF.

### `configuracoes/apresentacao/controladores/controlador_midias.dart` (alterado)

Método `definirAjuste(String id, AjusteMidia ajuste)`, no mesmo formato de
`definirDuracao`.

## Fluxo

```text
aba_propaganda (seletor) -> ControladorMidias.definirAjuste
  -> RepositorioPropaganda.salvarTodas -> SharedPreferences

PaginaPropaganda (lê tema, calcula primaria)
  -> PlayerPropaganda(midia, corFundo)
    -> LayoutBuilder (razaoTela) + razaoMidia medida
      -> resolverBoxFit -> BoxFit aplicado
```

## Erros e casos de borda

- **Arquivo ausente ou corrompido**: comportamento atual preservado. O player
  avança para a próxima mídia depois de 1 segundo em vez de deixar a tela
  parada. O que muda é a cor exibida nesse intervalo, que passa de preta para
  `corFundo`.
- **Dimensões da mídia ainda desconhecidas**: `automatico` devolve `contain`,
  nunca `cover`.
- **Razão de tela ou de mídia inválida** (zero ou negativa, vídeo com metadados
  quebrados): tratar como `null`, ou seja, `contain`. Nenhuma divisão por zero.
- **JSON legado sem a chave `ajuste`**: vira `automatico` pelo `@Default`. Este
  é o caso que, mal resolvido, apaga a playlist.

## Testes

- Unitário de `resolverBoxFit`: os três modos explícitos; a tabela de razões do
  modo automático, incluindo o limite exato de 0,75; `razaoMidia` nula; razões
  inválidas.
- Repositório: round-trip com `ajuste`; desserialização de JSON legado sem a
  chave, confirmando `automatico` e, principalmente, que a lista **não** volta
  vazia.
- `ControladorMidias`: `definirAjuste` persiste e atualiza o estado.
- `ControladorMidias`: `.gif` é classificado como `TipoMidia.imagem`.
- Widget test de `PlayerPropaganda`: o `BoxFit` aplicado em cada um dos quatro
  modos e a cor de fundo visível no `contain`.

## Validação

```bash
dart format .
flutter analyze
flutter test
```
