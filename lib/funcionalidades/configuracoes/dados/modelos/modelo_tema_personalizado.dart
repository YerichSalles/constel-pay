// O JsonKey abaixo anota um parametro de construtor (padrao freezed), o que o
// analyzer confunde com alvo invalido mesmo sendo o uso correto e documentado.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../dominio/entidades/tema_personalizado.dart';

part 'modelo_tema_personalizado.freezed.dart';
part 'modelo_tema_personalizado.g.dart';

@freezed
class ModeloTemaPersonalizado with _$ModeloTemaPersonalizado {
  const ModeloTemaPersonalizado._();

  const factory ModeloTemaPersonalizado({
    required String corPrimaria,
    required String corSecundaria,
    required String corFundo,
    required String corBotoes,
    // Campos novos: temas ja salvos nao os possuem, por isso tem padrao.
    @Default('#2F2B3D') String corTexto,
    String? corFaixa,
    @Default('#FFFFFF') String corTextoFaixa,
    @Default(textoFaixaPadrao) String textoFaixa,
    @Default('') String textoFaixaEn,
    @Default('') String textoFaixaEs,
    @Default(false) bool pintarBarraCreditosPrincipal,
    String? corBarraCreditosPrincipal,
    String? corBarraCreditosChat,
    @Default('Inter') String fonte,
    String? logoPath,
    @Default(OrientacaoTela.vertical)
    @JsonKey(unknownEnumValue: OrientacaoTela.vertical)
    OrientacaoTela orientacaoTela,
  }) = _ModeloTemaPersonalizado;

  factory ModeloTemaPersonalizado.fromJson(Map<String, dynamic> json) =>
      _$ModeloTemaPersonalizadoFromJson(json);

  factory ModeloTemaPersonalizado.deEntidade(TemaPersonalizado entidade) =>
      ModeloTemaPersonalizado(
        corPrimaria: entidade.corPrimaria,
        corSecundaria: entidade.corSecundaria,
        corFundo: entidade.corFundo,
        corBotoes: entidade.corBotoes,
        corTexto: entidade.corTexto,
        corFaixa: entidade.corFaixa,
        corTextoFaixa: entidade.corTextoFaixa,
        textoFaixa: entidade.textoFaixa,
        textoFaixaEn: entidade.textoFaixaEn,
        textoFaixaEs: entidade.textoFaixaEs,
        pintarBarraCreditosPrincipal: entidade.pintarBarraCreditosPrincipal,
        corBarraCreditosPrincipal: entidade.corBarraCreditosPrincipal,
        corBarraCreditosChat: entidade.corBarraCreditosChat,
        fonte: entidade.fonte,
        logoPath: entidade.logoPath,
        orientacaoTela: entidade.orientacaoTela,
      );

  TemaPersonalizado paraEntidade() => TemaPersonalizado(
        corPrimaria: corPrimaria,
        corSecundaria: corSecundaria,
        corFundo: corFundo,
        corBotoes: corBotoes,
        corTexto: corTexto,
        corFaixa: corFaixa,
        corTextoFaixa: corTextoFaixa,
        textoFaixa: textoFaixa,
        textoFaixaEn: textoFaixaEn,
        textoFaixaEs: textoFaixaEs,
        pintarBarraCreditosPrincipal: pintarBarraCreditosPrincipal,
        corBarraCreditosPrincipal: corBarraCreditosPrincipal,
        corBarraCreditosChat: corBarraCreditosChat,
        fonte: fonte,
        logoPath: logoPath,
        orientacaoTela: orientacaoTela,
      );
}
