// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessao_nuvem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessaoNuvemImpl _$$SessaoNuvemImplFromJson(Map<String, dynamic> json) =>
    _$SessaoNuvemImpl(
      token: json['token'] as String,
      validade: DateTime.parse(json['validade'] as String),
      usuario: UsuarioSessao.fromJson(json['usuario'] as Map<String, dynamic>),
      empresa: EmpresaSessao.fromJson(json['empresa'] as Map<String, dynamic>),
      dispositivo: DispositivoSessao.fromJson(
          json['dispositivo'] as Map<String, dynamic>),
      estabelecimento: EstabelecimentoSessao.fromJson(
          json['estabelecimento'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SessaoNuvemImplToJson(_$SessaoNuvemImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'validade': instance.validade.toIso8601String(),
      'usuario': instance.usuario.toJson(),
      'empresa': instance.empresa.toJson(),
      'dispositivo': instance.dispositivo.toJson(),
      'estabelecimento': instance.estabelecimento.toJson(),
    };

_$UsuarioSessaoImpl _$$UsuarioSessaoImplFromJson(Map<String, dynamic> json) =>
    _$UsuarioSessaoImpl(
      nome: json['nome'] as String,
      credencial: json['credencial'] as String,
      imagem: json['imagem'] as String,
    );

Map<String, dynamic> _$$UsuarioSessaoImplToJson(_$UsuarioSessaoImpl instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'credencial': instance.credencial,
      'imagem': instance.imagem,
    };

_$EmpresaSessaoImpl _$$EmpresaSessaoImplFromJson(Map<String, dynamic> json) =>
    _$EmpresaSessaoImpl(
      id: json['id'] as String,
      nome: json['nome'] as String,
    );

Map<String, dynamic> _$$EmpresaSessaoImplToJson(_$EmpresaSessaoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
    };

_$DispositivoSessaoImpl _$$DispositivoSessaoImplFromJson(
        Map<String, dynamic> json) =>
    _$DispositivoSessaoImpl(
      id: json['id'] as String,
      nome: json['nome'] as String,
    );

Map<String, dynamic> _$$DispositivoSessaoImplToJson(
        _$DispositivoSessaoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
    };

_$AmbienteSessaoImpl _$$AmbienteSessaoImplFromJson(Map<String, dynamic> json) =>
    _$AmbienteSessaoImpl(
      id: json['id'] as String,
      nome: json['nome'] as String,
      padrao: json['padrao'] as bool,
    );

Map<String, dynamic> _$$AmbienteSessaoImplToJson(
        _$AmbienteSessaoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'padrao': instance.padrao,
    };

_$EstabelecimentoSessaoImpl _$$EstabelecimentoSessaoImplFromJson(
        Map<String, dynamic> json) =>
    _$EstabelecimentoSessaoImpl(
      id: json['id'] as String,
      nome: json['nome'] as String,
      ambientes: (json['ambientes'] as List<dynamic>?)
              ?.map((e) => AmbienteSessao.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AmbienteSessao>[],
    );

Map<String, dynamic> _$$EstabelecimentoSessaoImplToJson(
        _$EstabelecimentoSessaoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'ambientes': instance.ambientes.map((e) => e.toJson()).toList(),
    };
