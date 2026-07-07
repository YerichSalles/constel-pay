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
      logoPath: json['logoPath'] as String?,
    );

Map<String, dynamic> _$$ModeloTemaPersonalizadoImplToJson(
        _$ModeloTemaPersonalizadoImpl instance) =>
    <String, dynamic>{
      'corPrimaria': instance.corPrimaria,
      'corSecundaria': instance.corSecundaria,
      'corFundo': instance.corFundo,
      'corBotoes': instance.corBotoes,
      'logoPath': instance.logoPath,
    };
