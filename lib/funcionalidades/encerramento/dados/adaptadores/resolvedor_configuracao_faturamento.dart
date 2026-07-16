import '../../../../nucleo/utils/json_leniente.dart';
import '../../dominio/entidades/configuracao_faturamento.dart';

/// Monta a configuração de faturamento a partir dos CADASTROS do retaguarda —
/// sem depender de nenhuma venda anterior:
/// - o cabeçalho fiscal (histórico, operação, moeda, dispositivo,
///   departamento) vem do documento do dispositivo (`estrutura/dispositivo`);
/// - a forma/plano/conta de cada método vem do cadastro da forma
///   (`financeiro/forma`), que se autodescreve: a conta de recebimento
///   (`conta`, com override por estabelecimento em `formaContas`) e o plano
///   padrão (`formaPlanos`).
/// A `modalidade` de cabeçalho e o `resultado`/rateio NÃO são montados aqui: o
/// retaguarda os completa no POST da fatura.
abstract final class ResolvedorConfiguracaoFaturamento {
  /// Cabeçalho fiscal do documento do dispositivo + as [formas] já resolvidas.
  /// `null` quando o documento não tem os ids exigidos.
  static ConfiguracaoFaturamento? doDispositivo(
    Map<String, dynamic> dispositivo, {
    required String dispositivoId,
    Map<String, FormaFaturamento> formas = const {},
  }) {
    return ConfiguracaoFaturamento.deJson({
      'historico': dispositivo['historico'],
      'operacao': dispositivo['operacao'],
      'moeda': dispositivo['moeda'],
      'dispositivo': {
        'id': dispositivo['id'],
        'codigo': dispositivo['codigo'],
        'nome': dispositivo['nome'],
      },
      'estabelecimentoDepartamento': dispositivo['estabelecimentoDepartamento'],
      'formasPagamento': {
        for (final entrada in formas.entries)
          entrada.key: entrada.value.paraJson(),
      },
      'dispositivoOrigem': dispositivoId,
    });
  }

  /// Id da forma ativa cuja `especie` casa com a pedida — `''` se nenhuma.
  static String idFormaPorEspecie(
      List<Map<String, dynamic>> formas, int especie) {
    for (final forma in formas) {
      if (JsonLeniente.inteiro(forma['especie']) == especie &&
          JsonLeniente.inteiro(forma['situacao']) == 1) {
        return JsonLeniente.texto(forma['id']);
      }
    }
    return '';
  }

  /// Forma/plano/conta a partir do DETALHE do cadastro da forma. A conta é o
  /// override de `formaContas` para o [estabelecimentoId], senão a `conta`
  /// padrão da forma; o plano é o `formaPlanos` padrão. `null` se faltar id.
  static FormaFaturamento? formaDoCadastro(
    Map<String, dynamic> detalhe, {
    required String estabelecimentoId,
  }) {
    final forma =
        _trim(detalhe, const ['id', 'codigo', 'nome', 'especie', 'baixa']);
    final plano =
        _trim(_plano(detalhe), const ['id', 'codigo', 'nome', 'parcelas']);
    final conta = _trim(_conta(detalhe, estabelecimentoId),
        const ['id', 'codigo', 'nome', 'analitica', 'tipo']);
    final resolvida =
        FormaFaturamento(forma: forma, plano: plano, conta: conta);
    return resolvida.valida ? resolvida : null;
  }

  /// Conta de recebimento: o override de `formaContas` cujo
  /// `estabelecimentoIds` contém o estabelecimento; senão a `conta` da forma.
  static Map<String, dynamic> _conta(
      Map<String, dynamic> detalhe, String estabelecimentoId) {
    if (estabelecimentoId.isNotEmpty) {
      for (final override in JsonLeniente.lista(detalhe['formaContas'])) {
        final ids = override['estabelecimentoIds'];
        if (ids is List && ids.contains(estabelecimentoId)) {
          return JsonLeniente.mapa(override['conta']);
        }
      }
    }
    return JsonLeniente.mapa(detalhe['conta']);
  }

  /// Plano padrão de `formaPlanos` (ou o primeiro disponível).
  static Map<String, dynamic> _plano(Map<String, dynamic> detalhe) {
    final planos = JsonLeniente.lista(detalhe['formaPlanos']);
    if (planos.isEmpty) return const {};
    final padrao = planos.firstWhere(
      (p) => p['padrao'] == true,
      orElse: () => planos.first,
    );
    return JsonLeniente.mapa(padrao['plano']);
  }

  static Map<String, dynamic> _trim(
      Map<String, dynamic> origem, List<String> chaves) {
    return {
      for (final chave in chaves)
        if (origem.containsKey(chave)) chave: origem[chave],
    };
  }
}
