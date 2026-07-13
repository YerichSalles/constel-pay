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
    @Default('Inter') String fonte,
    String? logoPath,
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
        fonte: entidade.fonte,
        logoPath: entidade.logoPath,
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
        fonte: fonte,
        logoPath: logoPath,
      );
}
