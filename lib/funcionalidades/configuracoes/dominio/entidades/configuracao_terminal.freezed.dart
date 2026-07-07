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
  Ambiente get ambiente => throw _privateConstructorUsedError;
  String get urlBaseProducao => throw _privateConstructorUsedError;
  String get urlBaseHomologacao => throw _privateConstructorUsedError;
  String get pinHash => throw _privateConstructorUsedError;

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
      Ambiente ambiente,
      String urlBaseProducao,
      String urlBaseHomologacao,
      String pinHash});
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
    Object? ambiente = null,
    Object? urlBaseProducao = null,
    Object? urlBaseHomologacao = null,
    Object? pinHash = null,
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
      pinHash: null == pinHash
          ? _value.pinHash
          : pinHash // ignore: cast_nullable_to_non_nullable
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
      Ambiente ambiente,
      String urlBaseProducao,
      String urlBaseHomologacao,
      String pinHash});
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
    Object? ambiente = null,
    Object? urlBaseProducao = null,
    Object? urlBaseHomologacao = null,
    Object? pinHash = null,
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
      pinHash: null == pinHash
          ? _value.pinHash
          : pinHash // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ConfiguracaoTerminalImpl extends _ConfiguracaoTerminal {
  const _$ConfiguracaoTerminalImpl(
      {this.nomeRestaurante = 'Constel Pay',
      this.identificadorDispositivo = 'TERMINAL-01',
      this.ambiente = Ambiente.homologacao,
      this.urlBaseProducao = '',
      this.urlBaseHomologacao = '',
      this.pinHash = ''})
      : super._();

  @override
  @JsonKey()
  final String nomeRestaurante;
  @override
  @JsonKey()
  final String identificadorDispositivo;
  @override
  @JsonKey()
  final Ambiente ambiente;
  @override
  @JsonKey()
  final String urlBaseProducao;
  @override
  @JsonKey()
  final String urlBaseHomologacao;
  @override
  @JsonKey()
  final String pinHash;

  @override
  String toString() {
    return 'ConfiguracaoTerminal(nomeRestaurante: $nomeRestaurante, identificadorDispositivo: $identificadorDispositivo, ambiente: $ambiente, urlBaseProducao: $urlBaseProducao, urlBaseHomologacao: $urlBaseHomologacao, pinHash: $pinHash)';
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
            (identical(other.ambiente, ambiente) ||
                other.ambiente == ambiente) &&
            (identical(other.urlBaseProducao, urlBaseProducao) ||
                other.urlBaseProducao == urlBaseProducao) &&
            (identical(other.urlBaseHomologacao, urlBaseHomologacao) ||
                other.urlBaseHomologacao == urlBaseHomologacao) &&
            (identical(other.pinHash, pinHash) || other.pinHash == pinHash));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      nomeRestaurante,
      identificadorDispositivo,
      ambiente,
      urlBaseProducao,
      urlBaseHomologacao,
      pinHash);

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
      final Ambiente ambiente,
      final String urlBaseProducao,
      final String urlBaseHomologacao,
      final String pinHash}) = _$ConfiguracaoTerminalImpl;
  const _ConfiguracaoTerminal._() : super._();

  @override
  String get nomeRestaurante;
  @override
  String get identificadorDispositivo;
  @override
  Ambiente get ambiente;
  @override
  String get urlBaseProducao;
  @override
  String get urlBaseHomologacao;
  @override
  String get pinHash;

  /// Create a copy of ConfiguracaoTerminal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfiguracaoTerminalImplCopyWith<_$ConfiguracaoTerminalImpl>
      get copyWith => throw _privateConstructorUsedError;
}
