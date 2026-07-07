import 'package:freezed_annotation/freezed_annotation.dart';

import 'tipo_mensagem.dart';

part 'mensagem.freezed.dart';

@freezed
class Mensagem with _$Mensagem {
  const factory Mensagem({
    required int id,
    required TipoMensagem tipo,
    @Default(LadoMensagem.assistente) LadoMensagem lado,
    String? texto,
    String? subtexto,
    String? emoji,
    Map<String, dynamic>? dados,
  }) = _Mensagem;
}
