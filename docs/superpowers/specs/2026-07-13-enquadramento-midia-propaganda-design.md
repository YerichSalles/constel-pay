# Enquadramento da mídia de propaganda (fundo borrado, âncora e zoom)

Data: 2026-07-13

Substitui a seção **"Regra do modo automático"** do spec
`2026-07-13-ajuste-tela-propaganda-design.md`. O resto daquele documento (modos
`preencher`/`encaixar`/`esticar`, GIF, persistência do `ajuste`) continua valendo.

## Problema

O modo `automatico` corta a mídia. A regra atual, em `ajuste_tela.dart`, aceita
`BoxFit.cover` sempre que `min(razão)/max(razão) >= 0.75` — ou seja, tolera
**perder até 25% da peça**.

Isso destrói arte com texto perto das bordas, que é a norma em propaganda de
restaurante. Nos prints do operador, o corte decepou o título da peça rente à
borda esquerda. O operador não pediu corte nenhum: ele espera que a mídia
apareça inteira.

O limiar `0.75` foi calibrado olhando razão de aspecto, não conteúdo. Não existe
limiar de razão que saiba onde está o texto. A regra está errada na raiz, não
mal calibrada.

Além disso, quando sobra borda, a sobra vira **tarja de cor chapada** — o que faz
a peça parecer pequena e "sobrando" numa tela grande.

## Objetivo

1. `automatico` nunca corta.
2. A sobra deixa de ser tarja chapada e vira **fundo borrado da própria mídia**,
   dando aspecto de tela cheia sem sacrificar um pixel do conteúdo.
3. Quem *quiser* cortar (modo `preencher`) ganha controle de **de onde cortar**
   (âncora) e de **quanto ampliar** (zoom).
4. Esses controles ficam usáveis: um diálogo por mídia, com **preview ao vivo**.

Fora de escopo: recorte por arraste livre (pan), edição de mídia, playlist por
horário, detecção de conteúdo (saliency).

## Decisões

### 1. `automatico` nunca corta

`resolverBoxFit` passa a devolver `BoxFit.contain` para `automatico`,
incondicionalmente. Somem a constante `aproveitamentoMinimoParaPreencher` e toda
a comparação de razões.

Por que não um limiar mais conservador (ex.: 0.95): quando a razão da mídia bate
com a da tela, `contain` e `cover` produzem **exatamente o mesmo resultado** —
sem tarja, sem corte. O caso "corte imperceptível" já se resolve sozinho, sem
regra nenhuma. E quando as razões diferem por pouco, o fundo borrado esconde a
faixa fina melhor do que um corte esconderia. Um limiar novo compraria zero e
traria de volta a classe de bug que estamos consertando.

**Consequência:** o player deixa de precisar da razão da mídia. Some o
`_razaoMidia`, o `ImageStream` de medição, o `_razaoDe()` e a espera-antes-de-
pintar. É deleção intencional, aprovada.

### 2. Fundo da sobra: `FundoMidia`

```dart
enum FundoMidia { borrado, cor }
```

- `borrado` (padrão): a própria mídia, em `cover`, desfocada, atrás da mídia
  nítida.
- `cor`: comportamento atual — cor primária do tema.

Aplicável apenas onde sobra borda: `automatico` e `encaixar`. Em `preencher` e
`esticar` não há sobra, e a UI esconde o controle.

**Mudança silenciosa aceita pelo operador:** com `@Default(borrado)`, as mídias
já cadastradas passam a exibir fundo borrado no próximo boot, sem intervenção.
É a melhoria pretendida.

### 3. Âncora do corte: `AncoraMidia`

```dart
enum AncoraMidia {
  topoEsquerda, topo, topoDireita,
  esquerda, centro, direita,
  baseEsquerda, base, baseDireita,
}
```

Grade 3×3, mapeada para `Alignment` por função pura. Diz **qual parte da mídia
sobrevive** ao corte. Resolve o caso real (assunto no topo sendo cortado pelo
centro) sem a superfície de erro do arraste livre: todo estado possível é válido,
não dá para "perder" a mídia fora da tela.

Aplicável apenas em `preencher`.

### 4. Zoom: `zoomPercentual`

`int`, faixa 100–300, padrão 100. Convertido para escala por função pura, com
`clamp` — valor fora da faixa (JSON adulterado) é corrigido, não estoura.

Aplicável apenas em `preencher`. Combinado com a âncora, dá enquadramento
suficiente sem pan livre.

### 5. UI: diálogo com preview

O card da mídia **perde o dropdown** e passa a mostrar só o resumo do modo em
texto + botão **"Ajustar…"**.

Motivo prático, não estético: âncora e zoom são **inúteis sem preview** — pedir
"corte a partir do topo com 140%" sem ver a mídia é chute. O diálogo mostra o
resultado ao vivo.

Efeito colateral desejado: o card volta a ficar folgado. O `RenderFlex
overflowed` corrigido em `3d8a390` tinha piso de ~380px justamente porque o card
estava lotado; com o dropdown fora, o aperto some na raiz.

## Modelo de dados e migração

`MidiaPropaganda` e `ModeloMidia` ganham:

| Campo | Tipo | Default |
| --- | --- | --- |
| `fundo` | `FundoMidia` | `borrado` |
| `ancora` | `AncoraMidia` | `centro` |
| `zoomPercentual` | `int` | `100` |

Os três com `@Default(...)`; os dois enums com
`@JsonKey(unknownEnumValue: ...)`, seguindo o padrão já usado no `ajuste`.

**O `@Default` é obrigatório, não conveniência.** Playlist já gravada no
`SharedPreferences` não tem essas chaves. Campo `required` faria o `fromJson`
lançar, o `catch` de `repositorio_propaganda_impl.dart` engoliria o erro e
devolveria `const []` — **a playlist da loja sumiria sem aviso**. O teste de
regressão que já existe para esse caminho (`playlist gravada antes do campo
ajuste continua carregando`) será estendido para os campos novos.

`build_runner` está liberado para esta tarefa. Ao commitar, conferir `git status`
e **deixar de fora** `pubspec.lock` e `windows/flutter/generated_*` se o codegen
os tocar.

## Performance no totem — requisito duro

O totem não pode engasgar. Imagem e vídeo têm custos **diferentes** e recebem
tratamentos diferentes.

### Imagem e GIF

O fundo borrado é **estático**. Envolver a camada borrada num `RepaintBoundary`
para rasterizar uma vez e reaproveitar; não há re-blur por frame. Custo
desprezível.

### Vídeo — o ponto caro

Borrar textura viva custa GPU **a cada frame**. Mitigações, em ordem:

1. **Borrar em baixa resolução.** A camada de fundo não precisa de detalhe: ela
   está desfocada. Renderizar a cópia borrada reduzida e deixar o `cover`
   ampliá-la corta o custo do blur por um fator quadrático.
2. **Sigma moderado.** Blur grande é caro; o suficiente para descaracterizar a
   borda, não mais.
3. **Uma textura, dois `Texture`.** O mesmo `VideoPlayerController` alimenta as
   duas camadas — não se instancia um segundo decoder.

### Regra de decisão (não é "boa intenção", é gate)

Medir em **profile build** o custo de frame do vídeo com fundo borrado, contra o
baseline de fundo em cor sólida.

- Se o vídeo se mantiver **em 60fps sem frames perdidos**: fundo borrado vale
  para vídeo também.
- Se **não** se mantiver: `FundoMidia.borrado` passa a valer só para
  imagem/GIF, e **vídeo cai para fundo em cor sólida** — a UI deixa de oferecer
  a opção para vídeo, em vez de oferecer uma opção que trava o totem.

O resultado da medição vai no relatório. Não vou "achar" que está leve.

## Componentes

| Arquivo | Mudança |
| --- | --- |
| `propaganda/dominio/entidades/midia_propaganda.dart` | +2 enums, +3 campos (codegen) |
| `propaganda/dados/modelos/modelo_midia.dart` | +3 campos espelhados (codegen) |
| `propaganda/apresentacao/ajuste_tela.dart` | `automatico`→`contain`; +`resolverAlinhamento`, +`resolverEscala`; −limiar |
| `propaganda/apresentacao/componentes/player_propaganda.dart` | camada de fundo borrado; âncora; zoom; −medição de razão |
| `configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart` | **novo** — preview + modo + fundo + âncora + zoom |
| `configuracoes/apresentacao/componentes/aba_propaganda.dart` | card: resumo + botão "Ajustar…"; texto de ajuda reescrito |
| `configuracoes/apresentacao/controladores/controlador_midias.dart` | `definirEnquadramento(id, {fundo, ancora, zoom})` |
| `configuracoes/apresentacao/componentes/seletor_ajuste_midia.dart` | passa a viver dentro do diálogo |

O texto de ajuda no topo da aba afirma hoje que o Automático "preenche quando o
formato é parecido e encaixa com tarja". Vira mentira — **precisa** ser
reescrito.

## Erros e casos de borda

- **Arquivo ausente/corrompido**: comportamento atual preservado (avança em 1s).
  Sem mídia, não há o que borrar: cai na cor de fundo.
- **`zoomPercentual` fora da faixa** (JSON adulterado): `clamp(100, 300)`.
- **JSON legado sem os campos novos**: `@Default`. É o caso que, mal resolvido,
  apaga a playlist da loja.
- **Diálogo cancelado**: nada persiste. O estado do diálogo é local; só o
  "Salvar" chama o controlador.
- **Zoom/âncora em modo que não corta**: ignorados na renderização e escondidos
  na UI. Não são apagados do modelo — o operador pode voltar para `preencher` e
  reencontrar o que tinha configurado.

## Testes (TDD — escritos antes)

- **`ajuste_tela`**: `automatico` devolve `contain` em qualquer razão (inclusive
  as que hoje dão `cover`, provando a correção); os 3 modos explícitos; as 9
  âncoras → `Alignment`; `clamp` do zoom acima e abaixo da faixa.
- **`modelo_midia`**: round-trip dos 3 campos; **JSON legado sem eles carrega com
  os defaults e a lista não volta vazia**.
- **`controlador_midias`**: `definirEnquadramento` persiste e atualiza o estado.
- **`player_propaganda`**: camada borrada presente quando `fundo == borrado` e o
  modo sobra borda; ausente quando `fundo == cor`; `Transform.scale` aplicado só
  em `preencher`.
- **`dialogo_ajuste_midia`**: cancelar não persiste; salvar persiste; controles
  de âncora/zoom só aparecem em `preencher`; controle de fundo só em
  `automatico`/`encaixar`.
- **`aba_propaganda`**: card mostra resumo + botão; **o teste de largura estreita
  (480px) continua passando**.

## Validação

```bash
dart format .
flutter analyze
flutter test
```

Mais a medição de frame do vídeo em profile build, conforme o gate acima.
