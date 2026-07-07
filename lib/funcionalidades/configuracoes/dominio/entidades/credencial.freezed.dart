// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credencial.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Credencial {
  String get usuario => throw _privateConstructorUsedError;
  String get senha => throw _privateConstructorUsedError;

  /// Create a copy of Credencial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CredencialCopyWith<Credencial> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredencialCopyWith<$Res> {
  factory $CredencialCopyWith(
          Credencial value, $Res Function(Credencial) then) =
      _$CredencialCopyWithImpl<$Res, Credencial>;
  @useResult
  $Res call({String usuario, String senha});
}

/// @nodoc
class _$CredencialCopyWithImpl<$Res, $Val extends Credencial>
    implements $CredencialCopyWith<$Res> {
  _$CredencialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Credencial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? usuario = null,
    Object? senha = null,
  }) {
    return _then(_value.copyWith(
      usuario: null == usuario
          ? _value.usuario
          : usuario // ignore: cast_nullable_to_non_nullable
              as String,
      senha: null == senha
          ? _value.senha
          : senha // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CredencialImplCopyWith<$Res>
    implements $CredencialCopyWith<$Res> {
  factory _$$CredencialImplCopyWith(
          _$CredencialImpl value, $Res Function(_$CredencialImpl) then) =
      __$$CredencialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String usuario, String senha});
}

/// @nodoc
class __$$CredencialImplCopyWithImpl<$Res>
    extends _$CredencialCopyWithImpl<$Res, _$CredencialImpl>
    implements _$$CredencialImplCopyWith<$Res> {
  __$$CredencialImplCopyWithImpl(
      _$CredencialImpl _value, $Res Function(_$CredencialImpl) _then)
      : super(_value, _then);

  /// Create a copy of Credencial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? usuario = null,
    Object? senha = null,
  }) {
    return _then(_$CredencialImpl(
      usuario: null == usuario
          ? _value.usuario
          : usuario // ignore: cast_nullable_to_non_nullable
              as String,
      senha: null == senha
          ? _value.senha
          : senha // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CredencialImpl implements _Credencial {
  const _$CredencialImpl({required this.usuario, required this.senha});

  @override
  final String usuario;
  @override
  final String senha;

  @override
  String toString() {
    return 'Credencial(usuario: $usuario, senha: $senha)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredencialImpl &&
            (identical(other.usuario, usuario) || other.usuario == usuario) &&
            (identical(other.senha, senha) || other.senha == senha));
  }

  @override
  int get hashCode => Object.hash(runtimeType, usuario, senha);

  /// Create a copy of Credencial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CredencialImplCopyWith<_$CredencialImpl> get copyWith =>
      __$$CredencialImplCopyWithImpl<_$CredencialImpl>(this, _$identity);
}

abstract class _Credencial implements Credencial {
  const factory _Credencial(
      {required final String usuario,
      required final String senha}) = _$CredencialImpl;

  @override
  String get usuario;
  @override
  String get senha;

  /// Create a copy of Credencial
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CredencialImplCopyWith<_$CredencialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
