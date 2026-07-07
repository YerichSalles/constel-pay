// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mensagem.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Mensagem {
  int get id => throw _privateConstructorUsedError;
  TipoMensagem get tipo => throw _privateConstructorUsedError;
  LadoMensagem get lado => throw _privateConstructorUsedError;
  String? get texto => throw _privateConstructorUsedError;
  String? get subtexto => throw _privateConstructorUsedError;
  String? get emoji => throw _privateConstructorUsedError;
  Map<String, dynamic>? get dados => throw _privateConstructorUsedError;

  /// Create a copy of Mensagem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MensagemCopyWith<Mensagem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MensagemCopyWith<$Res> {
  factory $MensagemCopyWith(Mensagem value, $Res Function(Mensagem) then) =
      _$MensagemCopyWithImpl<$Res, Mensagem>;
  @useResult
  $Res call(
      {int id,
      TipoMensagem tipo,
      LadoMensagem lado,
      String? texto,
      String? subtexto,
      String? emoji,
      Map<String, dynamic>? dados});
}

/// @nodoc
class _$MensagemCopyWithImpl<$Res, $Val extends Mensagem>
    implements $MensagemCopyWith<$Res> {
  _$MensagemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Mensagem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? lado = null,
    Object? texto = freezed,
    Object? subtexto = freezed,
    Object? emoji = freezed,
    Object? dados = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoMensagem,
      lado: null == lado
          ? _value.lado
          : lado // ignore: cast_nullable_to_non_nullable
              as LadoMensagem,
      texto: freezed == texto
          ? _value.texto
          : texto // ignore: cast_nullable_to_non_nullable
              as String?,
      subtexto: freezed == subtexto
          ? _value.subtexto
          : subtexto // ignore: cast_nullable_to_non_nullable
              as String?,
      emoji: freezed == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String?,
      dados: freezed == dados
          ? _value.dados
          : dados // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MensagemImplCopyWith<$Res>
    implements $MensagemCopyWith<$Res> {
  factory _$$MensagemImplCopyWith(
          _$MensagemImpl value, $Res Function(_$MensagemImpl) then) =
      __$$MensagemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      TipoMensagem tipo,
      LadoMensagem lado,
      String? texto,
      String? subtexto,
      String? emoji,
      Map<String, dynamic>? dados});
}

/// @nodoc
class __$$MensagemImplCopyWithImpl<$Res>
    extends _$MensagemCopyWithImpl<$Res, _$MensagemImpl>
    implements _$$MensagemImplCopyWith<$Res> {
  __$$MensagemImplCopyWithImpl(
      _$MensagemImpl _value, $Res Function(_$MensagemImpl) _then)
      : super(_value, _then);

  /// Create a copy of Mensagem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? lado = null,
    Object? texto = freezed,
    Object? subtexto = freezed,
    Object? emoji = freezed,
    Object? dados = freezed,
  }) {
    return _then(_$MensagemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoMensagem,
      lado: null == lado
          ? _value.lado
          : lado // ignore: cast_nullable_to_non_nullable
              as LadoMensagem,
      texto: freezed == texto
          ? _value.texto
          : texto // ignore: cast_nullable_to_non_nullable
              as String?,
      subtexto: freezed == subtexto
          ? _value.subtexto
          : subtexto // ignore: cast_nullable_to_non_nullable
              as String?,
      emoji: freezed == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String?,
      dados: freezed == dados
          ? _value._dados
          : dados // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$MensagemImpl implements _Mensagem {
  const _$MensagemImpl(
      {required this.id,
      required this.tipo,
      this.lado = LadoMensagem.assistente,
      this.texto,
      this.subtexto,
      this.emoji,
      final Map<String, dynamic>? dados})
      : _dados = dados;

  @override
  final int id;
  @override
  final TipoMensagem tipo;
  @override
  @JsonKey()
  final LadoMensagem lado;
  @override
  final String? texto;
  @override
  final String? subtexto;
  @override
  final String? emoji;
  final Map<String, dynamic>? _dados;
  @override
  Map<String, dynamic>? get dados {
    final value = _dados;
    if (value == null) return null;
    if (_dados is EqualUnmodifiableMapView) return _dados;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Mensagem(id: $id, tipo: $tipo, lado: $lado, texto: $texto, subtexto: $subtexto, emoji: $emoji, dados: $dados)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MensagemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.lado, lado) || other.lado == lado) &&
            (identical(other.texto, texto) || other.texto == texto) &&
            (identical(other.subtexto, subtexto) ||
                other.subtexto == subtexto) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            const DeepCollectionEquality().equals(other._dados, _dados));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, tipo, lado, texto, subtexto,
      emoji, const DeepCollectionEquality().hash(_dados));

  /// Create a copy of Mensagem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MensagemImplCopyWith<_$MensagemImpl> get copyWith =>
      __$$MensagemImplCopyWithImpl<_$MensagemImpl>(this, _$identity);
}

abstract class _Mensagem implements Mensagem {
  const factory _Mensagem(
      {required final int id,
      required final TipoMensagem tipo,
      final LadoMensagem lado,
      final String? texto,
      final String? subtexto,
      final String? emoji,
      final Map<String, dynamic>? dados}) = _$MensagemImpl;

  @override
  int get id;
  @override
  TipoMensagem get tipo;
  @override
  LadoMensagem get lado;
  @override
  String? get texto;
  @override
  String? get subtexto;
  @override
  String? get emoji;
  @override
  Map<String, dynamic>? get dados;

  /// Create a copy of Mensagem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MensagemImplCopyWith<_$MensagemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
