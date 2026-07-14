import '../../../../nucleo/utils/json_leniente.dart';
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
      bruto: json,
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

  // Delegam ao utilitário central para a leniência (e o arredondamento de
  // centavos) ser idêntica em toda leitura de JSON do app.
  static int _centavos(dynamic v) => JsonLeniente.centavos(v);

  static int _inteiro(dynamic v) => JsonLeniente.inteiro(v);

  static String _texto(dynamic v) => JsonLeniente.texto(v);

  static DateTime? _data(dynamic v) =>
      v is String ? DateTime.tryParse(v) : null;

  static Map<String, dynamic> _mapa(dynamic v) => JsonLeniente.mapa(v);

  static List<Map<String, dynamic>> _lista(dynamic v) => JsonLeniente.lista(v);
}
