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
      fundo: $enumDecodeNullable(_$FundoMidiaEnumMap, json['fundo'],
              unknownValue: FundoMidia.borrado) ??
          FundoMidia.borrado,
      ancora: $enumDecodeNullable(_$AncoraMidiaEnumMap, json['ancora'],
              unknownValue: AncoraMidia.centro) ??
          AncoraMidia.centro,
      zoomPercentual: (json['zoomPercentual'] as num?)?.toInt() ?? 100,
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
      'fundo': _$FundoMidiaEnumMap[instance.fundo]!,
      'ancora': _$AncoraMidiaEnumMap[instance.ancora]!,
      'zoomPercentual': instance.zoomPercentual,
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

const _$FundoMidiaEnumMap = {
  FundoMidia.borrado: 'borrado',
  FundoMidia.cor: 'cor',
};

const _$AncoraMidiaEnumMap = {
  AncoraMidia.topoEsquerda: 'topoEsquerda',
  AncoraMidia.topo: 'topo',
  AncoraMidia.topoDireita: 'topoDireita',
  AncoraMidia.esquerda: 'esquerda',
  AncoraMidia.centro: 'centro',
  AncoraMidia.direita: 'direita',
  AncoraMidia.baseEsquerda: 'baseEsquerda',
  AncoraMidia.base: 'base',
  AncoraMidia.baseDireita: 'baseDireita',
};
