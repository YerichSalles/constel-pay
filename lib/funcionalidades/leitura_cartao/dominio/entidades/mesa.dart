import 'package:freezed_annotation/freezed_annotation.dart';

part 'mesa.freezed.dart';

enum StatusMesa { aberta, fechada }

@freezed
class Mesa with _$Mesa {
  const factory Mesa({
    required int numero,
    required DateTime abertoEm,
    required int totalComandas,
    required int totalCentavos,
    @Default(StatusMesa.aberta) StatusMesa status,
  }) = _Mesa;
}
