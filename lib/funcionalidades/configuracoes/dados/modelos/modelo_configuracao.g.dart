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
      idDispositivo: json['idDispositivo'] as String? ?? '',
      ambiente: $enumDecode(_$AmbienteEnumMap, json['ambiente']),
      urlBaseProducao: json['urlBaseProducao'] as String,
      urlBaseHomologacao: json['urlBaseHomologacao'] as String,
      urlNuvemProducao: json['urlNuvemProducao'] as String? ?? '',
      urlNuvemHomologacao: json['urlNuvemHomologacao'] as String? ?? '',
    );

Map<String, dynamic> _$$ModeloConfiguracaoImplToJson(
        _$ModeloConfiguracaoImpl instance) =>
    <String, dynamic>{
      'nomeRestaurante': instance.nomeRestaurante,
      'identificadorDispositivo': instance.identificadorDispositivo,
      'idDispositivo': instance.idDispositivo,
      'ambiente': _$AmbienteEnumMap[instance.ambiente]!,
      'urlBaseProducao': instance.urlBaseProducao,
      'urlBaseHomologacao': instance.urlBaseHomologacao,
      'urlNuvemProducao': instance.urlNuvemProducao,
      'urlNuvemHomologacao': instance.urlNuvemHomologacao,
    };

const _$AmbienteEnumMap = {
  Ambiente.producao: 'producao',
  Ambiente.homologacao: 'homologacao',
};
