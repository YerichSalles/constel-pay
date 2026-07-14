// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modelo_publicidade.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModeloMensagemLetreiroImpl _$$ModeloMensagemLetreiroImplFromJson(
        Map<String, dynamic> json) =>
    _$ModeloMensagemLetreiroImpl(
      id: json['id'] as String,
      texto: json['texto'] as String,
      ordem: (json['ordem'] as num).toInt(),
      ativo: json['ativo'] as bool? ?? true,
    );

Map<String, dynamic> _$$ModeloMensagemLetreiroImplToJson(
        _$ModeloMensagemLetreiroImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'texto': instance.texto,
      'ordem': instance.ordem,
      'ativo': instance.ativo,
    };

_$ModeloPublicidadeImpl _$$ModeloPublicidadeImplFromJson(
        Map<String, dynamic> json) =>
    _$ModeloPublicidadeImpl(
      ativa: json['ativa'] as bool? ?? false,
      formato: $enumDecodeNullable(_$FormatoPublicidadeEnumMap, json['formato'],
              unknownValue: FormatoPublicidade.carrossel) ??
          FormatoPublicidade.carrossel,
      banners: (json['banners'] as List<dynamic>?)
              ?.map((e) => ModeloMidia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      intervaloSegundos: (json['intervaloSegundos'] as num?)?.toInt() ?? 6,
      transicao: $enumDecodeNullable(
              _$TransicaoCarrosselEnumMap, json['transicao'],
              unknownValue: TransicaoCarrossel.suave) ??
          TransicaoCarrossel.suave,
      mensagens: (json['mensagens'] as List<dynamic>?)
              ?.map((e) =>
                  ModeloMensagemLetreiro.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      velocidade: $enumDecodeNullable(
              _$VelocidadeLetreiroEnumMap, json['velocidade'],
              unknownValue: VelocidadeLetreiro.normal) ??
          VelocidadeLetreiro.normal,
      separador: json['separador'] as String? ?? '•',
      midiaParceiro: json['midiaParceiro'] == null
          ? null
          : ModeloMidia.fromJson(json['midiaParceiro'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ModeloPublicidadeImplToJson(
        _$ModeloPublicidadeImpl instance) =>
    <String, dynamic>{
      'ativa': instance.ativa,
      'formato': _$FormatoPublicidadeEnumMap[instance.formato]!,
      'banners': instance.banners.map((e) => e.toJson()).toList(),
      'intervaloSegundos': instance.intervaloSegundos,
      'transicao': _$TransicaoCarrosselEnumMap[instance.transicao]!,
      'mensagens': instance.mensagens.map((e) => e.toJson()).toList(),
      'velocidade': _$VelocidadeLetreiroEnumMap[instance.velocidade]!,
      'separador': instance.separador,
      'midiaParceiro': instance.midiaParceiro?.toJson(),
    };

const _$FormatoPublicidadeEnumMap = {
  FormatoPublicidade.carrossel: 'carrossel',
  FormatoPublicidade.letreiro: 'letreiro',
  FormatoPublicidade.parceiro: 'parceiro',
};

const _$TransicaoCarrosselEnumMap = {
  TransicaoCarrossel.suave: 'suave',
  TransicaoCarrossel.deslizar: 'deslizar',
  TransicaoCarrossel.semAnimacao: 'semAnimacao',
};

const _$VelocidadeLetreiroEnumMap = {
  VelocidadeLetreiro.lenta: 'lenta',
  VelocidadeLetreiro.normal: 'normal',
  VelocidadeLetreiro.rapida: 'rapida',
};
