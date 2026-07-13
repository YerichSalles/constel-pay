// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_consumo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ItemConsumo {
  String get emoji => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;
  int get quantidade => throw _privateConstructorUsedError;
  int get valorCentavos => throw _privateConstructorUsedError;

  /// Id do cadastro do item; vazio no mock. Usado para buscar a foto.
  String get itemId => throw _privateConstructorUsedError;

  /// URL pública da foto (campo `imagem` de `recurso/item/{itemId}`).
  /// Vazia quando o item não tem foto — a UI cai no emoji.
  String get imagemUrl => throw _privateConstructorUsedError;

  /// Create a copy of ItemConsumo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemConsumoCopyWith<ItemConsumo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemConsumoCopyWith<$Res> {
  factory $ItemConsumoCopyWith(
          ItemConsumo value, $Res Function(ItemConsumo) then) =
      _$ItemConsumoCopyWithImpl<$Res, ItemConsumo>;
  @useResult
  $Res call(
      {String emoji,
      String nome,
      int quantidade,
      int valorCentavos,
      String itemId,
      String imagemUrl});
}

/// @nodoc
class _$ItemConsumoCopyWithImpl<$Res, $Val extends ItemConsumo>
    implements $ItemConsumoCopyWith<$Res> {
  _$ItemConsumoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItemConsumo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emoji = null,
    Object? nome = null,
    Object? quantidade = null,
    Object? valorCentavos = null,
    Object? itemId = null,
    Object? imagemUrl = null,
  }) {
    return _then(_value.copyWith(
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
      quantidade: null == quantidade
          ? _value.quantidade
          : quantidade // ignore: cast_nullable_to_non_nullable
              as int,
      valorCentavos: null == valorCentavos
          ? _value.valorCentavos
          : valorCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      imagemUrl: null == imagemUrl
          ? _value.imagemUrl
          : imagemUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItemConsumoImplCopyWith<$Res>
    implements $ItemConsumoCopyWith<$Res> {
  factory _$$ItemConsumoImplCopyWith(
          _$ItemConsumoImpl value, $Res Function(_$ItemConsumoImpl) then) =
      __$$ItemConsumoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String emoji,
      String nome,
      int quantidade,
      int valorCentavos,
      String itemId,
      String imagemUrl});
}

/// @nodoc
class __$$ItemConsumoImplCopyWithImpl<$Res>
    extends _$ItemConsumoCopyWithImpl<$Res, _$ItemConsumoImpl>
    implements _$$ItemConsumoImplCopyWith<$Res> {
  __$$ItemConsumoImplCopyWithImpl(
      _$ItemConsumoImpl _value, $Res Function(_$ItemConsumoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItemConsumo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emoji = null,
    Object? nome = null,
    Object? quantidade = null,
    Object? valorCentavos = null,
    Object? itemId = null,
    Object? imagemUrl = null,
  }) {
    return _then(_$ItemConsumoImpl(
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
      quantidade: null == quantidade
          ? _value.quantidade
          : quantidade // ignore: cast_nullable_to_non_nullable
              as int,
      valorCentavos: null == valorCentavos
          ? _value.valorCentavos
          : valorCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      imagemUrl: null == imagemUrl
          ? _value.imagemUrl
          : imagemUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ItemConsumoImpl extends _ItemConsumo {
  const _$ItemConsumoImpl(
      {required this.emoji,
      required this.nome,
      required this.quantidade,
      required this.valorCentavos,
      this.itemId = '',
      this.imagemUrl = ''})
      : super._();

  @override
  final String emoji;
  @override
  final String nome;
  @override
  final int quantidade;
  @override
  final int valorCentavos;

  /// Id do cadastro do item; vazio no mock. Usado para buscar a foto.
  @override
  @JsonKey()
  final String itemId;

  /// URL pública da foto (campo `imagem` de `recurso/item/{itemId}`).
  /// Vazia quando o item não tem foto — a UI cai no emoji.
  @override
  @JsonKey()
  final String imagemUrl;

  @override
  String toString() {
    return 'ItemConsumo(emoji: $emoji, nome: $nome, quantidade: $quantidade, valorCentavos: $valorCentavos, itemId: $itemId, imagemUrl: $imagemUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemConsumoImpl &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.quantidade, quantidade) ||
                other.quantidade == quantidade) &&
            (identical(other.valorCentavos, valorCentavos) ||
                other.valorCentavos == valorCentavos) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.imagemUrl, imagemUrl) ||
                other.imagemUrl == imagemUrl));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, emoji, nome, quantidade, valorCentavos, itemId, imagemUrl);

  /// Create a copy of ItemConsumo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemConsumoImplCopyWith<_$ItemConsumoImpl> get copyWith =>
      __$$ItemConsumoImplCopyWithImpl<_$ItemConsumoImpl>(this, _$identity);
}

abstract class _ItemConsumo extends ItemConsumo {
  const factory _ItemConsumo(
      {required final String emoji,
      required final String nome,
      required final int quantidade,
      required final int valorCentavos,
      final String itemId,
      final String imagemUrl}) = _$ItemConsumoImpl;
  const _ItemConsumo._() : super._();

  @override
  String get emoji;
  @override
  String get nome;
  @override
  int get quantidade;
  @override
  int get valorCentavos;

  /// Id do cadastro do item; vazio no mock. Usado para buscar a foto.
  @override
  String get itemId;

  /// URL pública da foto (campo `imagem` de `recurso/item/{itemId}`).
  /// Vazia quando o item não tem foto — a UI cai no emoji.
  @override
  String get imagemUrl;

  /// Create a copy of ItemConsumo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemConsumoImplCopyWith<_$ItemConsumoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
