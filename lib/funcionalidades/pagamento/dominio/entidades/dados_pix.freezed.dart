// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dados_pix.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DadosPix {
  String get qrCode => throw _privateConstructorUsedError;
  String get copiaCola => throw _privateConstructorUsedError;
  int get valorCentavos => throw _privateConstructorUsedError;
  DateTime get expiraEm => throw _privateConstructorUsedError;

  /// Create a copy of DadosPix
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DadosPixCopyWith<DadosPix> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DadosPixCopyWith<$Res> {
  factory $DadosPixCopyWith(DadosPix value, $Res Function(DadosPix) then) =
      _$DadosPixCopyWithImpl<$Res, DadosPix>;
  @useResult
  $Res call(
      {String qrCode, String copiaCola, int valorCentavos, DateTime expiraEm});
}

/// @nodoc
class _$DadosPixCopyWithImpl<$Res, $Val extends DadosPix>
    implements $DadosPixCopyWith<$Res> {
  _$DadosPixCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DadosPix
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qrCode = null,
    Object? copiaCola = null,
    Object? valorCentavos = null,
    Object? expiraEm = null,
  }) {
    return _then(_value.copyWith(
      qrCode: null == qrCode
          ? _value.qrCode
          : qrCode // ignore: cast_nullable_to_non_nullable
              as String,
      copiaCola: null == copiaCola
          ? _value.copiaCola
          : copiaCola // ignore: cast_nullable_to_non_nullable
              as String,
      valorCentavos: null == valorCentavos
          ? _value.valorCentavos
          : valorCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      expiraEm: null == expiraEm
          ? _value.expiraEm
          : expiraEm // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DadosPixImplCopyWith<$Res>
    implements $DadosPixCopyWith<$Res> {
  factory _$$DadosPixImplCopyWith(
          _$DadosPixImpl value, $Res Function(_$DadosPixImpl) then) =
      __$$DadosPixImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String qrCode, String copiaCola, int valorCentavos, DateTime expiraEm});
}

/// @nodoc
class __$$DadosPixImplCopyWithImpl<$Res>
    extends _$DadosPixCopyWithImpl<$Res, _$DadosPixImpl>
    implements _$$DadosPixImplCopyWith<$Res> {
  __$$DadosPixImplCopyWithImpl(
      _$DadosPixImpl _value, $Res Function(_$DadosPixImpl) _then)
      : super(_value, _then);

  /// Create a copy of DadosPix
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qrCode = null,
    Object? copiaCola = null,
    Object? valorCentavos = null,
    Object? expiraEm = null,
  }) {
    return _then(_$DadosPixImpl(
      qrCode: null == qrCode
          ? _value.qrCode
          : qrCode // ignore: cast_nullable_to_non_nullable
              as String,
      copiaCola: null == copiaCola
          ? _value.copiaCola
          : copiaCola // ignore: cast_nullable_to_non_nullable
              as String,
      valorCentavos: null == valorCentavos
          ? _value.valorCentavos
          : valorCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      expiraEm: null == expiraEm
          ? _value.expiraEm
          : expiraEm // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$DadosPixImpl implements _DadosPix {
  const _$DadosPixImpl(
      {required this.qrCode,
      required this.copiaCola,
      required this.valorCentavos,
      required this.expiraEm});

  @override
  final String qrCode;
  @override
  final String copiaCola;
  @override
  final int valorCentavos;
  @override
  final DateTime expiraEm;

  @override
  String toString() {
    return 'DadosPix(qrCode: $qrCode, copiaCola: $copiaCola, valorCentavos: $valorCentavos, expiraEm: $expiraEm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DadosPixImpl &&
            (identical(other.qrCode, qrCode) || other.qrCode == qrCode) &&
            (identical(other.copiaCola, copiaCola) ||
                other.copiaCola == copiaCola) &&
            (identical(other.valorCentavos, valorCentavos) ||
                other.valorCentavos == valorCentavos) &&
            (identical(other.expiraEm, expiraEm) ||
                other.expiraEm == expiraEm));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, qrCode, copiaCola, valorCentavos, expiraEm);

  /// Create a copy of DadosPix
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DadosPixImplCopyWith<_$DadosPixImpl> get copyWith =>
      __$$DadosPixImplCopyWithImpl<_$DadosPixImpl>(this, _$identity);
}

abstract class _DadosPix implements DadosPix {
  const factory _DadosPix(
      {required final String qrCode,
      required final String copiaCola,
      required final int valorCentavos,
      required final DateTime expiraEm}) = _$DadosPixImpl;

  @override
  String get qrCode;
  @override
  String get copiaCola;
  @override
  int get valorCentavos;
  @override
  DateTime get expiraEm;

  /// Create a copy of DadosPix
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DadosPixImplCopyWith<_$DadosPixImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
