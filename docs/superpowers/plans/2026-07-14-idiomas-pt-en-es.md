# Múltiplos Idiomas (pt-BR / en / es) — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cliente escolhe o idioma (🌐 PT/EN/ES) na tela inicial; toda a experiência do cliente no terminal é traduzida; o idioma vale só para o atendimento atual e volta ao pt-BR ao concluir/cancelar/timeout.

**Architecture:** `flutter gen-l10n` (l10n.yaml + ARBs pt/en/es, chaves semânticas, plural ICU) gerando `AppLocalizations`. `ControladorIdioma extends StateNotifier<Locale>` (sem persistência) + `provedorIdioma`; `MaterialApp.locale` observa o provider. O `ControladorFluxoPagamento` recebe `AppLocalizations Function() obterTraducoes` (lazy, via `lookupAppLocalizations(ref.read(provedorIdioma))`) — mensagens resolvidas na criação (idioma é imutável durante o atendimento: o seletor fica só na tela inicial e o histórico é descartado a cada atendimento). Widgets usam `AppLocalizations.of(context)`. Reset nos 3 pontos que já fazem `novaOperacao()` + `go('/splash')`.

**Tech Stack:** flutter_localizations + intl (JÁ nas dependências — nada novo no pubspec.lock), gen-l10n, Riverpod.

## Global Constraints

- Root git: `D:\constel-pay-main\constel-pay-main`; branch `feat/sessao-2026-07-14` (não criar branch). Commits SEM `Co-Authored-By` (conferir `git log -1 --format=%B`).
- **gen-l10n NÃO é build_runner** — roda no build/`flutter gen-l10n`; não altera `pubspec.lock` (nenhuma dependência nova). Conferir lock intocado em todo commit mesmo assim. Arquivos gerados ficam em `.dart_tool/` (synthetic package `flutter_gen`) — NÃO são commitados.
- pt-BR é o idioma padrão e fallback. Testes existentes asseram texto pt-BR — devem continuar verdes sem mudança de asserção (só wrappers de `MaterialApp` de teste ganham `localizationsDelegates`/`supportedLocales` quando o widget sob teste usa `AppLocalizations.of`).
- Moeda SEMPRE `R$ 0,00` via `FormatadorMoeda` atual (CLAUDE.md manda; spec autoriza não adaptar). Data mantém `dd/MM/yyyy HH:mm`. NÃO tocar nos formatadores.
- NÃO traduzir: nome do restaurante/produtos/comandas (conteúdo da API), publicidade da barra (conteúdo do operador), telas de configurações e PIN (operador), `_BarraCreditos` ('Audax e Solução Sistemas'), identificadores/códigos/valores.
- NÃO remover a engrenagem; NÃO alterar regras de negócio/cálculos/integrações; NÃO adicionar outros idiomas.
- Sem condicionais de idioma em widgets (`language == 'en' ? ...` PROIBIDO); tudo via chaves ARB. Pluralização via ICU (`{n, plural, one{...} other{...}}`), nunca concatenação.
- Arquivos < 600 linhas; `dart format .` + `flutter analyze` + `flutter test` ao final.

## Convenções

- ARBs: `lib/l10n/app_pt.arb` (template, com `@@locale: pt` e metadados `@chave`), `app_en.arb`, `app_es.arb`. `l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_pt.arb`, `output-class: AppLocalizations`, `nullable-getter: false`.
- Locales suportados: `Locale('pt', 'BR')`, `Locale('en')`, `Locale('es')` (ARB pt serve pt e pt-BR).
- Chaves em inglês semântico (spec §6): `welcomeMessage`, `scanInstruction`, `addAnotherCard`, `continueToPayment`, `noOpenItems`, `tryAgain`, etc.
- Textos pt = EXATAMENTE os atuais do app (byte a byte — testes dependem). Textos en/es = os da spec quando dados; demais seguem o mesmo tom (conversacional, sem jargão). Traduções-chave da spec (usar verbatim):
  - Tela inicial: PT `Toque para pagar` / EN `Tap to pay` / ES `Toca para pagar`; splash PT `Terminal de AutoPagamento` / EN `Self-Checkout Terminal` / ES `Terminal de Autopago`.
  - Boas-vindas: EN `Hello! Welcome. I'll help you pay your bill in just a few seconds. 😊` / ES `¡Hola! Te damos la bienvenida. Te ayudaré a pagar tu cuenta en pocos segundos. 😊`.
  - Instrução: EN `To get started, point the camera at the code on your consumption card 👇` / ES `Para comenzar, apunta la cámara al código de tu tarjeta de consumo 👇`.
  - Scanner: EN `Position the card code inside the frame` / `Simulate code scan` / `Card number` / `Search`; ES `Coloca el código de la tarjeta dentro del área` / `Simular lectura del código` / `N.º de tarjeta` / `Buscar`.
  - Cartão adicional: EN `Would you like to add another card to this bill?` / `Add another card` / `Continue to payment`; ES `¿Deseas agregar otra tarjeta a esta cuenta?` / `Agregar otra tarjeta` / `Continuar al pago`.
  - Sem consumo: EN `No open items` / `We couldn't find any pending items for this card.`; ES `No hay consumos pendientes` / `No encontramos consumos pendientes para esta tarjeta.`
  - Ações: EN `Try again` / `Continue with the added cards`; ES `Intentar de nuevo` / `Continuar con las tarjetas agregadas`.
  - Plural: EN `Continue with 1 added card`/`Continue with N added cards`; ES `Continuar con 1 tarjeta agregada`/`Continuar con N tarjetas agregadas` (ICU plural; pt: `1 cartão adicionado`/`N cartões adicionados`).
  - Seletor: título PT `Escolha o idioma` / EN `Choose your language` / ES `Elige tu idioma`; opções sempre `Português`/`English`/`Español` (no próprio idioma); semantics PT `Alterar idioma. Idioma atual: Português.` / EN `Change language. Current language: English.` / ES `Cambiar idioma. Idioma actual: Español.`.

---

### Task L1: Infra l10n + provedorIdioma + wiring do MaterialApp

**Files:**
- Create: `l10n.yaml`
- Modify: `pubspec.yaml` (adicionar `generate: true` sob `flutter:` — NADA mais)
- Create: `lib/l10n/app_pt.arb`, `lib/l10n/app_en.arb`, `lib/l10n/app_es.arb` — INVENTÁRIO COMPLETO: todas as chaves de todos os textos do cliente (chat/bot 36+, chips, scanner, comanda [Subtotal/Taxa de serviço/Desconto/Total da comanda/Pago], pix, sucesso, comprovante [6 rótulos], banner boas-vindas, diálogo saída [4], inatividade [3, com placeholder de segundos], splash, falhas [6 tipos], métodos de pagamento [7 rótulos + 7 descrições], status de pagamento [rótulos], faixa padrão, seletor de idioma, dica `👆 Toque em uma opção acima para continuar`, plurais ICU: cartões adicionados, cartões restantes, rótulo da barra de total).
- Create: `lib/aplicativo/idioma/controlador_idioma.dart` — `ControladorIdioma extends StateNotifier<Locale>` (default `Locale('pt','BR')`; `void selecionar(Locale l)`; `void resetar()` → pt-BR) + `provedorIdioma` no MESMO arquivo (padrão `controlador_tema.dart` que registra em injecao — aqui manter provider junto do controlador OU em injecao.dart, seguir o padrão do tema: controlador em arquivo próprio, provider em `injecao.dart`).
- Modify: `lib/aplicativo/injecao.dart` (provider), `lib/aplicativo/constel_pay_app.dart` (locale dinâmico + supportedLocales + delegates gerados).
- Modify (reset, 3 pontos): `lib/compartilhado/widgets/detector_inatividade.dart` (~l.83), `lib/funcionalidades/chat/apresentacao/paginas/pagina_chat.dart` (`_confirmarSaida` e `aoNovaOperacao`) — em cada um, junto de `novaOperacao()`: `ref.read(provedorIdioma.notifier).resetar();`
- Test: `test/aplicativo/controlador_idioma_test.dart` (novo) + teste de widget em `test/aplicativo/` que monta `ConstelPayApp` e verifica `MaterialApp.locale` muda com o provider e reseta.

**Interfaces (Produces):** `provedorIdioma` (`StateNotifierProvider<ControladorIdioma, Locale>`); `AppLocalizations` gerado com TODAS as chaves; `lookupAppLocalizations(Locale)` (função gerada) disponível para L3.

**Steps:** testes → FAIL → implementar (rodar `flutter gen-l10n` e conferir compilação; `git status` sem pubspec.lock) → `flutter test test/aplicativo/` PASS + suite completa verde (nada visível mudou ainda) → commit `feat: infraestrutura de idiomas pt/en/es com locale por atendimento`.

---

### Task L2: Seletor de idioma na tela inicial

**Files:**
- Create: `lib/compartilhado/widgets/seletor_idioma.dart`
- Modify: `lib/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart` (Positioned da engrenagem vira Row [SeletorIdioma, 8px, engrenagem]; faixa: usar tradução do default preservando override do operador)
- Test: `test/compartilhado/seletor_idioma_test.dart` (novo) + Modify `test/funcionalidades/propaganda/propaganda_test.dart` (wrapper com delegates se necessário; asserções pt intactas)

**Interfaces:**
- `SeletorIdioma` (ConsumerWidget): botão pill `🌐 PT ▾` (sigla do locale atual: PT/EN/ES), mesmo estilo visual da engrenagem (fundo `Colors.black.withValues(alpha: .45)`, conteúdo branco, borderRadius, altura ≥44px, `Semantics` com a frase da convenção). Toque abre `showDialog` compacto: título traduzido (`Escolha o idioma`), 3 opções `🇧🇷 Português` / `🇺🇸 English` / `🇪🇸 Español` (bandeira como apoio + nome no próprio idioma + `✓`/check no atual, área de toque ≥48px). Selecionar → `provedorIdioma.notifier.selecionar(...)` + fecha; textos visíveis da tela atualizam imediatamente (locale do MaterialApp).
- Faixa: em `pagina_propaganda.dart`, o texto passado à `FaixaPagamento` vira: `tema.textoFaixa.trim().isEmpty || tema.textoFaixa.trim() == textoFaixaPadrao ? AppLocalizations.of(context).tapToPay : tema.textoFaixaEfetivo` (override do operador respeitado; default traduzido). Tooltip da engrenagem: traduzir? É acesso do operador — manter `Configurações` fixo (fora do escopo do cliente).
- Comportamento crítico: selecionar idioma NÃO navega, NÃO reinicia nada; tocar fora do seletor continua indo ao chat (o seletor captura o próprio toque).

**Steps:** testes (seletor mostra sigla atual; abre diálogo com 3 opções; selecionar English muda o provider e a faixa default vira `Tap to pay`; faixa personalizada pelo operador NÃO muda; engrenagem continua presente e funcional) → FAIL → implementar → PASS (`test/compartilhado/ test/funcionalidades/propaganda/`) → commit `feat: seletor de idioma na tela inicial`.

---

### Task L3: Tradução do fluxo do chat (controlador)

**Files:**
- Modify: `lib/funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart` — novo parâmetro `required AppLocalizations Function() obterTraducoes`; TODAS as ~36 mensagens passam a usar `obterTraducoes().chave(...)`; plurais via chaves ICU; ecos do cliente usam as mesmas chaves dos chips; falhas: `String _mensagemFalha(Falha falha)` traduz por tipo (`FalhaRede`→`errorNetwork`, `FalhaTimeout`→`errorTimeout`, `FalhaServidor`→`errorServer`, `FalhaNaoAutorizado`→`errorUnauthorized`, `FalhaValidacao`/`FalhaDesconhecida`→ usa `falha.mensagem` se vier custom senão chave genérica); rótulo do método (`metodo.rotulo`) nos ecos → chave por método.
- Modify: `lib/aplicativo/injecao.dart` — `provedorFluxoPagamento` injeta `obterTraducoes: () => lookupAppLocalizations(ref.read(provedorIdioma))`.
- Test (modify): `test/funcionalidades/chat/controlador_fluxo_pagamento_test.dart` — construtor ganha `obterTraducoes: () => lookupAppLocalizations(const Locale('pt', 'BR'))`; asserções pt intactas; NOVOS testes: controlador com `Locale('en')` → mensagem de boas-vindas contém 'Welcome', pergunta contém 'another card'; com `Locale('es')` → 'bienvenida'.

**Interfaces:**
- Consumes: `lookupAppLocalizations` (L1).
- Produces: `ControladorFluxoPagamento(obterTraducoes: ...)` — assinatura usada por L4/testes. Textos pt resultantes IDÊNTICOS aos atuais (contrato: testes existentes verdes sem mudar asserções).

**Steps:** atualizar/criar testes → FAIL → implementar → `flutter test test/funcionalidades/chat/` PASS → commit `feat: mensagens do fluxo de pagamento traduzidas por idioma`.

---

### Task L4: Tradução dos widgets (chat, comprovante, diálogos, inatividade, splash)

**Files (Modify):**
- Chat: `area_acoes.dart` (chips + dica + rótulo da barra com plural ICU), `card_scanner.dart`, `card_comanda.dart` (Subtotal/Taxa de serviço (x%)/Desconto/Total da comanda/Pago ✓/`N un · R$ x cada`), `card_metodos_pagamento.dart` (usar chaves de rótulo/descrição por método), `card_pix.dart`, `card_sucesso.dart`, `banner_boas_vindas.dart`.
- `lib/funcionalidades/comprovante/apresentacao/componentes/card_comprovante.dart` (6 rótulos).
- `lib/funcionalidades/chat/apresentacao/paginas/pagina_chat.dart` (diálogo de saída: 4 textos).
- `lib/compartilhado/widgets/detector_inatividade.dart` (3 textos, placeholder de segundos via chave ICU/placeholder).
- `lib/funcionalidades/splash/apresentacao/paginas/pagina_splash.dart` (`Terminal de AutoPagamento`).
- Tests (modify): wrappers de `MaterialApp` nos testes desses widgets ganham `localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales` (asserções pt intactas — pt é default). Arquivos: `componentes_chat_1_test.dart`, `componentes_chat_2_test.dart`, `area_acoes_test.dart`, `pagina_chat_test.dart`, `test/funcionalidades/comprovante/*`, `test/compartilhado/*` (dialogo/detector se testados), `test/integracao/fluxo_completo_test.dart` (usa `ConstelPayApp`? já tem delegates via L1). NOVO teste: `area_acoes` com locale `en` mostra `Continue to payment`; `card_comanda` com `es` mostra rótulos es.

**Interfaces:** Consumes `AppLocalizations.of(context)` (L1). Textos pt idênticos aos atuais.

**Steps:** testes → FAIL (delegates ausentes/chaves) → implementar → `flutter test` completo PASS → commit `feat: interface do atendimento traduzida nos tres idiomas`.

---

### Task L5: Verificação final + e2e

- [ ] 1. `dart format .` / `flutter analyze` (0) / `flutter test` (tudo verde). `git status`: lock intocado; `.dart_tool` fora.
- [ ] 2. Conferir critérios de aceite da spec (28 itens; mapa: 1-5 L2; 6-10 L1/L2; 11 L3/L4; 12-16 design (estado preservado — idioma não mexe em estado); 17-20 L1 (reset nos 3 pontos); 21-22 L4 (overflow: textos en/es em botões — testes de largura estreita); 23 ICU; 24-25 arquitetura ARB; 26-27 nada de negócio tocado; 28 engrenagem intacta).
- [ ] 3. Review final whole-branch (opus) + fixes.
- [ ] 4. E2E ao vivo (flutter run -d windows): tela inicial com `[🌐 PT ▾][⚙]`; selecionar English → `PAY HERE`-equivalente da faixa (`Tap to pay`) + entrar no atendimento → mensagens en → adicionar cartão → chips en → cancelar operação (voltar) → volta à propaganda EM PT (reset validado ao vivo); selecionar Español → mensagens es; screenshots. Fechar app ao final.
