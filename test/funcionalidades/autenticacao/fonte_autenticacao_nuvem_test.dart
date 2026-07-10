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

// JWT real capturado do log (exp = 1783812111 -> 2026-07-11T23:21:51Z).
const _token =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c3VhcmlvIjp7ImlkIjoiODVhODNhZmItM2M4MS00Y2RkLWE2YWEtMTU3NTg1NjRkODQxIiwibm9tZSI6IlllcmljaCBTYWxlcyIsImltYWdlbSI6Imh0dHBzOi8vczMuYW1hem9uYXdzLmNvbS9hdGxhcy5jb25zdGVsLmNsb3VkL2ZpbGVzL2RkZmU0NzliLTliMTEtNGVhMi04ZTMwLWFjZDk4NWRjMmZmOC5qcGcifSwiZW1wcmVzYSI6eyJpZCI6IjBkMTU0MmUxLTcxZmQtNDBmOS1iMWY3LWFlMDBhYjA4NjI2YyIsIm5vbWUiOiJEdXJhbmdvIEJ1aWxkZXIncyJ9LCJkaXNwb3NpdGl2byI6eyJpZCI6ImJlN2I1YjNmLTJjZjEtNGU3OC1iYjAyLWZkY2RkYjcyNzY4YiIsIm5vbWUiOiJOQllFUklDSCBDQUlYQSJ9LCJlc3RhYmVsZWNpbWVudG8iOnsiaWQiOiJmZTViNDIyZS1iZmIyLTQzMjgtODNkNC03ODc2MDIwYWNlZjkiLCJub21lIjoiRGlvbsOtc2lvIFRvcnJlcyJ9LCJmdXNvIjoiR01ULTAzIiwiaWF0IjoxNzgzNjM5MzExLCJleHAiOjE3ODM4MTIxMTF9.50n8zdd69zfxTWBgflX23w0uUbe0uyReP3C_efUY3xw';

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
      'token': _token,
      'usuario': {'nome': 'Ana', 'imagem': ''},
      'empresa': {'id': 'e1', 'nome': 'Empresa'},
      'dispositivo': {'id': 'd1', 'nome': 'Terminal'},
      'estabelecimento': {'id': 's1', 'nome': 'Loja'},
      'fuso': 'GMT-03',
    }, 201)));
    final resultado = await fonte.login(_requisicao);
    expect(resultado, isA<Sucesso<SessaoNuvem>>());
    expect((resultado as Sucesso<SessaoNuvem>).valor.token, _token);
  });

  test('login com erro HTTP devolve Erro', () async {
    final fonte = FonteAutenticacaoNuvem(
        _cliente(_AdaptadorResposta(const {'mensagem': 'nao autorizado'}, 401)));
    final resultado = await fonte.login(_requisicao);
    expect(resultado, isA<Erro<SessaoNuvem>>());
    expect((resultado as Erro<SessaoNuvem>).falha, isA<Falha>());
  });
}
