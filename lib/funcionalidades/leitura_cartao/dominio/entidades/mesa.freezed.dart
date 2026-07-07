// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mesa.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Mesa {
  int get numero => throw _privateConstructorUsedError;
  DateTime get abertoEm => throw _privateConstructorUsedError;
  int get totalComandas => throw _privateConstructorUsedError;
  int get totalCentavos => throw _privateConstructorUsedError;
  StatusMesa get status => throw _privateConstructorUsedError;

  /// Create a copy of Mesa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MesaCopyWith<Mesa> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MesaCopyWith<$Res> {
  factory $MesaCopyWith(Mesa value, $Res Function(Mesa) then) =
      _$MesaCopyWithImpl<$Res, Mesa>;
  @useResult
  $Res call(
      {int numero,
      DateTime abertoEm,
      int totalComandas,
      int totalCentavos,
      StatusMesa status});
}

/// @nodoc
class _$MesaCopyWithImpl<$Res, $Val extends Mesa>
    implements $MesaCopyWith<$Res> {
  _$MesaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Mesa
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? numero = null,
    Object? abertoEm = null,
    Object? totalComandas = null,
    Object? totalCentavos = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      numero: null == numero
          ? _value.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as int,
      abertoEm: null == abertoEm
          ? _value.abertoEm
          : abertoEm // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalComandas: null == totalComandas
          ? _value.totalComandas
          : totalComandas // ignore: cast_nullable_to_non_nullable
              as int,
      totalCentavos: null == totalCentavos
          ? _value.totalCentavos
          : totalCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusMesa,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MesaImplCopyWith<$Res> implements $MesaCopyWith<$Res> {
  factory _$$MesaImplCopyWith(
          _$MesaImpl value, $Res Function(_$MesaImpl) then) =
      __$$MesaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int numero,
      DateTime abertoEm,
      int totalComandas,
      int totalCentavos,
      StatusMesa status});
}

/// @nodoc
class __$$MesaImplCopyWithImpl<$Res>
    extends _$MesaCopyWithImpl<$Res, _$MesaImpl>
    implements _$$MesaImplCopyWith<$Res> {
  __$$MesaImplCopyWithImpl(_$MesaImpl _value, $Res Function(_$MesaImpl) _then)
      : super(_value, _then);

  /// Create a copy of Mesa
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? numero = null,
    Object? abertoEm = null,
    Object? totalComandas = null,
    Object? totalCentavos = null,
    Object? status = null,
  }) {
    return _then(_$MesaImpl(
      numero: null == numero
          ? _value.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as int,
      abertoEm: null == abertoEm
          ? _value.abertoEm
          : abertoEm // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalComandas: null == totalComandas
          ? _value.totalComandas
          : totalComandas // ignore: cast_nullable_to_non_nullable
              as int,
      totalCentavos: null == totalCentavos
          ? _value.totalCentavos
          : totalCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusMesa,
    ));
  }
}

/// @nodoc

class _$MesaImpl implements _Mesa {
  const _$MesaImpl(
      {required this.numero,
      required this.abertoEm,
      required this.totalComandas,
      required this.totalCentavos,
      this.status = StatusMesa.aberta});

  @override
  final int numero;
  @override
  final DateTime abertoEm;
  @override
  final int totalComandas;
  @override
  final int totalCentavos;
  @override
  @JsonKey()
  final StatusMesa status;

  @override
  String toString() {
    return 'Mesa(numero: $numero, abertoEm: $abertoEm, totalComandas: $totalComandas, totalCentavos: $totalCentavos, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MesaImpl &&
            (identical(other.numero, numero) || other.numero == numero) &&
            (identical(other.abertoEm, abertoEm) ||
                other.abertoEm == abertoEm) &&
            (identical(other.totalComandas, totalComandas) ||
                other.totalComandas == totalComandas) &&
            (identical(other.totalCentavos, totalCentavos) ||
                other.totalCentavos == totalCentavos) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, numero, abertoEm, totalComandas, totalCentavos, status);

  /// Create a copy of Mesa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MesaImplCopyWith<_$MesaImpl> get copyWith =>
      __$$MesaImplCopyWithImpl<_$MesaImpl>(this, _$identity);
}

abstract class _Mesa implements Mesa {
  const factory _Mesa(
      {required final int numero,
      required final DateTime abertoEm,
      required final int totalComandas,
      required final int totalCentavos,
      final StatusMesa status}) = _$MesaImpl;

  @override
  int get numero;
  @override
  DateTime get abertoEm;
  @override
  int get totalComandas;
  @override
  int get totalCentavos;
  @override
  StatusMesa get status;

  /// Create a copy of Mesa
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MesaImplCopyWith<_$MesaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
