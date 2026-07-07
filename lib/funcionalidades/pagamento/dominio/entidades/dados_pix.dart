import 'package:freezed_annotation/freezed_annotation.dart';

part 'dados_pix.freezed.dart';

@freezed
class DadosPix with _$DadosPix {
  const factory DadosPix({
    required String qrCode,
    required String copiaCola,
    required int valorCentavos,
    required DateTime expiraEm,
  }) = _DadosPix;
}
