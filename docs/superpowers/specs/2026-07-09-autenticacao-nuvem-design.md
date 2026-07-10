# Autenticação de nuvem — Design

- **Data:** 2026-07-09
- **Escopo desta spec:** autenticação da **API de nuvem** (envio de vendas). A autenticação **local** (consumo da loja) será tratada em spec separada, reaproveitando esta estrutura.
- **Abordagem escolhida:** login silencioso em segundo plano (o app não tem tela de login).

## Contexto

O Constel Pay é um terminal de autoatendimento. Ele conversa com duas APIs:

- **API de nuvem** — para onde as vendas são enviadas. Autentica em `POST auth/login` e devolve um JWT com informações adicionais.
- **API local (loja)** — consumo do cartão no estabelecimento. Autenticação tratada depois.

A infraestrutura já existente e reaproveitada:

- `ConfiguracaoTerminal`: URLs local/nuvem (produção+homologação), `identificadorDispositivo`, `idDispositivo`, `ambiente`, `urlBaseAtiva`, `urlNuvemAtiva`.
- `RepositorioCredencial`: guarda `usuario`/`senha` no secure storage (aba Comunicação).
- `ClienteApi` + `provedorClienteApiNuvem`: cliente Dio apontando para a URL de nuvem (`urlNuvemAtiva`).
- `InfoAplicativo.versao()`: versão do pacote.
- `FusoHorario.gmt()`: deslocamento no formato `GMT-03`.
- Padrão `Resultado<T>` / `Falha` para erros; `registrador` para logs seguros.

O fluxo anterior de autenticação foi removido ("começar de novo"); esta spec o recria de forma enxuta.

## Contrato da API de nuvem

### Request — `POST auth/login`

```json
{
  "username": "admin@audax.com",
  "password": "c0nst3ll4t10",
  "timezone": "GMT-03",
  "aplicativo": {
    "nome": "Constel Pay",
    "versao": "5.1.1.0",
    "data": "2025-07-28T08:32:51.648Z"
  },
  "api": { "caminho": "http://localhost:3000/api/" },
  "dispositivo": {
    "id": "be7b5b3f-2cf1-4e78-bb02-fdcddb72768b",
    "nome": "NBYERICH TOUCH"
  }
}
```

Mapeamento das fontes de cada campo:

| Campo | Fonte |
|---|---|
| `username` | `RepositorioCredencial.usuario` |
| `password` | `RepositorioCredencial.senha` |
| `timezone` | `FusoHorario.gmt()` |
| `aplicativo.nome` | constante `ConstantesApp.nomeAplicativoLogin = 'Constel Pay'` |
| `aplicativo.versao` | `InfoAplicativo.versao()` |
| `aplicativo.data` | constante de data de build `ConstantesApp.dataBuild` (ver Constantes) |
| `api.caminho` | `configuracao.urlBaseAtiva` (URL da API local do ambiente ativo) |
| `dispositivo.id` | `configuracao.idDispositivo` |
| `dispositivo.nome` | `configuracao.identificadorDispositivo` |

### Response — `201 Created`

Resposta rica; apenas os campos abaixo são modelados (o restante é ignorado). Exemplo real:

```json
{
  "id": "85a83afb-...",
  "nome": "Yerich Sales",
  "credencial": "admin@audax.com",
  "email": "admin@audax.com",
  "imagem": "https://.../ddfe479b-....jpg",
  "empresa": { "id": "0d1542e1-...", "nome": "Durango Builder's" },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "validade": "2026-07-11T00:00:13.000Z",
  "dispositivo": { "id": "be7b5b3f-...", "nome": "NBYERICH CAIXA" },
  "estabelecimento": {
    "id": "fe5b422e-...",
    "nome": "Dionísio Torres",
    "estabelecimentoAmbientes": [
      { "id": "ef58a474-...", "nome": "Padrão", "situacao": 1, "padrao": true },
      { "id": "d67a3435-...", "nome": "AMBIENTE_IFOOD", "situacao": 1, "padrao": false }
    ]
  }
}
```

Campos **ignorados** por ora (YAGNI): `administrador`, `sistema`, `navegador`, `fuso`, `conexao`, `regraBase`, `corporacao`, `empresas[]`, `regras[]`, `responsabilidades[]`, `situacao` dos ambientes.

## Estrutura de pastas

Feature única `autenticacao/`, arquivos sufixados `_nuvem`. A auth local virá depois como `_local`.

```
lib/funcionalidades/autenticacao/
  dominio/
    entidades/
      sessao_nuvem.dart              (freezed)
    repositorios/
      repositorio_sessao_nuvem.dart  (interface)
    casos_uso/
      caso_uso_login_nuvem.dart
      caso_uso_garantir_sessao.dart
  dados/
    modelos/
      requisicao_login_nuvem.dart    (json — toJson)
      resposta_login_nuvem.dart      (json — fromJson → entidade)
    fontes_dados/
      fonte_autenticacao_nuvem.dart  (usa o ClienteApi da nuvem)
    repositorios/
      repositorio_sessao_nuvem_impl.dart  (secure storage)
```

Sem camada de apresentação nova (o app não tem tela de login).

## Entidades (domínio)

`SessaoNuvem` (freezed), com sub-entidades:

```
SessaoNuvem
  String   token
  DateTime validade
  UsuarioSessao usuario
  EmpresaSessao empresa
  DispositivoSessao dispositivo
  EstabelecimentoSessao estabelecimento
  bool get expirada => DateTime.now().isAfter(validade)

UsuarioSessao         → String nome, String credencial, String imagem
EmpresaSessao         → String id, String nome
DispositivoSessao     → String id, String nome
EstabelecimentoSessao → String id, String nome, List<AmbienteSessao> ambientes
AmbienteSessao        → String id, String nome, bool padrao
```

## Modelos (dados)

- **`RequisicaoLoginNuvem`** — `toJson` produz exatamente o payload do request acima.
- **`RespostaLoginNuvem`** — `fromJson` lê a resposta e expõe um método `paraEntidade()` que devolve `SessaoNuvem`. Mapeia `estabelecimento.estabelecimentoAmbientes` → `List<AmbienteSessao>` e `validade` (string ISO) → `DateTime`.

## Fluxo de dados

```
Splash → CasoUsoGarantirSessao → (RepositorioSessaoNuvem | CasoUsoLoginNuvem)
CasoUsoLoginNuvem → FonteAutenticacaoNuvem → ClienteApi(nuvem) → API
```

### `CasoUsoLoginNuvem.executar() → Resultado<SessaoNuvem>`

1. Lê credenciais (`RepositorioCredencial`) e config (`RepositorioConfiguracao`).
2. **Guardas antes de qualquer rede:** credencial ausente **ou** `urlNuvemAtiva` vazia → `Erro(FalhaValidacao)` sem chamada HTTP.
3. Monta `RequisicaoLoginNuvem` (versão via `InfoAplicativo`, timezone via `FusoHorario`, demais campos conforme mapeamento).
4. `FonteAutenticacaoNuvem.login(requisicao)` → `POST ConstantesApp.caminhoLoginNuvem`.
5. Parseia `RespostaLoginNuvem` → `SessaoNuvem`; persiste via `RepositorioSessaoNuvem.salvar`; retorna `Sucesso(sessao)`.

### `CasoUsoGarantirSessao.executar() → Resultado<SessaoNuvem>`

- Lê sessão salva. Existe e **não** expirada → `Sucesso(sessao)`. Caso contrário → delega para `CasoUsoLoginNuvem`.

## Persistência e lifecycle do token

- `RepositorioSessaoNuvemImpl` serializa a `SessaoNuvem` inteira como JSON no **secure storage** (chave `sessao_nuvem`), sobrevivendo a reinício sem novo login. Métodos: `obter()`, `salvar()`, `remover()`.
- **Injeção do token:** interceptor no `ClienteApi` da nuvem adiciona `Authorization: Bearer <token>` lendo a sessão salva em tempo de requisição.
- **Expiração / `401`:** o interceptor tenta um único re-login (via `CasoUsoLoginNuvem`) e repete a chamada original; se o retry falhar, propaga o erro. Não há endpoint de refresh — o re-login é o refresh.

## Tratamento de erros e segurança

- Reusa `Resultado`/`Falha` e `ClienteApi.mapearFalha`.
- No splash, falha de login **apenas registra no log** e não bloqueia a navegação (comportamento anterior).
- **Nunca** logar token, senha ou payload — apenas método e caminho, como o `ClienteApi` já faz.
- Token e credenciais vivem exclusivamente no secure storage.

## Integração

- **`injecao.dart`** — readicionar:
  - `provedorRepositorioSessaoNuvem`
  - `provedorFonteAutenticacaoNuvem`
  - `provedorCasoUsoLoginNuvem`
  - `provedorCasoUsoGarantirSessao`
  - (`provedorClienteApiNuvem` e `provedorInfoAplicativo` já existem)
- **`pagina_splash.dart`** — readicionar o login silencioso em segundo plano chamando `provedorCasoUsoGarantirSessao`, logando em caso de erro (não bloqueia a navegação).
- **Interceptor de auth** plugado na construção do `provedorClienteApiNuvem`.

## Constantes (`ConstantesApp`)

- `nomeAplicativoLogin = 'Constel Pay'`
- `caminhoLoginNuvem = 'auth/login'`
- `dataBuild` — ISO-8601, sobrescrevível no build via `--dart-define=BUILD_DATE=...` com fallback fixo em código.

⚠️ A URL de nuvem configurada deve terminar com `/api/` (base), pois o path fica relativo (`auth/login`). Documentar na aba Comunicação/README.

## Testes

- `RequisicaoLoginNuvem.toJson` — payload exatamente conforme o contrato.
- `RespostaLoginNuvem.fromJson` / `paraEntidade` — mapeamento correto (incluindo ambientes e `validade`).
- `CasoUsoLoginNuvem` — guardas (sem credencial / URL vazia devolvem `FalhaValidacao` sem rede); sucesso monta o payload certo e persiste a sessão.
- `CasoUsoGarantirSessao` — sessão válida / expirada / ausente.
- `RepositorioSessaoNuvemImpl` — round-trip no storage (salvar → obter → remover).
- Interceptor — injeta `Bearer` e faz o retry único no `401`.
- Reaproveitar fakes no padrão dos testes existentes (`_InfoFake` etc.).

## Fora de escopo

- Autenticação da API local (loja) — spec separada.
- Tela de login / UI de autenticação (o app não tem login).
- Endpoint de refresh token (inexistente na API).
- Persistir/modelar campos da resposta não listados.
