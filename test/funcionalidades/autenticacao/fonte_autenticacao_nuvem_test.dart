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
