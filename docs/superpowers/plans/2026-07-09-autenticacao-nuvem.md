# Autenticação de Nuvem — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implementar o login silencioso na API de nuvem (JWT + informações da sessão), persistindo a sessão no secure storage e injetando o token automaticamente nas chamadas de nuvem.

**Architecture:** Clean architecture na feature `autenticacao`. Uma entidade `SessaoNuvem` (freezed + json) serve tanto ao parse quanto à persistência. Um mapper converte a resposta da API para a entidade. Casos de uso `CasoUsoLoginNuvem` (monta payload, chama a fonte, persiste) e `CasoUsoGarantirSessao` (reusa sessão válida ou faz login). Um interceptor no `ClienteApi` da nuvem injeta o `Bearer` e refaz o login uma vez em `401`. O login roda em segundo plano no splash.

**Tech Stack:** Flutter/Dart, flutter_riverpod, dio, freezed + json_serializable, flutter_secure_storage, mocktail (testes).

## Global Constraints

- Flutter `>=3.22.0`, Dart SDK `>=3.4.0 <4.0.0`.
- Nome do pacote nos imports de teste: `constel_pay`.
- Idioma pt-BR em textos visíveis e mensagens de erro.
- O app **não** tem tela de login — autenticação é silenciosa/segundo plano.
- **Segurança:** nunca logar token, senha ou payload. Token e credenciais só no secure storage.
- Reusar `Resultado<T>` / `Falha` para retornos; nunca lançar exceção para fora dos casos de uso/fontes.
- Padrão de entidades/modelos: `freezed`. Codegen: `dart run build_runner build --delete-conflicting-outputs`.
- Arquivos de código nunca acima de 600–700 linhas.
- Endpoint de login: `POST auth/login`, base = `configuracao.urlNuvemAtiva` (a URL de nuvem **deve terminar com `/`**).
- Mapeamento do payload de request (fonte de cada campo):
  - `username`←`Credencial.usuario`, `password`←`Credencial.senha`, `timezone`←`FusoHorario.gmt()`
  - `aplicativo.nome`←`ConstantesApp.nomeAplicativoLogin`, `aplicativo.versao`←`InfoAplicativo.versao()`, `aplicativo.data`←`ConstantesApp.dataVersaoAplicativo`
  - `api.caminho`←`configuracao.urlBaseAtiva`, `dispositivo.id`←`configuracao.idDispositivo`, `dispositivo.nome`←`configuracao.identificadorDispositivo`
- Campos modelados da resposta: `token`, `validade`, `usuario{nome,credencial,imagem}`, `empresa{id,nome}`, `dispositivo{id,nome}`, `estabelecimento{id,nome,ambientes[{id,nome,padrao}]}`. Restante ignorado.

---

### Task 1: Entidade `SessaoNuvem`

**Files:**
- Create: `build.yaml` (raiz do projeto)
- Create: `lib/funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart`
- Test: `test/funcionalidades/autenticacao/sessao_nuvem_test.dart`
- Generated: `sessao_nuvem.freezed.dart`, `sessao_nuvem.g.dart`

**Interfaces:**
- Produces:
  - `class SessaoNuvem` com `String token`, `DateTime validade`, `UsuarioSessao usuario`, `EmpresaSessao empresa`, `DispositivoSessao dispositivo`, `EstabelecimentoSessao estabelecimento`; getter `bool get expirada`; `factory SessaoNuvem.fromJson(Map<String,dynamic>)`; método `Map<String,dynamic> toJson()`.
  - `class UsuarioSessao{String nome, credencial, imagem}`
  - `class EmpresaSessao{String id, nome}`
  - `class DispositivoSessao{String id, nome}`
  - `class AmbienteSessao{String id, nome; bool padrao}`
  - `class EstabelecimentoSessao{String id, nome; List<AmbienteSessao> ambientes}`

- [ ] **Step 0: Criar `build.yaml` (raiz do projeto)**

`SessaoNuvem` é o primeiro modelo do projeto com objetos JSON aninhados. Sem `explicit_to_json`, o `toJson` gerado não chama `.toJson()` nos objetos aninhados e o round-trip quebra. Crie `build.yaml` na raiz com:

```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          explicit_to_json: true
```

Os modelos json existentes são flat (primitivos/enums), então essa opção não altera o comportamento deles.

- [ ] **Step 1: Write the entity file**

```dart
// lib/funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sessao_nuvem.freezed.dart';
part 'sessao_nuvem.g.dart';

@freezed
class SessaoNuvem with _$SessaoNuvem {
  const SessaoNuvem._();

  const factory SessaoNuvem({
    required String token,
    required DateTime validade,
    required UsuarioSessao usuario,
    required EmpresaSessao empresa,
    required DispositivoSessao dispositivo,
    required EstabelecimentoSessao estabelecimento,
  }) = _SessaoNuvem;

  factory SessaoNuvem.fromJson(Map<String, dynamic> json) =>
      _$SessaoNuvemFromJson(json);

  /// Considera a sessão expirada quando a data atual ultrapassa `validade`.
  bool get expirada => DateTime.now().isAfter(validade);
}

@freezed
class UsuarioSessao with _$UsuarioSessao {
  const factory UsuarioSessao({
    required String nome,
    required String credencial,
    required String imagem,
  }) = _UsuarioSessao;

  factory UsuarioSessao.fromJson(Map<String, dynamic> json) =>
      _$UsuarioSessaoFromJson(json);
}

@freezed
class EmpresaSessao with _$EmpresaSessao {
  const factory EmpresaSessao({
    required String id,
    required String nome,
  }) = _EmpresaSessao;

  factory EmpresaSessao.fromJson(Map<String, dynamic> json) =>
      _$EmpresaSessaoFromJson(json);
}

@freezed
class DispositivoSessao with _$DispositivoSessao {
  const factory DispositivoSessao({
    required String id,
    required String nome,
  }) = _DispositivoSessao;

  factory DispositivoSessao.fromJson(Map<String, dynamic> json) =>
      _$DispositivoSessaoFromJson(json);
}

@freezed
class AmbienteSessao with _$AmbienteSessao {
  const factory AmbienteSessao({
    required String id,
    required String nome,
    required bool padrao,
  }) = _AmbienteSessao;

  factory AmbienteSessao.fromJson(Map<String, dynamic> json) =>
      _$AmbienteSessaoFromJson(json);
}

@freezed
class EstabelecimentoSessao with _$EstabelecimentoSessao {
  const factory EstabelecimentoSessao({
    required String id,
    required String nome,
    @Default(<AmbienteSessao>[]) List<AmbienteSessao> ambientes,
  }) = _EstabelecimentoSessao;

  factory EstabelecimentoSessao.fromJson(Map<String, dynamic> json) =>
      _$EstabelecimentoSessaoFromJson(json);
}
```

- [ ] **Step 2: Run codegen**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: gera `sessao_nuvem.freezed.dart` e `sessao_nuvem.g.dart` sem erros ("Succeeded").

- [ ] **Step 3: Write the failing test**

```dart
// test/funcionalidades/autenticacao/sessao_nuvem_test.dart
import 'package:constel_pay/funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart';
import 'package:flutter_test/flutter_test.dart';

SessaoNuvem _sessao(DateTime validade) => SessaoNuvem(
      token: 'jwt',
      validade: validade,
      usuario: const UsuarioSessao(nome: 'Ana', credencial: 'a@x.com', imagem: ''),
      empresa: const EmpresaSessao(id: 'e1', nome: 'Empresa'),
      dispositivo: const DispositivoSessao(id: 'd1', nome: 'Terminal'),
      estabelecimento: const EstabelecimentoSessao(
        id: 's1',
        nome: 'Loja',
        ambientes: [AmbienteSessao(id: 'a1', nome: 'Padrão', padrao: true)],
      ),
    );

void main() {
  test('expirada é false quando validade está no futuro', () {
    final sessao = _sessao(DateTime.now().add(const Duration(days: 1)));
    expect(sessao.expirada, isFalse);
  });

  test('expirada é true quando validade está no passado', () {
    final sessao = _sessao(DateTime.now().subtract(const Duration(minutes: 1)));
    expect(sessao.expirada, isTrue);
  });

  test('round-trip toJson/fromJson preserva os dados', () {
    final original = _sessao(DateTime.utc(2026, 7, 11));
    final copia = SessaoNuvem.fromJson(original.toJson());
    expect(copia, original);
    expect(copia.estabelecimento.ambientes.first.padrao, isTrue);
  });
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/funcionalidades/autenticacao/sessao_nuvem_test.dart`
Expected: PASS (3 testes).

- [ ] **Step 5: Commit**

```bash
git add build.yaml lib/funcionalidades/autenticacao/dominio/entidades/ test/funcionalidades/autenticacao/sessao_nuvem_test.dart lib/funcionalidades/configuracoes/dados/modelos/ lib/funcionalidades/propaganda/dados/modelos/
git commit -m "feat: entidade SessaoNuvem e build.yaml com explicit_to_json"
```

> O codegen regenera também os `.g.dart`/`.freezed.dart` dos modelos existentes (sem mudança funcional). Inclua-os no commit se o `git status` os listar como modificados.

---

### Task 2: Mapper `RespostaLoginNuvem`

**Files:**
- Create: `lib/funcionalidades/autenticacao/dados/modelos/resposta_login_nuvem.dart`
- Test: `test/funcionalidades/autenticacao/resposta_login_nuvem_test.dart`

**Interfaces:**
- Consumes: `SessaoNuvem` e sub-entidades (Task 1).
- Produces: `abstract final class RespostaLoginNuvem` com `static SessaoNuvem paraEntidade(Map<String,dynamic> json)`.

- [ ] **Step 1: Write the failing test**

```dart
// test/funcionalidades/autenticacao/resposta_login_nuvem_test.dart
import 'package:constel_pay/funcionalidades/autenticacao/dados/modelos/resposta_login_nuvem.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const respostaApi = <String, dynamic>{
    'nome': 'Yerich Sales',
    'credencial': 'admin@audax.com',
    'imagem': 'https://x/y.jpg',
    'empresa': {'id': 'emp1', 'nome': "Durango Builder's"},
    'token': 'eyJhbGciOi...',
    'validade': '2026-07-11T00:00:13.000Z',
    'dispositivo': {'id': 'dev1', 'nome': 'NBYERICH CAIXA'},
    'estabelecimento': {
      'id': 'est1',
      'nome': 'Dionísio Torres',
      'estabelecimentoAmbientes': [
        {'id': 'amb1', 'nome': 'Padrão', 'situacao': 1, 'padrao': true},
        {'id': 'amb2', 'nome': 'BAR', 'situacao': 1, 'padrao': false},
      ],
    },
  };

  test('paraEntidade mapeia os campos relevantes', () {
    final sessao = RespostaLoginNuvem.paraEntidade(respostaApi);
    expect(sessao.token, 'eyJhbGciOi...');
    expect(sessao.validade, DateTime.parse('2026-07-11T00:00:13.000Z'));
    expect(sessao.usuario.nome, 'Yerich Sales');
    expect(sessao.usuario.credencial, 'admin@audax.com');
    expect(sessao.empresa.nome, "Durango Builder's");
    expect(sessao.dispositivo.nome, 'NBYERICH CAIXA');
    expect(sessao.estabelecimento.nome, 'Dionísio Torres');
    expect(sessao.estabelecimento.ambientes.length, 2);
    expect(sessao.estabelecimento.ambientes.first.padrao, isTrue);
    expect(sessao.estabelecimento.ambientes[1].nome, 'BAR');
  });

  test('paraEntidade tolera estabelecimento sem ambientes', () {
    final json = Map<String, dynamic>.from(respostaApi)
      ..['estabelecimento'] = {'id': 'est1', 'nome': 'Loja'};
    final sessao = RespostaLoginNuvem.paraEntidade(json);
    expect(sessao.estabelecimento.ambientes, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/funcionalidades/autenticacao/resposta_login_nuvem_test.dart`
Expected: FAIL (target of URI doesn't exist / RespostaLoginNuvem não definido).

- [ ] **Step 3: Write the mapper**

```dart
// lib/funcionalidades/autenticacao/dados/modelos/resposta_login_nuvem.dart
import '../../dominio/entidades/sessao_nuvem.dart';

/// Converte a resposta crua da API de nuvem (`POST auth/login`) na entidade
/// [SessaoNuvem], extraindo apenas os campos usados pelo app.
abstract final class RespostaLoginNuvem {
  static SessaoNuvem paraEntidade(Map<String, dynamic> json) {
    final estabelecimento =
        (json['estabelecimento'] as Map<String, dynamic>?) ?? const {};
    final empresa = (json['empresa'] as Map<String, dynamic>?) ?? const {};
    final dispositivo = (json['dispositivo'] as Map<String, dynamic>?) ?? const {};
    final ambientesJson =
        (estabelecimento['estabelecimentoAmbientes'] as List<dynamic>?) ??
            const [];

    return SessaoNuvem(
      token: json['token'] as String? ?? '',
      validade: DateTime.parse(json['validade'] as String),
      usuario: UsuarioSessao(
        nome: json['nome'] as String? ?? '',
        credencial: json['credencial'] as String? ?? '',
        imagem: json['imagem'] as String? ?? '',
      ),
      empresa: EmpresaSessao(
        id: empresa['id'] as String? ?? '',
        nome: empresa['nome'] as String? ?? '',
      ),
      dispositivo: DispositivoSessao(
        id: dispositivo['id'] as String? ?? '',
        nome: dispositivo['nome'] as String? ?? '',
      ),
      estabelecimento: EstabelecimentoSessao(
        id: estabelecimento['id'] as String? ?? '',
        nome: estabelecimento['nome'] as String? ?? '',
        ambientes: ambientesJson.map((item) {
          final mapa = item as Map<String, dynamic>;
          return AmbienteSessao(
            id: mapa['id'] as String? ?? '',
            nome: mapa['nome'] as String? ?? '',
            padrao: mapa['padrao'] as bool? ?? false,
          );
        }).toList(),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/funcionalidades/autenticacao/resposta_login_nuvem_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/funcionalidades/autenticacao/dados/modelos/resposta_login_nuvem.dart test/funcionalidades/autenticacao/resposta_login_nuvem_test.dart
git commit -m "feat: mapper da resposta de login da nuvem para SessaoNuvem"
```

---

### Task 3: Modelo de requisição `RequisicaoLoginNuvem`

**Files:**
- Create: `lib/funcionalidades/autenticacao/dados/modelos/requisicao_login_nuvem.dart`
- Test: `test/funcionalidades/autenticacao/requisicao_login_nuvem_test.dart`

**Interfaces:**
- Produces: `class RequisicaoLoginNuvem` com construtor nomeado (`username`, `password`, `timezone`, `nomeAplicativo`, `versaoAplicativo`, `dataAplicativo`, `caminhoApi`, `idDispositivo`, `nomeDispositivo`, todos `String`) e `Map<String,dynamic> paraJson()`.

- [ ] **Step 1: Write the failing test**

```dart
// test/funcionalidades/autenticacao/requisicao_login_nuvem_test.dart
import 'package:constel_pay/funcionalidades/autenticacao/dados/modelos/requisicao_login_nuvem.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('paraJson monta o payload no formato esperado pela API', () {
    const requisicao = RequisicaoLoginNuvem(
      username: 'admin@audax.com',
      password: 'segredo',
      timezone: 'GMT-03',
      nomeAplicativo: 'Constel Pay',
      versaoAplicativo: '1.0.0',
      dataAplicativo: '2026-07-08',
      caminhoApi: 'http://localhost:3000/api/',
      idDispositivo: 'dev-uuid',
      nomeDispositivo: 'TERMINAL-01',
    );

    expect(requisicao.paraJson(), {
      'username': 'admin@audax.com',
      'password': 'segredo',
      'timezone': 'GMT-03',
      'aplicativo': {
        'nome': 'Constel Pay',
        'versao': '1.0.0',
        'data': '2026-07-08',
      },
      'api': {'caminho': 'http://localhost:3000/api/'},
      'dispositivo': {'id': 'dev-uuid', 'nome': 'TERMINAL-01'},
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/funcionalidades/autenticacao/requisicao_login_nuvem_test.dart`
Expected: FAIL (RequisicaoLoginNuvem não definido).

- [ ] **Step 3: Write the model**

```dart
// lib/funcionalidades/autenticacao/dados/modelos/requisicao_login_nuvem.dart

/// Payload do `POST auth/login` da API de nuvem.
class RequisicaoLoginNuvem {
  const RequisicaoLoginNuvem({
    required this.username,
    required this.password,
    required this.timezone,
    required this.nomeAplicativo,
    required this.versaoAplicativo,
    required this.dataAplicativo,
    required this.caminhoApi,
    required this.idDispositivo,
    required this.nomeDispositivo,
  });

  final String username;
  final String password;
  final String timezone;
  final String nomeAplicativo;
  final String versaoAplicativo;
  final String dataAplicativo;
  final String caminhoApi;
  final String idDispositivo;
  final String nomeDispositivo;

  Map<String, dynamic> paraJson() => {
        'username': username,
        'password': password,
        'timezone': timezone,
        'aplicativo': {
          'nome': nomeAplicativo,
          'versao': versaoAplicativo,
          'data': dataAplicativo,
        },
        'api': {'caminho': caminhoApi},
        'dispositivo': {'id': idDispositivo, 'nome': nomeDispositivo},
      };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/funcionalidades/autenticacao/requisicao_login_nuvem_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/funcionalidades/autenticacao/dados/modelos/requisicao_login_nuvem.dart test/funcionalidades/autenticacao/requisicao_login_nuvem_test.dart
git commit -m "feat: modelo de requisicao de login da nuvem"
```

---

### Task 4: Repositório de sessão (interface + secure storage)

**Files:**
- Create: `lib/funcionalidades/autenticacao/dominio/repositorios/repositorio_sessao_nuvem.dart`
- Create: `lib/funcionalidades/autenticacao/dados/repositorios/repositorio_sessao_nuvem_impl.dart`
- Test: `test/funcionalidades/autenticacao/repositorio_sessao_nuvem_impl_test.dart`

**Interfaces:**
- Consumes: `SessaoNuvem` (Task 1).
- Produces:
  - `abstract interface class RepositorioSessaoNuvem` com `Future<SessaoNuvem?> obter()`, `Future<void> salvar(SessaoNuvem sessao)`, `Future<void> remover()`.
  - `class RepositorioSessaoNuvemImpl implements RepositorioSessaoNuvem` com construtor posicional `(FlutterSecureStorage armazenamento)`.

- [ ] **Step 1: Write the interface**

```dart
// lib/funcionalidades/autenticacao/dominio/repositorios/repositorio_sessao_nuvem.dart
import '../entidades/sessao_nuvem.dart';

abstract interface class RepositorioSessaoNuvem {
  Future<SessaoNuvem?> obter();

  Future<void> salvar(SessaoNuvem sessao);

  Future<void> remover();
}
```

- [ ] **Step 2: Write the failing test**

```dart
// test/funcionalidades/autenticacao/repositorio_sessao_nuvem_impl_test.dart
import 'dart:convert';

import 'package:constel_pay/funcionalidades/autenticacao/dados/repositorios/repositorio_sessao_nuvem_impl.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _StorageMock extends Mock implements FlutterSecureStorage {}

SessaoNuvem _sessao() => SessaoNuvem(
      token: 'jwt',
      validade: DateTime.utc(2026, 7, 11),
      usuario: const UsuarioSessao(nome: 'Ana', credencial: 'a@x.com', imagem: ''),
      empresa: const EmpresaSessao(id: 'e1', nome: 'Empresa'),
      dispositivo: const DispositivoSessao(id: 'd1', nome: 'Terminal'),
      estabelecimento: const EstabelecimentoSessao(id: 's1', nome: 'Loja'),
    );

void main() {
  late _StorageMock storage;
  late RepositorioSessaoNuvemImpl repositorio;

  setUp(() {
    storage = _StorageMock();
    repositorio = RepositorioSessaoNuvemImpl(storage);
  });

  test('salvar grava o JSON da sessão na chave sessao_nuvem', () async {
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    await repositorio.salvar(_sessao());
    final captured = verify(() => storage.write(
        key: 'sessao_nuvem', value: captureAny(named: 'value'))).captured.single;
    final decodificado = jsonDecode(captured as String) as Map<String, dynamic>;
    expect(decodificado['token'], 'jwt');
  });

  test('obter devolve a sessão desserializada', () async {
    when(() => storage.read(key: 'sessao_nuvem'))
        .thenAnswer((_) async => jsonEncode(_sessao().toJson()));
    final sessao = await repositorio.obter();
    expect(sessao, isNotNull);
    expect(sessao!.token, 'jwt');
  });

  test('obter devolve null quando não há nada gravado', () async {
    when(() => storage.read(key: 'sessao_nuvem')).thenAnswer((_) async => null);
    expect(await repositorio.obter(), isNull);
  });

  test('obter devolve null quando o conteúdo está corrompido', () async {
    when(() => storage.read(key: 'sessao_nuvem'))
        .thenAnswer((_) async => 'não é json');
    expect(await repositorio.obter(), isNull);
  });

  test('remover apaga a chave', () async {
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
    await repositorio.remover();
    verify(() => storage.delete(key: 'sessao_nuvem')).called(1);
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/funcionalidades/autenticacao/repositorio_sessao_nuvem_impl_test.dart`
Expected: FAIL (RepositorioSessaoNuvemImpl não definido).

- [ ] **Step 4: Write the implementation**

```dart
// lib/funcionalidades/autenticacao/dados/repositorios/repositorio_sessao_nuvem_impl.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../dominio/entidades/sessao_nuvem.dart';
import '../../dominio/repositorios/repositorio_sessao_nuvem.dart';

class RepositorioSessaoNuvemImpl implements RepositorioSessaoNuvem {
  RepositorioSessaoNuvemImpl(this._armazenamento);

  final FlutterSecureStorage _armazenamento;

  static const String _chave = 'sessao_nuvem';

  @override
  Future<SessaoNuvem?> obter() async {
    final bruto = await _armazenamento.read(key: _chave);
    if (bruto == null || bruto.isEmpty) return null;
    try {
      return SessaoNuvem.fromJson(jsonDecode(bruto) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> salvar(SessaoNuvem sessao) =>
      _armazenamento.write(key: _chave, value: jsonEncode(sessao.toJson()));

  @override
  Future<void> remover() => _armazenamento.delete(key: _chave);
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/funcionalidades/autenticacao/repositorio_sessao_nuvem_impl_test.dart`
Expected: PASS (5 testes).

- [ ] **Step 6: Commit**

```bash
git add lib/funcionalidades/autenticacao/dominio/repositorios/repositorio_sessao_nuvem.dart lib/funcionalidades/autenticacao/dados/repositorios/repositorio_sessao_nuvem_impl.dart test/funcionalidades/autenticacao/repositorio_sessao_nuvem_impl_test.dart
git commit -m "feat: repositorio de sessao da nuvem no secure storage"
```

---

### Task 5: Constante de rota + `FonteAutenticacaoNuvem`

**Files:**
- Modify: `lib/nucleo/constantes/constantes_app.dart` (adicionar `caminhoLoginNuvem`)
- Create: `lib/funcionalidades/autenticacao/dados/fontes_dados/fonte_autenticacao_nuvem.dart`
- Test: `test/funcionalidades/autenticacao/fonte_autenticacao_nuvem_test.dart`

**Interfaces:**
- Consumes: `ClienteApi` (`Future<Resultado<Response>> post(String, {Object? dados})`), `RequisicaoLoginNuvem.paraJson()` (Task 3), `RespostaLoginNuvem.paraEntidade` (Task 2), `SessaoNuvem` (Task 1), `ConstantesApp.caminhoLoginNuvem`.
- Produces: `class FonteAutenticacaoNuvem` com construtor posicional `(ClienteApi)` e `Future<Resultado<SessaoNuvem>> login(RequisicaoLoginNuvem requisicao)`.

- [ ] **Step 1: Add the constant**

Em `lib/nucleo/constantes/constantes_app.dart`, dentro da classe `ConstantesApp`, adicione após `dataVersaoAplicativo`:

```dart
  // Caminho do login na API de nuvem (relativo à urlNuvemAtiva, que deve
  // terminar com '/'). Ex.: base 'http://host/api/' + 'auth/login'.
  static const String caminhoLoginNuvem = 'auth/login';
```

- [ ] **Step 2: Write the failing test**

```dart
// test/funcionalidades/autenticacao/fonte_autenticacao_nuvem_test.dart
import 'dart:convert';

import 'package:constel_pay/funcionalidades/autenticacao/dados/fontes_dados/fonte_autenticacao_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dados/modelos/requisicao_login_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/nucleo/configuracao/cliente_api.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepositorioFake implements RepositorioConfiguracao {
  _RepositorioFake(this.configuracao);
  ConfiguracaoTerminal configuracao;
  @override
  Future<ConfiguracaoTerminal> obter() async => configuracao;
  @override
  Future<void> salvar(ConfiguracaoTerminal nova) async => configuracao = nova;
}

class _AdaptadorResposta implements HttpClientAdapter {
  _AdaptadorResposta(this.corpo, this.status);
  final Map<String, dynamic> corpo;
  final int status;
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    return ResponseBody.fromString(jsonEncode(corpo), status, headers: {
      'content-type': ['application/json']
    });
  }
  @override
  void close({bool force = false}) {}
}

const _requisicao = RequisicaoLoginNuvem(
  username: 'admin@audax.com',
  password: 'segredo',
  timezone: 'GMT-03',
  nomeAplicativo: 'Constel Pay',
  versaoAplicativo: '1.0.0',
  dataAplicativo: '2026-07-08',
  caminhoApi: 'http://localhost:3000/api/',
  idDispositivo: 'dev-uuid',
  nomeDispositivo: 'TERMINAL-01',
);

ClienteApi _cliente(HttpClientAdapter adaptador) {
  final repositorio = _RepositorioFake(const ConfiguracaoTerminal(
      urlNuvemHomologacao: 'http://localhost:3000/api/'));
  final dio = Dio()..httpClientAdapter = adaptador;
  return ClienteApi(
    repositorioConfiguracao: repositorio,
    seletorBase: (c) => c.urlNuvemAtiva,
    dio: dio,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('login com 201 devolve Sucesso com a sessão parseada', () async {
    final fonte = FonteAutenticacaoNuvem(_cliente(_AdaptadorResposta(const {
      'token': 'jwt',
      'validade': '2026-07-11T00:00:13.000Z',
      'nome': 'Ana',
      'credencial': 'a@x.com',
      'imagem': '',
      'empresa': {'id': 'e1', 'nome': 'Empresa'},
      'dispositivo': {'id': 'd1', 'nome': 'Terminal'},
      'estabelecimento': {'id': 's1', 'nome': 'Loja'},
    }, 201)));
    final resultado = await fonte.login(_requisicao);
    expect(resultado, isA<Sucesso<SessaoNuvem>>());
    expect((resultado as Sucesso<SessaoNuvem>).valor.token, 'jwt');
  });

  test('login com erro HTTP devolve Erro', () async {
    final fonte = FonteAutenticacaoNuvem(
        _cliente(_AdaptadorResposta(const {'mensagem': 'nao autorizado'}, 401)));
    final resultado = await fonte.login(_requisicao);
    expect(resultado, isA<Erro<SessaoNuvem>>());
    expect((resultado as Erro<SessaoNuvem>).falha, isA<Falha>());
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/funcionalidades/autenticacao/fonte_autenticacao_nuvem_test.dart`
Expected: FAIL (FonteAutenticacaoNuvem não definido).

- [ ] **Step 4: Write the data source**

```dart
// lib/funcionalidades/autenticacao/dados/fontes_dados/fonte_autenticacao_nuvem.dart
import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/entidades/sessao_nuvem.dart';
import '../modelos/requisicao_login_nuvem.dart';
import '../modelos/resposta_login_nuvem.dart';

class FonteAutenticacaoNuvem {
  FonteAutenticacaoNuvem(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<Resultado<SessaoNuvem>> login(RequisicaoLoginNuvem requisicao) async {
    final resposta = await _clienteApi.post(
      ConstantesApp.caminhoLoginNuvem,
      dados: requisicao.paraJson(),
    );
    try {
      return switch (resposta) {
        Sucesso(:final valor) => Sucesso(
            RespostaLoginNuvem.paraEntidade(valor.data as Map<String, dynamic>)),
        Erro(:final falha) => Erro(falha),
      };
    } catch (_) {
      return const Erro(FalhaServidor('Resposta de login inválida.'));
    }
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/funcionalidades/autenticacao/fonte_autenticacao_nuvem_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 6: Commit**

```bash
git add lib/nucleo/constantes/constantes_app.dart lib/funcionalidades/autenticacao/dados/fontes_dados/fonte_autenticacao_nuvem.dart test/funcionalidades/autenticacao/fonte_autenticacao_nuvem_test.dart
git commit -m "feat: fonte de autenticacao da nuvem e constante de rota de login"
```

---

### Task 6: `CasoUsoLoginNuvem`

**Files:**
- Create: `lib/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_login_nuvem.dart`
- Test: `test/funcionalidades/autenticacao/caso_uso_login_nuvem_test.dart`

**Interfaces:**
- Consumes: `FonteAutenticacaoNuvem.login` (Task 5), `RepositorioConfiguracao.obter`, `RepositorioCredencial.obter`, `RepositorioSessaoNuvem.salvar` (Task 4), `InfoAplicativo.versao`, `FusoHorario.gmt`, `ConstantesApp`, `RequisicaoLoginNuvem` (Task 3).
- Produces: `class CasoUsoLoginNuvem` com construtor nomeado `({FonteAutenticacaoNuvem fonte, RepositorioConfiguracao repositorioConfiguracao, RepositorioCredencial repositorioCredencial, RepositorioSessaoNuvem repositorioSessao, InfoAplicativo infoAplicativo})` e `Future<Resultado<SessaoNuvem>> executar()`.

- [ ] **Step 1: Write the failing test**

```dart
// test/funcionalidades/autenticacao/caso_uso_login_nuvem_test.dart
import 'package:constel_pay/funcionalidades/autenticacao/dados/fontes_dados/fonte_autenticacao_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dados/modelos/requisicao_login_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_login_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/repositorios/repositorio_sessao_nuvem.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/credencial.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_credencial.dart';
import 'package:constel_pay/nucleo/dispositivo/info_aplicativo.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FonteMock extends Mock implements FonteAutenticacaoNuvem {}

class _ConfiguracaoFake implements RepositorioConfiguracao {
  _ConfiguracaoFake(this.configuracao);
  ConfiguracaoTerminal configuracao;
  @override
  Future<ConfiguracaoTerminal> obter() async => configuracao;
  @override
  Future<void> salvar(ConfiguracaoTerminal nova) async => configuracao = nova;
}

class _CredencialFake implements RepositorioCredencial {
  _CredencialFake(this.credencial);
  Credencial? credencial;
  @override
  Future<Credencial?> obter() async => credencial;
  @override
  Future<void> salvar(Credencial nova) async => credencial = nova;
  @override
  Future<void> remover() async => credencial = null;
}

class _SessaoFake implements RepositorioSessaoNuvem {
  SessaoNuvem? salva;
  @override
  Future<SessaoNuvem?> obter() async => salva;
  @override
  Future<void> salvar(SessaoNuvem sessao) async => salva = sessao;
  @override
  Future<void> remover() async => salva = null;
}

class _InfoFake implements InfoAplicativo {
  @override
  Future<String> versao() async => '1.0.0';
}

SessaoNuvem _sessao() => SessaoNuvem(
      token: 'jwt',
      validade: DateTime.utc(2026, 7, 11),
      usuario: const UsuarioSessao(nome: 'Ana', credencial: 'a@x.com', imagem: ''),
      empresa: const EmpresaSessao(id: 'e1', nome: 'Empresa'),
      dispositivo: const DispositivoSessao(id: 'd1', nome: 'Terminal'),
      estabelecimento: const EstabelecimentoSessao(id: 's1', nome: 'Loja'),
    );

const _configValida = ConfiguracaoTerminal(
  identificadorDispositivo: 'TERMINAL-01',
  idDispositivo: 'dev-uuid',
  urlNuvemHomologacao: 'http://localhost:3000/api/',
  urlBaseHomologacao: 'http://localhost:3000/api/',
);

void main() {
  setUpAll(() {
    registerFallbackValue(const RequisicaoLoginNuvem(
      username: '', password: '', timezone: '', nomeAplicativo: '',
      versaoAplicativo: '', dataAplicativo: '', caminhoApi: '',
      idDispositivo: '', nomeDispositivo: '',
    ));
  });

  CasoUsoLoginNuvem construir({
    required _FonteMock fonte,
    Credencial? credencial =
        const Credencial(usuario: 'admin@audax.com', senha: 'segredo'),
    ConfiguracaoTerminal configuracao = _configValida,
    required _SessaoFake sessao,
  }) =>
      CasoUsoLoginNuvem(
        fonte: fonte,
        repositorioConfiguracao: _ConfiguracaoFake(configuracao),
        repositorioCredencial: _CredencialFake(credencial),
        repositorioSessao: sessao,
        infoAplicativo: _InfoFake(),
      );

  test('sem credencial devolve FalhaValidacao sem chamar a fonte', () async {
    final fonte = _FonteMock();
    final caso = construir(fonte: fonte, credencial: null, sessao: _SessaoFake());
    final resultado = await caso.executar();
    expect(resultado, isA<Erro<SessaoNuvem>>());
    expect((resultado as Erro<SessaoNuvem>).falha, isA<FalhaValidacao>());
    verifyNever(() => fonte.login(any()));
  });

  test('sem URL de nuvem devolve FalhaValidacao sem chamar a fonte', () async {
    final fonte = _FonteMock();
    final caso = construir(
        fonte: fonte,
        configuracao: const ConfiguracaoTerminal(),
        sessao: _SessaoFake());
    final resultado = await caso.executar();
    expect(resultado, isA<Erro<SessaoNuvem>>());
    verifyNever(() => fonte.login(any()));
  });

  test('login com sucesso persiste a sessão e monta o payload correto', () async {
    final fonte = _FonteMock();
    final sessao = _SessaoFake();
    when(() => fonte.login(any())).thenAnswer((_) async => Sucesso(_sessao()));
    final caso = construir(fonte: fonte, sessao: sessao);

    final resultado = await caso.executar();

    expect(resultado, isA<Sucesso<SessaoNuvem>>());
    expect(sessao.salva?.token, 'jwt');
    final capturada =
        verify(() => fonte.login(captureAny())).captured.single as RequisicaoLoginNuvem;
    expect(capturada.username, 'admin@audax.com');
    expect(capturada.nomeAplicativo, 'Constel Pay');
    expect(capturada.versaoAplicativo, '1.0.0');
    expect(capturada.caminhoApi, 'http://localhost:3000/api/');
    expect(capturada.idDispositivo, 'dev-uuid');
    expect(capturada.nomeDispositivo, 'TERMINAL-01');
  });

  test('falha da fonte não persiste sessão', () async {
    final fonte = _FonteMock();
    final sessao = _SessaoFake();
    when(() => fonte.login(any()))
        .thenAnswer((_) async => const Erro(FalhaServidor()));
    final caso = construir(fonte: fonte, sessao: sessao);
    final resultado = await caso.executar();
    expect(resultado, isA<Erro<SessaoNuvem>>());
    expect(sessao.salva, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/funcionalidades/autenticacao/caso_uso_login_nuvem_test.dart`
Expected: FAIL (CasoUsoLoginNuvem não definido).

- [ ] **Step 3: Write the use case**

```dart
// lib/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_login_nuvem.dart
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/dispositivo/info_aplicativo.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../../nucleo/utils/fuso_horario.dart';
import '../../../configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import '../../../configuracoes/dominio/repositorios/repositorio_credencial.dart';
import '../../dados/fontes_dados/fonte_autenticacao_nuvem.dart';
import '../../dados/modelos/requisicao_login_nuvem.dart';
import '../entidades/sessao_nuvem.dart';
import '../repositorios/repositorio_sessao_nuvem.dart';

class CasoUsoLoginNuvem {
  CasoUsoLoginNuvem({
    required FonteAutenticacaoNuvem fonte,
    required RepositorioConfiguracao repositorioConfiguracao,
    required RepositorioCredencial repositorioCredencial,
    required RepositorioSessaoNuvem repositorioSessao,
    required InfoAplicativo infoAplicativo,
  })  : _fonte = fonte,
        _repositorioConfiguracao = repositorioConfiguracao,
        _repositorioCredencial = repositorioCredencial,
        _repositorioSessao = repositorioSessao,
        _infoAplicativo = infoAplicativo;

  final FonteAutenticacaoNuvem _fonte;
  final RepositorioConfiguracao _repositorioConfiguracao;
  final RepositorioCredencial _repositorioCredencial;
  final RepositorioSessaoNuvem _repositorioSessao;
  final InfoAplicativo _infoAplicativo;

  Future<Resultado<SessaoNuvem>> executar() async {
    final credencial = await _repositorioCredencial.obter();
    if (credencial == null ||
        credencial.usuario.isEmpty ||
        credencial.senha.isEmpty) {
      return const Erro(
          FalhaValidacao('Configure usuário e senha nas configurações.'));
    }

    final configuracao = await _repositorioConfiguracao.obter();
    if (configuracao.urlNuvemAtiva.isEmpty) {
      return const Erro(
          FalhaValidacao('Configure a URL da nuvem nas configurações.'));
    }

    final requisicao = RequisicaoLoginNuvem(
      username: credencial.usuario,
      password: credencial.senha,
      timezone: FusoHorario.gmt(),
      nomeAplicativo: ConstantesApp.nomeAplicativoLogin,
      versaoAplicativo: await _infoAplicativo.versao(),
      dataAplicativo: ConstantesApp.dataVersaoAplicativo,
      caminhoApi: configuracao.urlBaseAtiva,
      idDispositivo: configuracao.idDispositivo,
      nomeDispositivo: configuracao.identificadorDispositivo,
    );

    final resultado = await _fonte.login(requisicao);
    if (resultado case Sucesso(:final valor)) {
      await _repositorioSessao.salvar(valor);
    }
    return resultado;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/funcionalidades/autenticacao/caso_uso_login_nuvem_test.dart`
Expected: PASS (4 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_login_nuvem.dart test/funcionalidades/autenticacao/caso_uso_login_nuvem_test.dart
git commit -m "feat: caso de uso de login na nuvem"
```

---

### Task 7: `CasoUsoGarantirSessao`

**Files:**
- Create: `lib/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_garantir_sessao.dart`
- Test: `test/funcionalidades/autenticacao/caso_uso_garantir_sessao_test.dart`

**Interfaces:**
- Consumes: `RepositorioSessaoNuvem.obter` (Task 4), `SessaoNuvem.expirada` (Task 1), `CasoUsoLoginNuvem.executar` (Task 6).
- Produces: `class CasoUsoGarantirSessao` com construtor nomeado `({RepositorioSessaoNuvem repositorioSessao, CasoUsoLoginNuvem casoUsoLogin})` e `Future<Resultado<SessaoNuvem>> executar()`.

- [ ] **Step 1: Write the failing test**

```dart
// test/funcionalidades/autenticacao/caso_uso_garantir_sessao_test.dart
import 'package:constel_pay/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_garantir_sessao.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_login_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/repositorios/repositorio_sessao_nuvem.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _LoginMock extends Mock implements CasoUsoLoginNuvem {}

class _SessaoFake implements RepositorioSessaoNuvem {
  _SessaoFake(this.salva);
  SessaoNuvem? salva;
  @override
  Future<SessaoNuvem?> obter() async => salva;
  @override
  Future<void> salvar(SessaoNuvem sessao) async => salva = sessao;
  @override
  Future<void> remover() async => salva = null;
}

SessaoNuvem _sessao(DateTime validade) => SessaoNuvem(
      token: 'jwt',
      validade: validade,
      usuario: const UsuarioSessao(nome: 'Ana', credencial: 'a@x.com', imagem: ''),
      empresa: const EmpresaSessao(id: 'e1', nome: 'Empresa'),
      dispositivo: const DispositivoSessao(id: 'd1', nome: 'Terminal'),
      estabelecimento: const EstabelecimentoSessao(id: 's1', nome: 'Loja'),
    );

void main() {
  test('sessão válida é reusada sem chamar o login', () async {
    final login = _LoginMock();
    final repo = _SessaoFake(_sessao(DateTime.now().add(const Duration(days: 1))));
    final caso =
        CasoUsoGarantirSessao(repositorioSessao: repo, casoUsoLogin: login);
    final resultado = await caso.executar();
    expect(resultado, isA<Sucesso<SessaoNuvem>>());
    verifyNever(() => login.executar());
  });

  test('sessão expirada dispara novo login', () async {
    final login = _LoginMock();
    final novaSessao = _sessao(DateTime.now().add(const Duration(days: 2)));
    when(() => login.executar()).thenAnswer((_) async => Sucesso(novaSessao));
    final repo =
        _SessaoFake(_sessao(DateTime.now().subtract(const Duration(minutes: 1))));
    final caso =
        CasoUsoGarantirSessao(repositorioSessao: repo, casoUsoLogin: login);
    final resultado = await caso.executar();
    expect(resultado, isA<Sucesso<SessaoNuvem>>());
    verify(() => login.executar()).called(1);
  });

  test('sessão ausente dispara login e propaga falha', () async {
    final login = _LoginMock();
    when(() => login.executar())
        .thenAnswer((_) async => const Erro(FalhaValidacao('sem credencial')));
    final repo = _SessaoFake(null);
    final caso =
        CasoUsoGarantirSessao(repositorioSessao: repo, casoUsoLogin: login);
    final resultado = await caso.executar();
    expect(resultado, isA<Erro<SessaoNuvem>>());
    verify(() => login.executar()).called(1);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/funcionalidades/autenticacao/caso_uso_garantir_sessao_test.dart`
Expected: FAIL (CasoUsoGarantirSessao não definido).

- [ ] **Step 3: Write the use case**

```dart
// lib/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_garantir_sessao.dart
import '../../../../nucleo/erros/resultado.dart';
import '../entidades/sessao_nuvem.dart';
import '../repositorios/repositorio_sessao_nuvem.dart';
import 'caso_uso_login_nuvem.dart';

class CasoUsoGarantirSessao {
  CasoUsoGarantirSessao({
    required RepositorioSessaoNuvem repositorioSessao,
    required CasoUsoLoginNuvem casoUsoLogin,
  })  : _repositorioSessao = repositorioSessao,
        _casoUsoLogin = casoUsoLogin;

  final RepositorioSessaoNuvem _repositorioSessao;
  final CasoUsoLoginNuvem _casoUsoLogin;

  Future<Resultado<SessaoNuvem>> executar() async {
    final sessao = await _repositorioSessao.obter();
    if (sessao != null && !sessao.expirada) {
      return Sucesso(sessao);
    }
    return _casoUsoLogin.executar();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/funcionalidades/autenticacao/caso_uso_garantir_sessao_test.dart`
Expected: PASS (3 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_garantir_sessao.dart test/funcionalidades/autenticacao/caso_uso_garantir_sessao_test.dart
git commit -m "feat: caso de uso garantir sessao da nuvem"
```

---

### Task 8: `InterceptadorAutenticacaoNuvem`

**Files:**
- Create: `lib/funcionalidades/autenticacao/dados/interceptadores/interceptador_autenticacao_nuvem.dart`
- Test: `test/funcionalidades/autenticacao/interceptador_autenticacao_nuvem_test.dart`

**Interfaces:**
- Consumes: `Dio` (do pacote dio).
- Produces: `class InterceptadorAutenticacaoNuvem extends QueuedInterceptor` com construtor nomeado `({Dio dio, String caminhoLogin, Future<String?> Function() tokenAtual, Future<bool> Function() renovarSessao})`.
- Comportamento: injeta `Authorization: Bearer <token>` em toda requisição que **não** seja o login; em resposta `401` de rota não-login e ainda não repetida, chama `renovarSessao()` uma vez e refaz a requisição com o novo token.

- [ ] **Step 1: Write the failing test**

```dart
// test/funcionalidades/autenticacao/interceptador_autenticacao_nuvem_test.dart
import 'dart:convert';

import 'package:constel_pay/funcionalidades/autenticacao/dados/interceptadores/interceptador_autenticacao_nuvem.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adaptador que devolve 401 na primeira chamada e 200 nas seguintes,
/// registrando o header Authorization recebido em cada chamada.
class _AdaptadorSequencia implements HttpClientAdapter {
  final List<String?> autorizacoes = [];
  int chamadas = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    chamadas++;
    autorizacoes.add(options.headers['Authorization'] as String?);
    final status = chamadas == 1 ? 401 : 200;
    return ResponseBody.fromString(jsonEncode({'ok': status == 200}), status,
        headers: {
          'content-type': ['application/json']
        });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('injeta Bearer e refaz a requisição uma vez no 401', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://x/api/'));
    final adaptador = _AdaptadorSequencia();
    dio.httpClientAdapter = adaptador;
    var tokens = ['antigo', 'novo'];
    var renovacoes = 0;

    dio.interceptors.add(InterceptadorAutenticacaoNuvem(
      dio: dio,
      caminhoLogin: 'auth/login',
      tokenAtual: () async => tokens.first,
      renovarSessao: () async {
        renovacoes++;
        tokens = ['novo'];
        return true;
      },
    ));

    final resposta = await dio.get<dynamic>('vendas');

    expect(resposta.statusCode, 200);
    expect(renovacoes, 1);
    expect(adaptador.chamadas, 2);
    expect(adaptador.autorizacoes[0], 'Bearer antigo');
    expect(adaptador.autorizacoes[1], 'Bearer novo');
  });

  test('não injeta token nem renova na rota de login', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://x/api/'));
    final adaptador = _AdaptadorSequencia();
    dio.httpClientAdapter = adaptador;
    var renovacoes = 0;

    dio.interceptors.add(InterceptadorAutenticacaoNuvem(
      dio: dio,
      caminhoLogin: 'auth/login',
      tokenAtual: () async => 'qualquer',
      renovarSessao: () async {
        renovacoes++;
        return true;
      },
    ));

    // O login responde 401 (credencial inválida) e NÃO deve disparar renovação.
    await expectLater(
      dio.post<dynamic>('auth/login'),
      throwsA(isA<DioException>()),
    );
    expect(renovacoes, 0);
    expect(adaptador.autorizacoes.first, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/funcionalidades/autenticacao/interceptador_autenticacao_nuvem_test.dart`
Expected: FAIL (InterceptadorAutenticacaoNuvem não definido).

- [ ] **Step 3: Write the interceptor**

```dart
// lib/funcionalidades/autenticacao/dados/interceptadores/interceptador_autenticacao_nuvem.dart
import 'package:dio/dio.dart';

/// Injeta o token da sessão de nuvem e, ao receber 401, tenta um único
/// re-login antes de repetir a requisição original. A própria rota de login
/// é isenta (não recebe token nem dispara renovação), evitando recursão.
class InterceptadorAutenticacaoNuvem extends QueuedInterceptor {
  InterceptadorAutenticacaoNuvem({
    required Dio dio,
    required String caminhoLogin,
    required Future<String?> Function() tokenAtual,
    required Future<bool> Function() renovarSessao,
  })  : _dio = dio,
        _caminhoLogin = caminhoLogin,
        _tokenAtual = tokenAtual,
        _renovarSessao = renovarSessao;

  final Dio _dio;
  final String _caminhoLogin;
  final Future<String?> Function() _tokenAtual;
  final Future<bool> Function() _renovarSessao;

  bool _ehLogin(String caminho) => caminho.contains(_caminhoLogin);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_ehLogin(options.path)) {
      final token = await _tokenAtual();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final jaRenovou = options.extra['auth_retry'] == true;
    if (err.response?.statusCode == 401 &&
        !jaRenovou &&
        !_ehLogin(options.path)) {
      final renovado = await _renovarSessao();
      if (renovado) {
        options.extra['auth_retry'] = true;
        final token = await _tokenAtual();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        try {
          final resposta = await _dio.fetch<dynamic>(options);
          return handler.resolve(resposta);
        } on DioException catch (excecao) {
          return handler.next(excecao);
        }
      }
    }
    handler.next(err);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/funcionalidades/autenticacao/interceptador_autenticacao_nuvem_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/funcionalidades/autenticacao/dados/interceptadores/interceptador_autenticacao_nuvem.dart test/funcionalidades/autenticacao/interceptador_autenticacao_nuvem_test.dart
git commit -m "feat: interceptor de autenticacao da nuvem com retry no 401"
```

---

### Task 9: Integração (injeção + cliente de nuvem + splash)

**Files:**
- Modify: `lib/aplicativo/injecao.dart`
- Modify: `lib/funcionalidades/splash/apresentacao/paginas/pagina_splash.dart`

**Interfaces:**
- Consumes: todos os tipos das Tasks 1–8 e os providers existentes `provedorClienteApiNuvem`, `provedorInfoAplicativo`, `provedorRepositorioConfiguracao`, `provedorRepositorioCredencial`, `provedorArmazenamentoSeguro`.
- Produces: providers `provedorRepositorioSessaoNuvem`, `provedorFonteAutenticacaoNuvem`, `provedorCasoUsoLoginNuvem`, `provedorCasoUsoGarantirSessao`; `provedorClienteApiNuvem` passa a montar o `Dio` com o interceptor de autenticação.

- [ ] **Step 1: Adicionar imports em `injecao.dart`**

No topo de `lib/aplicativo/injecao.dart`, adicione (mantendo a ordem alfabética existente dos imports de `funcionalidades`):

```dart
import 'package:dio/dio.dart';
```

junto aos imports de features:

```dart
import '../funcionalidades/autenticacao/dados/fontes_dados/fonte_autenticacao_nuvem.dart';
import '../funcionalidades/autenticacao/dados/interceptadores/interceptador_autenticacao_nuvem.dart';
import '../funcionalidades/autenticacao/dados/repositorios/repositorio_sessao_nuvem_impl.dart';
import '../funcionalidades/autenticacao/dominio/casos_uso/caso_uso_garantir_sessao.dart';
import '../funcionalidades/autenticacao/dominio/casos_uso/caso_uso_login_nuvem.dart';
import '../funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart';
import '../funcionalidades/autenticacao/dominio/repositorios/repositorio_sessao_nuvem.dart';
```

e, junto aos imports de `nucleo` (o arquivo ainda não importa `resultado.dart`, necessário para `Sucesso<SessaoNuvem>`):

```dart
import '../nucleo/erros/resultado.dart';
```

- [ ] **Step 2: Substituir o `provedorClienteApiNuvem` e adicionar os providers de auth**

Localize o bloco atual em `injecao.dart`:

```dart
// Cliente da API na nuvem (login) — usa a URL de nuvem do ambiente ativo.
final provedorClienteApiNuvem = Provider<ClienteApi>(
  (ref) => ClienteApi(
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    seletorBase: (configuracao) => configuracao.urlNuvemAtiva,
  ),
);
```

Substitua por:

```dart
// Repositório da sessão de nuvem (token + dados do login) no secure storage.
final provedorRepositorioSessaoNuvem = Provider<RepositorioSessaoNuvem>(
  (ref) => RepositorioSessaoNuvemImpl(ref.watch(provedorArmazenamentoSeguro)),
);

// Cliente da API na nuvem (login/envio de vendas) — usa a URL de nuvem do
// ambiente ativo e injeta o token da sessão, com re-login automático no 401.
final provedorClienteApiNuvem = Provider<ClienteApi>((ref) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptadorAutenticacaoNuvem(
      dio: dio,
      caminhoLogin: ConstantesApp.caminhoLoginNuvem,
      tokenAtual: () async =>
          (await ref.read(provedorRepositorioSessaoNuvem).obter())?.token,
      renovarSessao: () async {
        final resultado = await ref.read(provedorCasoUsoLoginNuvem).executar();
        return resultado is Sucesso<SessaoNuvem>;
      },
    ),
  );
  return ClienteApi(
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    seletorBase: (configuracao) => configuracao.urlNuvemAtiva,
    dio: dio,
  );
});

final provedorFonteAutenticacaoNuvem = Provider<FonteAutenticacaoNuvem>(
  (ref) => FonteAutenticacaoNuvem(ref.watch(provedorClienteApiNuvem)),
);

final provedorCasoUsoLoginNuvem = Provider<CasoUsoLoginNuvem>(
  (ref) => CasoUsoLoginNuvem(
    fonte: ref.watch(provedorFonteAutenticacaoNuvem),
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    repositorioCredencial: ref.watch(provedorRepositorioCredencial),
    repositorioSessao: ref.watch(provedorRepositorioSessaoNuvem),
    infoAplicativo: ref.watch(provedorInfoAplicativo),
  ),
);

final provedorCasoUsoGarantirSessao = Provider<CasoUsoGarantirSessao>(
  (ref) => CasoUsoGarantirSessao(
    repositorioSessao: ref.watch(provedorRepositorioSessaoNuvem),
    casoUsoLogin: ref.watch(provedorCasoUsoLoginNuvem),
  ),
);
```

> Observação: `Sucesso<SessaoNuvem>` depende do import `../nucleo/erros/resultado.dart` adicionado no Step 1; `ConstantesApp` já é importado no arquivo (`../nucleo/constantes/constantes_app.dart`).

- [ ] **Step 3: Rodar a análise estática do `injecao.dart`**

Run: `flutter analyze lib/aplicativo/injecao.dart`
Expected: No issues found. (Se acusar import faltando de `resultado.dart`, adicione-o e rode de novo.)

- [ ] **Step 4: Religar o login em segundo plano no splash**

Em `lib/funcionalidades/splash/apresentacao/paginas/pagina_splash.dart`:

1. Reponha o import do registrador logo após o import de `constantes_app.dart`:

```dart
import '../../../../nucleo/utils/registrador.dart';
```

2. No `initState`, após o bloco `addPostFrameCallback(...)` e antes do fechamento do método, acrescente a chamada:

```dart
    _autenticarEmSegundoPlano();
```

3. Adicione o método logo após `initState` (antes de `dispose`):

```dart
  /// Login automático na nuvem sem bloquear a navegação. Falhas apenas
  /// registram no log; a URL/credencial inválida não dispara chamada de rede.
  void _autenticarEmSegundoPlano() {
    unawaited(
      ref.read(provedorCasoUsoGarantirSessao).executar().then(
            (resultado) => resultado.quando(
              sucesso: (_) {},
              erro: (falha) =>
                  registrador.w('Login automático: ${falha.mensagem}'),
            ),
          ),
    );
  }
```

> `unawaited` vem de `dart:async` (já importado no arquivo por causa do `Timer`). `provedorCasoUsoGarantirSessao` já está acessível via o import existente `../../../../aplicativo/injecao.dart`.

- [ ] **Step 5: Rodar análise estática completa**

Run: `flutter analyze`
Expected: No issues found!

- [ ] **Step 6: Rodar toda a suíte de testes**

Run: `flutter test`
Expected: All tests passed! (inclui os novos testes da feature de autenticação e os já existentes).

- [ ] **Step 7: Commit**

```bash
git add lib/aplicativo/injecao.dart lib/funcionalidades/splash/apresentacao/paginas/pagina_splash.dart
git commit -m "feat: integra autenticacao de nuvem na injecao e login silencioso no splash"
```

---

## Notas de implementação

- **Desvio consciente da spec:** a spec previa `resposta_login_nuvem.dart` como modelo e um modelo de storage separado. Para evitar duplicação, `SessaoNuvem` (entidade) carrega `fromJson/toJson` e é persistida diretamente; `RespostaLoginNuvem` virou um mapper puro (sem estado) que converte a resposta da API na entidade. Comportamento e campos permanecem os da spec.
- **`aplicativo.data`:** usa `ConstantesApp.dataVersaoAplicativo` (já existente). Ajuste seu valor a cada release. A spec mencionava `--dart-define=BUILD_DATE`; ficou fora do escopo por já existir a constante — pode ser adicionado depois sem quebrar nada.
- **URL de nuvem:** deve terminar com `/` para o `dio` concatenar `auth/login` corretamente. Documentar na aba Comunicação, se necessário, em tarefa futura.
```
