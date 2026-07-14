// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fatura_referencia.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FaturaReferencia {
  String get id => throw _privateConstructorUsedError;
  String get codigo => throw _privateConstructorUsedError;
  String get identificador => throw _privateConstructorUsedError;
  int get situacao => throw _privateConstructorUsedError;
  int get pagoCentavos => throw _privateConstructorUsedError;
  int get saldoCentavos => throw _privateConstructorUsedError;

  /// Ids dos atendimentos encerrados por esta fatura
  /// (`faturaModalidades[].referenciaId`). A consulta de reconciliação do
  /// retaguarda NEM SEMPRE devolve o `identificador` — este é o casamento
  /// alternativo com a transação pendente.
  List<String> get atendimentoIds => throw _privateConstructorUsedError;

  /// Create a copy of FaturaReferencia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FaturaReferenciaCopyWith<FaturaReferencia> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaturaReferenciaCopyWith<$Res> {
  factory $FaturaReferenciaCopyWith(
          FaturaReferencia value, $Res Function(FaturaReferencia) then) =
      _$FaturaReferenciaCopyWithImpl<$Res, FaturaReferencia>;
  @useResult
  $Res call(
      {String id,
      String codigo,
      String identificador,
      int situacao,
      int pagoCentavos,
      int saldoCentavos,
      List<String> atendimentoIds});
}

/// @nodoc
class _$FaturaReferenciaCopyWithImpl<$Res, $Val extends FaturaReferencia>
    implements $FaturaReferenciaCopyWith<$Res> {
  _$FaturaReferenciaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FaturaReferencia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? identificador = null,
    Object? situacao = null,
    Object? pagoCentavos = null,
    Object? saldoCentavos = null,
    Object? atendimentoIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: null == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String,
      identificador: null == identificador
          ? _value.identificador
          : identificador // ignore: cast_nullable_to_non_nullable
              as String,
      situacao: null == situacao
          ? _value.situacao
          : situacao // ignore: cast_nullable_to_non_nullable
              as int,
      pagoCentavos: null == pagoCentavos
          ? _value.pagoCentavos
          : pagoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      saldoCentavos: null == saldoCentavos
          ? _value.saldoCentavos
          : saldoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      atendimentoIds: null == atendimentoIds
          ? _value.atendimentoIds
          : atendimentoIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FaturaReferenciaImplCopyWith<$Res>
    implements $FaturaReferenciaCopyWith<$Res> {
  factory _$$FaturaReferenciaImplCopyWith(_$FaturaReferenciaImpl value,
          $Res Function(_$FaturaReferenciaImpl) then) =
      __$$FaturaReferenciaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String codigo,
      String identificador,
      int situacao,
      int pagoCentavos,
      int saldoCentavos,
      List<String> atendimentoIds});
}

/// @nodoc
class __$$FaturaReferenciaImplCopyWithImpl<$Res>
    extends _$FaturaReferenciaCopyWithImpl<$Res, _$FaturaReferenciaImpl>
    implements _$$FaturaReferenciaImplCopyWith<$Res> {
  __$$FaturaReferenciaImplCopyWithImpl(_$FaturaReferenciaImpl _value,
      $Res Function(_$FaturaReferenciaImpl) _then)
      : super(_value, _then);

  /// Create a copy of FaturaReferencia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? identificador = null,
    Object? situacao = null,
    Object? pagoCentavos = null,
    Object? saldoCentavos = null,
    Object? atendimentoIds = null,
  }) {
    return _then(_$FaturaReferenciaImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: null == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String,
      identificador: null == identificador
          ? _value.identificador
          : identificador // ignore: cast_nullable_to_non_nullable
              as String,
      situacao: null == situacao
          ? _value.situacao
          : situacao // ignore: cast_nullable_to_non_nullable
              as int,
      pagoCentavos: null == pagoCentavos
          ? _value.pagoCentavos
          : pagoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      saldoCentavos: null == saldoCentavos
          ? _value.saldoCentavos
          : saldoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      atendimentoIds: null == atendimentoIds
          ? _value._atendimentoIds
          : atendimentoIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$FaturaReferenciaImpl implements _FaturaReferencia {
  const _$FaturaReferenciaImpl(
      {required this.id,
      required this.codigo,
      required this.identificador,
      required this.situacao,
      required this.pagoCentavos,
      required this.saldoCentavos,
      final List<String> atendimentoIds = const <String>[]})
      : _atendimentoIds = atendimentoIds;

  @override
  final String id;
  @override
  final String codigo;
  @override
  final String identificador;
  @override
  final int situacao;
  @override
  final int pagoCentavos;
  @override
  final int saldoCentavos;

  /// Ids dos atendimentos encerrados por esta fatura
  /// (`faturaModalidades[].referenciaId`). A consulta de reconciliação do
  /// retaguarda NEM SEMPRE devolve o `identificador` — este é o casamento
  /// alternativo com a transação pendente.
  final List<String> _atendimentoIds;

  /// Ids dos atendimentos encerrados por esta fatura
  /// (`faturaModalidades[].referenciaId`). A consulta de reconciliação do
  /// retaguarda NEM SEMPRE devolve o `identificador` — este é o casamento
  /// alternativo com a transação pendente.
  @override
  @JsonKey()
  List<String> get atendimentoIds {
    if (_atendimentoIds is EqualUnmodifiableListView) return _atendimentoIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_atendimentoIds);
  }

  @override
  String toString() {
    return 'FaturaReferencia(id: $id, codigo: $codigo, identificador: $identificador, situacao: $situacao, pagoCentavos: $pagoCentavos, saldoCentavos: $saldoCentavos, atendimentoIds: $atendimentoIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FaturaReferenciaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.identificador, identificador) ||
                other.identificador == identificador) &&
            (identical(other.situacao, situacao) ||
                other.situacao == situacao) &&
            (identical(other.pagoCentavos, pagoCentavos) ||
                other.pagoCentavos == pagoCentavos) &&
            (identical(other.saldoCentavos, saldoCentavos) ||
                other.saldoCentavos == saldoCentavos) &&
            const DeepCollectionEquality()
                .equals(other._atendimentoIds, _atendimentoIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      codigo,
      identificador,
      situacao,
      pagoCentavos,
      saldoCentavos,
      const DeepCollectionEquality().hash(_atendimentoIds));

  /// Create a copy of FaturaReferencia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FaturaReferenciaImplCopyWith<_$FaturaReferenciaImpl> get copyWith =>
      __$$FaturaReferenciaImplCopyWithImpl<_$FaturaReferenciaImpl>(
          this, _$identity);
}

abstract class _FaturaReferencia implements FaturaReferencia {
  const factory _FaturaReferencia(
      {required final String id,
      required final String codigo,
      required final String identificador,
      required final int situacao,
      required final int pagoCentavos,
      required final int saldoCentavos,
      final List<String> atendimentoIds}) = _$FaturaReferenciaImpl;

  @override
  String get id;
  @override
  String get codigo;
  @override
  String get identificador;
  @override
  int get situacao;
  @override
  int get pagoCentavos;
  @override
  int get saldoCentavos;

  /// Ids dos atendimentos encerrados por esta fatura
  /// (`faturaModalidades[].referenciaId`). A consulta de reconciliação do
  /// retaguarda NEM SEMPRE devolve o `identificador` — este é o casamento
  /// alternativo com a transação pendente.
  @override
  List<String> get atendimentoIds;

  /// Create a copy of FaturaReferencia
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FaturaReferenciaImplCopyWith<_$FaturaReferenciaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
