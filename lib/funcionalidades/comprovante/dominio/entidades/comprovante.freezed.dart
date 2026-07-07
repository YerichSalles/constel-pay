// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comprovante.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Comprovante {
  String get id => throw _privateConstructorUsedError;
  String get pagamentoId => throw _privateConstructorUsedError;
  int get valorCentavos => throw _privateConstructorUsedError;
  MetodoPagamento get metodo => throw _privateConstructorUsedError;
  List<String> get comandas => throw _privateConstructorUsedError;
  DateTime get dataHora => throw _privateConstructorUsedError;
  String get nomeRestaurante => throw _privateConstructorUsedError;

  /// Create a copy of Comprovante
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComprovanteCopyWith<Comprovante> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComprovanteCopyWith<$Res> {
  factory $ComprovanteCopyWith(
          Comprovante value, $Res Function(Comprovante) then) =
      _$ComprovanteCopyWithImpl<$Res, Comprovante>;
  @useResult
  $Res call(
      {String id,
      String pagamentoId,
      int valorCentavos,
      MetodoPagamento metodo,
      List<String> comandas,
      DateTime dataHora,
      String nomeRestaurante});
}

/// @nodoc
class _$ComprovanteCopyWithImpl<$Res, $Val extends Comprovante>
    implements $ComprovanteCopyWith<$Res> {
  _$ComprovanteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Comprovante
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pagamentoId = null,
    Object? valorCentavos = null,
    Object? metodo = null,
    Object? comandas = null,
    Object? dataHora = null,
    Object? nomeRestaurante = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pagamentoId: null == pagamentoId
          ? _value.pagamentoId
          : pagamentoId // ignore: cast_nullable_to_non_nullable
              as String,
      valorCentavos: null == valorCentavos
          ? _value.valorCentavos
          : valorCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      metodo: null == metodo
          ? _value.metodo
          : metodo // ignore: cast_nullable_to_non_nullable
              as MetodoPagamento,
      comandas: null == comandas
          ? _value.comandas
          : comandas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dataHora: null == dataHora
          ? _value.dataHora
          : dataHora // ignore: cast_nullable_to_non_nullable
              as DateTime,
      nomeRestaurante: null == nomeRestaurante
          ? _value.nomeRestaurante
          : nomeRestaurante // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ComprovanteImplCopyWith<$Res>
    implements $ComprovanteCopyWith<$Res> {
  factory _$$ComprovanteImplCopyWith(
          _$ComprovanteImpl value, $Res Function(_$ComprovanteImpl) then) =
      __$$ComprovanteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String pagamentoId,
      int valorCentavos,
      MetodoPagamento metodo,
      List<String> comandas,
      DateTime dataHora,
      String nomeRestaurante});
}

/// @nodoc
class __$$ComprovanteImplCopyWithImpl<$Res>
    extends _$ComprovanteCopyWithImpl<$Res, _$ComprovanteImpl>
    implements _$$ComprovanteImplCopyWith<$Res> {
  __$$ComprovanteImplCopyWithImpl(
      _$ComprovanteImpl _value, $Res Function(_$ComprovanteImpl) _then)
      : super(_value, _then);

  /// Create a copy of Comprovante
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pagamentoId = null,
    Object? valorCentavos = null,
    Object? metodo = null,
    Object? comandas = null,
    Object? dataHora = null,
    Object? nomeRestaurante = null,
  }) {
    return _then(_$ComprovanteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pagamentoId: null == pagamentoId
          ? _value.pagamentoId
          : pagamentoId // ignore: cast_nullable_to_non_nullable
              as String,
      valorCentavos: null == valorCentavos
          ? _value.valorCentavos
          : valorCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      metodo: null == metodo
          ? _value.metodo
          : metodo // ignore: cast_nullable_to_non_nullable
              as MetodoPagamento,
      comandas: null == comandas
          ? _value._comandas
          : comandas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dataHora: null == dataHora
          ? _value.dataHora
          : dataHora // ignore: cast_nullable_to_non_nullable
              as DateTime,
      nomeRestaurante: null == nomeRestaurante
          ? _value.nomeRestaurante
          : nomeRestaurante // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ComprovanteImpl implements _Comprovante {
  const _$ComprovanteImpl(
      {required this.id,
      required this.pagamentoId,
      required this.valorCentavos,
      required this.metodo,
      required final List<String> comandas,
      required this.dataHora,
      required this.nomeRestaurante})
      : _comandas = comandas;

  @override
  final String id;
  @override
  final String pagamentoId;
  @override
  final int valorCentavos;
  @override
  final MetodoPagamento metodo;
  final List<String> _comandas;
  @override
  List<String> get comandas {
    if (_comandas is EqualUnmodifiableListView) return _comandas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comandas);
  }

  @override
  final DateTime dataHora;
  @override
  final String nomeRestaurante;

  @override
  String toString() {
    return 'Comprovante(id: $id, pagamentoId: $pagamentoId, valorCentavos: $valorCentavos, metodo: $metodo, comandas: $comandas, dataHora: $dataHora, nomeRestaurante: $nomeRestaurante)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComprovanteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pagamentoId, pagamentoId) ||
                other.pagamentoId == pagamentoId) &&
            (identical(other.valorCentavos, valorCentavos) ||
                other.valorCentavos == valorCentavos) &&
            (identical(other.metodo, metodo) || other.metodo == metodo) &&
            const DeepCollectionEquality().equals(other._comandas, _comandas) &&
            (identical(other.dataHora, dataHora) ||
                other.dataHora == dataHora) &&
            (identical(other.nomeRestaurante, nomeRestaurante) ||
                other.nomeRestaurante == nomeRestaurante));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      pagamentoId,
      valorCentavos,
      metodo,
      const DeepCollectionEquality().hash(_comandas),
      dataHora,
      nomeRestaurante);

  /// Create a copy of Comprovante
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComprovanteImplCopyWith<_$ComprovanteImpl> get copyWith =>
      __$$ComprovanteImplCopyWithImpl<_$ComprovanteImpl>(this, _$identity);
}

abstract class _Comprovante implements Comprovante {
  const factory _Comprovante(
      {required final String id,
      required final String pagamentoId,
      required final int valorCentavos,
      required final MetodoPagamento metodo,
      required final List<String> comandas,
      required final DateTime dataHora,
      required final String nomeRestaurante}) = _$ComprovanteImpl;

  @override
  String get id;
  @override
  String get pagamentoId;
  @override
  int get valorCentavos;
  @override
  MetodoPagamento get metodo;
  @override
  List<String> get comandas;
  @override
  DateTime get dataHora;
  @override
  String get nomeRestaurante;

  /// Create a copy of Comprovante
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComprovanteImplCopyWith<_$ComprovanteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
