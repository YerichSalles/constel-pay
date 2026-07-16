// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modelo_tema_personalizado.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModeloTemaPersonalizadoImpl _$$ModeloTemaPersonalizadoImplFromJson(
        Map<String, dynamic> json) =>
    _$ModeloTemaPersonalizadoImpl(
      corPrimaria: json['corPrimaria'] as String,
      corSecundaria: json['corSecundaria'] as String,
      corFundo: json['corFundo'] as String,
      corBotoes: json['corBotoes'] as String,
      corTexto: json['corTexto'] as String? ?? '#2F2B3D',
      corFaixa: json['corFaixa'] as String?,
      corTextoFaixa: json['corTextoFaixa'] as String? ?? '#FFFFFF',
      textoFaixa: json['textoFaixa'] as String? ?? textoFaixaPadrao,
      textoFaixaEn: json['textoFaixaEn'] as String? ?? '',
      textoFaixaEs: json['textoFaixaEs'] as String? ?? '',
      fonte: json['fonte'] as String? ?? 'Inter',
      logoPath: json['logoPath'] as String?,
      orientacaoTela: $enumDecodeNullable(
              _$OrientacaoTelaEnumMap, json['orientacaoTela'],
              unknownValue: OrientacaoTela.vertical) ??
          OrientacaoTela.vertical,
    );

Map<String, dynamic> _$$ModeloTemaPersonalizadoImplToJson(
        _$ModeloTemaPersonalizadoImpl instance) =>
    <String, dynamic>{
      'corPrimaria': instance.corPrimaria,
      'corSecundaria': instance.corSecundaria,
      'corFundo': instance.corFundo,
      'corBotoes': instance.corBotoes,
      'corTexto': instance.corTexto,
      'corFaixa': instance.corFaixa,
      'corTextoFaixa': instance.corTextoFaixa,
      'textoFaixa': instance.textoFaixa,
      'textoFaixaEn': instance.textoFaixaEn,
      'textoFaixaEs': instance.textoFaixaEs,
      'fonte': instance.fonte,
      'logoPath': instance.logoPath,
      'orientacaoTela': _$OrientacaoTelaEnumMap[instance.orientacaoTela]!,
    };

const _$OrientacaoTelaEnumMap = {
  OrientacaoTela.vertical: 'vertical',
  OrientacaoTela.horizontal: 'horizontal',
};
