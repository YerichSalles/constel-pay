// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'controlador_diagnostico.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EstadoDiagnostico {
  String get versaoApp => throw _privateConstructorUsedError;
  String get ambienteRotulo => throw _privateConstructorUsedError;
  String get ip => throw _privateConstructorUsedError;
  DateTime? get ultimaSincronizacao => throw _privateConstructorUsedError;

  /// Create a copy of EstadoDiagnostico
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EstadoDiagnosticoCopyWith<EstadoDiagnostico> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EstadoDiagnosticoCopyWith<$Res> {
  factory $EstadoDiagnosticoCopyWith(
          EstadoDiagnostico value, $Res Function(EstadoDiagnostico) then) =
      _$EstadoDiagnosticoCopyWithImpl<$Res, EstadoDiagnostico>;
  @useResult
  $Res call(
      {String versaoApp,
      String ambienteRotulo,
      String ip,
      DateTime? ultimaSincronizacao});
}

/// @nodoc
class _$EstadoDiagnosticoCopyWithImpl<$Res, $Val extends EstadoDiagnostico>
    implements $EstadoDiagnosticoCopyWith<$Res> {
  _$EstadoDiagnosticoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EstadoDiagnostico
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? versaoApp = null,
    Object? ambienteRotulo = null,
    Object? ip = null,
    Object? ultimaSincronizacao = freezed,
  }) {
    return _then(_value.copyWith(
      versaoApp: null == versaoApp
          ? _value.versaoApp
          : versaoApp // ignore: cast_nullable_to_non_nullable
              as String,
      ambienteRotulo: null == ambienteRotulo
          ? _value.ambienteRotulo
          : ambienteRotulo // ignore: cast_nullable_to_non_nullable
              as String,
      ip: null == ip
          ? _value.ip
          : ip // ignore: cast_nullable_to_non_nullable
              as String,
      ultimaSincronizacao: freezed == ultimaSincronizacao
          ? _value.ultimaSincronizacao
          : ultimaSincronizacao // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EstadoDiagnosticoImplCopyWith<$Res>
    implements $EstadoDiagnosticoCopyWith<$Res> {
  factory _$$EstadoDiagnosticoImplCopyWith(_$EstadoDiagnosticoImpl value,
          $Res Function(_$EstadoDiagnosticoImpl) then) =
      __$$EstadoDiagnosticoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String versaoApp,
      String ambienteRotulo,
      String ip,
      DateTime? ultimaSincronizacao});
}

/// @nodoc
class __$$EstadoDiagnosticoImplCopyWithImpl<$Res>
    extends _$EstadoDiagnosticoCopyWithImpl<$Res, _$EstadoDiagnosticoImpl>
    implements _$$EstadoDiagnosticoImplCopyWith<$Res> {
  __$$EstadoDiagnosticoImplCopyWithImpl(_$EstadoDiagnosticoImpl _value,
      $Res Function(_$EstadoDiagnosticoImpl) _then)
      : super(_value, _then);

  /// Create a copy of EstadoDiagnostico
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? versaoApp = null,
    Object? ambienteRotulo = null,
    Object? ip = null,
    Object? ultimaSincronizacao = freezed,
  }) {
    return _then(_$EstadoDiagnosticoImpl(
      versaoApp: null == versaoApp
          ? _value.versaoApp
          : versaoApp // ignore: cast_nullable_to_non_nullable
              as String,
      ambienteRotulo: null == ambienteRotulo
          ? _value.ambienteRotulo
          : ambienteRotulo // ignore: cast_nullable_to_non_nullable
              as String,
      ip: null == ip
          ? _value.ip
          : ip // ignore: cast_nullable_to_non_nullable
              as String,
      ultimaSincronizacao: freezed == ultimaSincronizacao
          ? _value.ultimaSincronizacao
          : ultimaSincronizacao // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$EstadoDiagnosticoImpl implements _EstadoDiagnostico {
  const _$EstadoDiagnosticoImpl(
      {this.versaoApp = '—',
      this.ambienteRotulo = '',
      this.ip = '—',
      this.ultimaSincronizacao});

  @override
  @JsonKey()
  final String versaoApp;
  @override
  @JsonKey()
  final String ambienteRotulo;
  @override
  @JsonKey()
  final String ip;
  @override
  final DateTime? ultimaSincronizacao;

  @override
  String toString() {
    return 'EstadoDiagnostico(versaoApp: $versaoApp, ambienteRotulo: $ambienteRotulo, ip: $ip, ultimaSincronizacao: $ultimaSincronizacao)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EstadoDiagnosticoImpl &&
            (identical(other.versaoApp, versaoApp) ||
                other.versaoApp == versaoApp) &&
            (identical(other.ambienteRotulo, ambienteRotulo) ||
                other.ambienteRotulo == ambienteRotulo) &&
            (identical(other.ip, ip) || other.ip == ip) &&
            (identical(other.ultimaSincronizacao, ultimaSincronizacao) ||
                other.ultimaSincronizacao == ultimaSincronizacao));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, versaoApp, ambienteRotulo, ip, ultimaSincronizacao);

  /// Create a copy of EstadoDiagnostico
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EstadoDiagnosticoImplCopyWith<_$EstadoDiagnosticoImpl> get copyWith =>
      __$$EstadoDiagnosticoImplCopyWithImpl<_$EstadoDiagnosticoImpl>(
          this, _$identity);
}

abstract class _EstadoDiagnostico implements EstadoDiagnostico {
  const factory _EstadoDiagnostico(
      {final String versaoApp,
      final String ambienteRotulo,
      final String ip,
      final DateTime? ultimaSincronizacao}) = _$EstadoDiagnosticoImpl;

  @override
  String get versaoApp;
  @override
  String get ambienteRotulo;
  @override
  String get ip;
  @override
  DateTime? get ultimaSincronizacao;

  /// Create a copy of EstadoDiagnostico
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EstadoDiagnosticoImplCopyWith<_$EstadoDiagnosticoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
