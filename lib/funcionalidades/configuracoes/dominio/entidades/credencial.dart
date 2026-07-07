import 'package:freezed_annotation/freezed_annotation.dart';

part 'credencial.freezed.dart';

@freezed
class Credencial with _$Credencial {
  const factory Credencial({
    required String usuario,
    required String senha,
  }) = _Credencial;
}
