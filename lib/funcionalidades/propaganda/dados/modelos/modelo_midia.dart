import 'package:freezed_annotation/freezed_annotation.dart';

import '../../dominio/entidades/midia_propaganda.dart';

part 'modelo_midia.freezed.dart';
part 'modelo_midia.g.dart';

@freezed
class ModeloMidia with _$ModeloMidia {
  const ModeloMidia._();

  const factory ModeloMidia({
    required String id,
    required TipoMidia tipo,
    required String caminho,
    required int duracaoSegundos,
    required int ordem,
    required bool ativo,
  }) = _ModeloMidia;

  factory ModeloMidia.fromJson(Map<String, dynamic> json) =>
      _$ModeloMidiaFromJson(json);

  factory ModeloMidia.deEntidade(MidiaPropaganda entidade) => ModeloMidia(
        id: entidade.id,
        tipo: entidade.tipo,
        caminho: entidade.caminho,
        duracaoSegundos: entidade.duracaoSegundos,
        ordem: entidade.ordem,
        ativo: entidade.ativo,
      );

  MidiaPropaganda paraEntidade() => MidiaPropaganda(
        id: id,
        tipo: tipo,
        caminho: caminho,
        duracaoSegundos: duracaoSegundos,
        ordem: ordem,
        ativo: ativo,
      );
}
