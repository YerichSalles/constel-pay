import 'package:freezed_annotation/freezed_annotation.dart';

part 'tema_personalizado.freezed.dart';

const String textoFaixaPadrao = 'Toque para pagar';

@freezed
class TemaPersonalizado with _$TemaPersonalizado {
  const TemaPersonalizado._();

  const factory TemaPersonalizado({
    @Default('#5E52D6') String corPrimaria,
    @Default('#FFD166') String corSecundaria,
    @Default('#F7F7FB') String corFundo,
    @Default('#5E52D6') String corBotoes,
    @Default('#2F2B3D') String corTexto,
    String? corFaixa,
    @Default('#FFFFFF') String corTextoFaixa,
    @Default(textoFaixaPadrao) String textoFaixa,
    @Default('Inter') String fonte,
    String? logoPath,
  }) = _TemaPersonalizado;

  /// A faixa acompanha a cor principal ate o operador escolher uma cor propria
  /// para ela. Nulo aqui e o que da a heranca, sem precisar de uma flag
  /// "herdar sim/nao" separada para manter em sincronia.
  String get corFaixaEfetiva => corFaixa ?? corPrimaria;

  /// Um totem sem chamada para pagar e um defeito, nao uma preferencia: campo
  /// vazio cai no padrao.
  String get textoFaixaEfetivo =>
      textoFaixa.trim().isEmpty ? textoFaixaPadrao : textoFaixa;
}
