// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pagamento.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Pagamento {
  String get id => throw _privateConstructorUsedError;
  int get valorCentavos => throw _privateConstructorUsedError;
  int get gorjetaCentavos => throw _privateConstructorUsedError;
  int get totalCentavos => throw _privateConstructorUsedError;
  MetodoPagamento get metodo => throw _privateConstructorUsedError;
  StatusPagamento get status => throw _privateConstructorUsedError;
  DateTime get criadoEm => throw _privateConstructorUsedError;
  DateTime get atualizadoEm => throw _privateConstructorUsedError;
  List<String> get comandaIds => throw _privateConstructorUsedError;

  /// Create a copy of Pagamento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PagamentoCopyWith<Pagamento> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PagamentoCopyWith<$Res> {
  factory $PagamentoCopyWith(Pagamento value, $Res Function(Pagamento) then) =
      _$PagamentoCopyWithImpl<$Res, Pagamento>;
  @useResult
  $Res call(
      {String id,
      int valorCentavos,
      int gorjetaCentavos,
      int totalCentavos,
      MetodoPagamento metodo,
      StatusPagamento status,
      DateTime criadoEm,
      DateTime atualizadoEm,
      List<String> comandaIds});
}

/// @nodoc
class _$PagamentoCopyWithImpl<$Res, $Val extends Pagamento>
    implements $PagamentoCopyWith<$Res> {
  _$PagamentoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Pagamento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? valorCentavos = null,
    Object? gorjetaCentavos = null,
    Object? totalCentavos = null,
    Object? metodo = null,
    Object? status = null,
    Object? criadoEm = null,
    Object? atualizadoEm = null,
    Object? comandaIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      valorCentavos: null == valorCentavos
          ? _value.valorCentavos
          : valorCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      gorjetaCentavos: null == gorjetaCentavos
          ? _value.gorjetaCentavos
          : gorjetaCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      totalCentavos: null == totalCentavos
          ? _value.totalCentavos
          : totalCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      metodo: null == metodo
          ? _value.metodo
          : metodo // ignore: cast_nullable_to_non_nullable
              as MetodoPagamento,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusPagamento,
      criadoEm: null == criadoEm
          ? _value.criadoEm
          : criadoEm // ignore: cast_nullable_to_non_nullable
              as DateTime,
      atualizadoEm: null == atualizadoEm
          ? _value.atualizadoEm
          : atualizadoEm // ignore: cast_nullable_to_non_nullable
              as DateTime,
      comandaIds: null == comandaIds
          ? _value.comandaIds
          : comandaIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PagamentoImplCopyWith<$Res>
    implements $PagamentoCopyWith<$Res> {
  factory _$$PagamentoImplCopyWith(
          _$PagamentoImpl value, $Res Function(_$PagamentoImpl) then) =
      __$$PagamentoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int valorCentavos,
      int gorjetaCentavos,
      int totalCentavos,
      MetodoPagamento metodo,
      StatusPagamento status,
      DateTime criadoEm,
      DateTime atualizadoEm,
      List<String> comandaIds});
}

/// @nodoc
class __$$PagamentoImplCopyWithImpl<$Res>
    extends _$PagamentoCopyWithImpl<$Res, _$PagamentoImpl>
    implements _$$PagamentoImplCopyWith<$Res> {
  __$$PagamentoImplCopyWithImpl(
      _$PagamentoImpl _value, $Res Function(_$PagamentoImpl) _then)
      : super(_value, _then);

  /// Create a copy of Pagamento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? valorCentavos = null,
    Object? gorjetaCentavos = null,
    Object? totalCentavos = null,
    Object? metodo = null,
    Object? status = null,
    Object? criadoEm = null,
    Object? atualizadoEm = null,
    Object? comandaIds = null,
  }) {
    return _then(_$PagamentoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      valorCentavos: null == valorCentavos
          ? _value.valorCentavos
          : valorCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      gorjetaCentavos: null == gorjetaCentavos
          ? _value.gorjetaCentavos
          : gorjetaCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      totalCentavos: null == totalCentavos
          ? _value.totalCentavos
          : totalCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      metodo: null == metodo
          ? _value.metodo
          : metodo // ignore: cast_nullable_to_non_nullable
              as MetodoPagamento,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusPagamento,
      criadoEm: null == criadoEm
          ? _value.criadoEm
          : criadoEm // ignore: cast_nullable_to_non_nullable
              as DateTime,
      atualizadoEm: null == atualizadoEm
          ? _value.atualizadoEm
          : atualizadoEm // ignore: cast_nullable_to_non_nullable
              as DateTime,
      comandaIds: null == comandaIds
          ? _value._comandaIds
          : comandaIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$PagamentoImpl implements _Pagamento {
  const _$PagamentoImpl(
      {required this.id,
      required this.valorCentavos,
      required this.gorjetaCentavos,
      required this.totalCentavos,
      required this.metodo,
      required this.status,
      required this.criadoEm,
      required this.atualizadoEm,
      required final List<String> comandaIds})
      : _comandaIds = comandaIds;

  @override
  final String id;
  @override
  final int valorCentavos;
  @override
  final int gorjetaCentavos;
  @override
  final int totalCentavos;
  @override
  final MetodoPagamento metodo;
  @override
  final StatusPagamento status;
  @override
  final DateTime criadoEm;
  @override
  final DateTime atualizadoEm;
  final List<String> _comandaIds;
  @override
  List<String> get comandaIds {
    if (_comandaIds is EqualUnmodifiableListView) return _comandaIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comandaIds);
  }

  @override
  String toString() {
    return 'Pagamento(id: $id, valorCentavos: $valorCentavos, gorjetaCentavos: $gorjetaCentavos, totalCentavos: $totalCentavos, metodo: $metodo, status: $status, criadoEm: $criadoEm, atualizadoEm: $atualizadoEm, comandaIds: $comandaIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PagamentoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.valorCentavos, valorCentavos) ||
                other.valorCentavos == valorCentavos) &&
            (identical(other.gorjetaCentavos, gorjetaCentavos) ||
                other.gorjetaCentavos == gorjetaCentavos) &&
            (identical(other.totalCentavos, totalCentavos) ||
                other.totalCentavos == totalCentavos) &&
            (identical(other.metodo, metodo) || other.metodo == metodo) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.criadoEm, criadoEm) ||
                other.criadoEm == criadoEm) &&
            (identical(other.atualizadoEm, atualizadoEm) ||
                other.atualizadoEm == atualizadoEm) &&
            const DeepCollectionEquality()
                .equals(other._comandaIds, _comandaIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      valorCentavos,
      gorjetaCentavos,
      totalCentavos,
      metodo,
      status,
      criadoEm,
      atualizadoEm,
      const DeepCollectionEquality().hash(_comandaIds));

  /// Create a copy of Pagamento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PagamentoImplCopyWith<_$PagamentoImpl> get copyWith =>
      __$$PagamentoImplCopyWithImpl<_$PagamentoImpl>(this, _$identity);
}

abstract class _Pagamento implements Pagamento {
  const factory _Pagamento(
      {required final String id,
      required final int valorCentavos,
      required final int gorjetaCentavos,
      required final int totalCentavos,
      required final MetodoPagamento metodo,
      required final StatusPagamento status,
      required final DateTime criadoEm,
      required final DateTime atualizadoEm,
      required final List<String> comandaIds}) = _$PagamentoImpl;

  @override
  String get id;
  @override
  int get valorCentavos;
  @override
  int get gorjetaCentavos;
  @override
  int get totalCentavos;
  @override
  MetodoPagamento get metodo;
  @override
  StatusPagamento get status;
  @override
  DateTime get criadoEm;
  @override
  DateTime get atualizadoEm;
  @override
  List<String> get comandaIds;

  /// Create a copy of Pagamento
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PagamentoImplCopyWith<_$PagamentoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
