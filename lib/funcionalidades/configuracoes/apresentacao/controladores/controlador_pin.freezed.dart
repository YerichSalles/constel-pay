// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'controlador_pin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EstadoPin {
  String get digitos => throw _privateConstructorUsedError;
  String? get erro => throw _privateConstructorUsedError;
  bool get concluido => throw _privateConstructorUsedError;

  /// Create a copy of EstadoPin
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EstadoPinCopyWith<EstadoPin> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EstadoPinCopyWith<$Res> {
  factory $EstadoPinCopyWith(EstadoPin value, $Res Function(EstadoPin) then) =
      _$EstadoPinCopyWithImpl<$Res, EstadoPin>;
  @useResult
  $Res call({String digitos, String? erro, bool concluido});
}

/// @nodoc
class _$EstadoPinCopyWithImpl<$Res, $Val extends EstadoPin>
    implements $EstadoPinCopyWith<$Res> {
  _$EstadoPinCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EstadoPin
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? digitos = null,
    Object? erro = freezed,
    Object? concluido = null,
  }) {
    return _then(_value.copyWith(
      digitos: null == digitos
          ? _value.digitos
          : digitos // ignore: cast_nullable_to_non_nullable
              as String,
      erro: freezed == erro
          ? _value.erro
          : erro // ignore: cast_nullable_to_non_nullable
              as String?,
      concluido: null == concluido
          ? _value.concluido
          : concluido // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EstadoPinImplCopyWith<$Res>
    implements $EstadoPinCopyWith<$Res> {
  factory _$$EstadoPinImplCopyWith(
          _$EstadoPinImpl value, $Res Function(_$EstadoPinImpl) then) =
      __$$EstadoPinImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String digitos, String? erro, bool concluido});
}

/// @nodoc
class __$$EstadoPinImplCopyWithImpl<$Res>
    extends _$EstadoPinCopyWithImpl<$Res, _$EstadoPinImpl>
    implements _$$EstadoPinImplCopyWith<$Res> {
  __$$EstadoPinImplCopyWithImpl(
      _$EstadoPinImpl _value, $Res Function(_$EstadoPinImpl) _then)
      : super(_value, _then);

  /// Create a copy of EstadoPin
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? digitos = null,
    Object? erro = freezed,
    Object? concluido = null,
  }) {
    return _then(_$EstadoPinImpl(
      digitos: null == digitos
          ? _value.digitos
          : digitos // ignore: cast_nullable_to_non_nullable
              as String,
      erro: freezed == erro
          ? _value.erro
          : erro // ignore: cast_nullable_to_non_nullable
              as String?,
      concluido: null == concluido
          ? _value.concluido
          : concluido // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$EstadoPinImpl implements _EstadoPin {
  const _$EstadoPinImpl({this.digitos = '', this.erro, this.concluido = false});

  @override
  @JsonKey()
  final String digitos;
  @override
  final String? erro;
  @override
  @JsonKey()
  final bool concluido;

  @override
  String toString() {
    return 'EstadoPin(digitos: $digitos, erro: $erro, concluido: $concluido)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EstadoPinImpl &&
            (identical(other.digitos, digitos) || other.digitos == digitos) &&
            (identical(other.erro, erro) || other.erro == erro) &&
            (identical(other.concluido, concluido) ||
                other.concluido == concluido));
  }

  @override
  int get hashCode => Object.hash(runtimeType, digitos, erro, concluido);

  /// Create a copy of EstadoPin
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EstadoPinImplCopyWith<_$EstadoPinImpl> get copyWith =>
      __$$EstadoPinImplCopyWithImpl<_$EstadoPinImpl>(this, _$identity);
}

abstract class _EstadoPin implements EstadoPin {
  const factory _EstadoPin(
      {final String digitos,
      final String? erro,
      final bool concluido}) = _$EstadoPinImpl;

  @override
  String get digitos;
  @override
  String? get erro;
  @override
  bool get concluido;

  /// Create a copy of EstadoPin
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EstadoPinImplCopyWith<_$EstadoPinImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
