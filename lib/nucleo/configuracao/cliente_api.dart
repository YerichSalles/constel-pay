import 'package:dio/dio.dart';

import '../../funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import '../../funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import '../erros/falha.dart';
import '../erros/resultado.dart';
import '../utils/registrador.dart';

/// Seleciona qual base URL usar a partir da configuração do terminal.
/// Permite reaproveitar o mesmo cliente para a API local e a API na nuvem.
typedef SeletorBaseUrl = String Function(ConfiguracaoTerminal configuracao);

class ClienteApi {
  ClienteApi({
    required RepositorioConfiguracao repositorioConfiguracao,
    Dio? dio,
    SeletorBaseUrl? seletorBase,
  })  : _repositorioConfiguracao = repositorioConfiguracao,
        _seletorBase = seletorBase ?? ((c) => c.urlBaseAtiva),
        _dio = dio ?? Dio() {
    // A confiança em qualquer certificado é aplicada globalmente no início do
    // app (instalarConfiancaTlsGlobal), cobrindo este Dio e o Image.network.
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (opcoes, manipulador) async {
          final configuracao = await _repositorioConfiguracao.obter();
          final base = _seletorBase(configuracao);
          if (base.isEmpty) {
            return manipulador.reject(
              DioException(
                  requestOptions: opcoes, type: DioExceptionType.cancel),
            );
          }
          opcoes.baseUrl = base;
          // Log seguro: método e URL apenas — nunca headers nem corpo.
          registrador.i('HTTP ${opcoes.method} ${opcoes.uri}');
          manipulador.next(opcoes);
        },
        onError: (erro, manipulador) {
          final status = erro.response?.statusCode;
          registrador.w('HTTP erro ${erro.type.name}'
              '${status != null ? ' ($status)' : ''}'
              ' em ${erro.requestOptions.uri}');
          manipulador.next(erro);
        },
      ),
    );
  }

  final Dio _dio;
  final RepositorioConfiguracao _repositorioConfiguracao;
  final SeletorBaseUrl _seletorBase;

  Future<Resultado<Response<dynamic>>> get(
    String caminho, {
    Map<String, dynamic>? parametros,
  }) async {
    try {
      return Sucesso(
          await _dio.get<dynamic>(caminho, queryParameters: parametros));
    } on DioException catch (excecao) {
      return Erro(mapearFalha(excecao));
    }
  }

  Future<Resultado<Response<dynamic>>> post(
    String caminho, {
    Object? dados,
    String? chaveIdempotencia,
  }) async {
    try {
      return Sucesso(
        await _dio.post<dynamic>(
          caminho,
          data: dados,
          options: Options(
            headers: {
              if (chaveIdempotencia != null)
                'Idempotency-Key': chaveIdempotencia
            },
          ),
        ),
      );
    } on DioException catch (excecao) {
      return Erro(mapearFalha(excecao));
    }
  }

  static Falha mapearFalha(DioException excecao) => switch (excecao.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          const FalhaTimeout(),
        DioExceptionType.connectionError => const FalhaRede(),
        DioExceptionType.badResponse
            when excecao.response?.statusCode == 401 ||
                excecao.response?.statusCode == 403 =>
          const FalhaNaoAutorizado(),
        DioExceptionType.badResponse => switch (_mensagemServidor(excecao)) {
            final mensagem? => FalhaServidor('Servidor: $mensagem'),
            null => const FalhaServidor(),
          },
        DioExceptionType.cancel => const FalhaValidacao(
            'Configure a URL do ambiente nas configurações.'),
        DioExceptionType.unknown when _falhaDeTls(excecao) => const FalhaRede(
            'Falha de segurança na conexão. Verifique se a URL usa http:// '
            'ou https:// conforme o servidor e se o certificado é confiável.'),
        DioExceptionType.unknown when _falhaDeSocket(excecao) =>
          const FalhaRede(),
        _ => const FalhaDesconhecida(),
      };

  // O Dio marca falhas de socket/TLS fora da fase de conexão como `unknown`
  // (ex.: HandshakeException ao usar https contra um servidor http). São
  // problemas de comunicação com a API, não erros internos do app.
  // Detecção por nome para não importar dart:io (quebraria o build web).
  static bool _falhaDeTls(DioException excecao) =>
      '${excecao.error}'.contains('HandshakeException');

  static bool _falhaDeSocket(DioException excecao) =>
      '${excecao.error}'.contains('SocketException');

  /// Extrai a mensagem de erro do corpo da resposta (campo `message`),
  /// quando o servidor devolve JSON. Ajuda o operador a ver o motivo real
  /// de recusas de validação (ex.: 422) sem expor headers nem payload.
  static String? _mensagemServidor(DioException excecao) {
    final dados = excecao.response?.data;
    if (dados is! Map) return null;
    final mensagem = dados['message'];
    final texto = switch (mensagem) {
      final String valor when valor.isNotEmpty => valor,
      final List valores when valores.isNotEmpty => valores.join(' · '),
      _ => null,
    };
    if (texto == null) return null;
    return texto.length > 160 ? '${texto.substring(0, 160)}…' : texto;
  }
}
