// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'controlador_publicidade.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EstadoPublicidade {
  PublicidadeBarra get salva => throw _privateConstructorUsedError;
  PublicidadeBarra get rascunho => throw _privateConstructorUsedError;
  bool get carregando => throw _privateConstructorUsedError;

  /// Create a copy of EstadoPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EstadoPublicidadeCopyWith<EstadoPublicidade> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EstadoPublicidadeCopyWith<$Res> {
  factory $EstadoPublicidadeCopyWith(
          EstadoPublicidade value, $Res Function(EstadoPublicidade) then) =
      _$EstadoPublicidadeCopyWithImpl<$Res, EstadoPublicidade>;
  @useResult
  $Res call(
      {PublicidadeBarra salva, PublicidadeBarra rascunho, bool carregando});

  $PublicidadeBarraCopyWith<$Res> get salva;
  $PublicidadeBarraCopyWith<$Res> get rascunho;
}

/// @nodoc
class _$EstadoPublicidadeCopyWithImpl<$Res, $Val extends EstadoPublicidade>
    implements $EstadoPublicidadeCopyWith<$Res> {
  _$EstadoPublicidadeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EstadoPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? salva = null,
    Object? rascunho = null,
    Object? carregando = null,
  }) {
    return _then(_value.copyWith(
      salva: null == salva
          ? _value.salva
          : salva // ignore: cast_nullable_to_non_nullable
              as PublicidadeBarra,
      rascunho: null == rascunho
          ? _value.rascunho
          : rascunho // ignore: cast_nullable_to_non_nullable
              as PublicidadeBarra,
      carregando: null == carregando
          ? _value.carregando
          : carregando // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of EstadoPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PublicidadeBarraCopyWith<$Res> get salva {
    return $PublicidadeBarraCopyWith<$Res>(_value.salva, (value) {
      return _then(_value.copyWith(salva: value) as $Val);
    });
  }

  /// Create a copy of EstadoPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PublicidadeBarraCopyWith<$Res> get rascunho {
    return $PublicidadeBarraCopyWith<$Res>(_value.rascunho, (value) {
      return _then(_value.copyWith(rascunho: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EstadoPublicidadeImplCopyWith<$Res>
    implements $EstadoPublicidadeCopyWith<$Res> {
  factory _$$EstadoPublicidadeImplCopyWith(_$EstadoPublicidadeImpl value,
          $Res Function(_$EstadoPublicidadeImpl) then) =
      __$$EstadoPublicidadeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PublicidadeBarra salva, PublicidadeBarra rascunho, bool carregando});

  @override
  $PublicidadeBarraCopyWith<$Res> get salva;
  @override
  $PublicidadeBarraCopyWith<$Res> get rascunho;
}

/// @nodoc
class __$$EstadoPublicidadeImplCopyWithImpl<$Res>
    extends _$EstadoPublicidadeCopyWithImpl<$Res, _$EstadoPublicidadeImpl>
    implements _$$EstadoPublicidadeImplCopyWith<$Res> {
  __$$EstadoPublicidadeImplCopyWithImpl(_$EstadoPublicidadeImpl _value,
      $Res Function(_$EstadoPublicidadeImpl) _then)
      : super(_value, _then);

  /// Create a copy of EstadoPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? salva = null,
    Object? rascunho = null,
    Object? carregando = null,
  }) {
    return _then(_$EstadoPublicidadeImpl(
      salva: null == salva
          ? _value.salva
          : salva // ignore: cast_nullable_to_non_nullable
              as PublicidadeBarra,
      rascunho: null == rascunho
          ? _value.rascunho
          : rascunho // ignore: cast_nullable_to_non_nullable
              as PublicidadeBarra,
      carregando: null == carregando
          ? _value.carregando
          : carregando // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$EstadoPublicidadeImpl extends _EstadoPublicidade {
  const _$EstadoPublicidadeImpl(
      {this.salva = const PublicidadeBarra(),
      this.rascunho = const PublicidadeBarra(),
      this.carregando = true})
      : super._();

  @override
  @JsonKey()
  final PublicidadeBarra salva;
  @override
  @JsonKey()
  final PublicidadeBarra rascunho;
  @override
  @JsonKey()
  final bool carregando;

  @override
  String toString() {
    return 'EstadoPublicidade(salva: $salva, rascunho: $rascunho, carregando: $carregando)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EstadoPublicidadeImpl &&
            (identical(other.salva, salva) || other.salva == salva) &&
            (identical(other.rascunho, rascunho) ||
                other.rascunho == rascunho) &&
            (identical(other.carregando, carregando) ||
                other.carregando == carregando));
  }

  @override
  int get hashCode => Object.hash(runtimeType, salva, rascunho, carregando);

  /// Create a copy of EstadoPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EstadoPublicidadeImplCopyWith<_$EstadoPublicidadeImpl> get copyWith =>
      __$$EstadoPublicidadeImplCopyWithImpl<_$EstadoPublicidadeImpl>(
          this, _$identity);
}

abstract class _EstadoPublicidade extends EstadoPublicidade {
  const factory _EstadoPublicidade(
      {final PublicidadeBarra salva,
      final PublicidadeBarra rascunho,
      final bool carregando}) = _$EstadoPublicidadeImpl;
  const _EstadoPublicidade._() : super._();

  @override
  PublicidadeBarra get salva;
  @override
  PublicidadeBarra get rascunho;
  @override
  bool get carregando;

  /// Create a copy of EstadoPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EstadoPublicidadeImplCopyWith<_$EstadoPublicidadeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
