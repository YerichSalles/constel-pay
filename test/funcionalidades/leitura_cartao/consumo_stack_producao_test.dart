import 'dart:convert';

import 'package:constel_pay/funcionalidades/autenticacao/dados/interceptadores/interceptador_autenticacao_nuvem.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_consumo_atendimento.dart';
import 'package:constel_pay/nucleo/configuracao/cliente_api.dart';
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

/// Devolve 401 na primeira chamada e 200 nas seguintes, registrando cada
/// requisição que chega ao transporte.
class _Adaptador401Depois200 implements HttpClientAdapter {
  final List<RequestOptions> requisicoes = [];
  int _chamadas = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    requisicoes.add(options);
    _chamadas++;
    if (_chamadas == 1) {
      return ResponseBody.fromString(
          jsonEncode({'message': 'token expirado'}), 401,
          headers: {
            'content-type': ['application/json']
          });
    }
    return ResponseBody.fromString(jsonEncode(const []), 200, headers: {
      'content-type': ['application/json']
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stack real (auth + retry de 401) preserva a query da consulta',
      () async {
    final adaptador = _Adaptador401Depois200();
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal(
        urlNuvemHomologacao: 'https://localhost:3001/api/'));
    final dio = Dio()..httpClientAdapter = adaptador;
    dio.interceptors.add(InterceptadorAutenticacaoNuvem(
      dio: dio,
      caminhoLogin: 'auth/login',
      tokenAtual: () async => 'token-fake',
      renovarSessao: () async => true,
    ));
    final fonte = FonteConsumoAtendimento(ClienteApi(
      repositorioConfiguracao: repositorio,
      seletorBase: (c) => c.urlNuvemAtiva,
      dio: dio,
    ));

    await fonte.consultar(referencia: '502');

    expect(adaptador.requisicoes.length, 2, reason: 'deve ter havido retry');
    for (final requisicao in adaptador.requisicoes) {
      expect(requisicao.uri.queryParameters['referencia'], '502',
          reason: 'query perdida em ${requisicao.uri}');
    }
  });
}
