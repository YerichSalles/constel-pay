// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'controlador_propaganda.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EstadoPropaganda {
  List<MidiaPropaganda> get midias => throw _privateConstructorUsedError;
  int get indice => throw _privateConstructorUsedError;
  bool get carregando => throw _privateConstructorUsedError;

  /// Create a copy of EstadoPropaganda
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EstadoPropagandaCopyWith<EstadoPropaganda> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EstadoPropagandaCopyWith<$Res> {
  factory $EstadoPropagandaCopyWith(
          EstadoPropaganda value, $Res Function(EstadoPropaganda) then) =
      _$EstadoPropagandaCopyWithImpl<$Res, EstadoPropaganda>;
  @useResult
  $Res call({List<MidiaPropaganda> midias, int indice, bool carregando});
}

/// @nodoc
class _$EstadoPropagandaCopyWithImpl<$Res, $Val extends EstadoPropaganda>
    implements $EstadoPropagandaCopyWith<$Res> {
  _$EstadoPropagandaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EstadoPropaganda
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? midias = null,
    Object? indice = null,
    Object? carregando = null,
  }) {
    return _then(_value.copyWith(
      midias: null == midias
          ? _value.midias
          : midias // ignore: cast_nullable_to_non_nullable
              as List<MidiaPropaganda>,
      indice: null == indice
          ? _value.indice
          : indice // ignore: cast_nullable_to_non_nullable
              as int,
      carregando: null == carregando
          ? _value.carregando
          : carregando // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EstadoPropagandaImplCopyWith<$Res>
    implements $EstadoPropagandaCopyWith<$Res> {
  factory _$$EstadoPropagandaImplCopyWith(_$EstadoPropagandaImpl value,
          $Res Function(_$EstadoPropagandaImpl) then) =
      __$$EstadoPropagandaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<MidiaPropaganda> midias, int indice, bool carregando});
}

/// @nodoc
class __$$EstadoPropagandaImplCopyWithImpl<$Res>
    extends _$EstadoPropagandaCopyWithImpl<$Res, _$EstadoPropagandaImpl>
    implements _$$EstadoPropagandaImplCopyWith<$Res> {
  __$$EstadoPropagandaImplCopyWithImpl(_$EstadoPropagandaImpl _value,
      $Res Function(_$EstadoPropagandaImpl) _then)
      : super(_value, _then);

  /// Create a copy of EstadoPropaganda
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? midias = null,
    Object? indice = null,
    Object? carregando = null,
  }) {
    return _then(_$EstadoPropagandaImpl(
      midias: null == midias
          ? _value._midias
          : midias // ignore: cast_nullable_to_non_nullable
              as List<MidiaPropaganda>,
      indice: null == indice
          ? _value.indice
          : indice // ignore: cast_nullable_to_non_nullable
              as int,
      carregando: null == carregando
          ? _value.carregando
          : carregando // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$EstadoPropagandaImpl extends _EstadoPropaganda {
  const _$EstadoPropagandaImpl(
      {final List<MidiaPropaganda> midias = const [],
      this.indice = 0,
      this.carregando = true})
      : _midias = midias,
        super._();

  final List<MidiaPropaganda> _midias;
  @override
  @JsonKey()
  List<MidiaPropaganda> get midias {
    if (_midias is EqualUnmodifiableListView) return _midias;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_midias);
  }

  @override
  @JsonKey()
  final int indice;
  @override
  @JsonKey()
  final bool carregando;

  @override
  String toString() {
    return 'EstadoPropaganda(midias: $midias, indice: $indice, carregando: $carregando)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EstadoPropagandaImpl &&
            const DeepCollectionEquality().equals(other._midias, _midias) &&
            (identical(other.indice, indice) || other.indice == indice) &&
            (identical(other.carregando, carregando) ||
                other.carregando == carregando));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_midias), indice, carregando);

  /// Create a copy of EstadoPropaganda
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EstadoPropagandaImplCopyWith<_$EstadoPropagandaImpl> get copyWith =>
      __$$EstadoPropagandaImplCopyWithImpl<_$EstadoPropagandaImpl>(
          this, _$identity);
}

abstract class _EstadoPropaganda extends EstadoPropaganda {
  const factory _EstadoPropaganda(
      {final List<MidiaPropaganda> midias,
      final int indice,
      final bool carregando}) = _$EstadoPropagandaImpl;
  const _EstadoPropaganda._() : super._();

  @override
  List<MidiaPropaganda> get midias;
  @override
  int get indice;
  @override
  bool get carregando;

  /// Create a copy of EstadoPropaganda
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EstadoPropagandaImplCopyWith<_$EstadoPropagandaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
