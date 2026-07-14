import '../../../../nucleo/utils/json_leniente.dart';
import '../../dominio/entidades/configuracao_faturamento.dart';
import '../../dominio/entidades/especie_forma.dart';
import '../../dominio/entidades/fatura_enums.dart';

/// Deriva a configuração de faturamento das faturas que o caixa já gerou na
/// sessão — o terminal aprende histórico, operação, moeda, modalidade,
/// resultado, dispositivo e forma/plano/conta sem nenhuma configuração
/// manual. A forma é reconhecida pela `especie` do pagamento
/// ([EspecieForma]); espécie desconhecida é ignorada.
abstract final class DerivadorConfiguracaoFaturamento {
  /// [faturas] devem vir da MESMA sessão, preferencialmente completas
  /// (com `faturaPagamentos`/`faturaResultados`). Devolve `null` quando
  /// nenhuma fatura de venda serve de base.
  static ConfiguracaoFaturamento? derivar(
    List<Map<String, dynamic>> faturas, {
    required String sessaoId,
  }) {
    final vendas = [
      for (final f in faturas)
        if (JsonLeniente.inteiro(f['tipo']) == FaturaTipo.venda.valor) f,
    ]..sort((a, b) => JsonLeniente.texto(b['inclusao'])
        .compareTo(JsonLeniente.texto(a['inclusao'])));

    Map<String, dynamic>? base;
    for (final fatura in vendas) {
      if (_temBaseCompleta(fatura)) {
        base = fatura;
        break;
      }
    }
    if (base == null) return null;

    // Formas: varre TODAS as vendas (mais recentes primeiro) — uma fatura
    // em dinheiro ensina dinheiro, uma em PIX ensina PIX.
    final formas = <String, FormaFaturamento>{};
    for (final fatura in vendas) {
      for (final pagamento in JsonLeniente.lista(fatura['faturaPagamentos'])) {
        final forma = JsonLeniente.mapa(pagamento['forma']);
        final especie = JsonLeniente.inteiro(pagamento['especie']) != 0
            ? JsonLeniente.inteiro(pagamento['especie'])
            : JsonLeniente.inteiro(forma['especie']);
        final metodo = EspecieForma.paraMetodo[especie];
        if (metodo == null || formas.containsKey(metodo.name)) continue;
        final candidata = FormaFaturamento(
          forma: forma,
          plano: JsonLeniente.mapa(pagamento['plano']),
          conta: JsonLeniente.mapa(pagamento['conta']),
        );
        if (candidata.valida) formas[metodo.name] = candidata;
      }
    }
    if (formas.isEmpty) return null;

    final resultados = JsonLeniente.lista(base['faturaResultados']);
    return ConfiguracaoFaturamento.deJson({
      'historico': base['historico'],
      'operacao': base['operacao'],
      'moeda': base['moeda'],
      'modalidade': base['modalidade'],
      'resultado': resultados.isEmpty ? null : resultados.first['resultado'],
      'dispositivo': base['dispositivo'],
      'estabelecimentoDepartamento': base['estabelecimentoDepartamento'],
      'formasPagamento': {
        for (final entrada in formas.entries)
          entrada.key: entrada.value.paraJson(),
      },
      'sessaoOrigem': sessaoId,
    });
  }

  /// A fatura serve de base quando traz todas as referências com `id` e o
  /// resultado do rateio.
  static bool _temBaseCompleta(Map<String, dynamic> fatura) {
    bool temId(dynamic mapa) =>
        JsonLeniente.texto(JsonLeniente.mapa(mapa)['id']).isNotEmpty;
    final resultados = JsonLeniente.lista(fatura['faturaResultados']);
    return temId(fatura['historico']) &&
        temId(fatura['operacao']) &&
        temId(fatura['moeda']) &&
        temId(fatura['modalidade']) &&
        temId(fatura['dispositivo']) &&
        resultados.isNotEmpty &&
        temId(resultados.first['resultado']);
  }
}
