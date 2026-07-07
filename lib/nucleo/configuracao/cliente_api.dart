import 'package:dio/dio.dart';

import '../../funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import '../erros/falha.dart';
import '../erros/resultado.dart';
import '../utils/registrador.dart';

class ClienteApi {
  ClienteApi(
      {required RepositorioConfiguracao repositorioConfiguracao, Dio? dio})
      : _repositorioConfiguracao = repositorioConfiguracao,
        _dio = dio ?? Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (opcoes, manipulador) async {
          final configuracao = await _repositorioConfiguracao.obter();
          final base = configuracao.urlBaseAtiva;
          if (base.isEmpty) {
            return manipulador.reject(
              DioException(
                  requestOptions: opcoes, type: DioExceptionType.cancel),
            );
          }
          opcoes.baseUrl = base;
          // Log seguro: método e caminho apenas — nunca headers nem corpo.
          registrador.i('HTTP ${opcoes.method} ${opcoes.path}');
          manipulador.next(opcoes);
        },
        onError: (erro, manipulador) {
          registrador
              .w('HTTP erro ${erro.type.name} em ${erro.requestOptions.path}');
          manipulador.next(erro);
        },
      ),
    );
  }

  final Dio _dio;
  final RepositorioConfiguracao _repositorioConfiguracao;

  Future<Resultado<Response<dynamic>>> get(String caminho) async {
    try {
      return Sucesso(await _dio.get<dynamic>(caminho));
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
        DioExceptionType.badResponse => const FalhaServidor(),
        DioExceptionType.cancel => const FalhaValidacao(
            'Configure a URL do ambiente nas configurações.'),
        _ => const FalhaDesconhecida(),
      };
}
