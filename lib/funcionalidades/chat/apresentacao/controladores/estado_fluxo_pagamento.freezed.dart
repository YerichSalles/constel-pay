// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'estado_fluxo_pagamento.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EstadoFluxoPagamento {
  EtapaFluxo get etapa => throw _privateConstructorUsedError;
  List<Mensagem> get mensagens => throw _privateConstructorUsedError;
  Mesa? get mesa => throw _privateConstructorUsedError;
  List<CartaoConsumo> get cartoes => throw _privateConstructorUsedError;
  int get cartoesRestantes => throw _privateConstructorUsedError;
  DadosPix? get dadosPix => throw _privateConstructorUsedError;
  bool get digitando => throw _privateConstructorUsedError;
  bool get copiado => throw _privateConstructorUsedError;

  /// Create a copy of EstadoFluxoPagamento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EstadoFluxoPagamentoCopyWith<EstadoFluxoPagamento> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EstadoFluxoPagamentoCopyWith<$Res> {
  factory $EstadoFluxoPagamentoCopyWith(EstadoFluxoPagamento value,
          $Res Function(EstadoFluxoPagamento) then) =
      _$EstadoFluxoPagamentoCopyWithImpl<$Res, EstadoFluxoPagamento>;
  @useResult
  $Res call(
      {EtapaFluxo etapa,
      List<Mensagem> mensagens,
      Mesa? mesa,
      List<CartaoConsumo> cartoes,
      int cartoesRestantes,
      DadosPix? dadosPix,
      bool digitando,
      bool copiado});

  $MesaCopyWith<$Res>? get mesa;
  $DadosPixCopyWith<$Res>? get dadosPix;
}

/// @nodoc
class _$EstadoFluxoPagamentoCopyWithImpl<$Res,
        $Val extends EstadoFluxoPagamento>
    implements $EstadoFluxoPagamentoCopyWith<$Res> {
  _$EstadoFluxoPagamentoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EstadoFluxoPagamento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? etapa = null,
    Object? mensagens = null,
    Object? mesa = freezed,
    Object? cartoes = null,
    Object? cartoesRestantes = null,
    Object? dadosPix = freezed,
    Object? digitando = null,
    Object? copiado = null,
  }) {
    return _then(_value.copyWith(
      etapa: null == etapa
          ? _value.etapa
          : etapa // ignore: cast_nullable_to_non_nullable
              as EtapaFluxo,
      mensagens: null == mensagens
          ? _value.mensagens
          : mensagens // ignore: cast_nullable_to_non_nullable
              as List<Mensagem>,
      mesa: freezed == mesa
          ? _value.mesa
          : mesa // ignore: cast_nullable_to_non_nullable
              as Mesa?,
      cartoes: null == cartoes
          ? _value.cartoes
          : cartoes // ignore: cast_nullable_to_non_nullable
              as List<CartaoConsumo>,
      cartoesRestantes: null == cartoesRestantes
          ? _value.cartoesRestantes
          : cartoesRestantes // ignore: cast_nullable_to_non_nullable
              as int,
      dadosPix: freezed == dadosPix
          ? _value.dadosPix
          : dadosPix // ignore: cast_nullable_to_non_nullable
              as DadosPix?,
      digitando: null == digitando
          ? _value.digitando
          : digitando // ignore: cast_nullable_to_non_nullable
              as bool,
      copiado: null == copiado
          ? _value.copiado
          : copiado // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of EstadoFluxoPagamento
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MesaCopyWith<$Res>? get mesa {
    if (_value.mesa == null) {
      return null;
    }

    return $MesaCopyWith<$Res>(_value.mesa!, (value) {
      return _then(_value.copyWith(mesa: value) as $Val);
    });
  }

  /// Create a copy of EstadoFluxoPagamento
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DadosPixCopyWith<$Res>? get dadosPix {
    if (_value.dadosPix == null) {
      return null;
    }

    return $DadosPixCopyWith<$Res>(_value.dadosPix!, (value) {
      return _then(_value.copyWith(dadosPix: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EstadoFluxoPagamentoImplCopyWith<$Res>
    implements $EstadoFluxoPagamentoCopyWith<$Res> {
  factory _$$EstadoFluxoPagamentoImplCopyWith(_$EstadoFluxoPagamentoImpl value,
          $Res Function(_$EstadoFluxoPagamentoImpl) then) =
      __$$EstadoFluxoPagamentoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {EtapaFluxo etapa,
      List<Mensagem> mensagens,
      Mesa? mesa,
      List<CartaoConsumo> cartoes,
      int cartoesRestantes,
      DadosPix? dadosPix,
      bool digitando,
      bool copiado});

  @override
  $MesaCopyWith<$Res>? get mesa;
  @override
  $DadosPixCopyWith<$Res>? get dadosPix;
}

/// @nodoc
class __$$EstadoFluxoPagamentoImplCopyWithImpl<$Res>
    extends _$EstadoFluxoPagamentoCopyWithImpl<$Res, _$EstadoFluxoPagamentoImpl>
    implements _$$EstadoFluxoPagamentoImplCopyWith<$Res> {
  __$$EstadoFluxoPagamentoImplCopyWithImpl(_$EstadoFluxoPagamentoImpl _value,
      $Res Function(_$EstadoFluxoPagamentoImpl) _then)
      : super(_value, _then);

  /// Create a copy of EstadoFluxoPagamento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? etapa = null,
    Object? mensagens = null,
    Object? mesa = freezed,
    Object? cartoes = null,
    Object? cartoesRestantes = null,
    Object? dadosPix = freezed,
    Object? digitando = null,
    Object? copiado = null,
  }) {
    return _then(_$EstadoFluxoPagamentoImpl(
      etapa: null == etapa
          ? _value.etapa
          : etapa // ignore: cast_nullable_to_non_nullable
              as EtapaFluxo,
      mensagens: null == mensagens
          ? _value._mensagens
          : mensagens // ignore: cast_nullable_to_non_nullable
              as List<Mensagem>,
      mesa: freezed == mesa
          ? _value.mesa
          : mesa // ignore: cast_nullable_to_non_nullable
              as Mesa?,
      cartoes: null == cartoes
          ? _value._cartoes
          : cartoes // ignore: cast_nullable_to_non_nullable
              as List<CartaoConsumo>,
      cartoesRestantes: null == cartoesRestantes
          ? _value.cartoesRestantes
          : cartoesRestantes // ignore: cast_nullable_to_non_nullable
              as int,
      dadosPix: freezed == dadosPix
          ? _value.dadosPix
          : dadosPix // ignore: cast_nullable_to_non_nullable
              as DadosPix?,
      digitando: null == digitando
          ? _value.digitando
          : digitando // ignore: cast_nullable_to_non_nullable
              as bool,
      copiado: null == copiado
          ? _value.copiado
          : copiado // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$EstadoFluxoPagamentoImpl extends _EstadoFluxoPagamento {
  const _$EstadoFluxoPagamentoImpl(
      {this.etapa = EtapaFluxo.inicial,
      final List<Mensagem> mensagens = const [],
      this.mesa,
      final List<CartaoConsumo> cartoes = const [],
      this.cartoesRestantes = 0,
      this.dadosPix,
      this.digitando = false,
      this.copiado = false})
      : _mensagens = mensagens,
        _cartoes = cartoes,
        super._();

  @override
  @JsonKey()
  final EtapaFluxo etapa;
  final List<Mensagem> _mensagens;
  @override
  @JsonKey()
  List<Mensagem> get mensagens {
    if (_mensagens is EqualUnmodifiableListView) return _mensagens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mensagens);
  }

  @override
  final Mesa? mesa;
  final List<CartaoConsumo> _cartoes;
  @override
  @JsonKey()
  List<CartaoConsumo> get cartoes {
    if (_cartoes is EqualUnmodifiableListView) return _cartoes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cartoes);
  }

  @override
  @JsonKey()
  final int cartoesRestantes;
  @override
  final DadosPix? dadosPix;
  @override
  @JsonKey()
  final bool digitando;
  @override
  @JsonKey()
  final bool copiado;

  @override
  String toString() {
    return 'EstadoFluxoPagamento(etapa: $etapa, mensagens: $mensagens, mesa: $mesa, cartoes: $cartoes, cartoesRestantes: $cartoesRestantes, dadosPix: $dadosPix, digitando: $digitando, copiado: $copiado)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EstadoFluxoPagamentoImpl &&
            (identical(other.etapa, etapa) || other.etapa == etapa) &&
            const DeepCollectionEquality()
                .equals(other._mensagens, _mensagens) &&
            (identical(other.mesa, mesa) || other.mesa == mesa) &&
            const DeepCollectionEquality().equals(other._cartoes, _cartoes) &&
            (identical(other.cartoesRestantes, cartoesRestantes) ||
                other.cartoesRestantes == cartoesRestantes) &&
            (identical(other.dadosPix, dadosPix) ||
                other.dadosPix == dadosPix) &&
            (identical(other.digitando, digitando) ||
                other.digitando == digitando) &&
            (identical(other.copiado, copiado) || other.copiado == copiado));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      etapa,
      const DeepCollectionEquality().hash(_mensagens),
      mesa,
      const DeepCollectionEquality().hash(_cartoes),
      cartoesRestantes,
      dadosPix,
      digitando,
      copiado);

  /// Create a copy of EstadoFluxoPagamento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EstadoFluxoPagamentoImplCopyWith<_$EstadoFluxoPagamentoImpl>
      get copyWith =>
          __$$EstadoFluxoPagamentoImplCopyWithImpl<_$EstadoFluxoPagamentoImpl>(
              this, _$identity);
}

abstract class _EstadoFluxoPagamento extends EstadoFluxoPagamento {
  const factory _EstadoFluxoPagamento(
      {final EtapaFluxo etapa,
      final List<Mensagem> mensagens,
      final Mesa? mesa,
      final List<CartaoConsumo> cartoes,
      final int cartoesRestantes,
      final DadosPix? dadosPix,
      final bool digitando,
      final bool copiado}) = _$EstadoFluxoPagamentoImpl;
  const _EstadoFluxoPagamento._() : super._();

  @override
  EtapaFluxo get etapa;
  @override
  List<Mensagem> get mensagens;
  @override
  Mesa? get mesa;
  @override
  List<CartaoConsumo> get cartoes;
  @override
  int get cartoesRestantes;
  @override
  DadosPix? get dadosPix;
  @override
  bool get digitando;
  @override
  bool get copiado;

  /// Create a copy of EstadoFluxoPagamento
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EstadoFluxoPagamentoImplCopyWith<_$EstadoFluxoPagamentoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
