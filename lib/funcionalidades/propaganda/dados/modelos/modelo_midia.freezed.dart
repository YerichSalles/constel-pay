// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'modelo_midia.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ModeloMidia _$ModeloMidiaFromJson(Map<String, dynamic> json) {
  return _ModeloMidia.fromJson(json);
}

/// @nodoc
mixin _$ModeloMidia {
  String get id => throw _privateConstructorUsedError;
  TipoMidia get tipo => throw _privateConstructorUsedError;
  String get caminho => throw _privateConstructorUsedError;
  int get duracaoSegundos => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: AjusteMidia.automatico)
  AjusteMidia get ajuste => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: FundoMidia.borrado)
  FundoMidia get fundo => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: AncoraMidia.centro)
  AncoraMidia get ancora => throw _privateConstructorUsedError;
  int get zoomPercentual => throw _privateConstructorUsedError;
  int get ordem => throw _privateConstructorUsedError;
  bool get ativo => throw _privateConstructorUsedError;

  /// Serializes this ModeloMidia to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModeloMidia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModeloMidiaCopyWith<ModeloMidia> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModeloMidiaCopyWith<$Res> {
  factory $ModeloMidiaCopyWith(
          ModeloMidia value, $Res Function(ModeloMidia) then) =
      _$ModeloMidiaCopyWithImpl<$Res, ModeloMidia>;
  @useResult
  $Res call(
      {String id,
      TipoMidia tipo,
      String caminho,
      int duracaoSegundos,
      @JsonKey(unknownEnumValue: AjusteMidia.automatico) AjusteMidia ajuste,
      @JsonKey(unknownEnumValue: FundoMidia.borrado) FundoMidia fundo,
      @JsonKey(unknownEnumValue: AncoraMidia.centro) AncoraMidia ancora,
      int zoomPercentual,
      int ordem,
      bool ativo});
}

/// @nodoc
class _$ModeloMidiaCopyWithImpl<$Res, $Val extends ModeloMidia>
    implements $ModeloMidiaCopyWith<$Res> {
  _$ModeloMidiaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModeloMidia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? caminho = null,
    Object? duracaoSegundos = null,
    Object? ajuste = null,
    Object? fundo = null,
    Object? ancora = null,
    Object? zoomPercentual = null,
    Object? ordem = null,
    Object? ativo = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoMidia,
      caminho: null == caminho
          ? _value.caminho
          : caminho // ignore: cast_nullable_to_non_nullable
              as String,
      duracaoSegundos: null == duracaoSegundos
          ? _value.duracaoSegundos
          : duracaoSegundos // ignore: cast_nullable_to_non_nullable
              as int,
      ajuste: null == ajuste
          ? _value.ajuste
          : ajuste // ignore: cast_nullable_to_non_nullable
              as AjusteMidia,
      fundo: null == fundo
          ? _value.fundo
          : fundo // ignore: cast_nullable_to_non_nullable
              as FundoMidia,
      ancora: null == ancora
          ? _value.ancora
          : ancora // ignore: cast_nullable_to_non_nullable
              as AncoraMidia,
      zoomPercentual: null == zoomPercentual
          ? _value.zoomPercentual
          : zoomPercentual // ignore: cast_nullable_to_non_nullable
              as int,
      ordem: null == ordem
          ? _value.ordem
          : ordem // ignore: cast_nullable_to_non_nullable
              as int,
      ativo: null == ativo
          ? _value.ativo
          : ativo // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModeloMidiaImplCopyWith<$Res>
    implements $ModeloMidiaCopyWith<$Res> {
  factory _$$ModeloMidiaImplCopyWith(
          _$ModeloMidiaImpl value, $Res Function(_$ModeloMidiaImpl) then) =
      __$$ModeloMidiaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      TipoMidia tipo,
      String caminho,
      int duracaoSegundos,
      @JsonKey(unknownEnumValue: AjusteMidia.automatico) AjusteMidia ajuste,
      @JsonKey(unknownEnumValue: FundoMidia.borrado) FundoMidia fundo,
      @JsonKey(unknownEnumValue: AncoraMidia.centro) AncoraMidia ancora,
      int zoomPercentual,
      int ordem,
      bool ativo});
}

/// @nodoc
class __$$ModeloMidiaImplCopyWithImpl<$Res>
    extends _$ModeloMidiaCopyWithImpl<$Res, _$ModeloMidiaImpl>
    implements _$$ModeloMidiaImplCopyWith<$Res> {
  __$$ModeloMidiaImplCopyWithImpl(
      _$ModeloMidiaImpl _value, $Res Function(_$ModeloMidiaImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModeloMidia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? caminho = null,
    Object? duracaoSegundos = null,
    Object? ajuste = null,
    Object? fundo = null,
    Object? ancora = null,
    Object? zoomPercentual = null,
    Object? ordem = null,
    Object? ativo = null,
  }) {
    return _then(_$ModeloMidiaImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoMidia,
      caminho: null == caminho
          ? _value.caminho
          : caminho // ignore: cast_nullable_to_non_nullable
              as String,
      duracaoSegundos: null == duracaoSegundos
          ? _value.duracaoSegundos
          : duracaoSegundos // ignore: cast_nullable_to_non_nullable
              as int,
      ajuste: null == ajuste
          ? _value.ajuste
          : ajuste // ignore: cast_nullable_to_non_nullable
              as AjusteMidia,
      fundo: null == fundo
          ? _value.fundo
          : fundo // ignore: cast_nullable_to_non_nullable
              as FundoMidia,
      ancora: null == ancora
          ? _value.ancora
          : ancora // ignore: cast_nullable_to_non_nullable
              as AncoraMidia,
      zoomPercentual: null == zoomPercentual
          ? _value.zoomPercentual
          : zoomPercentual // ignore: cast_nullable_to_non_nullable
              as int,
      ordem: null == ordem
          ? _value.ordem
          : ordem // ignore: cast_nullable_to_non_nullable
              as int,
      ativo: null == ativo
          ? _value.ativo
          : ativo // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModeloMidiaImpl extends _ModeloMidia {
  const _$ModeloMidiaImpl(
      {required this.id,
      required this.tipo,
      required this.caminho,
      required this.duracaoSegundos,
      @JsonKey(unknownEnumValue: AjusteMidia.automatico)
      this.ajuste = AjusteMidia.automatico,
      @JsonKey(unknownEnumValue: FundoMidia.borrado)
      this.fundo = FundoMidia.borrado,
      @JsonKey(unknownEnumValue: AncoraMidia.centro)
      this.ancora = AncoraMidia.centro,
      this.zoomPercentual = 100,
      required this.ordem,
      required this.ativo})
      : super._();

  factory _$ModeloMidiaImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModeloMidiaImplFromJson(json);

  @override
  final String id;
  @override
  final TipoMidia tipo;
  @override
  final String caminho;
  @override
  final int duracaoSegundos;
  @override
  @JsonKey(unknownEnumValue: AjusteMidia.automatico)
  final AjusteMidia ajuste;
  @override
  @JsonKey(unknownEnumValue: FundoMidia.borrado)
  final FundoMidia fundo;
  @override
  @JsonKey(unknownEnumValue: AncoraMidia.centro)
  final AncoraMidia ancora;
  @override
  @JsonKey()
  final int zoomPercentual;
  @override
  final int ordem;
  @override
  final bool ativo;

  @override
  String toString() {
    return 'ModeloMidia(id: $id, tipo: $tipo, caminho: $caminho, duracaoSegundos: $duracaoSegundos, ajuste: $ajuste, fundo: $fundo, ancora: $ancora, zoomPercentual: $zoomPercentual, ordem: $ordem, ativo: $ativo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModeloMidiaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.caminho, caminho) || other.caminho == caminho) &&
            (identical(other.duracaoSegundos, duracaoSegundos) ||
                other.duracaoSegundos == duracaoSegundos) &&
            (identical(other.ajuste, ajuste) || other.ajuste == ajuste) &&
            (identical(other.fundo, fundo) || other.fundo == fundo) &&
            (identical(other.ancora, ancora) || other.ancora == ancora) &&
            (identical(other.zoomPercentual, zoomPercentual) ||
                other.zoomPercentual == zoomPercentual) &&
            (identical(other.ordem, ordem) || other.ordem == ordem) &&
            (identical(other.ativo, ativo) || other.ativo == ativo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, tipo, caminho,
      duracaoSegundos, ajuste, fundo, ancora, zoomPercentual, ordem, ativo);

  /// Create a copy of ModeloMidia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModeloMidiaImplCopyWith<_$ModeloMidiaImpl> get copyWith =>
      __$$ModeloMidiaImplCopyWithImpl<_$ModeloMidiaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModeloMidiaImplToJson(
      this,
    );
  }
}

abstract class _ModeloMidia extends ModeloMidia {
  const factory _ModeloMidia(
      {required final String id,
      required final TipoMidia tipo,
      required final String caminho,
      required final int duracaoSegundos,
      @JsonKey(unknownEnumValue: AjusteMidia.automatico)
      final AjusteMidia ajuste,
      @JsonKey(unknownEnumValue: FundoMidia.borrado) final FundoMidia fundo,
      @JsonKey(unknownEnumValue: AncoraMidia.centro) final AncoraMidia ancora,
      final int zoomPercentual,
      required final int ordem,
      required final bool ativo}) = _$ModeloMidiaImpl;
  const _ModeloMidia._() : super._();

  factory _ModeloMidia.fromJson(Map<String, dynamic> json) =
      _$ModeloMidiaImpl.fromJson;

  @override
  String get id;
  @override
  TipoMidia get tipo;
  @override
  String get caminho;
  @override
  int get duracaoSegundos;
  @override
  @JsonKey(unknownEnumValue: AjusteMidia.automatico)
  AjusteMidia get ajuste;
  @override
  @JsonKey(unknownEnumValue: FundoMidia.borrado)
  FundoMidia get fundo;
  @override
  @JsonKey(unknownEnumValue: AncoraMidia.centro)
  AncoraMidia get ancora;
  @override
  int get zoomPercentual;
  @override
  int get ordem;
  @override
  bool get ativo;

  /// Create a copy of ModeloMidia
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModeloMidiaImplCopyWith<_$ModeloMidiaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
