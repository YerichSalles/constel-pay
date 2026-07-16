# Constel Pay

Terminal de autoatendimento (totem) para pagamento de consumo em restaurantes, do ecossistema Constel.

O cliente encosta a comanda no leitor de código de barras, confere o consumo, paga por PIX e recebe o comprovante na tela. Não há login de cliente, cadastro nem dashboard: o app é operacional e roda sozinho no totem, em ciclo contínuo.

- **Aplicativo:** `constel_pay` — versão `1.0.0+1`
- **Plataformas:** Windows e Android
- **Idioma padrão:** pt-BR (também en e es)
- **Moeda:** Real brasileiro, sempre formatado `R$ 0,00`

## Stack

- **Flutter** ≥ 3.22 / **Dart** ≥ 3.4
- **Riverpod** (`flutter_riverpod`) — injeção de dependência e estado; controladores são `StateNotifier`
- **GoRouter** — rotas declarativas, sem transições (resposta imediata ao toque)
- **Dio** — cliente HTTP (o pacote `http` não é usado)
- **freezed** + **json_annotation** — entidades imutáveis e modelos de fronteira
- **shared_preferences** — persistência local não sensível (tema, configurações, mídias)
- **flutter_secure_storage** — sessão/token e credenciais
- **window_manager** — modo totem no Windows
- **qr_flutter** — QR Code do PIX
- **video_player** + **video_player_win** — vídeos da tela de espera
- **flutter_svg**, **file_picker**, **path_provider**, **package_info_plus**, **uuid**, **logger**, **intl**, **collection**

As 8 famílias de fonte (Inter, Roboto, Open Sans, Lato, Montserrat, Poppins, Nunito, Rubik) são empacotadas em `assets/fontes/`: o terminal funciona sem internet.

## Como rodar

```bash
flutter pub get
flutter run -d windows      # ou -d android
```

Validação antes de finalizar qualquer tarefa:

```bash
dart format .
flutter analyze
flutter test
```

Build de produção:

```bash
flutter build windows --release   # build\windows\x64\runner\Release\
flutter build apk --release
```

> O `.exe` do Windows não roda isolado: depende das DLLs e da pasta `data\` geradas ao lado dele. Distribua a pasta `Release` inteira.

## Arquitetura

Clean Architecture por funcionalidade, com nomenclatura toda em pt-BR (não criar pastas em inglês):

```
lib/
  main.dart              # bootstrap: TLS, modo totem, orientação, tema, ProviderScope
  aplicativo/            # app, rotas, injecao.dart, tema/, idioma/
  compartilhado/         # widgets/, layout/, feedback/
  nucleo/                # configuracao/, constantes/, erros/, formatadores/, janela/, utils/, dispositivo/
  funcionalidades/<feat>/
    dominio/             # entidades/, casos_uso/, repositorios/ (interfaces)
    dados/               # modelos/, fontes_dados/, repositorios/ (…Impl), adaptadores/, interceptadores/
    apresentacao/        # paginas/, componentes/, controladores/
```

Funcionalidades: `splash`, `propaganda`, `chat`, `leitura_cartao`, `pagamento`, `encerramento`, `comprovante`, `autenticacao`, `configuracoes`.

Fluxo das camadas: `UI → Controller → Repository → ApiClient → API`. Casos de uso expõem um único método `executar()`. Nem tudo passa por repositório — algumas fontes HTTP são injetadas direto no caso de uso.

## Telas e navegação

| Rota | Tela | Papel |
|---|---|---|
| `/splash` | `PaginaSplash` | Abertura; login automático na nuvem e retomada de transações pendentes em segundo plano |
| `/propaganda` | `PaginaPropaganda` | Tela de espera: carrossel de mídias ou tela de chamada, com faixa "Toque para pagar" |
| `/chat` | `PaginaChat` | Tela principal do atendimento |
| `/pin` | `PaginaPin` | Portão de acesso do operador |
| `/configuracoes` | `PaginaConfiguracoes` | Área do operador, 4 abas |

O acesso às configurações é **oculto** e protegido por PIN fixo (definido em `ConstantesApp`): toque longo no logo do splash, ou 4 toques no canto superior direito da propaganda. Não há botão visível ao cliente.

`DetectorInatividade` protege o `/chat`: passado o tempo limite, exibe "Ainda está aí?" com contagem regressiva e, sem resposta, descarta a operação e volta ao splash.

## Fluxo de pagamento

Etapas em `EtapaFluxo` (`estado_fluxo_pagamento.dart`), orquestradas por `ControladorFluxoPagamento`:

`inicial → lendo → aguardandoMaisCartoes → escolhaMetodo → pixAguardando → processando → sucessoComRestante | sucessoCompleto → encerramento`

Desvios: `semConsumo` (comanda sem itens em aberto) e `erroLeitura` — ambos oferecem tentar de novo preservando as comandas já lidas.

1. **Leitura.** O leitor de código de barras (keyboard wedge) é capturado pela página e cai em `consultarPorCodigo`, que consulta a API da loja. A referência lida aparece como fala do cliente. As fotos dos itens são buscadas em paralelo; se falharem, a tela mantém o emoji.
2. **Mais comandas.** O cliente pode adicionar outro cartão ou seguir para o pagamento. A barra de total acompanha.
3. **Método.** Ao entrar na escolha, é gerada a **chave de idempotência** (UUID v4) que identifica a operação até o fim. Crédito e débito ainda não estão disponíveis; PIX gera QR Code e copia-e-cola, válidos por 5 minutos.
4. **Confirmação.** Antes de qualquer cobrança, o encerramento é **validado** (configuração incompleta, pendência conflitante ou mistura com demonstração barram aqui — nunca depois do dinheiro debitado).
5. **Encerramento financeiro.** Aprovado o pagamento, roda o encerramento real: ação 10 → fatura → ação 30, com mensagem de progresso por fase. Falha aqui mantém a comanda aberta e preserva a pendência para retomada no próximo splash.
6. **Comprovante.** Quitado tudo, o app encerra sozinho; restando comandas, o cliente escolhe pagar o restante ou encerrar. O comprovante fica na tela e o terminal volta ao splash por conta própria.

**Valores:** o app soma o que a API já calculou e **nunca recalcula** taxa de serviço nem desconto. O total é a soma do saldo (total menos já pago) das comandas selecionadas. Valores em centavos (`int`), nunca `double`.

## Componentes

### Cards do chat (`funcionalidades/chat/apresentacao/componentes/`)

| Tipo | Widget | O que mostra |
|---|---|---|
| `texto` | `BolhaMensagem` | Fala do bot ou eco do cliente (emoji, texto, subtexto) |
| `scanner` | `CardScanner` | Visor animado orientando a posicionar o código |
| `comanda` / `leituraCartao` | `CardComanda` | Comanda lida: itens, fotos e valores |
| `metodos` | `CardMetodosPagamento` | Crédito, débito e PIX |
| `pix` | `CardPix` | QR Code, valor, validade, copiar código, "Já paguei" |
| `sucesso` | `CardSucesso` | Confirmação: valor e comandas quitadas |
| `comprovante` | `CardComprovante` | Comprovante final |

Complementam a tela: `AreaAcoes` (chips de decisão por etapa), `BarraTotal`, `IndicadorDigitando`, `AvatarBot`, `BannerBoasVindas`.

### Compartilhados (`lib/compartilhado/`)

**`widgets/`**
- `captura_leitor_codigo.dart` — captura leitores de código de barras keyboard wedge (USB/Bluetooth HID, Windows e Android). Escuta o teclado globalmente, sem depender de foco, e distingue o leitor de digitação humana pela cadência das teclas.
- `barra_superior.dart` — AppBar com título, avatar, voltar e slot opcional de publicidade.
- `barra_creditos.dart` — rodapé com nome, versão e site; contraste de texto automático.
- `detector_inatividade.dart`, `detector_toque_longo.dart`, `detector_toques_multiplos.dart` — expiração do atendimento e acessos ocultos ao operador.
- `faixa_pagamento.dart` — chamada "Toque para pagar" da tela de espera.
- `imagem_logo.dart` — logo do estabelecimento, SVG ou raster.
- `seletor_idioma.dart` — troca de idioma pelo cliente; bandeiras em SVG (Windows não tem fonte de emoji de bandeira).
- `icone_emoji.dart` — converte emojis vindos da API em ícones Material.
- `cartao.dart`, `botao_primario.dart`, `botao_secundario.dart`, `campo_texto.dart`, `campo_senha.dart`, `dialogo_confirmacao.dart`, `indicador_carregamento.dart`, `scaffold_padrao.dart`.

**`layout/`** — `layout_responsivo.dart`: `ModoDispositivo` (celular < 600 ≤ tablet < 1024 ≤ totem) e `ConteudoCentralizado`.

**`feedback/`** — `estado_erro.dart`, `estado_vazio.dart`, `snackbar_padrao.dart`.

## Integração com API

O terminal fala com **dois backends**, cada um com URL de produção e de homologação (`ConfiguracaoTerminal`):

- **API da loja** (local, na rede do estabelecimento) — consumo, encerramento, dispositivo, foto do item.
- **API da nuvem** — login, fatura, formas de pagamento.

`ClienteApi` (`nucleo/configuracao/cliente_api.dart`) encapsula o Dio: resolve a baseUrl a cada requisição por um seletor (é o que permite reusar a classe para os dois backends), aplica timeout de 30 s, injeta `Idempotency-Key` nos POSTs que pedem, e loga apenas método e URI — nunca headers ou corpo. URL não configurada vira erro de validação com mensagem para o operador, não exceção.

Existem **dois pares de clientes** (um de login sem interceptor, um autenticado) por backend: usar o mesmo Dio faria o re-login cair na fila do `QueuedInterceptor` e travar. E **duas sessões separadas**, porque o JWT só vale no servidor que o emitiu. O `InterceptadorAutenticacaoNuvem` injeta o Bearer e, em 401, tenta um único re-login antes de refazer a requisição.

Todos os caminhos de API e códigos de negócio ficam em `nucleo/constantes/constantes_app.dart` — não há URL espalhada pelo código.

**Erros.** `Resultado<T>` (`Sucesso` | `Erro`) e `Falha` são sealed: o `switch` exaustivo do Dart 3 obriga a tratar cada caso. `Falha` cobre rede, timeout, servidor, não autorizado, validação e desconhecido; a UI traduz cada tipo, exceto `FalhaValidacao`, que já carrega texto de negócio.

Duas decisões que parecem inconsistentes mas são deliberadas, documentadas no código:
- O **encerramento não usa `Idempotency-Key`**: as ações 10 e 30 compartilham o endpoint, e uma chave repetida poderia fazer um servidor com dedupe responder à ação 30 com o replay da 10, sem confirmar nada.
- A **fatura nunca converte corpo ilegível em `FalhaServidor`**: um 2xx malformado significa que a operação *pode* ter sido aplicada, então o caso de uso reconcilia em vez de arriscar fatura duplicada.

## Configurações

Quatro abas (`funcionalidades/configuracoes/apresentacao/`):

- **Comunicação** — nome do estabelecimento (vem do login), identificador do terminal, ID do dispositivo, ambiente (produção/homologação), credenciais e URL da nuvem, URL da API local, testes de conexão com status e latência.
- **Aparência** — logo, fonte, cores (principal, secundária, fundo, botões, textos), faixa de pagamento com texto por idioma e indicador de contraste (WCAG AA), com pré-visualização. Trabalha em rascunho: nada é salvo até "Aplicar alterações".
- **Propaganda** — conteúdo da tela de espera (carrossel/letreiro/parceiro) e publicidade da barra superior do chat.
- **Diagnóstico** — versão, ambiente, IP, última sincronização e "Limpar dados locais" (com confirmação).

## Tema e idioma

O tema é totalmente dinâmico: `TemaConstel.criar(TemaPersonalizado)` monta o `ThemeData` (Material 3) a partir das cores salvas em hex, e o `MaterialApp.router` observa o provider — muda em runtime. Paleta padrão em `cores_app.dart` (primária `#5E52D6`, secundária `#FFD166`, fundo `#F7F7FB`).

O idioma **não é persistido** de propósito: cada atendimento começa em pt-BR, e a escolha do cliente vale até o atendimento terminar. Os textos ficam em `lib/l10n/` (`app_pt.arb` é o template; en e es acompanham), gerados via `l10n.yaml`.

## Modo totem

Centralizado em `nucleo/janela/`, chamado no `main()` antes de exibir a UI para não piscar a janela normal:

- **Windows** — `window_manager`: tela cheia, sem barra de título nem botões, não redimensionável, sempre no topo.
- **Android** — `immersiveSticky`: esconde status bar e navigation bar.

O terminal opera em pé: a orientação é travada em retrato.

## Testes

78 arquivos em `test/`, espelhando a estrutura de `lib/`: unitários (domínio, dados, núcleo), de widget (compartilhados, páginas e componentes) e de integração de fluxo (`test/integracao/`). Mocks com `mocktail`; as fontes mockadas expõem `atraso` no construtor para testes determinísticos.

## Segurança e pontos de atenção

- **Validação de certificado TLS está desligada em todo o app.** `instalarConfiancaTlsGlobal()` (`main.dart` + `nucleo/configuracao/confianca_tls_io.dart`) instala um `HttpOverrides` cujo `badCertificateCallback` sempre aceita. É intencional — cobre o Dio e o `Image.network` das fotos dos itens em PCs sem as raízes atualizadas —, mas o app deixa de garantir a identidade do servidor: a conexão continua criptografada, porém exposta a MITM. A correção adequada é ajustar o certificado (SAN/cadeia) ou instalar as raízes na máquina.
- **A feature `pagamento` ainda é mock.** `FontePagamentoMock` sempre aprova após um atraso e o payload PIX é rotulado `…CONSTEL-PAY-MOCK…` — não é PIX real. `RepositorioPagamentoImpl` depende da classe concreta do mock, então a troca pela fonte real exige alterar o Impl ou introduzir a interface.
- **`FonteLeituraMock` (`lerCartao`) não tem mais chamador em produção** — a leitura real entra por `consultarPorCodigo`. A cadeia mock segue no projeto, exercitada apenas por testes; é dívida técnica consciente.
- **Sem plano B na tela de leitura:** não há busca manual nem botão de simular. O atendimento depende inteiramente do leitor físico.
- `connectivity_plus` e `crypto` estão no `pubspec.yaml` mas não são importados em lugar nenhum — candidatos a remoção.
- Nunca logar token, senha, payload sensível ou dados de cartão. O `ClienteApi` e o `Registrador` já seguem essa regra.

## Convenções

Regras de escopo, estilo e revisão do projeto estão em [`claude.md`](claude.md). Em resumo: pastas e nomes em pt-BR, arquivos abaixo de 600 linhas, sem telas fora das previstas, sem login nem dashboard, e a base visual oficial é `base_visual/constel-pay.html`.
