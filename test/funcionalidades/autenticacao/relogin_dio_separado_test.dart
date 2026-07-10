// test/funcionalidades/autenticacao/relogin_dio_separado_test.dart
import 'dart:convert';

import 'package:constel_pay/funcionalidades/autenticacao/dados/interceptadores/interceptador_autenticacao_nuvem.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adaptador que sempre responde 401.
class _Sempre401 implements HttpClientAdapter {
  int chamadas = 0;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    chamadas++;
    return ResponseBody.fromString(
      jsonEncode({'erro': 'nao autorizado'}),
      401,
      headers: {
        'content-type': ['application/json']
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('re-login em Dio separado nao trava a requisicao autenticada no 401',
      () async {
    final adaptadorAuth = _Sempre401();
    final adaptadorLogin = _Sempre401();
    final dioAuth = Dio(BaseOptions(baseUrl: 'http://x/api/'))
      ..httpClientAdapter = adaptadorAuth;
    final dioLogin = Dio(BaseOptions(baseUrl: 'http://x/api/'))
      ..httpClientAdapter = adaptadorLogin; // SEPARADO do dioAuth

    dioAuth.interceptors.add(InterceptadorAutenticacaoNuvem(
      dio: dioAuth,
      caminhoLogin: 'auth/login',
      tokenAtual: () async => 'tok',
      renovarSessao: () async {
        // re-login roda no Dio de login SEPARADO; falha (401) -> retorna false
        try {
          await dioLogin.post<dynamic>('auth/login');
          return true;
        } on DioException {
          return false;
        }
      },
    ));

    await expectLater(
      dioAuth.get<dynamic>('vendas').timeout(const Duration(seconds: 3)),
      throwsA(isA<DioException>()),
    );
  });
}
