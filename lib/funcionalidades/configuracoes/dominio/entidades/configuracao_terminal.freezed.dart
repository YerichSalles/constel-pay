// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'configuracao_terminal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ConfiguracaoTerminal {
  String get nomeRestaurante => throw _privateConstructorUsedError;
  String get identificadorDispositivo => throw _privateConstructorUsedError;
  String get idDispositivo => throw _privateConstructorUsedError;

  /// Liga a leitura por câmera no Android, para totens sem leitor de código
  /// de barras. Não dá para detectar o leitor sozinho: ele se apresenta ao
  /// sistema como teclado comum e só dá sinal quando digita — por isso a
  /// escolha é do operador, por dispositivo.
  bool get leituraPorCamera => throw _privateConstructorUsedError;
  Ambiente get ambiente =>
      throw _privateConstructorUsedError; // URLs da API local (consumo do cartão no estabelecimento).
  String get urlBaseProducao => throw _privateConstructorUsedError;
  String get urlBaseHomologacao =>
      throw _privateConstructorUsedError; // URLs da API na nuvem (login/autenticação).
  String get urlNuvemProducao => throw _privateConstructorUsedError;
  String get urlNuvemHomologacao => throw _privateConstructorUsedError;

  /// Create a copy of ConfiguracaoTerminal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConfiguracaoTerminalCopyWith<ConfiguracaoTerminal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfiguracaoTerminalCopyWith<$Res> {
  factory $ConfiguracaoTerminalCopyWith(ConfiguracaoTerminal value,
          $Res Function(ConfiguracaoTerminal) then) =
      _$ConfiguracaoTerminalCopyWithImpl<$Res, ConfiguracaoTerminal>;
  @useResult
  $Res call(
      {String nomeRestaurante,
      String identificadorDispositivo,
      String idDispositivo,
      bool leituraPorCamera,
      Ambiente ambiente,
      String urlBaseProducao,
      String urlBaseHomologacao,
      String urlNuvemProducao,
      String urlNuvemHomologacao});
}

/// @nodoc
class _$ConfiguracaoTerminalCopyWithImpl<$Res,
        $Val extends ConfiguracaoTerminal>
    implements $ConfiguracaoTerminalCopyWith<$Res> {
  _$ConfiguracaoTerminalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConfiguracaoTerminal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nomeRestaurante = null,
    Object? identificadorDispositivo = null,
    Object? idDispositivo = null,
    Object? leituraPorCamera = null,
    Object? ambiente = null,
    Object? urlBaseProducao = null,
    Object? urlBaseHomologacao = null,
    Object? urlNuvemProducao = null,
    Object? urlNuvemHomologacao = null,
  }) {
    return _then(_value.copyWith(
      nomeRestaurante: null == nomeRestaurante
          ? _value.nomeRestaurante
          : nomeRestaurante // ignore: cast_nullable_to_non_nullable
              as String,
      identificadorDispositivo: null == identificadorDispositivo
          ? _value.identificadorDispositivo
          : identificadorDispositivo // ignore: cast_nullable_to_non_nullable
              as String,
      idDispositivo: null == idDispositivo
          ? _value.idDispositivo
          : idDispositivo // ignore: cast_nullable_to_non_nullable
              as String,
      leituraPorCamera: null == leituraPorCamera
          ? _value.leituraPorCamera
          : leituraPorCamera // ignore: cast_nullable_to_non_nullable
              as bool,
      ambiente: null == ambiente
          ? _value.ambiente
          : ambiente // ignore: cast_nullable_to_non_nullable
              as Ambiente,
      urlBaseProducao: null == urlBaseProducao
          ? _value.urlBaseProducao
          : urlBaseProducao // ignore: cast_nullable_to_non_nullable
              as String,
      urlBaseHomologacao: null == urlBaseHomologacao
          ? _value.urlBaseHomologacao
          : urlBaseHomologacao // ignore: cast_nullable_to_non_nullable
              as String,
      urlNuvemProducao: null == urlNuvemProducao
          ? _value.urlNuvemProducao
          : urlNuvemProducao // ignore: cast_nullable_to_non_nullable
              as String,
      urlNuvemHomologacao: null == urlNuvemHomologacao
          ? _value.urlNuvemHomologacao
          : urlNuvemHomologacao // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConfiguracaoTerminalImplCopyWith<$Res>
    implements $ConfiguracaoTerminalCopyWith<$Res> {
  factory _$$ConfiguracaoTerminalImplCopyWith(_$ConfiguracaoTerminalImpl value,
          $Res Function(_$ConfiguracaoTerminalImpl) then) =
      __$$ConfiguracaoTerminalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String nomeRestaurante,
      String identificadorDispositivo,
      String idDispositivo,
      bool leituraPorCamera,
      Ambiente ambiente,
      String urlBaseProducao,
      String urlBaseHomologacao,
      String urlNuvemProducao,
      String urlNuvemHomologacao});
}

/// @nodoc
class __$$ConfiguracaoTerminalImplCopyWithImpl<$Res>
    extends _$ConfiguracaoTerminalCopyWithImpl<$Res, _$ConfiguracaoTerminalImpl>
    implements _$$ConfiguracaoTerminalImplCopyWith<$Res> {
  __$$ConfiguracaoTerminalImplCopyWithImpl(_$ConfiguracaoTerminalImpl _value,
      $Res Function(_$ConfiguracaoTerminalImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConfiguracaoTerminal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nomeRestaurante = null,
    Object? identificadorDispositivo = null,
    Object? idDispositivo = null,
    Object? leituraPorCamera = null,
    Object? ambiente = null,
    Object? urlBaseProducao = null,
    Object? urlBaseHomologacao = null,
    Object? urlNuvemProducao = null,
    Object? urlNuvemHomologacao = null,
  }) {
    return _then(_$ConfiguracaoTerminalImpl(
      nomeRestaurante: null == nomeRestaurante
          ? _value.nomeRestaurante
          : nomeRestaurante // ignore: cast_nullable_to_non_nullable
              as String,
      identificadorDispositivo: null == identificadorDispositivo
          ? _value.identificadorDispositivo
          : identificadorDispositivo // ignore: cast_nullable_to_non_nullable
              as String,
      idDispositivo: null == idDispositivo
          ? _value.idDispositivo
          : idDispositivo // ignore: cast_nullable_to_non_nullable
              as String,
      leituraPorCamera: null == leituraPorCamera
          ? _value.leituraPorCamera
          : leituraPorCamera // ignore: cast_nullable_to_non_nullable
              as bool,
      ambiente: null == ambiente
          ? _value.ambiente
          : ambiente // ignore: cast_nullable_to_non_nullable
              as Ambiente,
      urlBaseProducao: null == urlBaseProducao
          ? _value.urlBaseProducao
          : urlBaseProducao // ignore: cast_nullable_to_non_nullable
              as String,
      urlBaseHomologacao: null == urlBaseHomologacao
          ? _value.urlBaseHomologacao
          : urlBaseHomologacao // ignore: cast_nullable_to_non_nullable
              as String,
      urlNuvemProducao: null == urlNuvemProducao
          ? _value.urlNuvemProducao
          : urlNuvemProducao // ignore: cast_nullable_to_non_nullable
              as String,
      urlNuvemHomologacao: null == urlNuvemHomologacao
          ? _value.urlNuvemHomologacao
          : urlNuvemHomologacao // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ConfiguracaoTerminalImpl extends _ConfiguracaoTerminal {
  const _$ConfiguracaoTerminalImpl(
      {this.nomeRestaurante = 'Constel Pay',
      this.identificadorDispositivo = 'TERMINAL-01',
      this.idDispositivo = '',
      this.leituraPorCamera = false,
      this.ambiente = Ambiente.homologacao,
      this.urlBaseProducao = '',
      this.urlBaseHomologacao = '',
      this.urlNuvemProducao = '',
      this.urlNuvemHomologacao = ''})
      : super._();

  @override
  @JsonKey()
  final String nomeRestaurante;
  @override
  @JsonKey()
  final String identificadorDispositivo;
  @override
  @JsonKey()
  final String idDispositivo;

  /// Liga a leitura por câmera no Android, para totens sem leitor de código
  /// de barras. Não dá para detectar o leitor sozinho: ele se apresenta ao
  /// sistema como teclado comum e só dá sinal quando digita — por isso a
  /// escolha é do operador, por dispositivo.
  @override
  @JsonKey()
  final bool leituraPorCamera;
  @override
  @JsonKey()
  final Ambiente ambiente;
// URLs da API local (consumo do cartão no estabelecimento).
  @override
  @JsonKey()
  final String urlBaseProducao;
  @override
  @JsonKey()
  final String urlBaseHomologacao;
// URLs da API na nuvem (login/autenticação).
  @override
  @JsonKey()
  final String urlNuvemProducao;
  @override
  @JsonKey()
  final String urlNuvemHomologacao;

  @override
  String toString() {
    return 'ConfiguracaoTerminal(nomeRestaurante: $nomeRestaurante, identificadorDispositivo: $identificadorDispositivo, idDispositivo: $idDispositivo, leituraPorCamera: $leituraPorCamera, ambiente: $ambiente, urlBaseProducao: $urlBaseProducao, urlBaseHomologacao: $urlBaseHomologacao, urlNuvemProducao: $urlNuvemProducao, urlNuvemHomologacao: $urlNuvemHomologacao)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfiguracaoTerminalImpl &&
            (identical(other.nomeRestaurante, nomeRestaurante) ||
                other.nomeRestaurante == nomeRestaurante) &&
            (identical(
                    other.identificadorDispositivo, identificadorDispositivo) ||
                other.identificadorDispositivo == identificadorDispositivo) &&
            (identical(other.idDispositivo, idDispositivo) ||
                other.idDispositivo == idDispositivo) &&
            (identical(other.leituraPorCamera, leituraPorCamera) ||
                other.leituraPorCamera == leituraPorCamera) &&
            (identical(other.ambiente, ambiente) ||
                other.ambiente == ambiente) &&
            (identical(other.urlBaseProducao, urlBaseProducao) ||
                other.urlBaseProducao == urlBaseProducao) &&
            (identical(other.urlBaseHomologacao, urlBaseHomologacao) ||
                other.urlBaseHomologacao == urlBaseHomologacao) &&
            (identical(other.urlNuvemProducao, urlNuvemProducao) ||
                other.urlNuvemProducao == urlNuvemProducao) &&
            (identical(other.urlNuvemHomologacao, urlNuvemHomologacao) ||
                other.urlNuvemHomologacao == urlNuvemHomologacao));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      nomeRestaurante,
      identificadorDispositivo,
      idDispositivo,
      leituraPorCamera,
      ambiente,
      urlBaseProducao,
      urlBaseHomologacao,
      urlNuvemProducao,
      urlNuvemHomologacao);

  /// Create a copy of ConfiguracaoTerminal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfiguracaoTerminalImplCopyWith<_$ConfiguracaoTerminalImpl>
      get copyWith =>
          __$$ConfiguracaoTerminalImplCopyWithImpl<_$ConfiguracaoTerminalImpl>(
              this, _$identity);
}

abstract class _ConfiguracaoTerminal extends ConfiguracaoTerminal {
  const factory _ConfiguracaoTerminal(
      {final String nomeRestaurante,
      final String identificadorDispositivo,
      final String idDispositivo,
      final bool leituraPorCamera,
      final Ambiente ambiente,
      final String urlBaseProducao,
      final String urlBaseHomologacao,
      final String urlNuvemProducao,
      final String urlNuvemHomologacao}) = _$ConfiguracaoTerminalImpl;
  const _ConfiguracaoTerminal._() : super._();

  @override
  String get nomeRestaurante;
  @override
  String get identificadorDispositivo;
  @override
  String get idDispositivo;

  /// Liga a leitura por câmera no Android, para totens sem leitor de código
  /// de barras. Não dá para detectar o leitor sozinho: ele se apresenta ao
  /// sistema como teclado comum e só dá sinal quando digita — por isso a
  /// escolha é do operador, por dispositivo.
  @override
  bool get leituraPorCamera;
  @override
  Ambiente
      get ambiente; // URLs da API local (consumo do cartão no estabelecimento).
  @override
  String get urlBaseProducao;
  @override
  String get urlBaseHomologacao; // URLs da API na nuvem (login/autenticação).
  @override
  String get urlNuvemProducao;
  @override
  String get urlNuvemHomologacao;

  /// Create a copy of ConfiguracaoTerminal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfiguracaoTerminalImplCopyWith<_$ConfiguracaoTerminalImpl>
      get copyWith => throw _privateConstructorUsedError;
}
