# Zoom reduzido e âncoras visíveis no diálogo Ajustar

Data: 2026-07-13

Ajustes sobre os specs `2026-07-13-enquadramento-midia-propaganda-design.md` e
`2026-07-13-orientacao-rotacao-midia-design.md`. Nada daqueles documentos muda
além do que está aqui.

## Problema

1. **O zoom não desce de 100%.** No modo preencher o operador só amplia. Com
   vídeo na mesma orientação da tela, falta o movimento contrário: encolher a
   mídia para dar margem ("encaixar ainda mais").
2. **A grade de âncoras é quase invisível.** As células usam cores fixas da
   paleta padrão (`lilasClaro`, `primariaPadrao`, `bordaCard`); em temas claros
   (ex.: bege) as células não selecionadas somem e a selecionada destoa do tema
   da loja.

## Decisões

### 1. Zoom 50–300%

- `zoomMinimo` passa de `100` para `50` em `ajuste_tela.dart`. `resolverEscala`
  já clampa pela constante: JSON adulterado abaixo de 50 vira 50 (o teste de
  clamp atualiza: `resolverEscala(40)` → `0.5`, não mais `1.0`).
- **Zoom < 100% cria sobra**: a mídia coberta encolhe a partir da âncora
  (Transform.scale já se comporta assim) e a moldura em volta é pintada pela
  regra de fundo da mídia — borrado por padrão, ou cor do tema. Para isso,
  `modoDeixaSobra` ganha o zoom:

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

- Chamadores atualizam: player (`_mostraFundoBorrado` passa
  `widget.midia.zoomPercentual`) e diálogo (`_mostraFundo` passa `_zoom` —
  o controle "Fundo da sobra" aparece no preencher quando o slider cruza
  abaixo de 100%, reativo).
- Slider e resumo já derivam de `zoomMinimo`/`zoomMaximo` — mudam sozinhos
  (passos continuam de 5; divisões viram 50).
- Comportamento assumido: o quadro coberto encolhe **inteiro** (formato da
  tela). Não é campo-de-visão: zoom < 100 não revela mais conteúdo da mídia
  além do corte do cover; para ver a mídia inteira existe o automático.
- Mídias já salvas têm zoom ≥ 100: nada muda para elas.

### 2. Grade de âncoras na cor do tema

O diálogo já recebe `corTema` (cor primária da loja). A grade passa a usá-la:

- Célula **selecionada**: borda `widget.corTema` (2px) + preenchimento
  `widget.corTema.withValues(alpha: .18)`.
- Células **não selecionadas**: borda `widget.corTema.withValues(alpha: .45)`
  (1px), sem preenchimento.
- Somem da grade `CoresApp.lilasClaro`, `CoresApp.primariaPadrao` e
  `CoresApp.bordaCard`. (`CoresApp.textoSecundario` continua nos rótulos.)

A cor primária contrasta com o fundo do diálogo em qualquer tema da loja — é
a mesma lógica do restante da identidade visual.

## Erros e casos de borda

- `zoomPercentual` adulterado (< 50, > 300): clamp — nunca estoura.
- Esticar continua sem sobra e sem controles de corte/fundo.
- Vídeo continua atrás do gate do fundo borrado: no preencher com zoom < 100,
  vídeo cai na cor do tema e o controle segue escondido para vídeo.

## Componentes

| Arquivo | Mudança |
| --- | --- |
| `propaganda/apresentacao/ajuste_tela.dart` | `zoomMinimo = 50`; `modoDeixaSobra(ajuste, zoomPercentual)` |
| `propaganda/apresentacao/componentes/player_propaganda.dart` | `_mostraFundoBorrado` passa o zoom |
| `configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart` | `_mostraFundo` passa `_zoom`; grade de âncoras com `corTema` |

## Testes (TDD — escritos antes)

- **`ajuste_tela`**: `resolverEscala(50)` → 0.5; clamp de 40/-5 → 0.5 (atualiza
  o teste existente); `modoDeixaSobra`: automatico/encaixar true com qualquer
  zoom; preencher 80 → true, 100 → false, 300 → false; esticar false com 80.
- **`player_propaganda`**: preencher com zoom 80 e fundo borrado → camada
  borrada presente e `Transform.scale` 0.8; preencher com zoom 100 → sem
  camada (teste existente continua).
- **`dialogo_ajuste_midia`**: no preencher, controle de fundo ausente com zoom
  100 e presente após reduzir para < 100; slider alcança 50%; grade: célula
  selecionada com borda na `corTema` e não selecionada com a mesma cor
  translúcida.

## Validação

```bash
dart format .
flutter analyze
flutter test
```
