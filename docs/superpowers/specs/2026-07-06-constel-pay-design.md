# Constel Pay — Design Spec

**Data:** 2026-07-06
**Status:** Aprovado
**Escopo:** Implementação completa do aplicativo Constel Pay

---

## 1. Visão Geral

O Constel Pay é um terminal de autoatendimento para pagamento de consumo em restaurantes self-service. Instalado em tablets Android, permite que o cliente consulte seu cartão de consumo, visualize itens, realize pagamento e obtenha comprovante.

### Princípios

- Simplicidade e velocidade
- Estabilidade
- Baixo acoplamento e alta coesão
- Arquitetura escalável (novos métodos de pagamento/leitura)
- Código limpo, nomenclatura 100% em pt-BR
- Segurança em operações financeiras (centavos como int, idempotência, sem dados sensíveis em log)

---

## 2. Stack

### Obrigatório

- Flutter >= 3.22 / Dart >= 3.4
- Material 3
- Riverpod (gerenciamento de estado)
- GoRouter (navegação)
- Dio (HTTP)
- Freezed + JsonSerializable (modelos imutáveis)
- SharedPreferences (persistência não sensível)
- FlutterSecureStorage (credenciais)
- Logger (logging seguro)
- intl (formatação R$ 0,00)
- uuid (idempotência em pagamentos)
- connectivity_plus (status de rede)

### Proibido

- GetX, Provider, MobX, Bloc

---

## 3. Arquitetura

### Feature First em pt-BR

```
lib/
  main.dart
  aplicativo/
    constel_pay_app.dart
    rotas.dart
    tema/
      tema_constel.dart
      cores_app.dart
      estilos_texto.dart
  nucleo/
    configuracao/
      configuracao_app.dart
      ambiente.dart
    constantes/
      constantes_app.dart
    erros/
      falha.dart
      excecoes.dart
    formatadores/
      formatador_moeda.dart
      formatador_data.dart
    utils/
      validadores.dart
  funcionalidades/
    splash/
      apresentacao/
        paginas/
          pagina_splash.dart
        componentes/
    propaganda/
      dados/
        modelos/
          modelo_midia.dart
        fontes_dados/
          fonte_propaganda_local.dart
        repositorios/
          repositorio_propaganda_impl.dart
      dominio/
        entidades/
          midia.dart
        repositorios/
          repositorio_propaganda.dart
      apresentacao/
        paginas/
          pagina_propaganda.dart
        componentes/
          player_propaganda.dart
        controladores/
          controlador_propaganda.dart
    leitura_cartao/
      dados/
        modelos/
          modelo_cartao.dart
        fontes_dados/
          fonte_leitura_mock.dart
        repositorios/
          repositorio_leitura_impl.dart
      dominio/
        entidades/
          cartao_consumo.dart
        repositorios/
          repositorio_leitura.dart
        casos_uso/
          caso_uso_ler_cartao.dart
      apresentacao/
        paginas/
          pagina_leitura_cartao.dart
        componentes/
          scanner_codigo.dart
          campo_digitacao_manual.dart
        controladores/
          controlador_leitura.dart
    chat/
      dados/
        modelos/
          modelo_mensagem.dart
        repositorios/
          repositorio_chat_impl.dart
      dominio/
        entidades/
          mensagem.dart
          tipo_mensagem.dart
        repositorios/
          repositorio_chat.dart
      apresentacao/
        paginas/
          pagina_chat.dart
        componentes/
          bolha_mensagem.dart
          card_mesa.dart
          card_comanda.dart
          card_detalhe_comanda.dart
          card_scanner.dart
          card_metodos_pagamento.dart
          card_pix.dart
          card_sucesso.dart
          card_leitura_cartao.dart
          indicador_digitando.dart
          area_acoes.dart
          chip_acao.dart
          barra_total.dart
          banner_boas_vindas.dart
        controladores/
          controlador_chat.dart
          controlador_fluxo_pagamento.dart
    pagamento/
      dados/
        modelos/
          modelo_pagamento.dart
          modelo_pix.dart
        fontes_dados/
          fonte_pagamento_mock.dart
          cliente_api_pagamento.dart
        repositorios/
          repositorio_pagamento_impl.dart
      dominio/
        entidades/
          pagamento.dart
          status_pagamento.dart
          metodo_pagamento.dart
        repositorios/
          repositorio_pagamento.dart
        casos_uso/
          caso_uso_processar_pagamento.dart
          caso_uso_gerar_pix.dart
          caso_uso_verificar_pagamento.dart
    comprovante/
      dados/
        modelos/
          modelo_comprovante.dart
      dominio/
        entidades/
          comprovante.dart
      apresentacao/
        componentes/
          card_comprovante.dart
    configuracoes/
      dados/
        modelos/
          modelo_configuracao.dart
          modelo_credencial.dart
          modelo_tema_personalizado.dart
          modelo_midia_propaganda.dart
        fontes_dados/
          fonte_configuracao_local.dart
          fonte_credencial_segura.dart
        repositorios/
          repositorio_configuracao_impl.dart
          repositorio_credencial_impl.dart
          repositorio_tema_impl.dart
          repositorio_propaganda_impl.dart
      dominio/
        entidades/
          configuracao_terminal.dart
          credencial.dart
          tema_personalizado.dart
        repositorios/
          repositorio_configuracao.dart
          repositorio_credencial.dart
          repositorio_tema.dart
          repositorio_propaganda.dart
        casos_uso/
          caso_uso_salvar_configuracao.dart
          caso_uso_testar_conexao.dart
      apresentacao/
        paginas/
          pagina_configuracoes.dart
          pagina_pin.dart
        componentes/
          aba_geral.dart
          aba_comunicacao.dart
          aba_aparencia.dart
          aba_propaganda.dart
          aba_diagnostico.dart
        controladores/
          controlador_configuracoes.dart
          controlador_pin.dart
  compartilhado/
    widgets/
      botao_primario.dart
      botao_secundario.dart
      campo_texto.dart
      campo_senha.dart
      cartao.dart
      indicador_carregamento.dart
      dialogo_confirmacao.dart
      barra_superior.dart
      scaffold_padrao.dart
    layout/
      layout_responsivo.dart
    feedback/
      snackbar_padrao.dart
      estado_vazio.dart
      estado_erro.dart
```

### Camadas por funcionalidade

```
dados/
  fontes_dados/   → acesso direto a APIs, storage, filesystem
  modelos/        → DTOs com Freezed + JsonSerializable
  repositorios/   → implementação dos contratos do domínio

dominio/
  entidades/      → objetos de negócio puros
  repositorios/   → interfaces (contratos abstratos)
  casos_uso/      → regras de negócio isoladas

apresentacao/
  paginas/        → widgets de tela completa
  componentes/    → widgets reutilizáveis da feature
  controladores/  → StateNotifier com Riverpod
```

### Comunicação com API

```
UI (Widget)
  ↓ escuta estado via Riverpod
Controlador (StateNotifier)
  ↓ chama
CasoUso
  ↓ chama
Repositório (interface no domínio, impl em dados)
  ↓ chama
ClienteApi (Dio + interceptadores)
  ↓
API REST
```

**ClienteApi** centraliza:
- URL base dinâmica conforme ambiente ativo (produção/homologação)
- Headers padrão
- Timeout de 30 segundos
- Interceptador de log seguro (sem dados sensíveis)
- Interceptador de retry (apenas GETs, nunca pagamentos)
- Tratamento de erro unificado retornando `Falha`

---

## 4. Fluxo de Navegação

### Fluxo principal (híbrido)

```
App Inicia
  │
  ├─ Primeiro acesso? → Página PIN (criar PIN de 4-6 dígitos)
  │
  ▼
Splash (tela cheia, branding do restaurante)
  │ timer automático (3-5s) ou toque
  ▼
Propaganda (carrossel de imagens/vídeos)
  │ toque na tela
  ▼
Chat (interface conversacional — núcleo do fluxo)
  │
  │  [scan] → bot pede leitura do cartão, exibe scanner
  │  [addMore] → cartão lido, pergunta se quer ler outro
  │  [tip] → pergunta sobre gorjeta (10%)
  │  [payment] → exibe métodos de pagamento
  │  [pix] → QR Code + copia-e-cola
  │  [processing] → aguardando confirmação
  │  [success] → pagamento aprovado
  │  [successRemaining] → comandas restantes na mesa
  │  [successDone] → tudo pago
  │  [end] → enviar comprovante / novo pagamento
  │
  └── novo pagamento → volta ao Splash

Configurações (acesso via toque longo 3s no logo do Splash)
  │ protegida por PIN numérico
  ├── Aba Geral
  ├── Aba Comunicação
  ├── Aba Aparência
  ├── Aba Propaganda
  └── Aba Diagnóstico
```

### Rotas (GoRouter)

```
/                → redireciona para /splash
/splash          → PaginaSplash
/propaganda      → PaginaPropaganda
/chat            → PaginaChat
/pin             → PaginaPin
/configuracoes   → PaginaConfiguracoes
```

---

## 5. Modelos de Dados

### Entidades do domínio

Todos os valores monetários são `int` representando centavos. Nunca `double`.

```
CartaoConsumo
  id: String
  codigo: String
  nome: String                 // "Comanda 01"
  pessoa: String               // "João"
  emoji: String                // "🍲"
  resumo: String               // "2 pratos · 3 bebidas"
  itens: List<ItemConsumo>
  subtotalCentavos: int
  selecionado: bool
  pago: bool

ItemConsumo
  emoji: String
  nome: String
  quantidade: int
  valorCentavos: int           // valor unitário

Mesa
  numero: int
  abertoEm: DateTime
  totalComandas: int
  totalCentavos: int
  status: StatusMesa

Pagamento
  id: String                   // UUID para idempotência
  valorCentavos: int
  gorjetaCentavos: int
  totalCentavos: int
  metodo: MetodoPagamento
  status: StatusPagamento
  criadoEm: DateTime
  atualizadoEm: DateTime
  comandaIds: List<String>

DadosPix
  qrCode: String
  copiaCola: String
  valorCentavos: int
  expiraEm: DateTime

Comprovante
  id: String
  pagamentoId: String
  valorCentavos: int
  metodo: MetodoPagamento
  comandas: List<String>
  dataHora: DateTime
  nomeRestaurante: String

ConfiguracaoTerminal
  nomeRestaurante: String
  identificadorDispositivo: String
  logoPath: String?
  ambiente: Ambiente
  urlBaseProducao: String
  urlBaseHomologacao: String
  corPrimaria: String          // hex
  corSecundaria: String
  corFundo: String
  corBotoes: String
  pinHash: String              // hash, nunca texto plano

Credencial
  usuario: String
  senha: String                // armazenada em FlutterSecureStorage

MidiaPropaganda
  id: String
  tipo: TipoMidia
  caminho: String
  duracaoSegundos: int
  ordem: int
  ativo: bool

Mensagem
  id: int
  tipo: TipoMensagem
  lado: LadoMensagem
  texto: String?
  subtexto: String?
  emoji: String?
  dados: Map<String, dynamic>?
```

### Enums

```
Ambiente: producao, homologacao
StatusMesa: aberta, fechada
MetodoPagamento: pix, credito, debito, tef, pos, voucher, dinheiro
StatusPagamento: aguardando, processando, aprovado, recusado, cancelado, expirado, erro
TipoMidia: imagem, video
TipoMensagem: texto, mesa, comanda, detalhe, scanner, metodos, pix, sucesso, leituraCartao
LadoMensagem: assistente, cliente
```

### Persistência

| Dado | Storage | Motivo |
|------|---------|--------|
| ConfiguracaoTerminal | SharedPreferences | Não sensível, acesso rápido |
| Credencial (user/senha) | FlutterSecureStorage | Sensível, criptografado |
| PIN hash | SharedPreferences | Apenas hash |
| Tema (cores, logo) | SharedPreferences | Repositório dedicado (RepositorioTema) |
| Propagandas (metadata) | SharedPreferences | Repositório dedicado (RepositorioPropaganda) |
| Arquivos de mídia | Filesystem (app dir) | Imagens/vídeos |

---

## 6. Identidade Visual

### Referência principal: instruções do projeto

| Propriedade | Valor padrão | Configurável? |
|-------------|-------------|---------------|
| Cor primária | #5E52D6 | Sim (Aba Aparência) |
| Cor secundária | #FFD166 | Sim |
| Cor de fundo | #F7F7FB | Sim |
| Cor dos botões | #5E52D6 | Sim |
| Fonte | Inter | Não |
| Logo | — | Sim |

### TemaConstel

Classe única que centraliza todo o tema Material 3:

- ColorScheme baseado nas cores configuradas
- TextTheme com Inter em todos os pesos necessários (400, 500, 600, 700, 800)
- Componentes: ElevatedButton, OutlinedButton, Card, InputDecoration, AppBar, BottomSheet, Dialog
- Suporte a cores dinâmicas (aplicadas ao mudar nas configurações)

### Componentes visuais do chat (baseados no HTML)

- **Bolhas de mensagem:** assistente à esquerda (fundo branco, borda 4px 18px 18px 18px), cliente à direita (fundo lilás #ECE7FF, borda 18px 18px 4px 18px)
- **Avatar do bot:** círculo gradiente primário, emoji 🧑‍🍳
- **Cards:** fundo branco, border-radius 20px, sombra sutil, borda #F1F0F4
- **Botão primário:** gradiente primário, texto branco, peso 800, border-radius 30px, sombra colorida
- **Chips de ação:** primário (fundo primário, texto branco) ou secundário (fundo branco, borda lilás)
- **Barra de total:** fundo lilás claro #EEEBFD, texto primário
- **Animações:** fadeUp para mensagens novas, floaty para emojis, pulse para botão CTA, shine para brilho no botão principal

---

## 7. Tela de Configurações

### Acesso

- Toque longo (3 segundos) no logo do restaurante na tela Splash
- Protegida por PIN numérico de 4-6 dígitos
- Primeiro acesso: criação obrigatória do PIN

### Aba Geral

- Nome do restaurante (campo texto)
- Identificador do dispositivo (campo texto)
- Logo (seletor de imagem do filesystem)

### Aba Comunicação

- Usuário (campo texto)
- Senha (campo senha — armazenada em FlutterSecureStorage)
- Ambiente: toggle Produção / Homologação
- URL Base Produção (campo texto com validação de URL)
- URL Base Homologação (campo texto com validação de URL)
- Botão "Testar Conexão" com feedback visual (sucesso/erro)

### Aba Aparência

- Cor primária (seletor de cor com preview hex)
- Cor secundária (seletor de cor)
- Cor de fundo (seletor de cor)
- Cor dos botões (seletor de cor)
- Logo (seletor de imagem)
- Preview ao vivo das alterações

### Aba Propaganda

- Lista de mídias (imagens e vídeos)
- Adicionar mídia (seletor de arquivo)
- Para cada mídia: tipo, duração (imagens), ordem (drag ou setas), ativo/inativo (toggle)
- Botão preview/visualização
- Playlist com ordem configurável

### Aba Diagnóstico

- Versão do aplicativo (somente leitura)
- Versão da API (somente leitura, obtida via endpoint)
- Ambiente atual (somente leitura)
- Identificador do dispositivo (somente leitura)
- IP do dispositivo (somente leitura)
- Status da conexão (somente leitura, com indicador visual)
- Última sincronização (somente leitura)
- Botão "Testar API" — chama endpoint de health check
- Botão "Limpar Cache" — com diálogo de confirmação
- Botão "Exportar Logs" — salva arquivo de logs no filesystem

---

## 8. Mocks

Toda a primeira versão opera com dados mockados, isolados em fontes de dados específicas.

### Dados mock

- `fonte_leitura_mock.dart` — 3 comandas (João/Maria/Ana) com itens de restaurante, mesa 12
- `fonte_pagamento_mock.dart` — simula processamento de pagamento com delay de 900ms, retorna sucesso
- Mock de QR Code Pix — imagem placeholder estática

### Regras

- Mocks ficam na camada `dados/fontes_dados/`
- Nunca misturados com lógica real de API
- Repositórios recebem a fonte de dados por injeção (Riverpod)
- Troca mock → API real = criar nova fonte de dados e trocar o provider

---

## 9. Segurança

### Pagamentos

- Valores sempre em `int` (centavos)
- UUID de idempotência em cada operação de pagamento
- Nunca repetir operação crítica sem idempotência
- StatusPagamento com todos os estados: aguardando, processando, aprovado, recusado, cancelado, expirado, erro
- Mensagens de erro claras para o operador, sem detalhes internos

### Dados sensíveis

- Credenciais armazenadas em FlutterSecureStorage
- PIN armazenado como hash (nunca texto plano)
- Logger configurado para nunca registrar: tokens, senhas, payloads sensíveis, dados de cartão, dados pessoais
- Nenhum print solto em produção

### API

- URLs centralizadas em ConfiguracaoTerminal
- Nenhuma URL hardcoded no código
- Ambiente (prod/homolog) determina URL base automaticamente
- Retry apenas para operações idempotentes (GET)
- Timeout de 30 segundos

---

## 10. Responsividade

O app suporta 3 modos de dispositivo:

| Modo | Largura referência | Uso |
|------|-------------------|-----|
| Mobile | ~412px | Celular do cliente |
| Tablet | ~660px | Tablet na mesa |
| Totem | ~600px | Terminal fixo de autoatendimento |

### Adaptações por modo

- **Mobile/Tablet:** barra de status do sistema visível, layout padrão
- **Totem:** barra "AUTOATENDIMENTO · TERMINAL 01" no topo, sem barra de status do sistema, preparado para modo tela cheia futuro

A detecção do modo é automática por largura da tela, mas pode ser forçada via configuração.

---

## 11. Modo Quiosque (preparação)

A arquitetura está preparada para suportar no futuro:

- Modo tela cheia (via configuração + flag do sistema)
- Impedir retorno ao launcher
- Reinício automático após falhas
- Timeout de inatividade com retorno ao Splash
- Retorno automático para tela inicial após período sem interação

Para a primeira versão, o timeout de inatividade no chat (retorno ao Splash) será implementado. Os demais itens ficam como extensão futura já prevista na arquitetura.

---

## 12. Testes

### Unitários

- Formatadores (moeda, data)
- Casos de uso (processar pagamento, gerar pix, ler cartão)
- Controladores (estados do chat, fluxo de pagamento)
- Validadores

### Widgets

- Componentes compartilhados (BotaoPrimario, Cartao, etc.)
- Cards do chat (card_mesa, card_comanda, card_pix, card_sucesso)

### Integração

- Fluxo completo: splash → chat → scan → pagamento → comprovante (com mocks)
