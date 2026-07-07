import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_consumo.freezed.dart';

@freezed
class ItemConsumo with _$ItemConsumo {
  const ItemConsumo._();

  const factory ItemConsumo({
    required String emoji,
    required String nome,
    required int quantidade,
    required int valorCentavos,
  }) = _ItemConsumo;

  int get totalCentavos => quantidade * valorCentavos;
}
