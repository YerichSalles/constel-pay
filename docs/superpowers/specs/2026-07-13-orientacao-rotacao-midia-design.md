# Orientação da tela e rotação da mídia de propaganda

Data: 2026-07-13

Complementa o spec `2026-07-13-enquadramento-midia-propaganda-design.md` (fundo
borrado, âncora e zoom). Nada daquele documento muda; este adiciona duas
capacidades que faltaram lá.

## Problema

1. **O preview do diálogo "Ajustar mídia" mente em tela deitada.** O preview é
   `AspectRatio(9/16)` fixo — simula sempre um totem em pé. Rodando o app numa
   tela horizontal (caso real: PC do operador), um vídeo horizontal aparece
   "em pé" no preview e o modo preencher corta o que na tela real não seria
   cortado. O operador ajusta contra uma simulação errada.

2. **Não há como girar uma mídia.** Mídia que chega deitada para um totem em
   pé (ou vice-versa) só se ajusta por corte ou tarja; o operador não consegue
   girar 90° para aproveitar a tela.

## Objetivo

1. O operador declara a orientação da tela do totem (**em pé** ou **deitada**)
   e o preview do diálogo passa a simular essa orientação.
2. Cada mídia ganha rotação própria (0°/90°/180°/270°), aplicada **antes** do
   enquadramento: girar 90° troca a razão de aspecto e o contain/cover
   enquadram a mídia girada como se ela tivesse nascido naquela orientação.
3. Preview ao vivo reage aos dois controles na hora.

Fora de escopo: travar a orientação do dispositivo (`SystemChrome`), ler
metadata de rotação embutida no vídeo, ângulos livres, espelhamento.

## Decisões

### 1. Orientação da tela: campo do tema

```dart
enum OrientacaoTela { vertical, horizontal }
```

`TemaPersonalizado` ganha `@Default(OrientacaoTela.vertical) OrientacaoTela
orientacaoTela`. `ModeloTemaPersonalizado` espelha com `@Default` +
`@JsonKey(unknownEnumValue: OrientacaoTela.vertical)` — tema já salvo no
dispositivo carrega com o padrão, sem apagar nada (mesma regra de migração do
spec de enquadramento).

Por que no tema e não numa config própria: o diálogo Ajustar já lê
`provedorTema` para a cor do preview; a aba Aparência já edita esse objeto via
`ControladorTema.atualizar(copyWith(...))`. Campo novo no tema é o caminho de
menor tubulação e a orientação é, na prática, um traço da identidade visual do
totem.

**UI:** no topo da aba Propaganda (acima do texto de ajuda), linha
"Tela do totem:" com `SegmentedButton<OrientacaoTela>` — rótulos **"Em pé"** e
**"Deitada"**. Salvar = `ref.read(provedorTema.notifier).atualizar(
tema.copyWith(orientacaoTela: escolhida))`, efeito imediato.

O controle fica na aba Propaganda (não na Aparência) porque é lá que o
operador está quando o preview o engana.

### 2. Preview do diálogo segue a orientação

`DialogoAjusteMidia` ganha `required OrientacaoTela orientacao`. O preview
troca o `AspectRatio` fixo por:

- `vertical` → `9 / 16` (como hoje)
- `horizontal` → `16 / 9`

Em `horizontal`, o `SizedBox` do preview mantém a **largura** contida no
diálogo (340 de conteúdo): preview com `width: 300` + `AspectRatio(16/9)` em
vez de `height: 220`.

O texto de ajuda da aba Propaganda passa a citar a resolução ideal conforme a
orientação: "mídia em pé (retrato), 1080 × 1920 px" vs "mídia deitada
(paisagem), 1920 × 1080 px".

### 3. Rotação por mídia: `rotacaoGraus`

`MidiaPropaganda` e `ModeloMidia` ganham `@Default(0) int rotacaoGraus`
(codegen; mesmos cuidados com `pubspec.lock`). Valores legítimos: 0, 90, 180,
270.

Função pura em `ajuste_tela.dart`:

```dart
/// Converte graus em quartos de volta para o RotatedBox. JSON adulterado
/// (45, -90, 999) e normalizado para o quarto de volta valido mais proximo
/// abaixo, nunca estoura.
int resolverQuartosDeVolta(int rotacaoGraus) =>
    ((rotacaoGraus % 360) + 360) % 360 ~/ 90;
```

### 4. Rotação aplicada antes do fit — `RotatedBox`

`RotatedBox` gira o **layout** (90°/270° trocam largura e altura do filho), o
que faz o `FittedBox` enquadrar a mídia girada com a razão certa sem nenhuma
conta extra. Toda mídia passa a ser renderizada assim:

```
ClipRect/FittedBox(fit, alignment, clipBehavior: hardEdge)
  └── RotatedBox(quarterTurns: resolverQuartosDeVolta(rotacaoGraus))
        └── mídia em tamanho intrínseco
              (Image.file sem fit | SizedBox(videoSize) > VideoPlayer)
```

Consequências deliberadas:

- **Imagem muda de `Image.file(fit:)` para `FittedBox → RotatedBox →
  Image.file()` (tamanho intrínseco).** Um caminho só para imagem e vídeo,
  girado ou não — `RotatedBox(quarterTurns: 0)` é passthrough, não se cria um
  branch separado para "sem rotação". Enquanto a imagem decodifica, o
  `FittedBox` não tem tamanho intrínseco e a cor de fundo aparece — mesmo
  comportamento de espera de hoje.
- **A key `midia-nitida` (e o `fit`/`alignment` que os testes leem) migra do
  `Image` para o `FittedBox`.** Os testes existentes de `fitAplicado` passam a
  ler `FittedBox.fit` em vez de `Image.fit`.
- **O fundo borrado gira junto**: a camada borrada usa o mesmo
  `FittedBox(cover) → RotatedBox → mídia`. Fundo e mídia nunca divergem de
  orientação.
- Âncora e zoom continuam **fora** da rotação (aplicam-se ao resultado já
  girado), exatamente como o operador vê no preview.

### 5. UI do girar: botão que cicla

No diálogo Ajustar, abaixo do seletor de modo, botão **"Girar 90°"**
(`TextButton.icon` com `Icons.rotate_90_degrees_cw`). Cada toque soma 90°
(0→90→180→270→0) no estado local; o preview reage na hora. Visível em
**todos os modos** — rotação não depende de haver corte ou sobra.

Ao lado do botão, o valor atual quando ≠ 0: "Girada: 90°".

### 6. Persistência e resumo

- `definirEnquadramento` ganha o 5º parâmetro `required int rotacaoGraus`.
- Só "Salvar" persiste; "Cancelar" descarta, como hoje.
- `resumoEnquadramento` ganha sufixo ` · girada 90°` (ou 180°/270°) quando
  `rotacaoGraus != 0`, em qualquer modo.
- Rotação fica no modelo mesmo quando o operador troca de modo — nada é
  apagado (mesma regra de âncora/zoom).

## Migração

Tema e playlist já gravados não têm os campos novos. `@Default` em tudo;
enums com `unknownEnumValue`. Os testes de regressão de JSON legado existentes
(tema e playlist) são estendidos para os campos novos. Campo `required` é
proibido — apagaria tema/playlist da loja (regra herdada do spec de
enquadramento).

`build_runner` liberado (Tema + Midia mudam): commitar só os gerados
relevantes; `pubspec.lock` e `windows/flutter/generated_*` ficam fora.

## Erros e casos de borda

- **`rotacaoGraus` adulterado** (45, -90, 999): `resolverQuartosDeVolta`
  normaliza; nunca lança.
- **JSON legado sem os campos**: defaults (`vertical`, `0`).
- **Arquivo ausente/corrompido**: comportamento atual preservado (cor de
  fundo, avança em 1s) — rotação não interfere.
- **Diálogo cancelado**: rotação editada não persiste.
- **Preview em tela deitada com mídia em pé** (e vice-versa): é exatamente o
  cenário que o preview agora simula com honestidade.

## Componentes

| Arquivo | Mudança |
| --- | --- |
| `configuracoes/dominio/entidades/tema_personalizado.dart` | +`OrientacaoTela`, +campo (codegen) |
| `configuracoes/dados/modelos/modelo_tema_personalizado.dart` | +campo espelhado (codegen) |
| `propaganda/dominio/entidades/midia_propaganda.dart` | +`rotacaoGraus` (codegen) |
| `propaganda/dados/modelos/modelo_midia.dart` | +`rotacaoGraus` espelhado (codegen) |
| `propaganda/apresentacao/ajuste_tela.dart` | +`resolverQuartosDeVolta` |
| `propaganda/apresentacao/componentes/player_propaganda.dart` | `FittedBox → RotatedBox` unificado (nítido + borrado); key/fit migram pro FittedBox |
| `configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart` | +`orientacao` (AspectRatio), +botão Girar, +rotação no `aoSalvar`; resumo com sufixo |
| `configuracoes/apresentacao/componentes/aba_propaganda.dart` | +seletor "Tela do totem", ajuda dinâmica, passa orientação e rotação adiante |
| `configuracoes/apresentacao/controladores/controlador_midias.dart` | `definirEnquadramento` +`rotacaoGraus` |

## Testes (TDD — escritos antes)

- **`ajuste_tela`**: `resolverQuartosDeVolta` — 0/90/180/270 → 0/1/2/3;
  adulterados (45→0, 100→1, -90→3, 360→0, 999→3).
- **tema**: round-trip de `orientacaoTela`; JSON legado sem o campo carrega
  `vertical` e o tema não some.
- **`modelo_midia`**: round-trip de `rotacaoGraus`; JSON legado → 0.
- **`player_propaganda`**: `RotatedBox` com `quarterTurns` certo (90° → 1);
  `quarterTurns == 0` sem rotação; `fitAplicado` migrado para `FittedBox`;
  fundo borrado também girado (RotatedBox dentro da camada borrada).
- **`controlador_midias`**: `definirEnquadramento` persiste `rotacaoGraus`.
- **`dialogo_ajuste_midia`**: botão Girar cicla e o preview recebe a mídia
  girada; salvar persiste rotação; cancelar não; preview com `AspectRatio`
  16/9 quando `horizontal` e 9/16 quando `vertical`.
- **`aba_propaganda`**: seletor de orientação persiste no tema; texto de
  ajuda muda com a orientação; teste de 480px continua passando.

## Validação

```bash
dart format .
flutter analyze
flutter test
```
