// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publicidade_barra.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MensagemLetreiro {
  String get id => throw _privateConstructorUsedError;
  String get texto => throw _privateConstructorUsedError;
  int get ordem => throw _privateConstructorUsedError;
  bool get ativo => throw _privateConstructorUsedError;

  /// Create a copy of MensagemLetreiro
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MensagemLetreiroCopyWith<MensagemLetreiro> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MensagemLetreiroCopyWith<$Res> {
  factory $MensagemLetreiroCopyWith(
          MensagemLetreiro value, $Res Function(MensagemLetreiro) then) =
      _$MensagemLetreiroCopyWithImpl<$Res, MensagemLetreiro>;
  @useResult
  $Res call({String id, String texto, int ordem, bool ativo});
}

/// @nodoc
class _$MensagemLetreiroCopyWithImpl<$Res, $Val extends MensagemLetreiro>
    implements $MensagemLetreiroCopyWith<$Res> {
  _$MensagemLetreiroCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MensagemLetreiro
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
abstract class _$$MensagemLetreiroImplCopyWith<$Res>
    implements $MensagemLetreiroCopyWith<$Res> {
  factory _$$MensagemLetreiroImplCopyWith(_$MensagemLetreiroImpl value,
          $Res Function(_$MensagemLetreiroImpl) then) =
      __$$MensagemLetreiroImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String texto, int ordem, bool ativo});
}

/// @nodoc
class __$$MensagemLetreiroImplCopyWithImpl<$Res>
    extends _$MensagemLetreiroCopyWithImpl<$Res, _$MensagemLetreiroImpl>
    implements _$$MensagemLetreiroImplCopyWith<$Res> {
  __$$MensagemLetreiroImplCopyWithImpl(_$MensagemLetreiroImpl _value,
      $Res Function(_$MensagemLetreiroImpl) _then)
      : super(_value, _then);

  /// Create a copy of MensagemLetreiro
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? texto = null,
    Object? ordem = null,
    Object? ativo = null,
  }) {
    return _then(_$MensagemLetreiroImpl(
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

class _$MensagemLetreiroImpl implements _MensagemLetreiro {
  const _$MensagemLetreiroImpl(
      {required this.id,
      required this.texto,
      required this.ordem,
      this.ativo = true});

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
    return 'MensagemLetreiro(id: $id, texto: $texto, ordem: $ordem, ativo: $ativo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MensagemLetreiroImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.texto, texto) || other.texto == texto) &&
            (identical(other.ordem, ordem) || other.ordem == ordem) &&
            (identical(other.ativo, ativo) || other.ativo == ativo));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, texto, ordem, ativo);

  /// Create a copy of MensagemLetreiro
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MensagemLetreiroImplCopyWith<_$MensagemLetreiroImpl> get copyWith =>
      __$$MensagemLetreiroImplCopyWithImpl<_$MensagemLetreiroImpl>(
          this, _$identity);
}

abstract class _MensagemLetreiro implements MensagemLetreiro {
  const factory _MensagemLetreiro(
      {required final String id,
      required final String texto,
      required final int ordem,
      final bool ativo}) = _$MensagemLetreiroImpl;

  @override
  String get id;
  @override
  String get texto;
  @override
  int get ordem;
  @override
  bool get ativo;

  /// Create a copy of MensagemLetreiro
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MensagemLetreiroImplCopyWith<_$MensagemLetreiroImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PublicidadeBarra {
  bool get ativa => throw _privateConstructorUsedError;
  FormatoPublicidade get formato => throw _privateConstructorUsedError;
  List<MidiaPropaganda> get banners => throw _privateConstructorUsedError;
  int get intervaloSegundos => throw _privateConstructorUsedError;
  TransicaoCarrossel get transicao => throw _privateConstructorUsedError;
  List<MensagemLetreiro> get mensagens => throw _privateConstructorUsedError;
  VelocidadeLetreiro get velocidade => throw _privateConstructorUsedError;
  String get separador => throw _privateConstructorUsedError;
  MidiaPropaganda? get midiaParceiro => throw _privateConstructorUsedError;

  /// Create a copy of PublicidadeBarra
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicidadeBarraCopyWith<PublicidadeBarra> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicidadeBarraCopyWith<$Res> {
  factory $PublicidadeBarraCopyWith(
          PublicidadeBarra value, $Res Function(PublicidadeBarra) then) =
      _$PublicidadeBarraCopyWithImpl<$Res, PublicidadeBarra>;
  @useResult
  $Res call(
      {bool ativa,
      FormatoPublicidade formato,
      List<MidiaPropaganda> banners,
      int intervaloSegundos,
      TransicaoCarrossel transicao,
      List<MensagemLetreiro> mensagens,
      VelocidadeLetreiro velocidade,
      String separador,
      MidiaPropaganda? midiaParceiro});

  $MidiaPropagandaCopyWith<$Res>? get midiaParceiro;
}

/// @nodoc
class _$PublicidadeBarraCopyWithImpl<$Res, $Val extends PublicidadeBarra>
    implements $PublicidadeBarraCopyWith<$Res> {
  _$PublicidadeBarraCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicidadeBarra
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
              as List<MidiaPropaganda>,
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
              as List<MensagemLetreiro>,
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
              as MidiaPropaganda?,
    ) as $Val);
  }

  /// Create a copy of PublicidadeBarra
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MidiaPropagandaCopyWith<$Res>? get midiaParceiro {
    if (_value.midiaParceiro == null) {
      return null;
    }

    return $MidiaPropagandaCopyWith<$Res>(_value.midiaParceiro!, (value) {
      return _then(_value.copyWith(midiaParceiro: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PublicidadeBarraImplCopyWith<$Res>
    implements $PublicidadeBarraCopyWith<$Res> {
  factory _$$PublicidadeBarraImplCopyWith(_$PublicidadeBarraImpl value,
          $Res Function(_$PublicidadeBarraImpl) then) =
      __$$PublicidadeBarraImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool ativa,
      FormatoPublicidade formato,
      List<MidiaPropaganda> banners,
      int intervaloSegundos,
      TransicaoCarrossel transicao,
      List<MensagemLetreiro> mensagens,
      VelocidadeLetreiro velocidade,
      String separador,
      MidiaPropaganda? midiaParceiro});

  @override
  $MidiaPropagandaCopyWith<$Res>? get midiaParceiro;
}

/// @nodoc
class __$$PublicidadeBarraImplCopyWithImpl<$Res>
    extends _$PublicidadeBarraCopyWithImpl<$Res, _$PublicidadeBarraImpl>
    implements _$$PublicidadeBarraImplCopyWith<$Res> {
  __$$PublicidadeBarraImplCopyWithImpl(_$PublicidadeBarraImpl _value,
      $Res Function(_$PublicidadeBarraImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublicidadeBarra
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
    return _then(_$PublicidadeBarraImpl(
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
              as List<MidiaPropaganda>,
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
              as List<MensagemLetreiro>,
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
              as MidiaPropaganda?,
    ));
  }
}

/// @nodoc

class _$PublicidadeBarraImpl extends _PublicidadeBarra {
  const _$PublicidadeBarraImpl(
      {this.ativa = false,
      this.formato = FormatoPublicidade.carrossel,
      final List<MidiaPropaganda> banners = const [],
      this.intervaloSegundos = 6,
      this.transicao = TransicaoCarrossel.suave,
      final List<MensagemLetreiro> mensagens = const [],
      this.velocidade = VelocidadeLetreiro.normal,
      this.separador = '•',
      this.midiaParceiro})
      : _banners = banners,
        _mensagens = mensagens,
        super._();

  @override
  @JsonKey()
  final bool ativa;
  @override
  @JsonKey()
  final FormatoPublicidade formato;
  final List<MidiaPropaganda> _banners;
  @override
  @JsonKey()
  List<MidiaPropaganda> get banners {
    if (_banners is EqualUnmodifiableListView) return _banners;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_banners);
  }

  @override
  @JsonKey()
  final int intervaloSegundos;
  @override
  @JsonKey()
  final TransicaoCarrossel transicao;
  final List<MensagemLetreiro> _mensagens;
  @override
  @JsonKey()
  List<MensagemLetreiro> get mensagens {
    if (_mensagens is EqualUnmodifiableListView) return _mensagens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mensagens);
  }

  @override
  @JsonKey()
  final VelocidadeLetreiro velocidade;
  @override
  @JsonKey()
  final String separador;
  @override
  final MidiaPropaganda? midiaParceiro;

  @override
  String toString() {
    return 'PublicidadeBarra(ativa: $ativa, formato: $formato, banners: $banners, intervaloSegundos: $intervaloSegundos, transicao: $transicao, mensagens: $mensagens, velocidade: $velocidade, separador: $separador, midiaParceiro: $midiaParceiro)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicidadeBarraImpl &&
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

  /// Create a copy of PublicidadeBarra
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicidadeBarraImplCopyWith<_$PublicidadeBarraImpl> get copyWith =>
      __$$PublicidadeBarraImplCopyWithImpl<_$PublicidadeBarraImpl>(
          this, _$identity);
}

abstract class _PublicidadeBarra extends PublicidadeBarra {
  const factory _PublicidadeBarra(
      {final bool ativa,
      final FormatoPublicidade formato,
      final List<MidiaPropaganda> banners,
      final int intervaloSegundos,
      final TransicaoCarrossel transicao,
      final List<MensagemLetreiro> mensagens,
      final VelocidadeLetreiro velocidade,
      final String separador,
      final MidiaPropaganda? midiaParceiro}) = _$PublicidadeBarraImpl;
  const _PublicidadeBarra._() : super._();

  @override
  bool get ativa;
  @override
  FormatoPublicidade get formato;
  @override
  List<MidiaPropaganda> get banners;
  @override
  int get intervaloSegundos;
  @override
  TransicaoCarrossel get transicao;
  @override
  List<MensagemLetreiro> get mensagens;
  @override
  VelocidadeLetreiro get velocidade;
  @override
  String get separador;
  @override
  MidiaPropaganda? get midiaParceiro;

  /// Create a copy of PublicidadeBarra
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicidadeBarraImplCopyWith<_$PublicidadeBarraImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
