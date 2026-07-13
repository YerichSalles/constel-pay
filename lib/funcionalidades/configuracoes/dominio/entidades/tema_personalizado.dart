import 'package:freezed_annotation/freezed_annotation.dart';

part 'tema_personalizado.freezed.dart';

@freezed
class TemaPersonalizado with _$TemaPersonalizado {
  const factory TemaPersonalizado({
    @Default('#5E52D6') String corPrimaria,
    @Default('#FFD166') String corSecundaria,
    @Default('#F7F7FB') String corFundo,
    @Default('#5E52D6') String corBotoes,
    @Default('#2F2B3D') String corTexto,
    @Default('Inter') String fonte,
    String? logoPath,
  }) = _TemaPersonalizado;
}
