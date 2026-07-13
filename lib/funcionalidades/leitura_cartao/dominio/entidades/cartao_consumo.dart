import 'package:freezed_annotation/freezed_annotation.dart';

import 'item_consumo.dart';

part 'cartao_consumo.freezed.dart';

@freezed
class CartaoConsumo with _$CartaoConsumo {
  const factory CartaoConsumo({
    required String id,
    required String codigo,
    required String nome,
    required String pessoa,
    required String emoji,
    required String resumo,
    required List<ItemConsumo> itens,
    // Valores vêm prontos da API (venda/atendimento/colecao). Nunca recalcular:
    // a regra de serviço/desconto é do retaguarda. `saldoCentavos` é o devido.
    required int subtotalCentavos,
    required int servicoCentavos,

    /// Percentual da taxa de serviço definido pelo retaguarda (pode não ser 10).
    @Default(0) num servicoPercentual,
    required int descontoCentavos,
    required int totalCentavos,
    required int saldoCentavos,
    @Default(false) bool selecionado,
    @Default(false) bool pago,
  }) = _CartaoConsumo;
}
