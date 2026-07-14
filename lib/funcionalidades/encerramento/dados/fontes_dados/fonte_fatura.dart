import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/entidades/fatura_referencia.dart';
import '../modelos/resposta_fatura.dart';

/// Fatura na API da NUVEM (`movimento/fatura`): criação (POST) e consulta por
/// sessão (GET, usada na reconciliação de timeouts). O identificador vai
/// também no header `Idempotency-Key`.
///
/// Corpo ilegível NUNCA vira `FalhaServidor`: um 2xx com formato inesperado
/// significa que a operação pode ter sido aplicada — o caso de uso trata
/// `FalhaDesconhecida` como incerteza e reconcilia, em vez de descartar a
/// pendência e arriscar fatura duplicada.
class FonteFatura {
  FonteFatura(this._clienteApi);

  final ClienteApi _clienteApi;

  /// Envia o payload JÁ MONTADO (e possivelmente persistido) da fatura.
  /// Recebe o mapa cru para que um retry reenvie exatamente o que foi salvo.
  Future<Resultado<FaturaReferencia>> criar(
    Map<String, dynamic> faturaJson, {
    required String identificador,
  }) async {
    final resposta = await _clienteApi.post(
      ConstantesApp.caminhoFatura,
      dados: faturaJson,
      chaveIdempotencia: identificador,
    );
    try {
      return switch (resposta) {
        Sucesso(:final valor) => Sucesso(
            RespostaFatura.paraReferencia(valor.data as Map<String, dynamic>)),
        Erro(:final falha) => Erro(falha),
      };
    } catch (_) {
      return const Erro(FalhaDesconhecida(
          'A fatura pode ter sido criada, mas a resposta veio ilegível.'));
    }
  }

  /// Faturas da sessão — reconciliação: procura pela fatura de um
  /// identificador quando a resposta da criação se perdeu.
  Future<Resultado<List<FaturaReferencia>>> consultarPorSessao(
      String sessaoId) async {
    final resposta = await _clienteApi.get(
      ConstantesApp.caminhoFatura,
      parametros: {'sessao.id': sessaoId},
    );
    try {
      return switch (resposta) {
        Sucesso(:final valor) => switch (RespostaFatura.paraLista(valor.data)) {
            final List<FaturaReferencia> lista => Sucesso(lista),
            null => const Erro(FalhaDesconhecida(
                'A consulta de faturas veio em formato desconhecido.')),
          },
        Erro(:final falha) => Erro(falha),
      };
    } catch (_) {
      return const Erro(
          FalhaDesconhecida('A consulta de faturas veio ilegível.'));
    }
  }
}
