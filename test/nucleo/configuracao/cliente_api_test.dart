import 'dart:convert';

import 'package:constel_pay/funcionalidades/configuracoes/dominio/casos_uso/caso_uso_testar_conexao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/nucleo/configuracao/cliente_api.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RepositorioFake implements RepositorioConfiguracao {
  _RepositorioFake(this.configuracao);

  ConfiguracaoTerminal configuracao;

  @override
  Future<ConfiguracaoTerminal> obter() async => configuracao;

  @override
  Future<void> salvar(ConfiguracaoTerminal nova) async => configuracao = nova;
}

class _AdaptadorFake implements HttpClientAdapter {
  int chamadas = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    chamadas++;
    return ResponseBody.fromString(jsonEncode({'ok': true}), 200, headers: {
      'content-type': ['application/json']
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mapearFalha traduz os tipos de erro do Dio', () {
    final opcoes = RequestOptions(path: '/');
    expect(
        ClienteApi.mapearFalha(DioException(
            requestOptions: opcoes, type: DioExceptionType.connectionTimeout)),
        isA<FalhaTimeout>());
    expect(
        ClienteApi.mapearFalha(DioException(
            requestOptions: opcoes, type: DioExceptionType.receiveTimeout)),
        isA<FalhaTimeout>());
    expect(
        ClienteApi.mapearFalha(DioException(
            requestOptions: opcoes, type: DioExceptionType.connectionError)),
        isA<FalhaRede>());
    expect(
        ClienteApi.mapearFalha(DioException(
            requestOptions: opcoes, type: DioExceptionType.badResponse)),
        isA<FalhaServidor>());
    expect(
        ClienteApi.mapearFalha(DioException(
            requestOptions: opcoes, type: DioExceptionType.cancel)),
        isA<FalhaValidacao>());
  });

  test('get usa a URL base do ambiente ativo', () async {
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal(
        urlBaseHomologacao: 'https://homolog.constel.dev'));
    final dio = Dio();
    final adaptador = _AdaptadorFake();
    dio.httpClientAdapter = adaptador;
    final cliente = ClienteApi(repositorioConfiguracao: repositorio, dio: dio);
    final resultado = await cliente.get('/');
    expect(resultado, isA<Sucesso<Response<dynamic>>>());
    expect(adaptador.chamadas, 1);
  });

  test('get sem URL configurada devolve FalhaValidacao', () async {
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal());
    final cliente =
        ClienteApi(repositorioConfiguracao: repositorio, dio: Dio());
    final resultado = await cliente.get('/');
    expect(resultado, isA<Erro<Response<dynamic>>>());
    expect((resultado as Erro<Response<dynamic>>).falha, isA<FalhaValidacao>());
  });

  test('testar conexao grava ultima sincronizacao no sucesso', () async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal(
        urlBaseHomologacao: 'https://homolog.constel.dev'));
    final dio = Dio()..httpClientAdapter = _AdaptadorFake();
    final casoUso = CasoUsoTestarConexao(
      clienteApi: ClienteApi(repositorioConfiguracao: repositorio, dio: dio),
      repositorioConfiguracao: repositorio,
      preferencias: preferencias,
    );
    final resultado = await casoUso.executar();
    expect(resultado, isA<Sucesso<DateTime>>());
    expect(preferencias.getString('ultima_sincronizacao'), isNotNull);
  });

  test(
      'testar conexao com URL invalida devolve FalhaValidacao sem chamar a rede',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = _RepositorioFake(
        const ConfiguracaoTerminal(urlBaseHomologacao: 'nao-e-url'));
    final adaptador = _AdaptadorFake();
    final dio = Dio()..httpClientAdapter = adaptador;
    final casoUso = CasoUsoTestarConexao(
      clienteApi: ClienteApi(repositorioConfiguracao: repositorio, dio: dio),
      repositorioConfiguracao: repositorio,
      preferencias: preferencias,
    );
    final resultado = await casoUso.executar();
    expect(resultado, isA<Erro<DateTime>>());
    expect(adaptador.chamadas, 0);
  });
}
