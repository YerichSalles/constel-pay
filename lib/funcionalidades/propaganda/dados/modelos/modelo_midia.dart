// O JsonKey abaixo anota um parametro de construtor (padrao freezed), o que o
// analyzer confunde com alvo invalido mesmo sendo o uso correto e documentado.
// ignore_for_file: invalid_annotation_target
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
    @Default(AjusteMidia.automatico)
    @JsonKey(unknownEnumValue: AjusteMidia.automatico)
    AjusteMidia ajuste,
    @Default(FundoMidia.borrado)
    @JsonKey(unknownEnumValue: FundoMidia.borrado)
    FundoMidia fundo,
    @Default(AncoraMidia.centro)
    @JsonKey(unknownEnumValue: AncoraMidia.centro)
    AncoraMidia ancora,
    @Default(100) int zoomPercentual,
    @Default(0) int rotacaoGraus,
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
        ajuste: entidade.ajuste,
        fundo: entidade.fundo,
        ancora: entidade.ancora,
        zoomPercentual: entidade.zoomPercentual,
        rotacaoGraus: entidade.rotacaoGraus,
        ordem: entidade.ordem,
        ativo: entidade.ativo,
      );

  MidiaPropaganda paraEntidade() => MidiaPropaganda(
        id: id,
        tipo: tipo,
        caminho: caminho,
        duracaoSegundos: duracaoSegundos,
        ajuste: ajuste,
        fundo: fundo,
        ancora: ancora,
        zoomPercentual: zoomPercentual,
        rotacaoGraus: rotacaoGraus,
        ordem: ordem,
        ativo: ativo,
      );
}
