// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'modelo_publicidade.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ModeloMensagemLetreiro _$ModeloMensagemLetreiroFromJson(
    Map<String, dynamic> json) {
  return _ModeloMensagemLetreiro.fromJson(json);
}

/// @nodoc
mixin _$ModeloMensagemLetreiro {
  String get id => throw _privateConstructorUsedError;
  String get texto => throw _privateConstructorUsedError;
  int get ordem => throw _privateConstructorUsedError;
  bool get ativo => throw _privateConstructorUsedError;

  /// Serializes this ModeloMensagemLetreiro to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModeloMensagemLetreiro
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModeloMensagemLetreiroCopyWith<ModeloMensagemLetreiro> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModeloMensagemLetreiroCopyWith<$Res> {
  factory $ModeloMensagemLetreiroCopyWith(ModeloMensagemLetreiro value,
          $Res Function(ModeloMensagemLetreiro) then) =
      _$ModeloMensagemLetreiroCopyWithImpl<$Res, ModeloMensagemLetreiro>;
  @useResult
  $Res call({String id, String texto, int ordem, bool ativo});
}

/// @nodoc
class _$ModeloMensagemLetreiroCopyWithImpl<$Res,
        $Val extends ModeloMensagemLetreiro>
    implements $ModeloMensagemLetreiroCopyWith<$Res> {
  _$ModeloMensagemLetreiroCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModeloMensagemLetreiro
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? texto = null,
    Object? ordem = null,
    Object? ativo = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      texto: null == texto
          ? _value.texto
          : texto // ignore: cast_nullable_to_non_nullable
              as String,
      ordem: null == ordem
          ? _value.ordem
          : ordem // ignore: cast_nullable_to_non_nullable
              as int,
      ativo: null == ativo
          ? _value.ativo
          : ativo // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModeloMensagemLetreiroImplCopyWith<$Res>
    implements $ModeloMensagemLetreiroCopyWith<$Res> {
  factory _$$ModeloMensagemLetreiroImplCopyWith(
          _$ModeloMensagemLetreiroImpl value,
          $Res Function(_$ModeloMensagemLetreiroImpl) then) =
      __$$ModeloMensagemLetreiroImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String texto, int ordem, bool ativo});
}

/// @nodoc
class __$$ModeloMensagemLetreiroImplCopyWithImpl<$Res>
    extends _$ModeloMensagemLetreiroCopyWithImpl<$Res,
        _$ModeloMensagemLetreiroImpl>
    implements _$$ModeloMensagemLetreiroImplCopyWith<$Res> {
  __$$ModeloMensagemLetreiroImplCopyWithImpl(
      _$ModeloMensagemLetreiroImpl _value,
      $Res Function(_$ModeloMensagemLetreiroImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModeloMensagemLetreiro
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? texto = null,
    Object? ordem = null,
    Object? ativo = null,
  }) {
    return _then(_$ModeloMensagemLetreiroImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      texto: null == texto
          ? _value.texto
          : texto // ignore: cast_nullable_to_non_nullable
              as String,
      ordem: null == ordem
          ? _value.ordem
          : ordem // ignore: cast_nullable_to_non_nullable
              as int,
      ativo: null == ativo
          ? _value.ativo
          : ativo // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModeloMensagemLetreiroImpl extends _ModeloMensagemLetreiro {
  const _$ModeloMensagemLetreiroImpl(
      {required this.id,
      required this.texto,
      required this.ordem,
      this.ativo = true})
      : super._();

  factory _$ModeloMensagemLetreiroImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModeloMensagemLetreiroImplFromJson(json);

  @override
  final String id;
  @override
  final String texto;
  @override
  final int ordem;
  @override
  @JsonKey()
  final bool ativo;

  @override
  String toString() {
    return 'ModeloMensagemLetreiro(id: $id, texto: $texto, ordem: $ordem, ativo: $ativo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModeloMensagemLetreiroImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.texto, texto) || other.texto == texto) &&
            (identical(other.ordem, ordem) || other.ordem == ordem) &&
            (identical(other.ativo, ativo) || other.ativo == ativo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, texto, ordem, ativo);

  /// Create a copy of ModeloMensagemLetreiro
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModeloMensagemLetreiroImplCopyWith<_$ModeloMensagemLetreiroImpl>
      get copyWith => __$$ModeloMensagemLetreiroImplCopyWithImpl<
          _$ModeloMensagemLetreiroImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModeloMensagemLetreiroImplToJson(
      this,
    );
  }
}

abstract class _ModeloMensagemLetreiro extends ModeloMensagemLetreiro {
  const factory _ModeloMensagemLetreiro(
      {required final String id,
      required final String texto,
      required final int ordem,
      final bool ativo}) = _$ModeloMensagemLetreiroImpl;
  const _ModeloMensagemLetreiro._() : super._();

  factory _ModeloMensagemLetreiro.fromJson(Map<String, dynamic> json) =
      _$ModeloMensagemLetreiroImpl.fromJson;

  @override
  String get id;
  @override
  String get texto;
  @override
  int get ordem;
  @override
  bool get ativo;

  /// Create a copy of ModeloMensagemLetreiro
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModeloMensagemLetreiroImplCopyWith<_$ModeloMensagemLetreiroImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ModeloPublicidade _$ModeloPublicidadeFromJson(Map<String, dynamic> json) {
  return _ModeloPublicidade.fromJson(json);
}

/// @nodoc
mixin _$ModeloPublicidade {
  bool get ativa => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: FormatoPublicidade.carrossel)
  FormatoPublicidade get formato => throw _privateConstructorUsedError;
  List<ModeloMidia> get banners => throw _privateConstructorUsedError;
  int get intervaloSegundos => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: TransicaoCarrossel.suave)
  TransicaoCarrossel get transicao => throw _privateConstructorUsedError;
  List<ModeloMensagemLetreiro> get mensagens =>
      throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: VelocidadeLetreiro.normal)
  VelocidadeLetreiro get velocidade => throw _privateConstructorUsedError;
  String get separador => throw _privateConstructorUsedError;
  ModeloMidia? get midiaParceiro => throw _privateConstructorUsedError;

  /// Serializes this ModeloPublicidade to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModeloPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModeloPublicidadeCopyWith<ModeloPublicidade> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModeloPublicidadeCopyWith<$Res> {
  factory $ModeloPublicidadeCopyWith(
          ModeloPublicidade value, $Res Function(ModeloPublicidade) then) =
      _$ModeloPublicidadeCopyWithImpl<$Res, ModeloPublicidade>;
  @useResult
  $Res call(
      {bool ativa,
      @JsonKey(unknownEnumValue: FormatoPublicidade.carrossel)
      FormatoPublicidade formato,
      List<ModeloMidia> banners,
      int intervaloSegundos,
      @JsonKey(unknownEnumValue: TransicaoCarrossel.suave)
      TransicaoCarrossel transicao,
      List<ModeloMensagemLetreiro> mensagens,
      @JsonKey(unknownEnumValue: VelocidadeLetreiro.normal)
      VelocidadeLetreiro velocidade,
      String separador,
      ModeloMidia? midiaParceiro});

  $ModeloMidiaCopyWith<$Res>? get midiaParceiro;
}

/// @nodoc
class _$ModeloPublicidadeCopyWithImpl<$Res, $Val extends ModeloPublicidade>
    implements $ModeloPublicidadeCopyWith<$Res> {
  _$ModeloPublicidadeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModeloPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ativa = null,
    Object? formato = null,
    Object? banners = null,
    Object? intervaloSegundos = null,
    Object? transicao = null,
    Object? mensagens = null,
    Object? velocidade = null,
    Object? separador = null,
    Object? midiaParceiro = freezed,
  }) {
    return _then(_value.copyWith(
      ativa: null == ativa
          ? _value.ativa
          : ativa // ignore: cast_nullable_to_non_nullable
              as bool,
      formato: null == formato
          ? _value.formato
          : formato // ignore: cast_nullable_to_non_nullable
              as FormatoPublicidade,
      banners: null == banners
          ? _value.banners
          : banners // ignore: cast_nullable_to_non_nullable
              as List<ModeloMidia>,
      intervaloSegundos: null == intervaloSegundos
          ? _value.intervaloSegundos
          : intervaloSegundos // ignore: cast_nullable_to_non_nullable
              as int,
      transicao: null == transicao
          ? _value.transicao
          : transicao // ignore: cast_nullable_to_non_nullable
              as TransicaoCarrossel,
      mensagens: null == mensagens
          ? _value.mensagens
          : mensagens // ignore: cast_nullable_to_non_nullable
              as List<ModeloMensagemLetreiro>,
      velocidade: null == velocidade
          ? _value.velocidade
          : velocidade // ignore: cast_nullable_to_non_nullable
              as VelocidadeLetreiro,
      separador: null == separador
          ? _value.separador
          : separador // ignore: cast_nullable_to_non_nullable
              as String,
      midiaParceiro: freezed == midiaParceiro
          ? _value.midiaParceiro
          : midiaParceiro // ignore: cast_nullable_to_non_nullable
              as ModeloMidia?,
    ) as $Val);
  }

  /// Create a copy of ModeloPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ModeloMidiaCopyWith<$Res>? get midiaParceiro {
    if (_value.midiaParceiro == null) {
      return null;
    }

    return $ModeloMidiaCopyWith<$Res>(_value.midiaParceiro!, (value) {
      return _then(_value.copyWith(midiaParceiro: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ModeloPublicidadeImplCopyWith<$Res>
    implements $ModeloPublicidadeCopyWith<$Res> {
  factory _$$ModeloPublicidadeImplCopyWith(_$ModeloPublicidadeImpl value,
          $Res Function(_$ModeloPublicidadeImpl) then) =
      __$$ModeloPublicidadeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool ativa,
      @JsonKey(unknownEnumValue: FormatoPublicidade.carrossel)
      FormatoPublicidade formato,
      List<ModeloMidia> banners,
      int intervaloSegundos,
      @JsonKey(unknownEnumValue: TransicaoCarrossel.suave)
      TransicaoCarrossel transicao,
      List<ModeloMensagemLetreiro> mensagens,
      @JsonKey(unknownEnumValue: VelocidadeLetreiro.normal)
      VelocidadeLetreiro velocidade,
      String separador,
      ModeloMidia? midiaParceiro});

  @override
  $ModeloMidiaCopyWith<$Res>? get midiaParceiro;
}

/// @nodoc
class __$$ModeloPublicidadeImplCopyWithImpl<$Res>
    extends _$ModeloPublicidadeCopyWithImpl<$Res, _$ModeloPublicidadeImpl>
    implements _$$ModeloPublicidadeImplCopyWith<$Res> {
  __$$ModeloPublicidadeImplCopyWithImpl(_$ModeloPublicidadeImpl _value,
      $Res Function(_$ModeloPublicidadeImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModeloPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ativa = null,
    Object? formato = null,
    Object? banners = null,
    Object? intervaloSegundos = null,
    Object? transicao = null,
    Object? mensagens = null,
    Object? velocidade = null,
    Object? separador = null,
    Object? midiaParceiro = freezed,
  }) {
    return _then(_$ModeloPublicidadeImpl(
      ativa: null == ativa
          ? _value.ativa
          : ativa // ignore: cast_nullable_to_non_nullable
              as bool,
      formato: null == formato
          ? _value.formato
          : formato // ignore: cast_nullable_to_non_nullable
              as FormatoPublicidade,
      banners: null == banners
          ? _value._banners
          : banners // ignore: cast_nullable_to_non_nullable
              as List<ModeloMidia>,
      intervaloSegundos: null == intervaloSegundos
          ? _value.intervaloSegundos
          : intervaloSegundos // ignore: cast_nullable_to_non_nullable
              as int,
      transicao: null == transicao
          ? _value.transicao
          : transicao // ignore: cast_nullable_to_non_nullable
              as TransicaoCarrossel,
      mensagens: null == mensagens
          ? _value._mensagens
          : mensagens // ignore: cast_nullable_to_non_nullable
              as List<ModeloMensagemLetreiro>,
      velocidade: null == velocidade
          ? _value.velocidade
          : velocidade // ignore: cast_nullable_to_non_nullable
              as VelocidadeLetreiro,
      separador: null == separador
          ? _value.separador
          : separador // ignore: cast_nullable_to_non_nullable
              as String,
      midiaParceiro: freezed == midiaParceiro
          ? _value.midiaParceiro
          : midiaParceiro // ignore: cast_nullable_to_non_nullable
              as ModeloMidia?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModeloPublicidadeImpl extends _ModeloPublicidade {
  const _$ModeloPublicidadeImpl(
      {this.ativa = false,
      @JsonKey(unknownEnumValue: FormatoPublicidade.carrossel)
      this.formato = FormatoPublicidade.carrossel,
      final List<ModeloMidia> banners = const [],
      this.intervaloSegundos = 6,
      @JsonKey(unknownEnumValue: TransicaoCarrossel.suave)
      this.transicao = TransicaoCarrossel.suave,
      final List<ModeloMensagemLetreiro> mensagens = const [],
      @JsonKey(unknownEnumValue: VelocidadeLetreiro.normal)
      this.velocidade = VelocidadeLetreiro.normal,
      this.separador = '•',
      this.midiaParceiro})
      : _banners = banners,
        _mensagens = mensagens,
        super._();

  factory _$ModeloPublicidadeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModeloPublicidadeImplFromJson(json);

  @override
  @JsonKey()
  final bool ativa;
  @override
  @JsonKey(unknownEnumValue: FormatoPublicidade.carrossel)
  final FormatoPublicidade formato;
  final List<ModeloMidia> _banners;
  @override
  @JsonKey()
  List<ModeloMidia> get banners {
    if (_banners is EqualUnmodifiableListView) return _banners;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_banners);
  }

  @override
  @JsonKey()
  final int intervaloSegundos;
  @override
  @JsonKey(unknownEnumValue: TransicaoCarrossel.suave)
  final TransicaoCarrossel transicao;
  final List<ModeloMensagemLetreiro> _mensagens;
  @override
  @JsonKey()
  List<ModeloMensagemLetreiro> get mensagens {
    if (_mensagens is EqualUnmodifiableListView) return _mensagens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mensagens);
  }

  @override
  @JsonKey(unknownEnumValue: VelocidadeLetreiro.normal)
  final VelocidadeLetreiro velocidade;
  @override
  @JsonKey()
  final String separador;
  @override
  final ModeloMidia? midiaParceiro;

  @override
  String toString() {
    return 'ModeloPublicidade(ativa: $ativa, formato: $formato, banners: $banners, intervaloSegundos: $intervaloSegundos, transicao: $transicao, mensagens: $mensagens, velocidade: $velocidade, separador: $separador, midiaParceiro: $midiaParceiro)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModeloPublicidadeImpl &&
            (identical(other.ativa, ativa) || other.ativa == ativa) &&
            (identical(other.formato, formato) || other.formato == formato) &&
            const DeepCollectionEquality().equals(other._banners, _banners) &&
            (identical(other.intervaloSegundos, intervaloSegundos) ||
                other.intervaloSegundos == intervaloSegundos) &&
            (identical(other.transicao, transicao) ||
                other.transicao == transicao) &&
            const DeepCollectionEquality()
                .equals(other._mensagens, _mensagens) &&
            (identical(other.velocidade, velocidade) ||
                other.velocidade == velocidade) &&
            (identical(other.separador, separador) ||
                other.separador == separador) &&
            (identical(other.midiaParceiro, midiaParceiro) ||
                other.midiaParceiro == midiaParceiro));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      ativa,
      formato,
      const DeepCollectionEquality().hash(_banners),
      intervaloSegundos,
      transicao,
      const DeepCollectionEquality().hash(_mensagens),
      velocidade,
      separador,
      midiaParceiro);

  /// Create a copy of ModeloPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModeloPublicidadeImplCopyWith<_$ModeloPublicidadeImpl> get copyWith =>
      __$$ModeloPublicidadeImplCopyWithImpl<_$ModeloPublicidadeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModeloPublicidadeImplToJson(
      this,
    );
  }
}

abstract class _ModeloPublicidade extends ModeloPublicidade {
  const factory _ModeloPublicidade(
      {final bool ativa,
      @JsonKey(unknownEnumValue: FormatoPublicidade.carrossel)
      final FormatoPublicidade formato,
      final List<ModeloMidia> banners,
      final int intervaloSegundos,
      @JsonKey(unknownEnumValue: TransicaoCarrossel.suave)
      final TransicaoCarrossel transicao,
      final List<ModeloMensagemLetreiro> mensagens,
      @JsonKey(unknownEnumValue: VelocidadeLetreiro.normal)
      final VelocidadeLetreiro velocidade,
      final String separador,
      final ModeloMidia? midiaParceiro}) = _$ModeloPublicidadeImpl;
  const _ModeloPublicidade._() : super._();

  factory _ModeloPublicidade.fromJson(Map<String, dynamic> json) =
      _$ModeloPublicidadeImpl.fromJson;

  @override
  bool get ativa;
  @override
  @JsonKey(unknownEnumValue: FormatoPublicidade.carrossel)
  FormatoPublicidade get formato;
  @override
  List<ModeloMidia> get banners;
  @override
  int get intervaloSegundos;
  @override
  @JsonKey(unknownEnumValue: TransicaoCarrossel.suave)
  TransicaoCarrossel get transicao;
  @override
  List<ModeloMensagemLetreiro> get mensagens;
  @override
  @JsonKey(unknownEnumValue: VelocidadeLetreiro.normal)
  VelocidadeLetreiro get velocidade;
  @override
  String get separador;
  @override
  ModeloMidia? get midiaParceiro;

  /// Create a copy of ModeloPublicidade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModeloPublicidadeImplCopyWith<_$ModeloPublicidadeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
