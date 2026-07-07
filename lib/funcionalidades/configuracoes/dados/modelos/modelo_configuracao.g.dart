// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modelo_configuracao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModeloConfiguracaoImpl _$$ModeloConfiguracaoImplFromJson(
        Map<String, dynamic> json) =>
    _$ModeloConfiguracaoImpl(
      nomeRestaurante: json['nomeRestaurante'] as String,
      identificadorDispositivo: json['identificadorDispositivo'] as String,
      ambiente: $enumDecode(_$AmbienteEnumMap, json['ambiente']),
      urlBaseProducao: json['urlBaseProducao'] as String,
      urlBaseHomologacao: json['urlBaseHomologacao'] as String,
      pinHash: json['pinHash'] as String,
    );

Map<String, dynamic> _$$ModeloConfiguracaoImplToJson(
        _$ModeloConfiguracaoImpl instance) =>
    <String, dynamic>{
      'nomeRestaurante': instance.nomeRestaurante,
      'identificadorDispositivo': instance.identificadorDispositivo,
      'ambiente': _$AmbienteEnumMap[instance.ambiente]!,
      'urlBaseProducao': instance.urlBaseProducao,
      'urlBaseHomologacao': instance.urlBaseHomologacao,
      'pinHash': instance.pinHash,
    };

const _$AmbienteEnumMap = {
  Ambiente.producao: 'producao',
  Ambiente.homologacao: 'homologacao',
};
