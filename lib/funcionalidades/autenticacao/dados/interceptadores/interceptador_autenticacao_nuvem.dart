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
    try {
      if (!_ehLogin(options.path)) {
        final token = await _tokenAtual();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (_) {
      // Falha ao obter o token não deve travar a requisição: segue sem header.
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
      try {
        final renovado = await _renovarSessao();
        if (renovado) {
          options.extra['auth_retry'] = true;
          final token = await _tokenAtual();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final resposta = await _dio.fetch<dynamic>(options);
          return handler.resolve(resposta);
        }
      } on DioException catch (excecao) {
        return handler.next(excecao);
      } catch (_) {
        // Qualquer falha na renovação propaga o erro original — nunca trava.
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}
