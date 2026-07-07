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
    required int subtotalCentavos,
    @Default(false) bool selecionado,
    @Default(false) bool pago,
  }) = _CartaoConsumo;
}
