import 'package:freezed_annotation/freezed_annotation.dart';

part 'midia_propaganda.freezed.dart';

enum TipoMidia { imagem, video }

@freezed
class MidiaPropaganda with _$MidiaPropaganda {
  const factory MidiaPropaganda({
    required String id,
    required TipoMidia tipo,
    required String caminho,
    @Default(8) int duracaoSegundos,
    required int ordem,
    @Default(true) bool ativo,
  }) = _MidiaPropaganda;
}
