import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';

/// Cadastro de formas de pagamento na API da NUVEM (`financeiro/forma`).
/// [listar] devolve as formas (para localizar a certa pela espécie) e
/// [obter] o detalhe de uma forma, com a conta de recebimento
/// (`conta`/`formaContas`) e o plano padrão (`formaPlanos`).
class FonteFormaPagamento {
  FonteFormaPagamento(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<Resultado<List<Map<String, dynamic>>>> listar() async {
    final resposta = await _clienteApi
        .get(ConstantesApp.caminhoForma, parametros: {'texto': ''});
    try {
      return switch (resposta) {
        Sucesso(:final valor) => switch (_listaBruta(valor.data)) {
            final List<Map<String, dynamic>> lista => Sucesso(lista),
            null => const Erro(FalhaDesconhecida(
                'A consulta de formas de pagamento veio em formato '
                'desconhecido.')),
          },
        Erro(:final falha) => Erro(falha),
      };
    } catch (_) {
      return const Erro(FalhaDesconhecida(
          'A consulta de formas de pagamento veio ilegível.'));
    }
  }

  Future<Resultado<Map<String, dynamic>>> obter(String id) async {
    final resposta = await _clienteApi.get('${ConstantesApp.caminhoForma}/$id');
    try {
      return switch (resposta) {
        Sucesso(:final valor) => Sucesso(valor.data as Map<String, dynamic>),
        Erro(:final falha) => Erro(falha),
      };
    } catch (_) {
      return const Erro(
          FalhaDesconhecida('O detalhe da forma de pagamento veio ilegível.'));
    }
  }

  /// Lista crua ou envelope conhecido (`lista`/`itens`); formato desconhecido
  /// → `null`.
  static List<Map<String, dynamic>>? _listaBruta(dynamic corpo) =>
      switch (corpo) {
        final List lista => lista.whereType<Map<String, dynamic>>().toList(),
        final Map<String, dynamic> mapa when mapa['lista'] is List =>
          (mapa['lista'] as List).whereType<Map<String, dynamic>>().toList(),
        final Map<String, dynamic> mapa when mapa['itens'] is List =>
          (mapa['itens'] as List).whereType<Map<String, dynamic>>().toList(),
        _ => null,
      };
}
