// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resultado_transacao.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ResultadoTransacao {
  StatusPagamento get status => throw _privateConstructorUsedError;
  MetodoPagamento get metodo => throw _privateConstructorUsedError;

  /// Sempre em centavos (`int`): valor financeiro não passa por `double`.
  int get valorCentavos => throw _privateConstructorUsedError;
  int get parcelas => throw _privateConstructorUsedError;
  String get codigoAutorizacao => throw _privateConstructorUsedError;
  String get nsu => throw _privateConstructorUsedError;
  String get bandeira => throw _privateConstructorUsedError;

  /// Apenas os 4 últimos dígitos, já mascarados pelo lado nativo. O número
  /// completo, a trilha e qualquer dado do portador NUNCA atravessam o canal
  /// nem são gravados.
  String get finalCartao => throw _privateConstructorUsedError;

  /// Rótulo da adquirente para exibição no comprovante.
  String get adquirente => throw _privateConstructorUsedError;

  /// Texto vindo da adquirente para o operador. É conteúdo de terceiro:
  /// exibir como veio, sem interpretar.
  String get mensagemOperador => throw _privateConstructorUsedError;

  /// Identificador `atk` devolvido pela Stone no deep link de retorno.
  /// Capturado só para diagnóstico — sem uso definido no payload da
  /// fatura ainda.
  String get tokenTransacao => throw _privateConstructorUsedError;

  /// Create a copy of ResultadoTransacao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultadoTransacaoCopyWith<ResultadoTransacao> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultadoTransacaoCopyWith<$Res> {
  factory $ResultadoTransacaoCopyWith(
          ResultadoTransacao value, $Res Function(ResultadoTransacao) then) =
      _$ResultadoTransacaoCopyWithImpl<$Res, ResultadoTransacao>;
  @useResult
  $Res call(
      {StatusPagamento status,
      MetodoPagamento metodo,
      int valorCentavos,
      int parcelas,
      String codigoAutorizacao,
      String nsu,
      String bandeira,
      String finalCartao,
      String adquirente,
      String mensagemOperador,
      String tokenTransacao});
}

/// @nodoc
class _$ResultadoTransacaoCopyWithImpl<$Res, $Val extends ResultadoTransacao>
    implements $ResultadoTransacaoCopyWith<$Res> {
  _$ResultadoTransacaoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultadoTransacao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? metodo = null,
    Object? valorCentavos = null,
    Object? parcelas = null,
    Object? codigoAutorizacao = null,
    Object? nsu = null,
    Object? bandeira = null,
    Object? finalCartao = null,
    Object? adquirente = null,
    Object? mensagemOperador = null,
    Object? tokenTransacao = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusPagamento,
      metodo: null == metodo
          ? _value.metodo
          : metodo // ignore: cast_nullable_to_non_nullable
              as MetodoPagamento,
      valorCentavos: null == valorCentavos
          ? _value.valorCentavos
          : valorCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      parcelas: null == parcelas
          ? _value.parcelas
          : parcelas // ignore: cast_nullable_to_non_nullable
              as int,
      codigoAutorizacao: null == codigoAutorizacao
          ? _value.codigoAutorizacao
          : codigoAutorizacao // ignore: cast_nullable_to_non_nullable
              as String,
      nsu: null == nsu
          ? _value.nsu
          : nsu // ignore: cast_nullable_to_non_nullable
              as String,
      bandeira: null == bandeira
          ? _value.bandeira
          : bandeira // ignore: cast_nullable_to_non_nullable
              as String,
      finalCartao: null == finalCartao
          ? _value.finalCartao
          : finalCartao // ignore: cast_nullable_to_non_nullable
              as String,
      adquirente: null == adquirente
          ? _value.adquirente
          : adquirente // ignore: cast_nullable_to_non_nullable
              as String,
      mensagemOperador: null == mensagemOperador
          ? _value.mensagemOperador
          : mensagemOperador // ignore: cast_nullable_to_non_nullable
              as String,
      tokenTransacao: null == tokenTransacao
          ? _value.tokenTransacao
          : tokenTransacao // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResultadoTransacaoImplCopyWith<$Res>
    implements $ResultadoTransacaoCopyWith<$Res> {
  factory _$$ResultadoTransacaoImplCopyWith(_$ResultadoTransacaoImpl value,
          $Res Function(_$ResultadoTransacaoImpl) then) =
      __$$ResultadoTransacaoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {StatusPagamento status,
      MetodoPagamento metodo,
      int valorCentavos,
      int parcelas,
      String codigoAutorizacao,
      String nsu,
      String bandeira,
      String finalCartao,
      String adquirente,
      String mensagemOperador,
      String tokenTransacao});
}

/// @nodoc
class __$$ResultadoTransacaoImplCopyWithImpl<$Res>
    extends _$ResultadoTransacaoCopyWithImpl<$Res, _$ResultadoTransacaoImpl>
    implements _$$ResultadoTransacaoImplCopyWith<$Res> {
  __$$ResultadoTransacaoImplCopyWithImpl(_$ResultadoTransacaoImpl _value,
      $Res Function(_$ResultadoTransacaoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResultadoTransacao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? metodo = null,
    Object? valorCentavos = null,
    Object? parcelas = null,
    Object? codigoAutorizacao = null,
    Object? nsu = null,
    Object? bandeira = null,
    Object? finalCartao = null,
    Object? adquirente = null,
    Object? mensagemOperador = null,
    Object? tokenTransacao = null,
  }) {
    return _then(_$ResultadoTransacaoImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusPagamento,
      metodo: null == metodo
          ? _value.metodo
          : metodo // ignore: cast_nullable_to_non_nullable
              as MetodoPagamento,
      valorCentavos: null == valorCentavos
          ? _value.valorCentavos
          : valorCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      parcelas: null == parcelas
          ? _value.parcelas
          : parcelas // ignore: cast_nullable_to_non_nullable
              as int,
      codigoAutorizacao: null == codigoAutorizacao
          ? _value.codigoAutorizacao
          : codigoAutorizacao // ignore: cast_nullable_to_non_nullable
              as String,
      nsu: null == nsu
          ? _value.nsu
          : nsu // ignore: cast_nullable_to_non_nullable
              as String,
      bandeira: null == bandeira
          ? _value.bandeira
          : bandeira // ignore: cast_nullable_to_non_nullable
              as String,
      finalCartao: null == finalCartao
          ? _value.finalCartao
          : finalCartao // ignore: cast_nullable_to_non_nullable
              as String,
      adquirente: null == adquirente
          ? _value.adquirente
          : adquirente // ignore: cast_nullable_to_non_nullable
              as String,
      mensagemOperador: null == mensagemOperador
          ? _value.mensagemOperador
          : mensagemOperador // ignore: cast_nullable_to_non_nullable
              as String,
      tokenTransacao: null == tokenTransacao
          ? _value.tokenTransacao
          : tokenTransacao // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ResultadoTransacaoImpl implements _ResultadoTransacao {
  const _$ResultadoTransacaoImpl(
      {required this.status,
      required this.metodo,
      required this.valorCentavos,
      this.parcelas = 1,
      this.codigoAutorizacao = '',
      this.nsu = '',
      this.bandeira = '',
      this.finalCartao = '',
      this.adquirente = '',
      this.mensagemOperador = '',
      this.tokenTransacao = ''});

  @override
  final StatusPagamento status;
  @override
  final MetodoPagamento metodo;

  /// Sempre em centavos (`int`): valor financeiro não passa por `double`.
  @override
  final int valorCentavos;
  @override
  @JsonKey()
  final int parcelas;
  @override
  @JsonKey()
  final String codigoAutorizacao;
  @override
  @JsonKey()
  final String nsu;
  @override
  @JsonKey()
  final String bandeira;

  /// Apenas os 4 últimos dígitos, já mascarados pelo lado nativo. O número
  /// completo, a trilha e qualquer dado do portador NUNCA atravessam o canal
  /// nem são gravados.
  @override
  @JsonKey()
  final String finalCartao;

  /// Rótulo da adquirente para exibição no comprovante.
  @override
  @JsonKey()
  final String adquirente;

  /// Texto vindo da adquirente para o operador. É conteúdo de terceiro:
  /// exibir como veio, sem interpretar.
  @override
  @JsonKey()
  final String mensagemOperador;

  /// Identificador `atk` devolvido pela Stone no deep link de retorno.
  /// Capturado só para diagnóstico — sem uso definido no payload da
  /// fatura ainda.
  @override
  @JsonKey()
  final String tokenTransacao;

  @override
  String toString() {
    return 'ResultadoTransacao(status: $status, metodo: $metodo, valorCentavos: $valorCentavos, parcelas: $parcelas, codigoAutorizacao: $codigoAutorizacao, nsu: $nsu, bandeira: $bandeira, finalCartao: $finalCartao, adquirente: $adquirente, mensagemOperador: $mensagemOperador, tokenTransacao: $tokenTransacao)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultadoTransacaoImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.metodo, metodo) || other.metodo == metodo) &&
            (identical(other.valorCentavos, valorCentavos) ||
                other.valorCentavos == valorCentavos) &&
            (identical(other.parcelas, parcelas) ||
                other.parcelas == parcelas) &&
            (identical(other.codigoAutorizacao, codigoAutorizacao) ||
                other.codigoAutorizacao == codigoAutorizacao) &&
            (identical(other.nsu, nsu) || other.nsu == nsu) &&
            (identical(other.bandeira, bandeira) ||
                other.bandeira == bandeira) &&
            (identical(other.finalCartao, finalCartao) ||
                other.finalCartao == finalCartao) &&
            (identical(other.adquirente, adquirente) ||
                other.adquirente == adquirente) &&
            (identical(other.mensagemOperador, mensagemOperador) ||
                other.mensagemOperador == mensagemOperador) &&
            (identical(other.tokenTransacao, tokenTransacao) ||
                other.tokenTransacao == tokenTransacao));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      metodo,
      valorCentavos,
      parcelas,
      codigoAutorizacao,
      nsu,
      bandeira,
      finalCartao,
      adquirente,
      mensagemOperador,
      tokenTransacao);

  /// Create a copy of ResultadoTransacao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultadoTransacaoImplCopyWith<_$ResultadoTransacaoImpl> get copyWith =>
      __$$ResultadoTransacaoImplCopyWithImpl<_$ResultadoTransacaoImpl>(
          this, _$identity);
}

abstract class _ResultadoTransacao implements ResultadoTransacao {
  const factory _ResultadoTransacao(
      {required final StatusPagamento status,
      required final MetodoPagamento metodo,
      required final int valorCentavos,
      final int parcelas,
      final String codigoAutorizacao,
      final String nsu,
      final String bandeira,
      final String finalCartao,
      final String adquirente,
      final String mensagemOperador,
      final String tokenTransacao}) = _$ResultadoTransacaoImpl;

  @override
  StatusPagamento get status;
  @override
  MetodoPagamento get metodo;

  /// Sempre em centavos (`int`): valor financeiro não passa por `double`.
  @override
  int get valorCentavos;
  @override
  int get parcelas;
  @override
  String get codigoAutorizacao;
  @override
  String get nsu;
  @override
  String get bandeira;

  /// Apenas os 4 últimos dígitos, já mascarados pelo lado nativo. O número
  /// completo, a trilha e qualquer dado do portador NUNCA atravessam o canal
  /// nem são gravados.
  @override
  String get finalCartao;

  /// Rótulo da adquirente para exibição no comprovante.
  @override
  String get adquirente;

  /// Texto vindo da adquirente para o operador. É conteúdo de terceiro:
  /// exibir como veio, sem interpretar.
  @override
  String get mensagemOperador;

  /// Identificador `atk` devolvido pela Stone no deep link de retorno.
  /// Capturado só para diagnóstico — sem uso definido no payload da
  /// fatura ainda.
  @override
  String get tokenTransacao;

  /// Create a copy of ResultadoTransacao
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultadoTransacaoImplCopyWith<_$ResultadoTransacaoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
