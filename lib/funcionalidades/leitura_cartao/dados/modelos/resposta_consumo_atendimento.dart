import '../../dominio/entidades/atendimento.dart';

/// Converte o JSON cru do endpoint `venda/atendimento/colecao` nas entidades
/// de atendimento. Tolerante a campos ausentes: sub-objetos viram vazios,
/// strings viram '', números viram 0 — nunca lança por campo faltante.
abstract final class RespostaConsumoAtendimento {
  static List<Atendimento> paraLista(List<dynamic> json) =>
      json.whereType<Map<String, dynamic>>().map(_atendimento).toList();

  static Atendimento _atendimento(Map<String, dynamic> json) {
    final sessao = _mapa(json['sessao']);
    return Atendimento(
      id: _texto(json['id']),
      codigo: _texto(json['codigo']),
      nome: _texto(json['nome']),
      referencia: _texto(json['referencia']),
      situacao: _inteiro(json['situacao']),
      inicio: _data(json['inicio']),
      conclusao: _data(json['conclusao']),
      subtotalCentavos: _centavos(json['subtotal']),
      servicoCentavos: _centavos(json['servico']),
      servicoPercentual: json['servicoPercentual'] is num
          ? json['servicoPercentual'] as num
          : 0,
      descontoCentavos: _centavos(json['desconto']),
      totalCentavos: _centavos(json['total']),
      pagoCentavos: _centavos(json['pago']),
      saldoCentavos: _centavos(json['saldo']),
      sessaoId: _texto(sessao['id']),
      sessaoCodigo: _texto(sessao['codigo']),
      comandas: _lista(json['atendimentoComandas']).map(_comanda).toList(),
      itens: _lista(json['atendimentoItens']).map(_item).toList(),
    );
  }

  static ComandaAtendimento _comanda(Map<String, dynamic> json) =>
      ComandaAtendimento(
        id: _texto(json['id']),
        codigo: _texto(json['codigo']),
        numero: _inteiro(json['numero']),
        situacao: _inteiro(json['situacao']),
      );

  static ItemAtendimento _item(Map<String, dynamic> json) {
    final item = _mapa(json['item']);
    return ItemAtendimento(
      id: _texto(json['id']),
      itemId: _texto(item['id']),
      sequencial: _inteiro(json['sequencial']),
      nome: _texto(item['nome']),
      codigo: _texto(item['codigo']),
      quantidade: json['quantidade'] is num ? json['quantidade'] as num : 0,
      medida: _texto(json['medida']),
      valorCentavos: _centavos(json['valor']),
      subtotalCentavos: _centavos(json['subtotal']),
      totalCentavos: _centavos(json['total']),
      comandaId: _texto(json['comandaId']),
      comandaCodigo: _texto(json['comandaCodigo']),
    );
  }

  /// A API entrega dinheiro em reais como double; o `.round()` corrige
  /// artefatos de ponto flutuante (ex.: 5.390000000000001 * 100 -> 539).
  static int _centavos(dynamic v) => v is num ? (v * 100).round() : 0;

  static int _inteiro(dynamic v) => v is num ? v.toInt() : 0;

  static String _texto(dynamic v) => v is String ? v : '';

  static DateTime? _data(dynamic v) =>
      v is String ? DateTime.tryParse(v) : null;

  static Map<String, dynamic> _mapa(dynamic v) =>
      v is Map<String, dynamic> ? v : const {};

  static List<Map<String, dynamic>> _lista(dynamic v) =>
      v is List ? v.whereType<Map<String, dynamic>>().toList() : const [];
}
