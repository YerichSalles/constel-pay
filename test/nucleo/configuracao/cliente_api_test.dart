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
  _AdaptadorFake([this.status = 200]);

  final int status;
  int chamadas = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    chamadas++;
    return ResponseBody.fromString(jsonEncode({'ok': true}), status, headers: {
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

  test('mapearFalha traduz socket e TLS marcados como unknown em FalhaRede',
      () {
    final opcoes = RequestOptions(path: '/');
    final tls = ClienteApi.mapearFalha(DioException(
        requestOptions: opcoes,
        type: DioExceptionType.unknown,
        error: Exception(
            'HandshakeException: Connection terminated during handshake')));
    expect(tls, isA<FalhaRede>());
    expect(tls.mensagem, contains('certificado'));

    final socket = ClienteApi.mapearFalha(DioException(
        requestOptions: opcoes,
        type: DioExceptionType.unknown,
        error: Exception('SocketException: Connection refused')));
    expect(socket, isA<FalhaRede>());
    expect(socket.mensagem, contains('comunicação com a API'));

    expect(
        ClienteApi.mapearFalha(DioException(
            requestOptions: opcoes,
            type: DioExceptionType.unknown,
            error: Exception('outro erro qualquer'))),
        isA<FalhaDesconhecida>());
  });

  test('mapearFalha traduz 401 e 403 em FalhaNaoAutorizado', () {
    final opcoes = RequestOptions(path: '/');
    for (final status in [401, 403]) {
      expect(
          ClienteApi.mapearFalha(DioException(
              requestOptions: opcoes,
              type: DioExceptionType.badResponse,
              response: Response(requestOptions: opcoes, statusCode: status))),
          isA<FalhaNaoAutorizado>());
    }
    expect(
        ClienteApi.mapearFalha(DioException(
            requestOptions: opcoes,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: opcoes, statusCode: 500))),
        isA<FalhaServidor>());
  });

  test('mapearFalha aproveita a mensagem do corpo em erros de validação', () {
    final opcoes = RequestOptions(path: '/');
    final falha = ClienteApi.mapearFalha(DioException(
        requestOptions: opcoes,
        type: DioExceptionType.badResponse,
        response: Response(
            requestOptions: opcoes,
            statusCode: 422,
            data: {'message': 'aplicativo não registrado'})));
    expect(falha, isA<FalhaServidor>());
    expect(falha.mensagem, contains('aplicativo não registrado'));

    final semCorpo = ClienteApi.mapearFalha(DioException(
        requestOptions: opcoes,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: opcoes, statusCode: 422)));
    expect(semCorpo.mensagem, 'Erro ao comunicar com o servidor.');
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

  test('construtor preserva adaptador customizado (fakes de teste)', () {
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal());
    final adaptador = _AdaptadorFake();
    final dio = Dio()..httpClientAdapter = adaptador;
    ClienteApi(repositorioConfiguracao: repositorio, dio: dio);
    expect(dio.httpClientAdapter, same(adaptador));
  });

  test('get sem URL configurada devolve FalhaValidacao', () async {
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal());
    final cliente =
        ClienteApi(repositorioConfiguracao: repositorio, dio: Dio());
    final resultado = await cliente.get('/');
    expect(resultado, isA<Erro<Response<dynamic>>>());
    expect((resultado as Erro<Response<dynamic>>).falha, isA<FalhaValidacao>());
  });

  CasoUsoTestarConexao casoUsoTestarConexao({
    required _RepositorioFake repositorio,
    required SharedPreferences preferencias,
    required Dio dioLoja,
    required Dio dioNuvem,
  }) =>
      CasoUsoTestarConexao(
        clienteLoja: ClienteApi(
            repositorioConfiguracao: repositorio,
            seletorBase: (c) => c.urlBaseAtiva,
            dio: dioLoja),
        clienteNuvem: ClienteApi(
            repositorioConfiguracao: repositorio,
            seletorBase: (c) => c.urlNuvemAtiva,
            dio: dioNuvem),
        repositorioConfiguracao: repositorio,
        preferencias: preferencias,
      );

  test('testar conexao grava ultima sincronizacao no sucesso', () async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal(
      urlBaseHomologacao: 'https://homolog.constel.dev',
      urlNuvemHomologacao: 'https://nuvem.constel.dev',
    ));
    final resultado = await casoUsoTestarConexao(
      repositorio: repositorio,
      preferencias: preferencias,
      dioLoja: Dio()..httpClientAdapter = _AdaptadorFake(),
      dioNuvem: Dio()..httpClientAdapter = _AdaptadorFake(),
    ).executar();
    expect(resultado, isA<Sucesso<DateTime>>());
    expect(preferencias.getString('ultima_sincronizacao'), isNotNull);
  });

  test('testar conexao trata 404 como servidor alcançável', () async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal(
      urlBaseHomologacao: 'https://localhost:3001',
      urlNuvemHomologacao: 'https://nuvem.constel.dev',
    ));
    final resultado = await casoUsoTestarConexao(
      repositorio: repositorio,
      preferencias: preferencias,
      dioLoja: Dio()..httpClientAdapter = _AdaptadorFake(404),
      dioNuvem: Dio()..httpClientAdapter = _AdaptadorFake(404),
    ).executar();
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
    final resultado = await casoUsoTestarConexao(
      repositorio: repositorio,
      preferencias: preferencias,
      dioLoja: Dio()..httpClientAdapter = adaptador,
      dioNuvem: Dio()..httpClientAdapter = adaptador,
    ).executar();
    expect(resultado, isA<Erro<DateTime>>());
    expect(adaptador.chamadas, 0);
  });

  test('testar conexao reprova quando só a nuvem falha', () async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = _RepositorioFake(const ConfiguracaoTerminal(
      urlBaseHomologacao: 'https://localhost:3001',
      urlNuvemHomologacao: 'nao-e-url',
    ));
    final resultado = await casoUsoTestarConexao(
      repositorio: repositorio,
      preferencias: preferencias,
      dioLoja: Dio()..httpClientAdapter = _AdaptadorFake(),
      dioNuvem: Dio()..httpClientAdapter = _AdaptadorFake(),
    ).executar();
    expect(resultado, isA<Erro<DateTime>>());
    expect((resultado as Erro<DateTime>).falha.mensagem, contains('Nuvem'));
  });
}
