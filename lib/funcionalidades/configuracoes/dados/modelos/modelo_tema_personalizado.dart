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
        logoPath: entidade.logoPath,
      );

  TemaPersonalizado paraEntidade() => TemaPersonalizado(
        corPrimaria: corPrimaria,
        corSecundaria: corSecundaria,
        corFundo: corFundo,
        corBotoes: corBotoes,
        logoPath: logoPath,
      );
}
