// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tema_personalizado.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TemaPersonalizado {
  String get corPrimaria => throw _privateConstructorUsedError;
  String get corSecundaria => throw _privateConstructorUsedError;
  String get corFundo => throw _privateConstructorUsedError;
  String get corBotoes => throw _privateConstructorUsedError;
  String get corTexto => throw _privateConstructorUsedError;
  String? get corFaixa => throw _privateConstructorUsedError;
  String get corTextoFaixa =>
      throw _privateConstructorUsedError; // Texto da faixa por idioma. `textoFaixa` é o português (mantém o nome
// antigo para não quebrar temas já salvos); en/es entram vazios e, quando
// vazios, caem no texto padrão traduzido pelo l10n do idioma atual.
  String get textoFaixa => throw _privateConstructorUsedError;
  String get textoFaixaEn => throw _privateConstructorUsedError;
  String get textoFaixaEs =>
      throw _privateConstructorUsedError; // Barra de créditos (rodapé "Constel Pay" / site). Na tela principal ela
// nasce transparente sobre a faixa de pagamento; só ganha fundo próprio
// quando o operador liga `pintarBarraCreditosPrincipal`. No chat ela sempre
// tem fundo — só a cor é escolhida.
  bool get pintarBarraCreditosPrincipal => throw _privateConstructorUsedError;
  String? get corBarraCreditosPrincipal => throw _privateConstructorUsedError;
  String? get corBarraCreditosChat => throw _privateConstructorUsedError;
  String get fonte => throw _privateConstructorUsedError;
  String? get logoPath => throw _privateConstructorUsedError;
  OrientacaoTela get orientacaoTela => throw _privateConstructorUsedError;

  /// Create a copy of TemaPersonalizado
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemaPersonalizadoCopyWith<TemaPersonalizado> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TemaPersonalizadoCopyWith<$Res> {
  factory $TemaPersonalizadoCopyWith(
          TemaPersonalizado value, $Res Function(TemaPersonalizado) then) =
      _$TemaPersonalizadoCopyWithImpl<$Res, TemaPersonalizado>;
  @useResult
  $Res call(
      {String corPrimaria,
      String corSecundaria,
      String corFundo,
      String corBotoes,
      String corTexto,
      String? corFaixa,
      String corTextoFaixa,
      String textoFaixa,
      String textoFaixaEn,
      String textoFaixaEs,
      bool pintarBarraCreditosPrincipal,
      String? corBarraCreditosPrincipal,
      String? corBarraCreditosChat,
      String fonte,
      String? logoPath,
      OrientacaoTela orientacaoTela});
}

/// @nodoc
class _$TemaPersonalizadoCopyWithImpl<$Res, $Val extends TemaPersonalizado>
    implements $TemaPersonalizadoCopyWith<$Res> {
  _$TemaPersonalizadoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TemaPersonalizado
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? corPrimaria = null,
    Object? corSecundaria = null,
    Object? corFundo = null,
    Object? corBotoes = null,
    Object? corTexto = null,
    Object? corFaixa = freezed,
    Object? corTextoFaixa = null,
    Object? textoFaixa = null,
    Object? textoFaixaEn = null,
    Object? textoFaixaEs = null,
    Object? pintarBarraCreditosPrincipal = null,
    Object? corBarraCreditosPrincipal = freezed,
    Object? corBarraCreditosChat = freezed,
    Object? fonte = null,
    Object? logoPath = freezed,
    Object? orientacaoTela = null,
  }) {
    return _then(_value.copyWith(
      corPrimaria: null == corPrimaria
          ? _value.corPrimaria
          : corPrimaria // ignore: cast_nullable_to_non_nullable
              as String,
      corSecundaria: null == corSecundaria
          ? _value.corSecundaria
          : corSecundaria // ignore: cast_nullable_to_non_nullable
              as String,
      corFundo: null == corFundo
          ? _value.corFundo
          : corFundo // ignore: cast_nullable_to_non_nullable
              as String,
      corBotoes: null == corBotoes
          ? _value.corBotoes
          : corBotoes // ignore: cast_nullable_to_non_nullable
              as String,
      corTexto: null == corTexto
          ? _value.corTexto
          : corTexto // ignore: cast_nullable_to_non_nullable
              as String,
      corFaixa: freezed == corFaixa
          ? _value.corFaixa
          : corFaixa // ignore: cast_nullable_to_non_nullable
              as String?,
      corTextoFaixa: null == corTextoFaixa
          ? _value.corTextoFaixa
          : corTextoFaixa // ignore: cast_nullable_to_non_nullable
              as String,
      textoFaixa: null == textoFaixa
          ? _value.textoFaixa
          : textoFaixa // ignore: cast_nullable_to_non_nullable
              as String,
      textoFaixaEn: null == textoFaixaEn
          ? _value.textoFaixaEn
          : textoFaixaEn // ignore: cast_nullable_to_non_nullable
              as String,
      textoFaixaEs: null == textoFaixaEs
          ? _value.textoFaixaEs
          : textoFaixaEs // ignore: cast_nullable_to_non_nullable
              as String,
      pintarBarraCreditosPrincipal: null == pintarBarraCreditosPrincipal
          ? _value.pintarBarraCreditosPrincipal
          : pintarBarraCreditosPrincipal // ignore: cast_nullable_to_non_nullable
              as bool,
      corBarraCreditosPrincipal: freezed == corBarraCreditosPrincipal
          ? _value.corBarraCreditosPrincipal
          : corBarraCreditosPrincipal // ignore: cast_nullable_to_non_nullable
              as String?,
      corBarraCreditosChat: freezed == corBarraCreditosChat
          ? _value.corBarraCreditosChat
          : corBarraCreditosChat // ignore: cast_nullable_to_non_nullable
              as String?,
      fonte: null == fonte
          ? _value.fonte
          : fonte // ignore: cast_nullable_to_non_nullable
              as String,
      logoPath: freezed == logoPath
          ? _value.logoPath
          : logoPath // ignore: cast_nullable_to_non_nullable
              as String?,
      orientacaoTela: null == orientacaoTela
          ? _value.orientacaoTela
          : orientacaoTela // ignore: cast_nullable_to_non_nullable
              as OrientacaoTela,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TemaPersonalizadoImplCopyWith<$Res>
    implements $TemaPersonalizadoCopyWith<$Res> {
  factory _$$TemaPersonalizadoImplCopyWith(_$TemaPersonalizadoImpl value,
          $Res Function(_$TemaPersonalizadoImpl) then) =
      __$$TemaPersonalizadoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String corPrimaria,
      String corSecundaria,
      String corFundo,
      String corBotoes,
      String corTexto,
      String? corFaixa,
      String corTextoFaixa,
      String textoFaixa,
      String textoFaixaEn,
      String textoFaixaEs,
      bool pintarBarraCreditosPrincipal,
      String? corBarraCreditosPrincipal,
      String? corBarraCreditosChat,
      String fonte,
      String? logoPath,
      OrientacaoTela orientacaoTela});
}

/// @nodoc
class __$$TemaPersonalizadoImplCopyWithImpl<$Res>
    extends _$TemaPersonalizadoCopyWithImpl<$Res, _$TemaPersonalizadoImpl>
    implements _$$TemaPersonalizadoImplCopyWith<$Res> {
  __$$TemaPersonalizadoImplCopyWithImpl(_$TemaPersonalizadoImpl _value,
      $Res Function(_$TemaPersonalizadoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TemaPersonalizado
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? corPrimaria = null,
    Object? corSecundaria = null,
    Object? corFundo = null,
    Object? corBotoes = null,
    Object? corTexto = null,
    Object? corFaixa = freezed,
    Object? corTextoFaixa = null,
    Object? textoFaixa = null,
    Object? textoFaixaEn = null,
    Object? textoFaixaEs = null,
    Object? pintarBarraCreditosPrincipal = null,
    Object? corBarraCreditosPrincipal = freezed,
    Object? corBarraCreditosChat = freezed,
    Object? fonte = null,
    Object? logoPath = freezed,
    Object? orientacaoTela = null,
  }) {
    return _then(_$TemaPersonalizadoImpl(
      corPrimaria: null == corPrimaria
          ? _value.corPrimaria
          : corPrimaria // ignore: cast_nullable_to_non_nullable
              as String,
      corSecundaria: null == corSecundaria
          ? _value.corSecundaria
          : corSecundaria // ignore: cast_nullable_to_non_nullable
              as String,
      corFundo: null == corFundo
          ? _value.corFundo
          : corFundo // ignore: cast_nullable_to_non_nullable
              as String,
      corBotoes: null == corBotoes
          ? _value.corBotoes
          : corBotoes // ignore: cast_nullable_to_non_nullable
              as String,
      corTexto: null == corTexto
          ? _value.corTexto
          : corTexto // ignore: cast_nullable_to_non_nullable
              as String,
      corFaixa: freezed == corFaixa
          ? _value.corFaixa
          : corFaixa // ignore: cast_nullable_to_non_nullable
              as String?,
      corTextoFaixa: null == corTextoFaixa
          ? _value.corTextoFaixa
          : corTextoFaixa // ignore: cast_nullable_to_non_nullable
              as String,
      textoFaixa: null == textoFaixa
          ? _value.textoFaixa
          : textoFaixa // ignore: cast_nullable_to_non_nullable
              as String,
      textoFaixaEn: null == textoFaixaEn
          ? _value.textoFaixaEn
          : textoFaixaEn // ignore: cast_nullable_to_non_nullable
              as String,
      textoFaixaEs: null == textoFaixaEs
          ? _value.textoFaixaEs
          : textoFaixaEs // ignore: cast_nullable_to_non_nullable
              as String,
      pintarBarraCreditosPrincipal: null == pintarBarraCreditosPrincipal
          ? _value.pintarBarraCreditosPrincipal
          : pintarBarraCreditosPrincipal // ignore: cast_nullable_to_non_nullable
              as bool,
      corBarraCreditosPrincipal: freezed == corBarraCreditosPrincipal
          ? _value.corBarraCreditosPrincipal
          : corBarraCreditosPrincipal // ignore: cast_nullable_to_non_nullable
              as String?,
      corBarraCreditosChat: freezed == corBarraCreditosChat
          ? _value.corBarraCreditosChat
          : corBarraCreditosChat // ignore: cast_nullable_to_non_nullable
              as String?,
      fonte: null == fonte
          ? _value.fonte
          : fonte // ignore: cast_nullable_to_non_nullable
              as String,
      logoPath: freezed == logoPath
          ? _value.logoPath
          : logoPath // ignore: cast_nullable_to_non_nullable
              as String?,
      orientacaoTela: null == orientacaoTela
          ? _value.orientacaoTela
          : orientacaoTela // ignore: cast_nullable_to_non_nullable
              as OrientacaoTela,
    ));
  }
}

/// @nodoc

class _$TemaPersonalizadoImpl extends _TemaPersonalizado {
  const _$TemaPersonalizadoImpl(
      {this.corPrimaria = '#5E52D6',
      this.corSecundaria = '#FFD166',
      this.corFundo = '#F7F7FB',
      this.corBotoes = '#5E52D6',
      this.corTexto = '#2F2B3D',
      this.corFaixa,
      this.corTextoFaixa = '#FFFFFF',
      this.textoFaixa = textoFaixaPadrao,
      this.textoFaixaEn = '',
      this.textoFaixaEs = '',
      this.pintarBarraCreditosPrincipal = false,
      this.corBarraCreditosPrincipal,
      this.corBarraCreditosChat,
      this.fonte = 'Inter',
      this.logoPath,
      this.orientacaoTela = OrientacaoTela.vertical})
      : super._();

  @override
  @JsonKey()
  final String corPrimaria;
  @override
  @JsonKey()
  final String corSecundaria;
  @override
  @JsonKey()
  final String corFundo;
  @override
  @JsonKey()
  final String corBotoes;
  @override
  @JsonKey()
  final String corTexto;
  @override
  final String? corFaixa;
  @override
  @JsonKey()
  final String corTextoFaixa;
// Texto da faixa por idioma. `textoFaixa` é o português (mantém o nome
// antigo para não quebrar temas já salvos); en/es entram vazios e, quando
// vazios, caem no texto padrão traduzido pelo l10n do idioma atual.
  @override
  @JsonKey()
  final String textoFaixa;
  @override
  @JsonKey()
  final String textoFaixaEn;
  @override
  @JsonKey()
  final String textoFaixaEs;
// Barra de créditos (rodapé "Constel Pay" / site). Na tela principal ela
// nasce transparente sobre a faixa de pagamento; só ganha fundo próprio
// quando o operador liga `pintarBarraCreditosPrincipal`. No chat ela sempre
// tem fundo — só a cor é escolhida.
  @override
  @JsonKey()
  final bool pintarBarraCreditosPrincipal;
  @override
  final String? corBarraCreditosPrincipal;
  @override
  final String? corBarraCreditosChat;
  @override
  @JsonKey()
  final String fonte;
  @override
  final String? logoPath;
  @override
  @JsonKey()
  final OrientacaoTela orientacaoTela;

  @override
  String toString() {
    return 'TemaPersonalizado(corPrimaria: $corPrimaria, corSecundaria: $corSecundaria, corFundo: $corFundo, corBotoes: $corBotoes, corTexto: $corTexto, corFaixa: $corFaixa, corTextoFaixa: $corTextoFaixa, textoFaixa: $textoFaixa, textoFaixaEn: $textoFaixaEn, textoFaixaEs: $textoFaixaEs, pintarBarraCreditosPrincipal: $pintarBarraCreditosPrincipal, corBarraCreditosPrincipal: $corBarraCreditosPrincipal, corBarraCreditosChat: $corBarraCreditosChat, fonte: $fonte, logoPath: $logoPath, orientacaoTela: $orientacaoTela)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemaPersonalizadoImpl &&
            (identical(other.corPrimaria, corPrimaria) ||
                other.corPrimaria == corPrimaria) &&
            (identical(other.corSecundaria, corSecundaria) ||
                other.corSecundaria == corSecundaria) &&
            (identical(other.corFundo, corFundo) ||
                other.corFundo == corFundo) &&
            (identical(other.corBotoes, corBotoes) ||
                other.corBotoes == corBotoes) &&
            (identical(other.corTexto, corTexto) ||
                other.corTexto == corTexto) &&
            (identical(other.corFaixa, corFaixa) ||
                other.corFaixa == corFaixa) &&
            (identical(other.corTextoFaixa, corTextoFaixa) ||
                other.corTextoFaixa == corTextoFaixa) &&
            (identical(other.textoFaixa, textoFaixa) ||
                other.textoFaixa == textoFaixa) &&
            (identical(other.textoFaixaEn, textoFaixaEn) ||
                other.textoFaixaEn == textoFaixaEn) &&
            (identical(other.textoFaixaEs, textoFaixaEs) ||
                other.textoFaixaEs == textoFaixaEs) &&
            (identical(other.pintarBarraCreditosPrincipal,
                    pintarBarraCreditosPrincipal) ||
                other.pintarBarraCreditosPrincipal ==
                    pintarBarraCreditosPrincipal) &&
            (identical(other.corBarraCreditosPrincipal,
                    corBarraCreditosPrincipal) ||
                other.corBarraCreditosPrincipal == corBarraCreditosPrincipal) &&
            (identical(other.corBarraCreditosChat, corBarraCreditosChat) ||
                other.corBarraCreditosChat == corBarraCreditosChat) &&
            (identical(other.fonte, fonte) || other.fonte == fonte) &&
            (identical(other.logoPath, logoPath) ||
                other.logoPath == logoPath) &&
            (identical(other.orientacaoTela, orientacaoTela) ||
                other.orientacaoTela == orientacaoTela));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      corPrimaria,
      corSecundaria,
      corFundo,
      corBotoes,
      corTexto,
      corFaixa,
      corTextoFaixa,
      textoFaixa,
      textoFaixaEn,
      textoFaixaEs,
      pintarBarraCreditosPrincipal,
      corBarraCreditosPrincipal,
      corBarraCreditosChat,
      fonte,
      logoPath,
      orientacaoTela);

  /// Create a copy of TemaPersonalizado
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemaPersonalizadoImplCopyWith<_$TemaPersonalizadoImpl> get copyWith =>
      __$$TemaPersonalizadoImplCopyWithImpl<_$TemaPersonalizadoImpl>(
          this, _$identity);
}

abstract class _TemaPersonalizado extends TemaPersonalizado {
  const factory _TemaPersonalizado(
      {final String corPrimaria,
      final String corSecundaria,
      final String corFundo,
      final String corBotoes,
      final String corTexto,
      final String? corFaixa,
      final String corTextoFaixa,
      final String textoFaixa,
      final String textoFaixaEn,
      final String textoFaixaEs,
      final bool pintarBarraCreditosPrincipal,
      final String? corBarraCreditosPrincipal,
      final String? corBarraCreditosChat,
      final String fonte,
      final String? logoPath,
      final OrientacaoTela orientacaoTela}) = _$TemaPersonalizadoImpl;
  const _TemaPersonalizado._() : super._();

  @override
  String get corPrimaria;
  @override
  String get corSecundaria;
  @override
  String get corFundo;
  @override
  String get corBotoes;
  @override
  String get corTexto;
  @override
  String? get corFaixa;
  @override
  String
      get corTextoFaixa; // Texto da faixa por idioma. `textoFaixa` é o português (mantém o nome
// antigo para não quebrar temas já salvos); en/es entram vazios e, quando
// vazios, caem no texto padrão traduzido pelo l10n do idioma atual.
  @override
  String get textoFaixa;
  @override
  String get textoFaixaEn;
  @override
  String
      get textoFaixaEs; // Barra de créditos (rodapé "Constel Pay" / site). Na tela principal ela
// nasce transparente sobre a faixa de pagamento; só ganha fundo próprio
// quando o operador liga `pintarBarraCreditosPrincipal`. No chat ela sempre
// tem fundo — só a cor é escolhida.
  @override
  bool get pintarBarraCreditosPrincipal;
  @override
  String? get corBarraCreditosPrincipal;
  @override
  String? get corBarraCreditosChat;
  @override
  String get fonte;
  @override
  String? get logoPath;
  @override
  OrientacaoTela get orientacaoTela;

  /// Create a copy of TemaPersonalizado
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemaPersonalizadoImplCopyWith<_$TemaPersonalizadoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
