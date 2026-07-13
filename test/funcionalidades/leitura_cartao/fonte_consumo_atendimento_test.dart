import 'dart:convert';

import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_consumo_atendimento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/atendimento.dart';
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
  final Object corpo;
  final int status;
  RequestOptions? ultimaRequisicao;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    ultimaRequisicao = options;
    return ResponseBody.fromString(jsonEncode(corpo), status, headers: {
      'content-type': ['application/json']
    });
  }

  @override
  void close({bool force = false}) {}
}

FonteConsumoAtendimento _fonte(HttpClientAdapter adaptador) {
  final repositorio = _RepositorioFake(const ConfiguracaoTerminal(
      urlBaseHomologacao: 'https://localhost:3001/api/'));
  final dio = Dio()..httpClientAdapter = adaptador;
  return FonteConsumoAtendimento(
      ClienteApi(repositorioConfiguracao: repositorio, dio: dio));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('200 com array devolve Sucesso com a lista parseada', () async {
    final adaptador = _AdaptadorResposta([
      {
        'id': 'a1',
        'nome': 'Mesa 01',
        'referencia': '01',
        'saldo': 11,
        'sessao': {'id': 's1', 'codigo': '0003449'},
      }
    ], 200);
    final resultado = await _fonte(adaptador).consultar(referencia: '01');
    expect(resultado, isA<Sucesso<List<Atendimento>>>());
    final lista = (resultado as Sucesso<List<Atendimento>>).valor;
    expect(lista.length, 1);
    expect(lista.first.nome, 'Mesa 01');
    expect(lista.first.saldoCentavos, 1100);
  });

  test('envia classe=1600, situacao=20 e a referência como query params',
      () async {
    final adaptador = _AdaptadorResposta(const [], 200);
    await _fonte(adaptador).consultar(referencia: '07');
    final requisicao = adaptador.ultimaRequisicao!;
    expect(requisicao.uri.path, endsWith('venda/atendimento/colecao'));
    expect(requisicao.queryParameters, {
      'classe': 1600,
      'situacao': 20,
      'referencia': '07',
    });
  });

  test('200 com array vazio devolve Sucesso vazio (sem consumo)', () async {
    final resultado = await _fonte(_AdaptadorResposta(const [], 200))
        .consultar(referencia: '01');
    expect(resultado, isA<Sucesso<List<Atendimento>>>());
    expect((resultado as Sucesso<List<Atendimento>>).valor, isEmpty);
  });

  test('erro HTTP devolve Erro mapeado', () async {
    final resultado = await _fonte(
            _AdaptadorResposta(const {'message': 'nao autorizado'}, 401))
        .consultar(referencia: '01');
    expect(resultado, isA<Erro<List<Atendimento>>>());
    expect((resultado as Erro<List<Atendimento>>).falha,
        isA<FalhaNaoAutorizado>());
  });

  test('corpo inesperado (não-lista) devolve FalhaServidor', () async {
    final resultado = await _fonte(_AdaptadorResposta(const {'ok': true}, 200))
        .consultar(referencia: '01');
    expect(resultado, isA<Erro<List<Atendimento>>>());
    expect((resultado as Erro<List<Atendimento>>).falha, isA<FalhaServidor>());
  });
}
