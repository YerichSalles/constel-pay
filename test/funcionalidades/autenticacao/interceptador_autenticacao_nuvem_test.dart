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
