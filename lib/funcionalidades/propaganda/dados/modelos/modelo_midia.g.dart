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
      ordem: (json['ordem'] as num).toInt(),
      ativo: json['ativo'] as bool,
    );

Map<String, dynamic> _$$ModeloMidiaImplToJson(_$ModeloMidiaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tipo': _$TipoMidiaEnumMap[instance.tipo]!,
      'caminho': instance.caminho,
      'duracaoSegundos': instance.duracaoSegundos,
      'ordem': instance.ordem,
      'ativo': instance.ativo,
    };

const _$TipoMidiaEnumMap = {
  TipoMidia.imagem: 'imagem',
  TipoMidia.video: 'video',
};
