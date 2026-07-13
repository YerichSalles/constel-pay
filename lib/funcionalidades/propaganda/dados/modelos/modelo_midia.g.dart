// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modelo_midia.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModeloMidiaImpl _$$ModeloMidiaImplFromJson(Map<String, dynamic> json) =>
    _$ModeloMidiaImpl(
      id: json['id'] as String,
      tipo: $enumDecode(_$TipoMidiaEnumMap, json['tipo']),
      caminho: json['caminho'] as String,
      duracaoSegundos: (json['duracaoSegundos'] as num).toInt(),
      ajuste: $enumDecodeNullable(_$AjusteMidiaEnumMap, json['ajuste'],
              unknownValue: AjusteMidia.automatico) ??
          AjusteMidia.automatico,
      ordem: (json['ordem'] as num).toInt(),
      ativo: json['ativo'] as bool,
    );

Map<String, dynamic> _$$ModeloMidiaImplToJson(_$ModeloMidiaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tipo': _$TipoMidiaEnumMap[instance.tipo]!,
      'caminho': instance.caminho,
      'duracaoSegundos': instance.duracaoSegundos,
      'ajuste': _$AjusteMidiaEnumMap[instance.ajuste]!,
      'ordem': instance.ordem,
      'ativo': instance.ativo,
    };

const _$TipoMidiaEnumMap = {
  TipoMidia.imagem: 'imagem',
  TipoMidia.video: 'video',
};

const _$AjusteMidiaEnumMap = {
  AjusteMidia.automatico: 'automatico',
  AjusteMidia.preencher: 'preencher',
  AjusteMidia.encaixar: 'encaixar',
  AjusteMidia.esticar: 'esticar',
};
