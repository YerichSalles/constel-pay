import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/entidades/fatura_referencia.dart';
import '../modelos/resposta_fatura.dart';

/// Fatura na API da NUVEM (`movimento/fatura`): criação (POST) e consulta por
/// atendimento (GET, usada na reconciliação de timeouts). O identificador vai
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

  /// Faturas vinculadas a um atendimento — reconciliação quando a resposta
  /// da criação se perdeu. O retaguarda filtra `texto=<uuid>` pela própria
  /// fatura OU pela ocupação (`faturaModalidades[].referenciaId`); a
  /// resposta é o envelope paginado com `lista`, em formato enxuto (sem
  /// identificador nem quitação) — o detalhe vem depois por [obterBruta].
  Future<Resultado<List<Map<String, dynamic>>>> consultarPorAtendimento(
      String atendimentoId) async {
    final resposta = await _clienteApi.get(
      ConstantesApp.caminhoFatura,
      parametros: {'texto': atendimentoId},
    );
    try {
      return switch (resposta) {
        Sucesso(:final valor) => switch (_listaBruta(valor.data)) {
            final List<Map<String, dynamic>> lista => Sucesso(lista),
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

  /// Fatura completa por id — usada quando a coleção vem enxuta demais para
  /// derivar a configuração (sem pagamentos/resultados embutidos).
  Future<Resultado<Map<String, dynamic>>> obterBruta(String id) async {
    final resposta =
        await _clienteApi.get('${ConstantesApp.caminhoFatura}/$id');
    try {
      return switch (resposta) {
        Sucesso(:final valor) => Sucesso(valor.data as Map<String, dynamic>),
        Erro(:final falha) => Erro(falha),
      };
    } catch (_) {
      return const Erro(
          FalhaDesconhecida('A fatura consultada veio ilegível.'));
    }
  }

  /// Lista crua ou envelope conhecido (o retaguarda pagina em `lista`);
  /// formato desconhecido → `null`.
  static List<Map<String, dynamic>>? _listaBruta(dynamic corpo) =>
      switch (corpo) {
        final List lista => lista.whereType<Map<String, dynamic>>().toList(),
        final Map<String, dynamic> mapa when mapa['lista'] is List =>
          (mapa['lista'] as List).whereType<Map<String, dynamic>>().toList(),
        final Map<String, dynamic> mapa when mapa['itens'] is List =>
          (mapa['itens'] as List).whereType<Map<String, dynamic>>().toList(),
        final Map<String, dynamic> mapa when mapa['dados'] is List =>
          (mapa['dados'] as List).whereType<Map<String, dynamic>>().toList(),
        _ => null,
      };
}
