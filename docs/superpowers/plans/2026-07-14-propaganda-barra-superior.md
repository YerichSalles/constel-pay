# Aba Propaganda: Conteúdo da Tela + Publicidade da Barra Superior — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transformar a aba "Propaganda" em central com duas seções internas — "Conteúdo da tela" (preserva 100% do atual) e "Barra superior" (nova publicidade com 3 formatos exclusivos: carrossel 1A, letreiro 1B, parceiro fixo 1C) — com prévia ao vivo, herança visual da aba Aparência e persistência independente.

**Architecture:** Camadas padrão do projeto (`UI ConsumerWidget → StateNotifier → Repositorio interface → Impl SharedPreferences/JSON`, providers em `injecao.dart`). Nova entidade freezed `PublicidadeBarra` (chave SP `'publicidade_barra'`). Rascunho/aplicar SÓ na seção nova (padrão `AbaAparencia`); seção Conteúdo da tela mantém persistência imediata atual. Exibição no atendimento: slot opcional `publicidade` na `BarraSuperior`, preenchido pela `PaginaChat`.

**Tech Stack:** Flutter ≥3.22, Riverpod StateNotifier, freezed + json_serializable (codegen NECESSÁRIO em Task 1), SharedPreferences, flutter_test.

## Global Constraints

- Root git: `D:\constel-pay-main\constel-pay-main`; branch `feat/sessao-2026-07-14` (já existe — NÃO criar branch). Commits SEM `Co-Authored-By` (conferir `git log -1 --format=%B` após cada commit).
- **Codegen:** Task 1 exige `dart run build_runner build --delete-conflicting-outputs`. REGRA DA MÁQUINA: o build_runner rebaixa o `pubspec.lock` — após rodar, executar `git checkout -- pubspec.lock` e conferir `git status` antes de commitar. Commitar os `.freezed.dart`/`.g.dart` gerados, NUNCA o lock.
- Arquivos < 600 linhas (dividir widgets grandes). pt-BR em tudo. Moeda não se aplica aqui.
- NÃO alterar: abas Comunicação/Aparência/Diagnóstico, fluxo de pagamento, cálculos, integrações, lógica de reprodução das mídias da tela (`pagina_propaganda.dart`, `player_propaganda.dart`, `trocador_propaganda.dart`, `controlador_propaganda.dart`, `ajuste_tela.dart` — intocados).
- Preservar TODAS as mídias já cadastradas (chave SP `'midias_propaganda'` intocada) e todo o comportamento da lista atual (ordenar/ativar/remover/ajustar/visualizar/duração/orientação).
- Formatos aceitos na publicidade da barra: SOMENTE png/jpg/jpeg/webp/gif (decisão: sem vídeo nesta entrega — spec só permite vídeo com garantia de estabilidade, que não temos na barra).
- Somente um formato ativo por vez; trocar formato NUNCA apaga dados dos outros.
- Textos exatos deste plano são contrato de teste — não parafrasear.
- Ao final de cada task: rodar os testes focados; na última: `dart format .`, `flutter analyze`, `flutter test` completos.

## Textos exatos (contrato — usados em UI e testes)

| Chave | Texto |
|---|---|
| Navegação interna | `Conteúdo da tela` / `Barra superior` (inicial: Conteúdo da tela) |
| Cabeçalho conteúdo | `Conteúdo da tela` + `Configure as imagens, GIFs e vídeos exibidos enquanto o terminal estiver aguardando um atendimento.` |
| Orientação descrição | vertical: `Formato indicado para terminais verticais.` / horizontal: `Formato indicado para terminais horizontais.` |
| Ações conteúdo | `+ Adicionar mídia` (primário) / `Visualizar sequência` (secundário) |
| Remover mídia | `Remover mídia?` + `Esta mídia deixará de ser exibida no terminal.` (diálogo atual já usa confirmação — só garantir estes textos) |
| Seção barra | `Publicidade na barra superior` + `Exiba campanhas, eventos, avisos, marcas ou parceiros durante o atendimento.` |
| Toggle | `Exibir publicidade na barra` |
| Formato seção | `Formato de exibição` |
| Card 1A | código `1A`, nome `Carrossel de banners`, descrição `Alterne automaticamente campanhas, eventos, parceiros e conteúdos institucionais.`, complemento `Melhor opção para exibir várias artes no mesmo espaço.` |
| Card 1B | código `1B`, nome `Letreiro de mensagens`, descrição `Exiba frases e avisos em movimento sem precisar criar artes.`, complemento `Indicado para eventos, promoções e comunicados rápidos.` |
| Card 1C | código `1C`, nome `Espaço fixo de parceiro`, descrição `Exiba uma única imagem, GIF ou vídeo continuamente.`, complemento `Indicado para publicidade de parceiros ou campanhas prioritárias.` |
| Carrossel editor | título `Carrossel de banners`, descrição `Alterne automaticamente campanhas dentro da barra superior.`, campo `Tempo entre banners` (3/5/6/8/10/15 s, default 6), campo `Transição` (Suave/Deslizar/Sem animação, default Suave), lista `Banners`, botão `+ Adicionar banner`, dica `Recomendado: 384 × 192 px, proporção 2:1.`, aviso `Recomendamos até 5 banners ativos para manter uma rotação rápida.` |
| Letreiro editor | título `Letreiro de mensagens`, descrição `Crie avisos e divulgações sem precisar produzir imagens.`, lista `Mensagens`, botão `+ Adicionar mensagem`, campo `Mensagem` com contador `N / 100` (maxLength 100), campo `Velocidade` (Lenta/Normal/Rápida, default Normal), campo `Separador` (opções `•` `|` `—` `★`, default `•`), bloco `Estilo visual` + `Fonte e cores herdadas da aba Aparência.` + resumo somente leitura (Fonte, Cor principal, Cor secundária) + ação `Ajustar aparência` |
| Parceiro editor | título `Espaço fixo de parceiro`, descrição `Exiba uma única publicidade continuamente durante o atendimento.`, bloco `Publicidade atual`, botões `Alterar mídia` / `Remover mídia`, confirmação `Remover publicidade?`, dica `Recomendado: 1040 × 128 px.` |
| Remoções | `Remover banner?` / `Remover mensagem?` / `Remover publicidade?` |
| Sem conteúdo (config) | `Nenhum conteúdo configurado.` |
| Sem conteúdo (prévia) | `Adicione conteúdo para visualizar.` |
| Validação | `Adicione ao menos um conteúdo antes de ativar este formato.` |
| Barra de edição | `Alterações não salvas` / `Descartar alterações` / `Aplicar alterações` |
| Sucesso aplicar | `Configurações de propaganda aplicadas com sucesso.` |
| Prévia seção | `Pré-visualização` |

## Decisões de design travadas

1. **Banners e mídia do parceiro reutilizam `MidiaPropaganda`** (tipo sempre `imagem`; `duracaoSegundos`/`fundo`/`rotacaoGraus` ignorados na barra). Ganha de graça: `DialogoAjusteMidia` (ajustar), `resumoEnquadramento`, cards. Ajuste do banner usa `ajuste`/`ancora`/`zoomPercentual`.
2. **Rascunho/aplicar** só na seção Barra superior: `EstadoPublicidade{salva, rascunho, carregando}`; nada persiste até `aplicar()`. Conteúdo da tela intocado (persistência imediata via `provedorMidias`).
3. **Exibição**: `BarraSuperior` ganha `Widget? publicidade` (opcional, zero impacto nos usos atuais) inserido como `Expanded` após o título; `PaginaChat` monta `PublicidadeBarraSuperior` que lê a config SALVA no init (repositório direto — não o provedor de rascunho).
4. **Transições do carrossel**: `AnimatedSwitcher` (suave=fade, deslizar=slide horizontal, semAnimacao=troca direta). Timer por `intervaloSegundos`. Indicadores ● ○ ○ só com >1 banner ativo. Play/pause só na prévia.
5. **Letreiro**: `AnimationController.repeat` + medição do texto (`TextPainter`); se o texto couber na área → exibição estática (sem animação). Velocidades: lenta 40 px/s, normal 70 px/s, rápida 110 px/s. Texto = mensagens ativas ordenadas unidas por ` <separador> `.
6. **Cores do letreiro/container**: fundo = variação da `corPrimaria` (clarear se escura / escurecer se clara, via HSL como `_ajustarLuminosidade` da BarraSuperior); texto = branco se `computeLuminance()<.5`, senão `Color(0xFF1E1E1E)`; separador = `corSecundaria` se `razaoDeContraste(fundo, secundaria) >= 3.0` (usar `nucleo/utils/contraste.dart`), senão a cor do texto. Fonte = `EstilosTexto.estilo(tema.fonte, ...)`. NENHUM seletor próprio de fonte/cor.
7. **Navegar para a aba Aparência** ("Ajustar aparência"): `DefaultTabController.of(context).animateTo(1)` (índice 1 = Aparência). Rascunho da Propaganda preservado (KeepAlive).
8. **Validação no Aplicar**: se `rascunho.ativa` e o formato selecionado não tem conteúdo ativo → snackbar com o texto de validação e NÃO persiste.
9. **Split de arquivos**: `aba_propaganda.dart` vira casca (~80 linhas: `SegmentedButton` + `IndexedStack`); conteúdo atual movido para `secao_conteudo_tela.dart`; seção nova em `secao_barra_superior.dart` + componentes dedicados. Nenhum arquivo ≥600 linhas.

---

### Task 1: Entidade, modelo JSON, repositório e provider da publicidade

**Files:**
- Create: `lib/funcionalidades/propaganda/dominio/entidades/publicidade_barra.dart`
- Create: `lib/funcionalidades/propaganda/dados/modelos/modelo_publicidade.dart`
- Create: `lib/funcionalidades/propaganda/dominio/repositorios/repositorio_publicidade.dart`
- Create: `lib/funcionalidades/propaganda/dados/repositorios/repositorio_publicidade_impl.dart`
- Modify: `lib/aplicativo/injecao.dart` (novo provider)
- Test: `test/funcionalidades/propaganda/repositorio_publicidade_test.dart`

**Interfaces (Produces):**

```dart
// publicidade_barra.dart
enum FormatoPublicidade { carrossel, letreiro, parceiro }
enum TransicaoCarrossel { suave, deslizar, semAnimacao }
enum VelocidadeLetreiro { lenta, normal, rapida }

const List<int> intervalosCarrossel = [3, 5, 6, 8, 10, 15];
const List<String> separadoresLetreiro = ['•', '|', '—', '★'];
const int limiteMensagemLetreiro = 100;

@freezed
class MensagemLetreiro with _$MensagemLetreiro {
  const factory MensagemLetreiro({
    required String id,
    required String texto,
    required int ordem,
    @Default(true) bool ativo,
  }) = _MensagemLetreiro;
}

@freezed
class PublicidadeBarra with _$PublicidadeBarra {
  const PublicidadeBarra._();
  const factory PublicidadeBarra({
    @Default(false) bool ativa,
    @Default(FormatoPublicidade.carrossel) FormatoPublicidade formato,
    @Default([]) List<MidiaPropaganda> banners,
    @Default(6) int intervaloSegundos,
    @Default(TransicaoCarrossel.suave) TransicaoCarrossel transicao,
    @Default([]) List<MensagemLetreiro> mensagens,
    @Default(VelocidadeLetreiro.normal) VelocidadeLetreiro velocidade,
    @Default('•') String separador,
    MidiaPropaganda? midiaParceiro,
  }) = _PublicidadeBarra;

  List<MidiaPropaganda> get bannersAtivos =>
      (banners.where((b) => b.ativo).toList()..sort((a, b) => a.ordem.compareTo(b.ordem)));
  List<MensagemLetreiro> get mensagensAtivas =>
      (mensagens.where((m) => m.ativo).toList()..sort((a, b) => a.ordem.compareTo(b.ordem)));

  /// O formato selecionado tem conteúdo ativo para exibir?
  bool get formatoTemConteudo => switch (formato) {
        FormatoPublicidade.carrossel => bannersAtivos.isNotEmpty,
        FormatoPublicidade.letreiro => mensagensAtivas.isNotEmpty,
        FormatoPublicidade.parceiro => midiaParceiro != null,
      };

  /// Deve exibir publicidade no terminal?
  bool get exibivel => ativa && formatoTemConteudo;
}
```

```dart
// repositorio_publicidade.dart
abstract interface class RepositorioPublicidade {
  Future<PublicidadeBarra> obter();
  Future<void> salvar(PublicidadeBarra publicidade);
}
```

- `ModeloPublicidade` (freezed + json_serializable, espelha `ModeloMidia`/`ModeloTemaPersonalizado`): `fromJson`/`toJson`/`deEntidade`/`paraEntidade`, com `@JsonKey(unknownEnumValue: ...)` nos enums e sub-modelo `ModeloMensagemLetreiro`. Banners/midiaParceiro serializam via `ModeloMidia` existente. Header `// ignore_for_file: invalid_annotation_target` (padrão do repo).
- `RepositorioPublicidadeImpl(SharedPreferences)`: chave `'publicidade_barra'`, JSON. `obter()` sem chave/JSON inválido → `const PublicidadeBarra()` (nunca lançar).
- `injecao.dart`: `final provedorRepositorioPublicidade = Provider<RepositorioPublicidade>((ref) => RepositorioPublicidadeImpl(ref.watch(provedorSharedPreferences)));`

**Steps:**
- [ ] 1. Escrever `repositorio_publicidade_test.dart` (padrão de `repositorio_propaganda_test.dart`: `SharedPreferences.setMockInitialValues`): round-trip completo (todos os campos, incluindo banner com ajuste/âncora/zoom e midiaParceiro), obter() sem chave → defaults, JSON corrompido (`'{lixo'`) → defaults, enum desconhecido no JSON → `unknownEnumValue`, `formatoTemConteudo`/`exibivel`/`bannersAtivos` (ordena e filtra).
- [ ] 2. Rodar → FAIL (classes não existem).
- [ ] 3. Implementar os 4 arquivos + provider.
- [ ] 4. `dart run build_runner build --delete-conflicting-outputs` → gerar `.freezed.dart`/`.g.dart`. **Em seguida `git checkout -- pubspec.lock`.** Ler o `modelo_publicidade.g.dart` gerado e conferir `fromJson` com chaves ausentes (defaults) — anotar no report.
- [ ] 5. `flutter test test/funcionalidades/propaganda/repositorio_publicidade_test.dart` → PASS; `flutter test test/funcionalidades/propaganda/` → tudo verde.
- [ ] 6. Commit: `feat: entidade e persistencia da publicidade da barra superior` (conferir `git status` — pubspec.lock fora; incluir gerados).

---

### Task 2: ControladorPublicidade (rascunho/aplicar/descartar)

**Files:**
- Create: `lib/funcionalidades/configuracoes/apresentacao/controladores/controlador_publicidade.dart`
- Test: `test/funcionalidades/configuracoes/controlador_publicidade_test.dart`

**Interfaces:**
- Consumes: Task 1 (`PublicidadeBarra`, `RepositorioPublicidade`, `provedorRepositorioPublicidade`).
- Produces:

```dart
@freezed
class EstadoPublicidade with _$EstadoPublicidade {
  const EstadoPublicidade._();
  const factory EstadoPublicidade({
    @Default(PublicidadeBarra()) PublicidadeBarra salva,
    @Default(PublicidadeBarra()) PublicidadeBarra rascunho,
    @Default(true) bool carregando,
  }) = _EstadoPublicidade;
  bool get pendentes => !carregando && rascunho != salva;
}

class ControladorPublicidade extends StateNotifier<EstadoPublicidade> {
  ControladorPublicidade(this._repositorio) : super(const EstadoPublicidade());
  Future<void> carregar();                       // repo.obter() → salva=rascunho=valor, carregando=false
  void editar(PublicidadeBarra novo);            // só rascunho
  // Conveniências que operam no rascunho (todas via editar):
  void alternarAtiva(bool valor);
  void selecionarFormato(FormatoPublicidade formato);   // NUNCA limpa dados dos outros formatos
  void definirIntervalo(int segundos);
  void definirTransicao(TransicaoCarrossel transicao);
  void definirVelocidade(VelocidadeLetreiro velocidade);
  void definirSeparador(String separador);
  // Banners (mesma semântica do ControladorMidias, mas no rascunho):
  void adicionarBanners(List<String> caminhos);  // uuid, ordem sequencial, tipo imagem, ativo=true
  void alternarBannerAtivo(String id);
  void moverBanner(String id, int delta);
  void removerBanner(String id);
  void ajustarBanner(String id, {required AjusteMidia ajuste, required AncoraMidia ancora, required int zoomPercentual});
  // Mensagens:
  void adicionarMensagem(String texto);          // uuid, ordem sequencial, ativo=true, trim, ignora vazio
  void editarMensagem(String id, String texto);
  void alternarMensagemAtiva(String id);
  void moverMensagem(String id, int delta);
  void removerMensagem(String id);
  // Parceiro:
  void definirMidiaParceiro(String caminho);     // substitui (uma só)
  void ajustarMidiaParceiro({required AjusteMidia ajuste, required AncoraMidia ancora, required int zoomPercentual});
  void removerMidiaParceiro();
  // Ciclo:
  Future<bool> aplicar();   // se rascunho.ativa && !rascunho.formatoTemConteudo → return false (não persiste); senão salva no repo, salva=rascunho, return true
  void descartar();         // rascunho = salva
}

final provedorPublicidade = StateNotifierProvider.autoDispose<ControladorPublicidade, EstadoPublicidade>(...); // chama carregar(), padrão do provedorMidias
```

**Steps:**
- [ ] 1. Testes (padrão `controlador_midias_test.dart`, repo fake em memória): carregar popula salva=rascunho; edições só mudam rascunho (salva intacta, `pendentes=true`); trocar formato preserva banners/mensagens/parceiro; mover/ativar/remover banner e mensagem; `aplicar()` persiste e zera pendentes; `aplicar()` com ativa+formato vazio retorna false e NÃO persiste; `descartar()` restaura; `adicionarMensagem('  ')` ignorado.
- [ ] 2. FAIL → 3. Implementar (freezed no estado → build_runner de novo + `git checkout -- pubspec.lock`) → 4. PASS (`flutter test test/funcionalidades/configuracoes/controlador_publicidade_test.dart` + pasta) → 5. Commit `feat: controlador de rascunho da publicidade da barra`.

---

### Task 3: Reorganizar a aba — navegação interna + seção Conteúdo da tela

**Files:**
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart` (vira casca)
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/secao_conteudo_tela.dart` (conteúdo atual movido + melhorias)
- Test (modify): `test/funcionalidades/configuracoes/aba_propaganda_test.dart`

**Interfaces:**
- Produces: `AbaPropaganda` (mesma classe pública) com `SegmentedButton<int>` no topo (`Conteúdo da tela`=0 / `Barra superior`=1, inicial 0) + `IndexedStack` com `SecaoConteudoTela()` e placeholder `SecaoBarraSuperior` (até a Task 7, um `SizedBox.shrink()` interno — a casca importa a seção real na Task 7; nesta task, coloque um `Center(child: Text('Em construção'))` temporário que a Task 7 substitui). `AutomaticKeepAliveClientMixin` na casca.
- `SecaoConteudoTela`: TODO o conteúdo/comportamento atual da aba (lista, orientação, duração, ajuste, mover, ativar, remover, adicionar, visualizar) MOVIDO SEM ALTERAR LÓGICA, mais somente estas melhorias visuais:
  - Cabeçalho `SecaoConfiguracoes(titulo: 'Conteúdo da tela', descricao: 'Configure as imagens, GIFs e vídeos exibidos enquanto o terminal estiver aguardando um atendimento.', ...)`.
  - Descrição dinâmica da orientação: `Formato indicado para terminais verticais.` / `Formato indicado para terminais horizontais.` (mantendo o texto de resolução atual).
  - Botões renomeados: `+ Adicionar mídia` (BotaoPrimario) / `Visualizar sequência` (BotaoSecundario).
  - `Tooltip` nas ações do card (Mover para cima / Mover para baixo / Ativar ou desativar / Remover).
  - Confirmação de remoção com textos exatos `Remover mídia?` / `Esta mídia deixará de ser exibida no terminal.`.
  - Nome amigável no card: título `Imagem N`/`Vídeo N`/`GIF N` (N = posição na lista, 1-based; GIF = extensão .gif) com o nome do arquivo como subtítulo (informação secundária, fonte menor).

**Steps:**
- [ ] 1. Atualizar `aba_propaganda_test.dart`: testes existentes continuam (ajustar finders para os novos rótulos/nome amigável) + novos: navegação interna mostra os 2 segmentos, inicial é Conteúdo da tela; alternar para Barra superior e voltar preserva a lista (IndexedStack).
- [ ] 2. FAIL → 3. Implementar (mover código; casca <120 linhas; seção <450) → 4. `flutter test test/funcionalidades/configuracoes/` verde → 5. Commit `feat: navegacao interna da aba propaganda e secao conteudo da tela`.

---

### Task 4: Widgets de exibição da publicidade (letreiro, carrossel, parceiro)

**Files:**
- Create: `lib/funcionalidades/propaganda/apresentacao/componentes/letreiro_publicidade.dart`
- Create: `lib/funcionalidades/propaganda/apresentacao/componentes/carrossel_publicidade.dart`
- Create: `lib/funcionalidades/propaganda/apresentacao/componentes/conteudo_publicidade.dart`
- Test: `test/funcionalidades/propaganda/conteudo_publicidade_test.dart`

**Interfaces (Produces):**

```dart
// letreiro_publicidade.dart
class LetreiroPublicidade extends StatefulWidget {
  const LetreiroPublicidade({
    super.key,
    required this.mensagens,        // List<String> — já ativas e ordenadas
    required this.separador,
    required this.velocidade,       // VelocidadeLetreiro
    required this.corFundo,         // Color — variação da primária, calculada pelo chamador
    required this.corTexto,
    required this.corSeparador,
    required this.fonte,            // String — nome da fonte da Aparência
    this.animar = true,             // false na prévia pausada/testes
  });
}
// Comportamento: mede o texto composto (mensagens unidas por ' <sep> ') via TextPainter;
// se couber na largura disponível → Center estático; senão translação contínua
// (AnimationController.repeat, px/s: lenta 40, normal 70, rapida 110), repetindo o
// texto com espaçamento de 48px para reinício suave. ClipRect. Altura 40, borderRadius 10.

// carrossel_publicidade.dart
class CarrosselPublicidade extends StatefulWidget {
  const CarrosselPublicidade({
    super.key,
    required this.banners,          // List<MidiaPropaganda> — já ativos e ordenados
    required this.intervaloSegundos,
    required this.transicao,        // TransicaoCarrossel
    required this.corIndicadores,   // Color
    this.reproduzindo = true,       // pausável na prévia
  });
}
// Timer periódico avança índice circular; AnimatedSwitcher: suave=FadeTransition,
// deslizar=SlideTransition horizontal, semAnimacao=transitionBuilder direto (child).
// Cada banner: Image.file com resolverBoxFit(ajuste)/resolverAlinhamento(ancora)/
// Transform.scale(resolverEscala(zoom)) — reutilizar ajuste_tela.dart. ClipRRect(10).
// Indicadores ● ○ ○ (bolinhas 5px, corIndicadores com alpha .35 nas inativas) SÓ se banners.length > 1.
// banners com 1 item: sem timer, sem indicadores.

// conteudo_publicidade.dart — despachante puro (stateless)
/// Cores derivadas do tema para a área publicitária (função pura, testável).
class CoresPublicidade {
  const CoresPublicidade({required this.fundo, required this.texto, required this.destaque});
  final Color fundo;     // variação HSL da corPrimaria
  final Color texto;     // branco ou #1E1E1E por luminância do fundo
  final Color destaque;  // corSecundaria se contraste >= 3.0 com o fundo, senão = texto (separador/indicadores)
}
CoresPublicidade calcularCoresPublicidade(TemaPersonalizado tema) { ... }

class ConteudoPublicidade extends StatelessWidget {
  const ConteudoPublicidade({
    super.key,
    required this.publicidade,      // PublicidadeBarra
    required this.tema,             // TemaPersonalizado
    this.reproduzindo = true,
  });
}
// Se !publicidade.exibivel → SizedBox.shrink().
// Calcula cores (decisão 6 do plano): fundo = variação HSL da corPrimaria
// (lightness +0.10 se computeLuminance()<.5, senão -0.10, clamp 0..1);
// corTexto = luminância do fundo <.5 ? Colors.white : Color(0xFF1E1E1E);
// corSeparador/corIndicadores = corSecundaria se razaoDeContraste(fundo, secundaria) >= contrasteMinimoTextoGrande, senão corTexto.
// Despacha por formato: carrossel→CarrosselPublicidade, letreiro→LetreiroPublicidade
// (mensagens: publicidade.mensagensAtivas.map((m)=>m.texto), fonte: tema.fonte),
// parceiro→imagem única com enquadramento (mesmo render do banner, sem timer).
```

**Steps:**
- [ ] 1. Testes de widget (`conteudo_publicidade_test.dart`; imagens: usar arquivos inexistentes — `Image.file` com `errorBuilder`? NÃO: os widgets devem usar `Image.file(..., errorBuilder: (c,e,s) => const SizedBox.shrink())` para robustez, e os testes de carrossel/parceiro montam com caminho inexistente validando estrutura sem erro): `exibivel=false` → shrink; letreiro estático quando texto curto em área larga (sem exceção com `animar:false`); letreiro monta com emojis sem erro; carrossel 1 banner sem indicadores / 3 banners com 3 indicadores; parceiro renderiza; contraste: com primária escura o texto do letreiro é branco (expor cores calculadas via `Key`s ou testar função pura — extrair `CoresPublicidade calcularCoresPublicidade(TemaPersonalizado tema)` como função top-level testável em `conteudo_publicidade.dart` e testar direto: primária escura→texto branco; secundária sem contraste→separador cai na cor do texto).
- [ ] 2. FAIL → 3. Implementar (cada arquivo <300 linhas) → 4. PASS pasta propaganda → 5. Commit `feat: widgets de exibicao da publicidade da barra`.

---

### Task 5: Slot na BarraSuperior + integração na PaginaChat

**Files:**
- Modify: `lib/compartilhado/widgets/barra_superior.dart` (param opcional)
- Create: `lib/funcionalidades/propaganda/apresentacao/componentes/publicidade_barra_superior.dart`
- Modify: `lib/funcionalidades/chat/apresentacao/paginas/pagina_chat.dart` (só a chamada `BarraSuperior(...)`)
- Test: `test/funcionalidades/propaganda/publicidade_barra_superior_test.dart`; Modify: `test/compartilhado/barra_superior_test.dart`

**Interfaces:**
- `BarraSuperior` ganha `this.publicidade` (`Widget?`). No `title` Row atual, após o `Column` do título: `if (publicidade != null) const SizedBox(width: 12), if (publicidade != null) Expanded(child: publicidade!)`. Título deixa de ocupar `Expanded`? — hoje o Row tem avatar + Column; garantir que o `Column` do título fique em `Flexible` com `TextOverflow.ellipsis` quando houver publicidade, preservando prioridade visual: voltar > logo > nome > publicidade (publicidade só usa o espaço restante). Sem publicidade → layout EXATAMENTE igual ao atual.
- `PublicidadeBarraSuperior` (ConsumerStatefulWidget): no init lê `ref.read(provedorRepositorioPublicidade).obter()`; guarda em estado local; `tema = ref.watch(provedorTema)`; render `ConteudoPublicidade(publicidade: valor, tema: tema)`; enquanto carrega ou `!exibivel` → `SizedBox.shrink()` (barra idêntica à atual — some sem caixa vazia, sem alterar altura).
- `PaginaChat`: `appBar: BarraSuperior(titulo: ..., avatar: ..., aoVoltar: ..., publicidade: const PublicidadeBarraSuperior())`.

**Steps:**
- [ ] 1. Testes: `barra_superior_test.dart` — sem publicidade layout atual OK (testes existentes passam sem mudança); com publicidade widget aparece; título com nome longo + publicidade não overflowa em 480px (`tester.view.physicalSize`). `publicidade_barra_superior_test.dart` — SP vazio → shrink; SP com publicidade ativa+letreiro com mensagem → letreiro presente; ativa=false → shrink (preservando conteúdo salvo).
- [ ] 2. FAIL → 3. Implementar → 4. PASS (`test/compartilhado/` + `test/funcionalidades/propaganda/` + suite chat: `flutter test test/funcionalidades/chat/` para garantir PaginaChat intacta) → 5. Commit `feat: publicidade da barra superior no atendimento`.

---

### Task 6: Componentes de edição (cards de formato + 3 editores)

**Files:**
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/cartao_formato_publicidade.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/editor_carrossel.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/editor_letreiro.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/editor_parceiro.dart`
- Test: `test/funcionalidades/configuracoes/editores_publicidade_test.dart`

**Interfaces (todos componentes CONTROLADOS — recebem valor + callbacks, sem estado próprio de domínio, sem Riverpod):**

```dart
class CartaoFormatoPublicidade extends StatelessWidget {
  const CartaoFormatoPublicidade({super.key, required this.codigo, required this.nome,
    required this.descricao, required this.complemento, required this.miniatura,
    required this.selecionado, required this.aoTocar});
}
// Card inteiro clicável (InkWell), borda destacada + check quando selecionado (não só cor:
// mostrar Icon(Icons.check_circle)), Semantics(button: true, selected: selecionado).
// miniatura: Widget — representações estilizadas simples por formato (desenhadas com Containers/
// Text, sem assets): 1A barra com blocos + ● ○ ○; 1B texto 'Constel Pay · pague sem fila 😊';
// 1C bloco 'SEU ANÚNCIO AQUI'.

class EditorCarrossel extends StatelessWidget {
  const EditorCarrossel({super.key, required this.publicidade, // PublicidadeBarra (rascunho)
    required this.aoDefinirIntervalo, required this.aoDefinirTransicao,
    required this.aoAdicionarBanners,          // VoidCallback — abre FilePicker no pai? NÃO: recebe VoidCallback; o FilePicker fica na Task 7 (seção), que injeta
    required this.aoAlternarBanner, required this.aoMoverBanner,
    required this.aoRemoverBanner,             // ValueChanged<String> — pai confirma com 'Remover banner?'
    required this.aoAjustarBanner});           // ValueChanged<MidiaPropaganda> — pai abre DialogoAjusteMidia
}
// Dropdown 'Tempo entre banners' (intervalosCarrossel, sufixo ' segundos'), Dropdown 'Transição'
// (Suave/Deslizar/Sem animação), lista 'Banners' com cards no padrão do card de mídia da
// SecaoConteudoTela (miniatura Image.file 64x32 com errorBuilder, nome amigável 'Banner N' +
// arquivo como subtítulo, resumoEnquadramento, ações Ajustar/↑/↓/Switch/🗑 com Tooltips),
// BotaoSecundario '+ Adicionar banner', textos de dica e aviso de 5 banners (exatos da tabela).
// Estado vazio: 'Nenhum conteúdo configurado.'

class EditorLetreiro extends StatelessWidget {
  const EditorLetreiro({super.key, required this.publicidade, required this.tema, // TemaPersonalizado
    required this.aoAdicionarMensagem,   // ValueChanged<String>
    required this.aoEditarMensagem,      // void Function(String id, String texto)
    required this.aoAlternarMensagem, required this.aoMoverMensagem,
    required this.aoRemoverMensagem,     // ValueChanged<String> — pai confirma 'Remover mensagem?'
    required this.aoDefinirVelocidade, required this.aoDefinirSeparador,
    required this.aoAjustarAparencia});  // VoidCallback — pai faz animateTo(1)
}
// Lista 'Mensagens' (cards com texto, ↑/↓/Switch/🗑 + Tooltips), '+ Adicionar mensagem' abre
// diálogo com TextFormField maxLength 100 (contador nativo 'N / 100' via maxLength) — editar
// reutiliza o mesmo diálogo preenchido; Dropdown 'Velocidade'; Dropdown 'Separador'
// (opções separadoresLetreiro, itens renderizados na corSecundaria do tema);
// bloco 'Estilo visual': 'Fonte e cores herdadas da aba Aparência.' + linhas somente leitura
// (Fonte: tema.fonte na própria fonte via EstilosTexto.estilo; Cor principal: bolinha + hex;
// Cor secundária: bolinha + hex) + TextButton 'Ajustar aparência'.
// Estado vazio: 'Nenhum conteúdo configurado.'

class EditorParceiro extends StatelessWidget {
  const EditorParceiro({super.key, required this.publicidade,
    required this.aoAlterarMidia,       // VoidCallback (FilePicker no pai)
    required this.aoRemoverMidia,       // VoidCallback — pai confirma 'Remover publicidade?'
    required this.aoAjustarMidia});     // VoidCallback — pai abre DialogoAjusteMidia
}
// 'Publicidade atual': prévia larga (Image.file, AspectRatio 1040/128, errorBuilder), nome do
// arquivo + dica 'Recomendado: 1040 × 128 px.', botões 'Alterar mídia' (secundário),
// 'Ajustar…' e 'Remover mídia' (texto). Sem mídia: 'Nenhum conteúdo configurado.' +
// BotaoSecundario 'Alterar mídia' vira o CTA de adicionar. NUNCA lista/ordenar/tempo/indicadores.
```

**Steps:**
- [ ] 1. Testes de widget (montagem com `MaterialApp`+`Scaffold`, callbacks capturados em variáveis): cards de formato — 3 cards com códigos/nomes, tocar chama callback, selecionado mostra check; carrossel — dropdowns disparam callbacks, banner some/aparece, aviso de 5 banners presente, vazio mostra 'Nenhum conteúdo configurado.'; letreiro — adicionar mensagem via diálogo com contador, resumo de estilo mostra fonte/cores do tema, 'Ajustar aparência' dispara callback; parceiro — sem mídia mostra CTA, com mídia mostra botões.
- [ ] 2. FAIL → 3. Implementar (cada editor <350 linhas) → 4. PASS → 5. Commit `feat: editores dos formatos de publicidade`.

---

### Task 7: SecaoBarraSuperior — montagem, prévia ao vivo e aplicar/descartar

**Files:**
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/secao_barra_superior.dart`
- Create: `lib/funcionalidades/configuracoes/apresentacao/componentes/previa_publicidade.dart`
- Modify: `lib/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart` (trocar placeholder pela seção real)
- Test: `test/funcionalidades/configuracoes/secao_barra_superior_test.dart`

**Interfaces:**
- `PreviaPublicidade({required PublicidadeBarra publicidade, required TemaPersonalizado tema, required String nomeEstabelecimento, String? logoPath, required bool reproduzindo, required VoidCallback aoAlternarReproducao})` — réplica da barra real (mesmo gradiente/estrutura da `BarraSuperior` em miniatura, com ← + logo/avatar + nome reais) contendo `ConteudoPublicidade(publicidade, tema, reproduzindo: reproduzindo)`. Publicidade ativa sem conteúdo → texto `Adicione conteúdo para visualizar.`. Botões `▶ Reproduzir`/`⏸ Pausar` (alternam via callback) SÓ aqui. Rótulo `Pré-visualização` via `SecaoConfiguracoes`.
- `SecaoBarraSuperior` (ConsumerStatefulWidget): consome `provedorPublicidade` (rascunho) + `provedorTema` + nome via `provedorRepositorioConfiguracao.obter()` (padrão PaginaChat). Layout responsivo padrão AbaAparencia (`_larguraDuasColunas = 860`; largo: Row 62/38 com prévia à direita; estreito: coluna única, prévia abaixo, sem fixação). Conteúdo: `SecaoConfiguracoes('Publicidade na barra superior', descricao: ...)` com `SwitchListTile 'Exibir publicidade na barra'`; `SecaoConfiguracoes('Formato de exibição')` com os 3 `CartaoFormatoPublicidade` (empilham em <560px); editor do formato selecionado; prévia. Rodapé fixo: reutilizar `BarraAcoesAparencia`? — NÃO: rotulos diferem. Generalizar: **adicionar params opcionais `rotuloSecundario`/`rotuloPrimario`/`rotuloIndicador` a `BarraAcoesAparencia` com defaults atuais** (mudança mínima, aba Aparência intacta) e usar com `Descartar alterações`/`Aplicar alterações`/`Alterações não salvas`. FilePicker de banners/parceiro: mesma mecânica `_adicionar`/`_copiarParaDiretorioApp` da SecaoConteudoTela, MAS `allowedExtensions: ['jpg','jpeg','png','webp','gif']` — extrair helper compartilhado `Future<List<String>> escolherECopiarMidias({required List<String> extensoes, bool multiplas = true})` para `lib/funcionalidades/configuracoes/apresentacao/componentes/selecao_midia.dart` (Create) e usar nos dois lugares. Aplicar: `controlador.aplicar()` → true: snackbar `Configurações de propaganda aplicadas com sucesso.`; false: snackbar `Adicione ao menos um conteúdo antes de ativar este formato.`. Descartar: `mostrarDialogoConfirmacao` + `controlador.descartar()`. Ajustar banner/parceiro: `DialogoAjusteMidia` existente (passa `corTema`, `orientacao: OrientacaoTela.horizontal`, salva só ajuste/âncora/zoom — ignorar fundo/rotação do callback).
- `aba_propaganda.dart`: placeholder → `SecaoBarraSuperior()`.
- Modify também: `lib/funcionalidades/configuracoes/apresentacao/componentes/barra_acoes_aparencia.dart` (params opcionais com defaults — zero impacto na Aparência) e o teste dela se houver.

**Steps:**
- [ ] 1. Testes (`secao_barra_superior_test.dart`, padrão `aba_aparencia_test.dart` com SP mock): monta com defaults (toggle off, carrossel selecionado, 'Nenhum conteúdo configurado.'); selecionar letreiro troca editor e NÃO perde estado (voltar ao carrossel preserva); adicionar mensagem → pendentes (barra 'Alterações não salvas' aparece) e prévia atualiza; Aplicar com ativa+sem conteúdo → snackbar de validação e nada persiste no SP; fluxo feliz: ativa + mensagem + Aplicar → SP contém `'publicidade_barra'` e indicador some; Descartar restaura; prévia com ativa sem conteúdo mostra 'Adicione conteúdo para visualizar.'; largura 1200 mostra duas colunas, 480 empilha sem overflow.
- [ ] 2. FAIL → 3. Implementar (seção <450 linhas; prévia <200) → 4. `flutter test test/funcionalidades/configuracoes/` verde → 5. Commit `feat: secao barra superior com previa e aplicar/descartar`.

---

### Task 8: Verificação final

- [ ] 1. `dart format .` / `flutter analyze` (0 issues) / `flutter test` (suite completa verde). `git status`: pubspec.lock intocado.
- [ ] 2. Revisão adversarial (checklist CLAUDE.md) + conferir critérios de aceite 1-39 da spec (mapa: 1-4 Task 3; 5 Task 7; 6-8 Tasks 1/2/6/7; 9-16 Tasks 1/2/6; 17-22 Tasks 4/6; 23-24 Tasks 2/6; 25-29 Task 7; 30-33 Tasks 4/5; 34-35 Task 5; 36-37 Tasks 2/7; 38-39 escopo).
- [ ] 3. Review final whole-branch (base = commit do docs deste plano) + fixes.
- [ ] 4. E2E ao vivo (flutter run -d windows + automação): abrir Configurações→Propaganda; validar seção Conteúdo (mídias existentes preservadas); Barra superior: ativar, adicionar mensagem no letreiro, Aplicar, ir ao chat e ver o letreiro na barra; voltar, trocar para carrossel sem perder mensagens; screenshots.
