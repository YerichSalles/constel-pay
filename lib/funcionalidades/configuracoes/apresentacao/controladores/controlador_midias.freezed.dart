// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'controlador_midias.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EstadoMidias {
  List<MidiaPropaganda> get midias => throw _privateConstructorUsedError;
  bool get carregando => throw _privateConstructorUsedError;

  /// Create a copy of EstadoMidias
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EstadoMidiasCopyWith<EstadoMidias> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EstadoMidiasCopyWith<$Res> {
  factory $EstadoMidiasCopyWith(
          EstadoMidias value, $Res Function(EstadoMidias) then) =
      _$EstadoMidiasCopyWithImpl<$Res, EstadoMidias>;
  @useResult
  $Res call({List<MidiaPropaganda> midias, bool carregando});
}

/// @nodoc
class _$EstadoMidiasCopyWithImpl<$Res, $Val extends EstadoMidias>
    implements $EstadoMidiasCopyWith<$Res> {
  _$EstadoMidiasCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EstadoMidias
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? midias = null,
    Object? carregando = null,
  }) {
    return _then(_value.copyWith(
      midias: null == midias
          ? _value.midias
          : midias // ignore: cast_nullable_to_non_nullable
              as List<MidiaPropaganda>,
      carregando: null == carregando
          ? _value.carregando
          : carregando // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EstadoMidiasImplCopyWith<$Res>
    implements $EstadoMidiasCopyWith<$Res> {
  factory _$$EstadoMidiasImplCopyWith(
          _$EstadoMidiasImpl value, $Res Function(_$EstadoMidiasImpl) then) =
      __$$EstadoMidiasImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<MidiaPropaganda> midias, bool carregando});
}

/// @nodoc
class __$$EstadoMidiasImplCopyWithImpl<$Res>
    extends _$EstadoMidiasCopyWithImpl<$Res, _$EstadoMidiasImpl>
    implements _$$EstadoMidiasImplCopyWith<$Res> {
  __$$EstadoMidiasImplCopyWithImpl(
      _$EstadoMidiasImpl _value, $Res Function(_$EstadoMidiasImpl) _then)
      : super(_value, _then);

  /// Create a copy of EstadoMidias
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? midias = null,
    Object? carregando = null,
  }) {
    return _then(_$EstadoMidiasImpl(
      midias: null == midias
          ? _value._midias
          : midias // ignore: cast_nullable_to_non_nullable
              as List<MidiaPropaganda>,
      carregando: null == carregando
          ? _value.carregando
          : carregando // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$EstadoMidiasImpl implements _EstadoMidias {
  const _$EstadoMidiasImpl(
      {final List<MidiaPropaganda> midias = const [], this.carregando = true})
      : _midias = midias;

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
  final bool carregando;

  @override
  String toString() {
    return 'EstadoMidias(midias: $midias, carregando: $carregando)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EstadoMidiasImpl &&
            const DeepCollectionEquality().equals(other._midias, _midias) &&
            (identical(other.carregando, carregando) ||
                other.carregando == carregando));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_midias), carregando);

  /// Create a copy of EstadoMidias
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EstadoMidiasImplCopyWith<_$EstadoMidiasImpl> get copyWith =>
      __$$EstadoMidiasImplCopyWithImpl<_$EstadoMidiasImpl>(this, _$identity);
}

abstract class _EstadoMidias implements EstadoMidias {
  const factory _EstadoMidias(
      {final List<MidiaPropaganda> midias,
      final bool carregando}) = _$EstadoMidiasImpl;

  @override
  List<MidiaPropaganda> get midias;
  @override
  bool get carregando;

  /// Create a copy of EstadoMidias
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EstadoMidiasImplCopyWith<_$EstadoMidiasImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
