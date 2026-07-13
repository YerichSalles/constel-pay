// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cartao_consumo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CartaoConsumo {
  String get id => throw _privateConstructorUsedError;
  String get codigo => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;
  String get pessoa => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  String get resumo => throw _privateConstructorUsedError;
  List<ItemConsumo> get itens =>
      throw _privateConstructorUsedError; // Valores vêm prontos da API (venda/atendimento/colecao). Nunca recalcular:
// a regra de serviço/desconto é do retaguarda. `saldoCentavos` é o devido.
  int get subtotalCentavos => throw _privateConstructorUsedError;
  int get servicoCentavos => throw _privateConstructorUsedError;

  /// Percentual da taxa de serviço definido pelo retaguarda (pode não ser 10).
  num get servicoPercentual => throw _privateConstructorUsedError;
  int get descontoCentavos => throw _privateConstructorUsedError;
  int get totalCentavos => throw _privateConstructorUsedError;
  int get saldoCentavos => throw _privateConstructorUsedError;
  bool get selecionado => throw _privateConstructorUsedError;
  bool get pago => throw _privateConstructorUsedError;

  /// Create a copy of CartaoConsumo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartaoConsumoCopyWith<CartaoConsumo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartaoConsumoCopyWith<$Res> {
  factory $CartaoConsumoCopyWith(
          CartaoConsumo value, $Res Function(CartaoConsumo) then) =
      _$CartaoConsumoCopyWithImpl<$Res, CartaoConsumo>;
  @useResult
  $Res call(
      {String id,
      String codigo,
      String nome,
      String pessoa,
      String emoji,
      String resumo,
      List<ItemConsumo> itens,
      int subtotalCentavos,
      int servicoCentavos,
      num servicoPercentual,
      int descontoCentavos,
      int totalCentavos,
      int saldoCentavos,
      bool selecionado,
      bool pago});
}

/// @nodoc
class _$CartaoConsumoCopyWithImpl<$Res, $Val extends CartaoConsumo>
    implements $CartaoConsumoCopyWith<$Res> {
  _$CartaoConsumoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartaoConsumo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? nome = null,
    Object? pessoa = null,
    Object? emoji = null,
    Object? resumo = null,
    Object? itens = null,
    Object? subtotalCentavos = null,
    Object? servicoCentavos = null,
    Object? servicoPercentual = null,
    Object? descontoCentavos = null,
    Object? totalCentavos = null,
    Object? saldoCentavos = null,
    Object? selecionado = null,
    Object? pago = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: null == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
      pessoa: null == pessoa
          ? _value.pessoa
          : pessoa // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      resumo: null == resumo
          ? _value.resumo
          : resumo // ignore: cast_nullable_to_non_nullable
              as String,
      itens: null == itens
          ? _value.itens
          : itens // ignore: cast_nullable_to_non_nullable
              as List<ItemConsumo>,
      subtotalCentavos: null == subtotalCentavos
          ? _value.subtotalCentavos
          : subtotalCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      servicoCentavos: null == servicoCentavos
          ? _value.servicoCentavos
          : servicoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      servicoPercentual: null == servicoPercentual
          ? _value.servicoPercentual
          : servicoPercentual // ignore: cast_nullable_to_non_nullable
              as num,
      descontoCentavos: null == descontoCentavos
          ? _value.descontoCentavos
          : descontoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      totalCentavos: null == totalCentavos
          ? _value.totalCentavos
          : totalCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      saldoCentavos: null == saldoCentavos
          ? _value.saldoCentavos
          : saldoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      selecionado: null == selecionado
          ? _value.selecionado
          : selecionado // ignore: cast_nullable_to_non_nullable
              as bool,
      pago: null == pago
          ? _value.pago
          : pago // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CartaoConsumoImplCopyWith<$Res>
    implements $CartaoConsumoCopyWith<$Res> {
  factory _$$CartaoConsumoImplCopyWith(
          _$CartaoConsumoImpl value, $Res Function(_$CartaoConsumoImpl) then) =
      __$$CartaoConsumoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String codigo,
      String nome,
      String pessoa,
      String emoji,
      String resumo,
      List<ItemConsumo> itens,
      int subtotalCentavos,
      int servicoCentavos,
      num servicoPercentual,
      int descontoCentavos,
      int totalCentavos,
      int saldoCentavos,
      bool selecionado,
      bool pago});
}

/// @nodoc
class __$$CartaoConsumoImplCopyWithImpl<$Res>
    extends _$CartaoConsumoCopyWithImpl<$Res, _$CartaoConsumoImpl>
    implements _$$CartaoConsumoImplCopyWith<$Res> {
  __$$CartaoConsumoImplCopyWithImpl(
      _$CartaoConsumoImpl _value, $Res Function(_$CartaoConsumoImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartaoConsumo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? nome = null,
    Object? pessoa = null,
    Object? emoji = null,
    Object? resumo = null,
    Object? itens = null,
    Object? subtotalCentavos = null,
    Object? servicoCentavos = null,
    Object? servicoPercentual = null,
    Object? descontoCentavos = null,
    Object? totalCentavos = null,
    Object? saldoCentavos = null,
    Object? selecionado = null,
    Object? pago = null,
  }) {
    return _then(_$CartaoConsumoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: null == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
      pessoa: null == pessoa
          ? _value.pessoa
          : pessoa // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      resumo: null == resumo
          ? _value.resumo
          : resumo // ignore: cast_nullable_to_non_nullable
              as String,
      itens: null == itens
          ? _value._itens
          : itens // ignore: cast_nullable_to_non_nullable
              as List<ItemConsumo>,
      subtotalCentavos: null == subtotalCentavos
          ? _value.subtotalCentavos
          : subtotalCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      servicoCentavos: null == servicoCentavos
          ? _value.servicoCentavos
          : servicoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      servicoPercentual: null == servicoPercentual
          ? _value.servicoPercentual
          : servicoPercentual // ignore: cast_nullable_to_non_nullable
              as num,
      descontoCentavos: null == descontoCentavos
          ? _value.descontoCentavos
          : descontoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      totalCentavos: null == totalCentavos
          ? _value.totalCentavos
          : totalCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      saldoCentavos: null == saldoCentavos
          ? _value.saldoCentavos
          : saldoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      selecionado: null == selecionado
          ? _value.selecionado
          : selecionado // ignore: cast_nullable_to_non_nullable
              as bool,
      pago: null == pago
          ? _value.pago
          : pago // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$CartaoConsumoImpl implements _CartaoConsumo {
  const _$CartaoConsumoImpl(
      {required this.id,
      required this.codigo,
      required this.nome,
      required this.pessoa,
      required this.emoji,
      required this.resumo,
      required final List<ItemConsumo> itens,
      required this.subtotalCentavos,
      required this.servicoCentavos,
      this.servicoPercentual = 0,
      required this.descontoCentavos,
      required this.totalCentavos,
      required this.saldoCentavos,
      this.selecionado = false,
      this.pago = false})
      : _itens = itens;

  @override
  final String id;
  @override
  final String codigo;
  @override
  final String nome;
  @override
  final String pessoa;
  @override
  final String emoji;
  @override
  final String resumo;
  final List<ItemConsumo> _itens;
  @override
  List<ItemConsumo> get itens {
    if (_itens is EqualUnmodifiableListView) return _itens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itens);
  }

// Valores vêm prontos da API (venda/atendimento/colecao). Nunca recalcular:
// a regra de serviço/desconto é do retaguarda. `saldoCentavos` é o devido.
  @override
  final int subtotalCentavos;
  @override
  final int servicoCentavos;

  /// Percentual da taxa de serviço definido pelo retaguarda (pode não ser 10).
  @override
  @JsonKey()
  final num servicoPercentual;
  @override
  final int descontoCentavos;
  @override
  final int totalCentavos;
  @override
  final int saldoCentavos;
  @override
  @JsonKey()
  final bool selecionado;
  @override
  @JsonKey()
  final bool pago;

  @override
  String toString() {
    return 'CartaoConsumo(id: $id, codigo: $codigo, nome: $nome, pessoa: $pessoa, emoji: $emoji, resumo: $resumo, itens: $itens, subtotalCentavos: $subtotalCentavos, servicoCentavos: $servicoCentavos, servicoPercentual: $servicoPercentual, descontoCentavos: $descontoCentavos, totalCentavos: $totalCentavos, saldoCentavos: $saldoCentavos, selecionado: $selecionado, pago: $pago)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartaoConsumoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.pessoa, pessoa) || other.pessoa == pessoa) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.resumo, resumo) || other.resumo == resumo) &&
            const DeepCollectionEquality().equals(other._itens, _itens) &&
            (identical(other.subtotalCentavos, subtotalCentavos) ||
                other.subtotalCentavos == subtotalCentavos) &&
            (identical(other.servicoCentavos, servicoCentavos) ||
                other.servicoCentavos == servicoCentavos) &&
            (identical(other.servicoPercentual, servicoPercentual) ||
                other.servicoPercentual == servicoPercentual) &&
            (identical(other.descontoCentavos, descontoCentavos) ||
                other.descontoCentavos == descontoCentavos) &&
            (identical(other.totalCentavos, totalCentavos) ||
                other.totalCentavos == totalCentavos) &&
            (identical(other.saldoCentavos, saldoCentavos) ||
                other.saldoCentavos == saldoCentavos) &&
            (identical(other.selecionado, selecionado) ||
                other.selecionado == selecionado) &&
            (identical(other.pago, pago) || other.pago == pago));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      codigo,
      nome,
      pessoa,
      emoji,
      resumo,
      const DeepCollectionEquality().hash(_itens),
      subtotalCentavos,
      servicoCentavos,
      servicoPercentual,
      descontoCentavos,
      totalCentavos,
      saldoCentavos,
      selecionado,
      pago);

  /// Create a copy of CartaoConsumo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartaoConsumoImplCopyWith<_$CartaoConsumoImpl> get copyWith =>
      __$$CartaoConsumoImplCopyWithImpl<_$CartaoConsumoImpl>(this, _$identity);
}

abstract class _CartaoConsumo implements CartaoConsumo {
  const factory _CartaoConsumo(
      {required final String id,
      required final String codigo,
      required final String nome,
      required final String pessoa,
      required final String emoji,
      required final String resumo,
      required final List<ItemConsumo> itens,
      required final int subtotalCentavos,
      required final int servicoCentavos,
      final num servicoPercentual,
      required final int descontoCentavos,
      required final int totalCentavos,
      required final int saldoCentavos,
      final bool selecionado,
      final bool pago}) = _$CartaoConsumoImpl;

  @override
  String get id;
  @override
  String get codigo;
  @override
  String get nome;
  @override
  String get pessoa;
  @override
  String get emoji;
  @override
  String get resumo;
  @override
  List<ItemConsumo>
      get itens; // Valores vêm prontos da API (venda/atendimento/colecao). Nunca recalcular:
// a regra de serviço/desconto é do retaguarda. `saldoCentavos` é o devido.
  @override
  int get subtotalCentavos;
  @override
  int get servicoCentavos;

  /// Percentual da taxa de serviço definido pelo retaguarda (pode não ser 10).
  @override
  num get servicoPercentual;
  @override
  int get descontoCentavos;
  @override
  int get totalCentavos;
  @override
  int get saldoCentavos;
  @override
  bool get selecionado;
  @override
  bool get pago;

  /// Create a copy of CartaoConsumo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartaoConsumoImplCopyWith<_$CartaoConsumoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
