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

    /// Id do cadastro do item; vazio no mock. Usado para buscar a foto.
    @Default('') String itemId,

    /// URL pública da foto (campo `imagem` de `recurso/item/{itemId}`).
    /// Vazia quando o item não tem foto — a UI cai no emoji.
    @Default('') String imagemUrl,
  }) = _ItemConsumo;

  int get totalCentavos => quantidade * valorCentavos;
}
