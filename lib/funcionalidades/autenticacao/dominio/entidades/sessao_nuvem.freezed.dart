// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sessao_nuvem.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SessaoNuvem _$SessaoNuvemFromJson(Map<String, dynamic> json) {
  return _SessaoNuvem.fromJson(json);
}

/// @nodoc
mixin _$SessaoNuvem {
  String get token => throw _privateConstructorUsedError;
  DateTime get validade => throw _privateConstructorUsedError;
  UsuarioSessao get usuario => throw _privateConstructorUsedError;
  EmpresaSessao get empresa => throw _privateConstructorUsedError;
  DispositivoSessao get dispositivo => throw _privateConstructorUsedError;
  EstabelecimentoSessao get estabelecimento =>
      throw _privateConstructorUsedError;

  /// Serializes this SessaoNuvem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessaoNuvem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessaoNuvemCopyWith<SessaoNuvem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessaoNuvemCopyWith<$Res> {
  factory $SessaoNuvemCopyWith(
          SessaoNuvem value, $Res Function(SessaoNuvem) then) =
      _$SessaoNuvemCopyWithImpl<$Res, SessaoNuvem>;
  @useResult
  $Res call(
      {String token,
      DateTime validade,
      UsuarioSessao usuario,
      EmpresaSessao empresa,
      DispositivoSessao dispositivo,
      EstabelecimentoSessao estabelecimento});

  $UsuarioSessaoCopyWith<$Res> get usuario;
  $EmpresaSessaoCopyWith<$Res> get empresa;
  $DispositivoSessaoCopyWith<$Res> get dispositivo;
  $EstabelecimentoSessaoCopyWith<$Res> get estabelecimento;
}

/// @nodoc
class _$SessaoNuvemCopyWithImpl<$Res, $Val extends SessaoNuvem>
    implements $SessaoNuvemCopyWith<$Res> {
  _$SessaoNuvemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessaoNuvem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? validade = null,
    Object? usuario = null,
    Object? empresa = null,
    Object? dispositivo = null,
    Object? estabelecimento = null,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      validade: null == validade
          ? _value.validade
          : validade // ignore: cast_nullable_to_non_nullable
              as DateTime,
      usuario: null == usuario
          ? _value.usuario
          : usuario // ignore: cast_nullable_to_non_nullable
              as UsuarioSessao,
      empresa: null == empresa
          ? _value.empresa
          : empresa // ignore: cast_nullable_to_non_nullable
              as EmpresaSessao,
      dispositivo: null == dispositivo
          ? _value.dispositivo
          : dispositivo // ignore: cast_nullable_to_non_nullable
              as DispositivoSessao,
      estabelecimento: null == estabelecimento
          ? _value.estabelecimento
          : estabelecimento // ignore: cast_nullable_to_non_nullable
              as EstabelecimentoSessao,
    ) as $Val);
  }

  /// Create a copy of SessaoNuvem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UsuarioSessaoCopyWith<$Res> get usuario {
    return $UsuarioSessaoCopyWith<$Res>(_value.usuario, (value) {
      return _then(_value.copyWith(usuario: value) as $Val);
    });
  }

  /// Create a copy of SessaoNuvem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EmpresaSessaoCopyWith<$Res> get empresa {
    return $EmpresaSessaoCopyWith<$Res>(_value.empresa, (value) {
      return _then(_value.copyWith(empresa: value) as $Val);
    });
  }

  /// Create a copy of SessaoNuvem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DispositivoSessaoCopyWith<$Res> get dispositivo {
    return $DispositivoSessaoCopyWith<$Res>(_value.dispositivo, (value) {
      return _then(_value.copyWith(dispositivo: value) as $Val);
    });
  }

  /// Create a copy of SessaoNuvem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EstabelecimentoSessaoCopyWith<$Res> get estabelecimento {
    return $EstabelecimentoSessaoCopyWith<$Res>(_value.estabelecimento,
        (value) {
      return _then(_value.copyWith(estabelecimento: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SessaoNuvemImplCopyWith<$Res>
    implements $SessaoNuvemCopyWith<$Res> {
  factory _$$SessaoNuvemImplCopyWith(
          _$SessaoNuvemImpl value, $Res Function(_$SessaoNuvemImpl) then) =
      __$$SessaoNuvemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String token,
      DateTime validade,
      UsuarioSessao usuario,
      EmpresaSessao empresa,
      DispositivoSessao dispositivo,
      EstabelecimentoSessao estabelecimento});

  @override
  $UsuarioSessaoCopyWith<$Res> get usuario;
  @override
  $EmpresaSessaoCopyWith<$Res> get empresa;
  @override
  $DispositivoSessaoCopyWith<$Res> get dispositivo;
  @override
  $EstabelecimentoSessaoCopyWith<$Res> get estabelecimento;
}

/// @nodoc
class __$$SessaoNuvemImplCopyWithImpl<$Res>
    extends _$SessaoNuvemCopyWithImpl<$Res, _$SessaoNuvemImpl>
    implements _$$SessaoNuvemImplCopyWith<$Res> {
  __$$SessaoNuvemImplCopyWithImpl(
      _$SessaoNuvemImpl _value, $Res Function(_$SessaoNuvemImpl) _then)
      : super(_value, _then);

  /// Create a copy of SessaoNuvem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? validade = null,
    Object? usuario = null,
    Object? empresa = null,
    Object? dispositivo = null,
    Object? estabelecimento = null,
  }) {
    return _then(_$SessaoNuvemImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      validade: null == validade
          ? _value.validade
          : validade // ignore: cast_nullable_to_non_nullable
              as DateTime,
      usuario: null == usuario
          ? _value.usuario
          : usuario // ignore: cast_nullable_to_non_nullable
              as UsuarioSessao,
      empresa: null == empresa
          ? _value.empresa
          : empresa // ignore: cast_nullable_to_non_nullable
              as EmpresaSessao,
      dispositivo: null == dispositivo
          ? _value.dispositivo
          : dispositivo // ignore: cast_nullable_to_non_nullable
              as DispositivoSessao,
      estabelecimento: null == estabelecimento
          ? _value.estabelecimento
          : estabelecimento // ignore: cast_nullable_to_non_nullable
              as EstabelecimentoSessao,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SessaoNuvemImpl extends _SessaoNuvem {
  const _$SessaoNuvemImpl(
      {required this.token,
      required this.validade,
      required this.usuario,
      required this.empresa,
      required this.dispositivo,
      required this.estabelecimento})
      : super._();

  factory _$SessaoNuvemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessaoNuvemImplFromJson(json);

  @override
  final String token;
  @override
  final DateTime validade;
  @override
  final UsuarioSessao usuario;
  @override
  final EmpresaSessao empresa;
  @override
  final DispositivoSessao dispositivo;
  @override
  final EstabelecimentoSessao estabelecimento;

  @override
  String toString() {
    return 'SessaoNuvem(token: $token, validade: $validade, usuario: $usuario, empresa: $empresa, dispositivo: $dispositivo, estabelecimento: $estabelecimento)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessaoNuvemImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.validade, validade) ||
                other.validade == validade) &&
            (identical(other.usuario, usuario) || other.usuario == usuario) &&
            (identical(other.empresa, empresa) || other.empresa == empresa) &&
            (identical(other.dispositivo, dispositivo) ||
                other.dispositivo == dispositivo) &&
            (identical(other.estabelecimento, estabelecimento) ||
                other.estabelecimento == estabelecimento));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, validade, usuario,
      empresa, dispositivo, estabelecimento);

  /// Create a copy of SessaoNuvem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessaoNuvemImplCopyWith<_$SessaoNuvemImpl> get copyWith =>
      __$$SessaoNuvemImplCopyWithImpl<_$SessaoNuvemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessaoNuvemImplToJson(
      this,
    );
  }
}

abstract class _SessaoNuvem extends SessaoNuvem {
  const factory _SessaoNuvem(
          {required final String token,
          required final DateTime validade,
          required final UsuarioSessao usuario,
          required final EmpresaSessao empresa,
          required final DispositivoSessao dispositivo,
          required final EstabelecimentoSessao estabelecimento}) =
      _$SessaoNuvemImpl;
  const _SessaoNuvem._() : super._();

  factory _SessaoNuvem.fromJson(Map<String, dynamic> json) =
      _$SessaoNuvemImpl.fromJson;

  @override
  String get token;
  @override
  DateTime get validade;
  @override
  UsuarioSessao get usuario;
  @override
  EmpresaSessao get empresa;
  @override
  DispositivoSessao get dispositivo;
  @override
  EstabelecimentoSessao get estabelecimento;

  /// Create a copy of SessaoNuvem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessaoNuvemImplCopyWith<_$SessaoNuvemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UsuarioSessao _$UsuarioSessaoFromJson(Map<String, dynamic> json) {
  return _UsuarioSessao.fromJson(json);
}

/// @nodoc
mixin _$UsuarioSessao {
  String get nome => throw _privateConstructorUsedError;
  String get imagem => throw _privateConstructorUsedError;

  /// Serializes this UsuarioSessao to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UsuarioSessao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UsuarioSessaoCopyWith<UsuarioSessao> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UsuarioSessaoCopyWith<$Res> {
  factory $UsuarioSessaoCopyWith(
          UsuarioSessao value, $Res Function(UsuarioSessao) then) =
      _$UsuarioSessaoCopyWithImpl<$Res, UsuarioSessao>;
  @useResult
  $Res call({String nome, String imagem});
}

/// @nodoc
class _$UsuarioSessaoCopyWithImpl<$Res, $Val extends UsuarioSessao>
    implements $UsuarioSessaoCopyWith<$Res> {
  _$UsuarioSessaoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UsuarioSessao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nome = null,
    Object? imagem = null,
  }) {
    return _then(_value.copyWith(
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
      imagem: null == imagem
          ? _value.imagem
          : imagem // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UsuarioSessaoImplCopyWith<$Res>
    implements $UsuarioSessaoCopyWith<$Res> {
  factory _$$UsuarioSessaoImplCopyWith(
          _$UsuarioSessaoImpl value, $Res Function(_$UsuarioSessaoImpl) then) =
      __$$UsuarioSessaoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String nome, String imagem});
}

/// @nodoc
class __$$UsuarioSessaoImplCopyWithImpl<$Res>
    extends _$UsuarioSessaoCopyWithImpl<$Res, _$UsuarioSessaoImpl>
    implements _$$UsuarioSessaoImplCopyWith<$Res> {
  __$$UsuarioSessaoImplCopyWithImpl(
      _$UsuarioSessaoImpl _value, $Res Function(_$UsuarioSessaoImpl) _then)
      : super(_value, _then);

  /// Create a copy of UsuarioSessao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nome = null,
    Object? imagem = null,
  }) {
    return _then(_$UsuarioSessaoImpl(
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
      imagem: null == imagem
          ? _value.imagem
          : imagem // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UsuarioSessaoImpl implements _UsuarioSessao {
  const _$UsuarioSessaoImpl({required this.nome, required this.imagem});

  factory _$UsuarioSessaoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UsuarioSessaoImplFromJson(json);

  @override
  final String nome;
  @override
  final String imagem;

  @override
  String toString() {
    return 'UsuarioSessao(nome: $nome, imagem: $imagem)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UsuarioSessaoImpl &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.imagem, imagem) || other.imagem == imagem));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nome, imagem);

  /// Create a copy of UsuarioSessao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UsuarioSessaoImplCopyWith<_$UsuarioSessaoImpl> get copyWith =>
      __$$UsuarioSessaoImplCopyWithImpl<_$UsuarioSessaoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UsuarioSessaoImplToJson(
      this,
    );
  }
}

abstract class _UsuarioSessao implements UsuarioSessao {
  const factory _UsuarioSessao(
      {required final String nome,
      required final String imagem}) = _$UsuarioSessaoImpl;

  factory _UsuarioSessao.fromJson(Map<String, dynamic> json) =
      _$UsuarioSessaoImpl.fromJson;

  @override
  String get nome;
  @override
  String get imagem;

  /// Create a copy of UsuarioSessao
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UsuarioSessaoImplCopyWith<_$UsuarioSessaoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EmpresaSessao _$EmpresaSessaoFromJson(Map<String, dynamic> json) {
  return _EmpresaSessao.fromJson(json);
}

/// @nodoc
mixin _$EmpresaSessao {
  String get id => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;

  /// Serializes this EmpresaSessao to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmpresaSessao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmpresaSessaoCopyWith<EmpresaSessao> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmpresaSessaoCopyWith<$Res> {
  factory $EmpresaSessaoCopyWith(
          EmpresaSessao value, $Res Function(EmpresaSessao) then) =
      _$EmpresaSessaoCopyWithImpl<$Res, EmpresaSessao>;
  @useResult
  $Res call({String id, String nome});
}

/// @nodoc
class _$EmpresaSessaoCopyWithImpl<$Res, $Val extends EmpresaSessao>
    implements $EmpresaSessaoCopyWith<$Res> {
  _$EmpresaSessaoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmpresaSessao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nome = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmpresaSessaoImplCopyWith<$Res>
    implements $EmpresaSessaoCopyWith<$Res> {
  factory _$$EmpresaSessaoImplCopyWith(
          _$EmpresaSessaoImpl value, $Res Function(_$EmpresaSessaoImpl) then) =
      __$$EmpresaSessaoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String nome});
}

/// @nodoc
class __$$EmpresaSessaoImplCopyWithImpl<$Res>
    extends _$EmpresaSessaoCopyWithImpl<$Res, _$EmpresaSessaoImpl>
    implements _$$EmpresaSessaoImplCopyWith<$Res> {
  __$$EmpresaSessaoImplCopyWithImpl(
      _$EmpresaSessaoImpl _value, $Res Function(_$EmpresaSessaoImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmpresaSessao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nome = null,
  }) {
    return _then(_$EmpresaSessaoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmpresaSessaoImpl implements _EmpresaSessao {
  const _$EmpresaSessaoImpl({required this.id, required this.nome});

  factory _$EmpresaSessaoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmpresaSessaoImplFromJson(json);

  @override
  final String id;
  @override
  final String nome;

  @override
  String toString() {
    return 'EmpresaSessao(id: $id, nome: $nome)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmpresaSessaoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nome, nome) || other.nome == nome));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nome);

  /// Create a copy of EmpresaSessao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmpresaSessaoImplCopyWith<_$EmpresaSessaoImpl> get copyWith =>
      __$$EmpresaSessaoImplCopyWithImpl<_$EmpresaSessaoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmpresaSessaoImplToJson(
      this,
    );
  }
}

abstract class _EmpresaSessao implements EmpresaSessao {
  const factory _EmpresaSessao(
      {required final String id,
      required final String nome}) = _$EmpresaSessaoImpl;

  factory _EmpresaSessao.fromJson(Map<String, dynamic> json) =
      _$EmpresaSessaoImpl.fromJson;

  @override
  String get id;
  @override
  String get nome;

  /// Create a copy of EmpresaSessao
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmpresaSessaoImplCopyWith<_$EmpresaSessaoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DispositivoSessao _$DispositivoSessaoFromJson(Map<String, dynamic> json) {
  return _DispositivoSessao.fromJson(json);
}

/// @nodoc
mixin _$DispositivoSessao {
  String get id => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;

  /// Serializes this DispositivoSessao to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DispositivoSessao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DispositivoSessaoCopyWith<DispositivoSessao> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DispositivoSessaoCopyWith<$Res> {
  factory $DispositivoSessaoCopyWith(
          DispositivoSessao value, $Res Function(DispositivoSessao) then) =
      _$DispositivoSessaoCopyWithImpl<$Res, DispositivoSessao>;
  @useResult
  $Res call({String id, String nome});
}

/// @nodoc
class _$DispositivoSessaoCopyWithImpl<$Res, $Val extends DispositivoSessao>
    implements $DispositivoSessaoCopyWith<$Res> {
  _$DispositivoSessaoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DispositivoSessao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nome = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DispositivoSessaoImplCopyWith<$Res>
    implements $DispositivoSessaoCopyWith<$Res> {
  factory _$$DispositivoSessaoImplCopyWith(_$DispositivoSessaoImpl value,
          $Res Function(_$DispositivoSessaoImpl) then) =
      __$$DispositivoSessaoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String nome});
}

/// @nodoc
class __$$DispositivoSessaoImplCopyWithImpl<$Res>
    extends _$DispositivoSessaoCopyWithImpl<$Res, _$DispositivoSessaoImpl>
    implements _$$DispositivoSessaoImplCopyWith<$Res> {
  __$$DispositivoSessaoImplCopyWithImpl(_$DispositivoSessaoImpl _value,
      $Res Function(_$DispositivoSessaoImpl) _then)
      : super(_value, _then);

  /// Create a copy of DispositivoSessao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nome = null,
  }) {
    return _then(_$DispositivoSessaoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DispositivoSessaoImpl implements _DispositivoSessao {
  const _$DispositivoSessaoImpl({required this.id, required this.nome});

  factory _$DispositivoSessaoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DispositivoSessaoImplFromJson(json);

  @override
  final String id;
  @override
  final String nome;

  @override
  String toString() {
    return 'DispositivoSessao(id: $id, nome: $nome)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispositivoSessaoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nome, nome) || other.nome == nome));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nome);

  /// Create a copy of DispositivoSessao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DispositivoSessaoImplCopyWith<_$DispositivoSessaoImpl> get copyWith =>
      __$$DispositivoSessaoImplCopyWithImpl<_$DispositivoSessaoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DispositivoSessaoImplToJson(
      this,
    );
  }
}

abstract class _DispositivoSessao implements DispositivoSessao {
  const factory _DispositivoSessao(
      {required final String id,
      required final String nome}) = _$DispositivoSessaoImpl;

  factory _DispositivoSessao.fromJson(Map<String, dynamic> json) =
      _$DispositivoSessaoImpl.fromJson;

  @override
  String get id;
  @override
  String get nome;

  /// Create a copy of DispositivoSessao
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DispositivoSessaoImplCopyWith<_$DispositivoSessaoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AmbienteSessao _$AmbienteSessaoFromJson(Map<String, dynamic> json) {
  return _AmbienteSessao.fromJson(json);
}

/// @nodoc
mixin _$AmbienteSessao {
  String get id => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;
  bool get padrao => throw _privateConstructorUsedError;

  /// Serializes this AmbienteSessao to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AmbienteSessao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AmbienteSessaoCopyWith<AmbienteSessao> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AmbienteSessaoCopyWith<$Res> {
  factory $AmbienteSessaoCopyWith(
          AmbienteSessao value, $Res Function(AmbienteSessao) then) =
      _$AmbienteSessaoCopyWithImpl<$Res, AmbienteSessao>;
  @useResult
  $Res call({String id, String nome, bool padrao});
}

/// @nodoc
class _$AmbienteSessaoCopyWithImpl<$Res, $Val extends AmbienteSessao>
    implements $AmbienteSessaoCopyWith<$Res> {
  _$AmbienteSessaoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AmbienteSessao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nome = null,
    Object? padrao = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
      padrao: null == padrao
          ? _value.padrao
          : padrao // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AmbienteSessaoImplCopyWith<$Res>
    implements $AmbienteSessaoCopyWith<$Res> {
  factory _$$AmbienteSessaoImplCopyWith(_$AmbienteSessaoImpl value,
          $Res Function(_$AmbienteSessaoImpl) then) =
      __$$AmbienteSessaoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String nome, bool padrao});
}

/// @nodoc
class __$$AmbienteSessaoImplCopyWithImpl<$Res>
    extends _$AmbienteSessaoCopyWithImpl<$Res, _$AmbienteSessaoImpl>
    implements _$$AmbienteSessaoImplCopyWith<$Res> {
  __$$AmbienteSessaoImplCopyWithImpl(
      _$AmbienteSessaoImpl _value, $Res Function(_$AmbienteSessaoImpl) _then)
      : super(_value, _then);

  /// Create a copy of AmbienteSessao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nome = null,
    Object? padrao = null,
  }) {
    return _then(_$AmbienteSessaoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
      padrao: null == padrao
          ? _value.padrao
          : padrao // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AmbienteSessaoImpl implements _AmbienteSessao {
  const _$AmbienteSessaoImpl(
      {required this.id, required this.nome, required this.padrao});

  factory _$AmbienteSessaoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AmbienteSessaoImplFromJson(json);

  @override
  final String id;
  @override
  final String nome;
  @override
  final bool padrao;

  @override
  String toString() {
    return 'AmbienteSessao(id: $id, nome: $nome, padrao: $padrao)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AmbienteSessaoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.padrao, padrao) || other.padrao == padrao));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nome, padrao);

  /// Create a copy of AmbienteSessao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AmbienteSessaoImplCopyWith<_$AmbienteSessaoImpl> get copyWith =>
      __$$AmbienteSessaoImplCopyWithImpl<_$AmbienteSessaoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AmbienteSessaoImplToJson(
      this,
    );
  }
}

abstract class _AmbienteSessao implements AmbienteSessao {
  const factory _AmbienteSessao(
      {required final String id,
      required final String nome,
      required final bool padrao}) = _$AmbienteSessaoImpl;

  factory _AmbienteSessao.fromJson(Map<String, dynamic> json) =
      _$AmbienteSessaoImpl.fromJson;

  @override
  String get id;
  @override
  String get nome;
  @override
  bool get padrao;

  /// Create a copy of AmbienteSessao
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AmbienteSessaoImplCopyWith<_$AmbienteSessaoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EstabelecimentoSessao _$EstabelecimentoSessaoFromJson(
    Map<String, dynamic> json) {
  return _EstabelecimentoSessao.fromJson(json);
}

/// @nodoc
mixin _$EstabelecimentoSessao {
  String get id => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;
  List<AmbienteSessao> get ambientes => throw _privateConstructorUsedError;

  /// Serializes this EstabelecimentoSessao to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EstabelecimentoSessao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EstabelecimentoSessaoCopyWith<EstabelecimentoSessao> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EstabelecimentoSessaoCopyWith<$Res> {
  factory $EstabelecimentoSessaoCopyWith(EstabelecimentoSessao value,
          $Res Function(EstabelecimentoSessao) then) =
      _$EstabelecimentoSessaoCopyWithImpl<$Res, EstabelecimentoSessao>;
  @useResult
  $Res call({String id, String nome, List<AmbienteSessao> ambientes});
}

/// @nodoc
class _$EstabelecimentoSessaoCopyWithImpl<$Res,
        $Val extends EstabelecimentoSessao>
    implements $EstabelecimentoSessaoCopyWith<$Res> {
  _$EstabelecimentoSessaoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EstabelecimentoSessao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nome = null,
    Object? ambientes = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
      ambientes: null == ambientes
          ? _value.ambientes
          : ambientes // ignore: cast_nullable_to_non_nullable
              as List<AmbienteSessao>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EstabelecimentoSessaoImplCopyWith<$Res>
    implements $EstabelecimentoSessaoCopyWith<$Res> {
  factory _$$EstabelecimentoSessaoImplCopyWith(
          _$EstabelecimentoSessaoImpl value,
          $Res Function(_$EstabelecimentoSessaoImpl) then) =
      __$$EstabelecimentoSessaoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String nome, List<AmbienteSessao> ambientes});
}

/// @nodoc
class __$$EstabelecimentoSessaoImplCopyWithImpl<$Res>
    extends _$EstabelecimentoSessaoCopyWithImpl<$Res,
        _$EstabelecimentoSessaoImpl>
    implements _$$EstabelecimentoSessaoImplCopyWith<$Res> {
  __$$EstabelecimentoSessaoImplCopyWithImpl(_$EstabelecimentoSessaoImpl _value,
      $Res Function(_$EstabelecimentoSessaoImpl) _then)
      : super(_value, _then);

  /// Create a copy of EstabelecimentoSessao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nome = null,
    Object? ambientes = null,
  }) {
    return _then(_$EstabelecimentoSessaoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
      ambientes: null == ambientes
          ? _value._ambientes
          : ambientes // ignore: cast_nullable_to_non_nullable
              as List<AmbienteSessao>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EstabelecimentoSessaoImpl implements _EstabelecimentoSessao {
  const _$EstabelecimentoSessaoImpl(
      {required this.id,
      required this.nome,
      final List<AmbienteSessao> ambientes = const <AmbienteSessao>[]})
      : _ambientes = ambientes;

  factory _$EstabelecimentoSessaoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EstabelecimentoSessaoImplFromJson(json);

  @override
  final String id;
  @override
  final String nome;
  final List<AmbienteSessao> _ambientes;
  @override
  @JsonKey()
  List<AmbienteSessao> get ambientes {
    if (_ambientes is EqualUnmodifiableListView) return _ambientes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ambientes);
  }

  @override
  String toString() {
    return 'EstabelecimentoSessao(id: $id, nome: $nome, ambientes: $ambientes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EstabelecimentoSessaoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            const DeepCollectionEquality()
                .equals(other._ambientes, _ambientes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, nome, const DeepCollectionEquality().hash(_ambientes));

  /// Create a copy of EstabelecimentoSessao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EstabelecimentoSessaoImplCopyWith<_$EstabelecimentoSessaoImpl>
      get copyWith => __$$EstabelecimentoSessaoImplCopyWithImpl<
          _$EstabelecimentoSessaoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EstabelecimentoSessaoImplToJson(
      this,
    );
  }
}

abstract class _EstabelecimentoSessao implements EstabelecimentoSessao {
  const factory _EstabelecimentoSessao(
      {required final String id,
      required final String nome,
      final List<AmbienteSessao> ambientes}) = _$EstabelecimentoSessaoImpl;

  factory _EstabelecimentoSessao.fromJson(Map<String, dynamic> json) =
      _$EstabelecimentoSessaoImpl.fromJson;

  @override
  String get id;
  @override
  String get nome;
  @override
  List<AmbienteSessao> get ambientes;

  /// Create a copy of EstabelecimentoSessao
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EstabelecimentoSessaoImplCopyWith<_$EstabelecimentoSessaoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
