// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'atendimento.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Atendimento {
  String get id => throw _privateConstructorUsedError;
  String get codigo => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;
  String get referencia => throw _privateConstructorUsedError;
  int get situacao => throw _privateConstructorUsedError;
  DateTime? get inicio => throw _privateConstructorUsedError;
  DateTime? get conclusao => throw _privateConstructorUsedError;
  int get subtotalCentavos => throw _privateConstructorUsedError;
  int get servicoCentavos => throw _privateConstructorUsedError;
  num get servicoPercentual => throw _privateConstructorUsedError;
  int get descontoCentavos => throw _privateConstructorUsedError;
  int get totalCentavos => throw _privateConstructorUsedError;
  int get pagoCentavos => throw _privateConstructorUsedError;
  int get saldoCentavos => throw _privateConstructorUsedError;
  String get sessaoId => throw _privateConstructorUsedError;
  String get sessaoCodigo => throw _privateConstructorUsedError;
  List<ComandaAtendimento> get comandas => throw _privateConstructorUsedError;
  List<ItemAtendimento> get itens => throw _privateConstructorUsedError;

  /// JSON original do atendimento como veio da API. O encerramento ecoa o
  /// atendimento INTEIRO de volta (ações 10 e 30) e a fatura reaproveita
  /// sub-objetos (parceiro, preço, modalidade, resumos) — guardar o bruto
  /// evita modelar dezenas de campos que o app não usa.
  Map<String, dynamic> get bruto => throw _privateConstructorUsedError;

  /// Create a copy of Atendimento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AtendimentoCopyWith<Atendimento> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AtendimentoCopyWith<$Res> {
  factory $AtendimentoCopyWith(
          Atendimento value, $Res Function(Atendimento) then) =
      _$AtendimentoCopyWithImpl<$Res, Atendimento>;
  @useResult
  $Res call(
      {String id,
      String codigo,
      String nome,
      String referencia,
      int situacao,
      DateTime? inicio,
      DateTime? conclusao,
      int subtotalCentavos,
      int servicoCentavos,
      num servicoPercentual,
      int descontoCentavos,
      int totalCentavos,
      int pagoCentavos,
      int saldoCentavos,
      String sessaoId,
      String sessaoCodigo,
      List<ComandaAtendimento> comandas,
      List<ItemAtendimento> itens,
      Map<String, dynamic> bruto});
}

/// @nodoc
class _$AtendimentoCopyWithImpl<$Res, $Val extends Atendimento>
    implements $AtendimentoCopyWith<$Res> {
  _$AtendimentoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Atendimento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? nome = null,
    Object? referencia = null,
    Object? situacao = null,
    Object? inicio = freezed,
    Object? conclusao = freezed,
    Object? subtotalCentavos = null,
    Object? servicoCentavos = null,
    Object? servicoPercentual = null,
    Object? descontoCentavos = null,
    Object? totalCentavos = null,
    Object? pagoCentavos = null,
    Object? saldoCentavos = null,
    Object? sessaoId = null,
    Object? sessaoCodigo = null,
    Object? comandas = null,
    Object? itens = null,
    Object? bruto = null,
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
      referencia: null == referencia
          ? _value.referencia
          : referencia // ignore: cast_nullable_to_non_nullable
              as String,
      situacao: null == situacao
          ? _value.situacao
          : situacao // ignore: cast_nullable_to_non_nullable
              as int,
      inicio: freezed == inicio
          ? _value.inicio
          : inicio // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      conclusao: freezed == conclusao
          ? _value.conclusao
          : conclusao // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      pagoCentavos: null == pagoCentavos
          ? _value.pagoCentavos
          : pagoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      saldoCentavos: null == saldoCentavos
          ? _value.saldoCentavos
          : saldoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      sessaoId: null == sessaoId
          ? _value.sessaoId
          : sessaoId // ignore: cast_nullable_to_non_nullable
              as String,
      sessaoCodigo: null == sessaoCodigo
          ? _value.sessaoCodigo
          : sessaoCodigo // ignore: cast_nullable_to_non_nullable
              as String,
      comandas: null == comandas
          ? _value.comandas
          : comandas // ignore: cast_nullable_to_non_nullable
              as List<ComandaAtendimento>,
      itens: null == itens
          ? _value.itens
          : itens // ignore: cast_nullable_to_non_nullable
              as List<ItemAtendimento>,
      bruto: null == bruto
          ? _value.bruto
          : bruto // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AtendimentoImplCopyWith<$Res>
    implements $AtendimentoCopyWith<$Res> {
  factory _$$AtendimentoImplCopyWith(
          _$AtendimentoImpl value, $Res Function(_$AtendimentoImpl) then) =
      __$$AtendimentoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String codigo,
      String nome,
      String referencia,
      int situacao,
      DateTime? inicio,
      DateTime? conclusao,
      int subtotalCentavos,
      int servicoCentavos,
      num servicoPercentual,
      int descontoCentavos,
      int totalCentavos,
      int pagoCentavos,
      int saldoCentavos,
      String sessaoId,
      String sessaoCodigo,
      List<ComandaAtendimento> comandas,
      List<ItemAtendimento> itens,
      Map<String, dynamic> bruto});
}

/// @nodoc
class __$$AtendimentoImplCopyWithImpl<$Res>
    extends _$AtendimentoCopyWithImpl<$Res, _$AtendimentoImpl>
    implements _$$AtendimentoImplCopyWith<$Res> {
  __$$AtendimentoImplCopyWithImpl(
      _$AtendimentoImpl _value, $Res Function(_$AtendimentoImpl) _then)
      : super(_value, _then);

  /// Create a copy of Atendimento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? nome = null,
    Object? referencia = null,
    Object? situacao = null,
    Object? inicio = freezed,
    Object? conclusao = freezed,
    Object? subtotalCentavos = null,
    Object? servicoCentavos = null,
    Object? servicoPercentual = null,
    Object? descontoCentavos = null,
    Object? totalCentavos = null,
    Object? pagoCentavos = null,
    Object? saldoCentavos = null,
    Object? sessaoId = null,
    Object? sessaoCodigo = null,
    Object? comandas = null,
    Object? itens = null,
    Object? bruto = null,
  }) {
    return _then(_$AtendimentoImpl(
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
      referencia: null == referencia
          ? _value.referencia
          : referencia // ignore: cast_nullable_to_non_nullable
              as String,
      situacao: null == situacao
          ? _value.situacao
          : situacao // ignore: cast_nullable_to_non_nullable
              as int,
      inicio: freezed == inicio
          ? _value.inicio
          : inicio // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      conclusao: freezed == conclusao
          ? _value.conclusao
          : conclusao // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      pagoCentavos: null == pagoCentavos
          ? _value.pagoCentavos
          : pagoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      saldoCentavos: null == saldoCentavos
          ? _value.saldoCentavos
          : saldoCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      sessaoId: null == sessaoId
          ? _value.sessaoId
          : sessaoId // ignore: cast_nullable_to_non_nullable
              as String,
      sessaoCodigo: null == sessaoCodigo
          ? _value.sessaoCodigo
          : sessaoCodigo // ignore: cast_nullable_to_non_nullable
              as String,
      comandas: null == comandas
          ? _value._comandas
          : comandas // ignore: cast_nullable_to_non_nullable
              as List<ComandaAtendimento>,
      itens: null == itens
          ? _value._itens
          : itens // ignore: cast_nullable_to_non_nullable
              as List<ItemAtendimento>,
      bruto: null == bruto
          ? _value._bruto
          : bruto // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$AtendimentoImpl implements _Atendimento {
  const _$AtendimentoImpl(
      {required this.id,
      required this.codigo,
      required this.nome,
      required this.referencia,
      required this.situacao,
      this.inicio,
      this.conclusao,
      required this.subtotalCentavos,
      required this.servicoCentavos,
      required this.servicoPercentual,
      required this.descontoCentavos,
      required this.totalCentavos,
      required this.pagoCentavos,
      required this.saldoCentavos,
      required this.sessaoId,
      required this.sessaoCodigo,
      final List<ComandaAtendimento> comandas = const <ComandaAtendimento>[],
      final List<ItemAtendimento> itens = const <ItemAtendimento>[],
      final Map<String, dynamic> bruto = const <String, dynamic>{}})
      : _comandas = comandas,
        _itens = itens,
        _bruto = bruto;

  @override
  final String id;
  @override
  final String codigo;
  @override
  final String nome;
  @override
  final String referencia;
  @override
  final int situacao;
  @override
  final DateTime? inicio;
  @override
  final DateTime? conclusao;
  @override
  final int subtotalCentavos;
  @override
  final int servicoCentavos;
  @override
  final num servicoPercentual;
  @override
  final int descontoCentavos;
  @override
  final int totalCentavos;
  @override
  final int pagoCentavos;
  @override
  final int saldoCentavos;
  @override
  final String sessaoId;
  @override
  final String sessaoCodigo;
  final List<ComandaAtendimento> _comandas;
  @override
  @JsonKey()
  List<ComandaAtendimento> get comandas {
    if (_comandas is EqualUnmodifiableListView) return _comandas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comandas);
  }

  final List<ItemAtendimento> _itens;
  @override
  @JsonKey()
  List<ItemAtendimento> get itens {
    if (_itens is EqualUnmodifiableListView) return _itens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_itens);
  }

  /// JSON original do atendimento como veio da API. O encerramento ecoa o
  /// atendimento INTEIRO de volta (ações 10 e 30) e a fatura reaproveita
  /// sub-objetos (parceiro, preço, modalidade, resumos) — guardar o bruto
  /// evita modelar dezenas de campos que o app não usa.
  final Map<String, dynamic> _bruto;

  /// JSON original do atendimento como veio da API. O encerramento ecoa o
  /// atendimento INTEIRO de volta (ações 10 e 30) e a fatura reaproveita
  /// sub-objetos (parceiro, preço, modalidade, resumos) — guardar o bruto
  /// evita modelar dezenas de campos que o app não usa.
  @override
  @JsonKey()
  Map<String, dynamic> get bruto {
    if (_bruto is EqualUnmodifiableMapView) return _bruto;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bruto);
  }

  @override
  String toString() {
    return 'Atendimento(id: $id, codigo: $codigo, nome: $nome, referencia: $referencia, situacao: $situacao, inicio: $inicio, conclusao: $conclusao, subtotalCentavos: $subtotalCentavos, servicoCentavos: $servicoCentavos, servicoPercentual: $servicoPercentual, descontoCentavos: $descontoCentavos, totalCentavos: $totalCentavos, pagoCentavos: $pagoCentavos, saldoCentavos: $saldoCentavos, sessaoId: $sessaoId, sessaoCodigo: $sessaoCodigo, comandas: $comandas, itens: $itens, bruto: $bruto)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AtendimentoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.referencia, referencia) ||
                other.referencia == referencia) &&
            (identical(other.situacao, situacao) ||
                other.situacao == situacao) &&
            (identical(other.inicio, inicio) || other.inicio == inicio) &&
            (identical(other.conclusao, conclusao) ||
                other.conclusao == conclusao) &&
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
            (identical(other.pagoCentavos, pagoCentavos) ||
                other.pagoCentavos == pagoCentavos) &&
            (identical(other.saldoCentavos, saldoCentavos) ||
                other.saldoCentavos == saldoCentavos) &&
            (identical(other.sessaoId, sessaoId) ||
                other.sessaoId == sessaoId) &&
            (identical(other.sessaoCodigo, sessaoCodigo) ||
                other.sessaoCodigo == sessaoCodigo) &&
            const DeepCollectionEquality().equals(other._comandas, _comandas) &&
            const DeepCollectionEquality().equals(other._itens, _itens) &&
            const DeepCollectionEquality().equals(other._bruto, _bruto));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        codigo,
        nome,
        referencia,
        situacao,
        inicio,
        conclusao,
        subtotalCentavos,
        servicoCentavos,
        servicoPercentual,
        descontoCentavos,
        totalCentavos,
        pagoCentavos,
        saldoCentavos,
        sessaoId,
        sessaoCodigo,
        const DeepCollectionEquality().hash(_comandas),
        const DeepCollectionEquality().hash(_itens),
        const DeepCollectionEquality().hash(_bruto)
      ]);

  /// Create a copy of Atendimento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AtendimentoImplCopyWith<_$AtendimentoImpl> get copyWith =>
      __$$AtendimentoImplCopyWithImpl<_$AtendimentoImpl>(this, _$identity);
}

abstract class _Atendimento implements Atendimento {
  const factory _Atendimento(
      {required final String id,
      required final String codigo,
      required final String nome,
      required final String referencia,
      required final int situacao,
      final DateTime? inicio,
      final DateTime? conclusao,
      required final int subtotalCentavos,
      required final int servicoCentavos,
      required final num servicoPercentual,
      required final int descontoCentavos,
      required final int totalCentavos,
      required final int pagoCentavos,
      required final int saldoCentavos,
      required final String sessaoId,
      required final String sessaoCodigo,
      final List<ComandaAtendimento> comandas,
      final List<ItemAtendimento> itens,
      final Map<String, dynamic> bruto}) = _$AtendimentoImpl;

  @override
  String get id;
  @override
  String get codigo;
  @override
  String get nome;
  @override
  String get referencia;
  @override
  int get situacao;
  @override
  DateTime? get inicio;
  @override
  DateTime? get conclusao;
  @override
  int get subtotalCentavos;
  @override
  int get servicoCentavos;
  @override
  num get servicoPercentual;
  @override
  int get descontoCentavos;
  @override
  int get totalCentavos;
  @override
  int get pagoCentavos;
  @override
  int get saldoCentavos;
  @override
  String get sessaoId;
  @override
  String get sessaoCodigo;
  @override
  List<ComandaAtendimento> get comandas;
  @override
  List<ItemAtendimento> get itens;

  /// JSON original do atendimento como veio da API. O encerramento ecoa o
  /// atendimento INTEIRO de volta (ações 10 e 30) e a fatura reaproveita
  /// sub-objetos (parceiro, preço, modalidade, resumos) — guardar o bruto
  /// evita modelar dezenas de campos que o app não usa.
  @override
  Map<String, dynamic> get bruto;

  /// Create a copy of Atendimento
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AtendimentoImplCopyWith<_$AtendimentoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ComandaAtendimento {
  String get id => throw _privateConstructorUsedError;
  String get codigo => throw _privateConstructorUsedError;
  int get numero => throw _privateConstructorUsedError;
  int get situacao => throw _privateConstructorUsedError;

  /// Create a copy of ComandaAtendimento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComandaAtendimentoCopyWith<ComandaAtendimento> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComandaAtendimentoCopyWith<$Res> {
  factory $ComandaAtendimentoCopyWith(
          ComandaAtendimento value, $Res Function(ComandaAtendimento) then) =
      _$ComandaAtendimentoCopyWithImpl<$Res, ComandaAtendimento>;
  @useResult
  $Res call({String id, String codigo, int numero, int situacao});
}

/// @nodoc
class _$ComandaAtendimentoCopyWithImpl<$Res, $Val extends ComandaAtendimento>
    implements $ComandaAtendimentoCopyWith<$Res> {
  _$ComandaAtendimentoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComandaAtendimento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? numero = null,
    Object? situacao = null,
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
      numero: null == numero
          ? _value.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as int,
      situacao: null == situacao
          ? _value.situacao
          : situacao // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ComandaAtendimentoImplCopyWith<$Res>
    implements $ComandaAtendimentoCopyWith<$Res> {
  factory _$$ComandaAtendimentoImplCopyWith(_$ComandaAtendimentoImpl value,
          $Res Function(_$ComandaAtendimentoImpl) then) =
      __$$ComandaAtendimentoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String codigo, int numero, int situacao});
}

/// @nodoc
class __$$ComandaAtendimentoImplCopyWithImpl<$Res>
    extends _$ComandaAtendimentoCopyWithImpl<$Res, _$ComandaAtendimentoImpl>
    implements _$$ComandaAtendimentoImplCopyWith<$Res> {
  __$$ComandaAtendimentoImplCopyWithImpl(_$ComandaAtendimentoImpl _value,
      $Res Function(_$ComandaAtendimentoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComandaAtendimento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? numero = null,
    Object? situacao = null,
  }) {
    return _then(_$ComandaAtendimentoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: null == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String,
      numero: null == numero
          ? _value.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as int,
      situacao: null == situacao
          ? _value.situacao
          : situacao // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ComandaAtendimentoImpl implements _ComandaAtendimento {
  const _$ComandaAtendimentoImpl(
      {required this.id,
      required this.codigo,
      required this.numero,
      required this.situacao});

  @override
  final String id;
  @override
  final String codigo;
  @override
  final int numero;
  @override
  final int situacao;

  @override
  String toString() {
    return 'ComandaAtendimento(id: $id, codigo: $codigo, numero: $numero, situacao: $situacao)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComandaAtendimentoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.numero, numero) || other.numero == numero) &&
            (identical(other.situacao, situacao) ||
                other.situacao == situacao));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, codigo, numero, situacao);

  /// Create a copy of ComandaAtendimento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComandaAtendimentoImplCopyWith<_$ComandaAtendimentoImpl> get copyWith =>
      __$$ComandaAtendimentoImplCopyWithImpl<_$ComandaAtendimentoImpl>(
          this, _$identity);
}

abstract class _ComandaAtendimento implements ComandaAtendimento {
  const factory _ComandaAtendimento(
      {required final String id,
      required final String codigo,
      required final int numero,
      required final int situacao}) = _$ComandaAtendimentoImpl;

  @override
  String get id;
  @override
  String get codigo;
  @override
  int get numero;
  @override
  int get situacao;

  /// Create a copy of ComandaAtendimento
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComandaAtendimentoImplCopyWith<_$ComandaAtendimentoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ItemAtendimento {
  String get id => throw _privateConstructorUsedError;

  /// Id do item no cadastro (`item.id`) — chave de `recurso/item/{id}`,
  /// de onde vem a foto. Diferente do `id` da linha do atendimento.
  String get itemId => throw _privateConstructorUsedError;
  int get sequencial => throw _privateConstructorUsedError;
  String get nome => throw _privateConstructorUsedError;
  String get codigo => throw _privateConstructorUsedError;
  num get quantidade => throw _privateConstructorUsedError;
  String get medida => throw _privateConstructorUsedError;
  int get valorCentavos => throw _privateConstructorUsedError;
  int get subtotalCentavos => throw _privateConstructorUsedError;
  int get totalCentavos => throw _privateConstructorUsedError;
  String get comandaId => throw _privateConstructorUsedError;
  String get comandaCodigo => throw _privateConstructorUsedError;

  /// Create a copy of ItemAtendimento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemAtendimentoCopyWith<ItemAtendimento> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemAtendimentoCopyWith<$Res> {
  factory $ItemAtendimentoCopyWith(
          ItemAtendimento value, $Res Function(ItemAtendimento) then) =
      _$ItemAtendimentoCopyWithImpl<$Res, ItemAtendimento>;
  @useResult
  $Res call(
      {String id,
      String itemId,
      int sequencial,
      String nome,
      String codigo,
      num quantidade,
      String medida,
      int valorCentavos,
      int subtotalCentavos,
      int totalCentavos,
      String comandaId,
      String comandaCodigo});
}

/// @nodoc
class _$ItemAtendimentoCopyWithImpl<$Res, $Val extends ItemAtendimento>
    implements $ItemAtendimentoCopyWith<$Res> {
  _$ItemAtendimentoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItemAtendimento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = null,
    Object? sequencial = null,
    Object? nome = null,
    Object? codigo = null,
    Object? quantidade = null,
    Object? medida = null,
    Object? valorCentavos = null,
    Object? subtotalCentavos = null,
    Object? totalCentavos = null,
    Object? comandaId = null,
    Object? comandaCodigo = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      sequencial: null == sequencial
          ? _value.sequencial
          : sequencial // ignore: cast_nullable_to_non_nullable
              as int,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: null == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String,
      quantidade: null == quantidade
          ? _value.quantidade
          : quantidade // ignore: cast_nullable_to_non_nullable
              as num,
      medida: null == medida
          ? _value.medida
          : medida // ignore: cast_nullable_to_non_nullable
              as String,
      valorCentavos: null == valorCentavos
          ? _value.valorCentavos
          : valorCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      subtotalCentavos: null == subtotalCentavos
          ? _value.subtotalCentavos
          : subtotalCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      totalCentavos: null == totalCentavos
          ? _value.totalCentavos
          : totalCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      comandaId: null == comandaId
          ? _value.comandaId
          : comandaId // ignore: cast_nullable_to_non_nullable
              as String,
      comandaCodigo: null == comandaCodigo
          ? _value.comandaCodigo
          : comandaCodigo // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItemAtendimentoImplCopyWith<$Res>
    implements $ItemAtendimentoCopyWith<$Res> {
  factory _$$ItemAtendimentoImplCopyWith(_$ItemAtendimentoImpl value,
          $Res Function(_$ItemAtendimentoImpl) then) =
      __$$ItemAtendimentoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String itemId,
      int sequencial,
      String nome,
      String codigo,
      num quantidade,
      String medida,
      int valorCentavos,
      int subtotalCentavos,
      int totalCentavos,
      String comandaId,
      String comandaCodigo});
}

/// @nodoc
class __$$ItemAtendimentoImplCopyWithImpl<$Res>
    extends _$ItemAtendimentoCopyWithImpl<$Res, _$ItemAtendimentoImpl>
    implements _$$ItemAtendimentoImplCopyWith<$Res> {
  __$$ItemAtendimentoImplCopyWithImpl(
      _$ItemAtendimentoImpl _value, $Res Function(_$ItemAtendimentoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItemAtendimento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = null,
    Object? sequencial = null,
    Object? nome = null,
    Object? codigo = null,
    Object? quantidade = null,
    Object? medida = null,
    Object? valorCentavos = null,
    Object? subtotalCentavos = null,
    Object? totalCentavos = null,
    Object? comandaId = null,
    Object? comandaCodigo = null,
  }) {
    return _then(_$ItemAtendimentoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      sequencial: null == sequencial
          ? _value.sequencial
          : sequencial // ignore: cast_nullable_to_non_nullable
              as int,
      nome: null == nome
          ? _value.nome
          : nome // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: null == codigo
          ? _value.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String,
      quantidade: null == quantidade
          ? _value.quantidade
          : quantidade // ignore: cast_nullable_to_non_nullable
              as num,
      medida: null == medida
          ? _value.medida
          : medida // ignore: cast_nullable_to_non_nullable
              as String,
      valorCentavos: null == valorCentavos
          ? _value.valorCentavos
          : valorCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      subtotalCentavos: null == subtotalCentavos
          ? _value.subtotalCentavos
          : subtotalCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      totalCentavos: null == totalCentavos
          ? _value.totalCentavos
          : totalCentavos // ignore: cast_nullable_to_non_nullable
              as int,
      comandaId: null == comandaId
          ? _value.comandaId
          : comandaId // ignore: cast_nullable_to_non_nullable
              as String,
      comandaCodigo: null == comandaCodigo
          ? _value.comandaCodigo
          : comandaCodigo // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ItemAtendimentoImpl implements _ItemAtendimento {
  const _$ItemAtendimentoImpl(
      {required this.id,
      this.itemId = '',
      required this.sequencial,
      required this.nome,
      required this.codigo,
      required this.quantidade,
      required this.medida,
      required this.valorCentavos,
      required this.subtotalCentavos,
      required this.totalCentavos,
      required this.comandaId,
      required this.comandaCodigo});

  @override
  final String id;

  /// Id do item no cadastro (`item.id`) — chave de `recurso/item/{id}`,
  /// de onde vem a foto. Diferente do `id` da linha do atendimento.
  @override
  @JsonKey()
  final String itemId;
  @override
  final int sequencial;
  @override
  final String nome;
  @override
  final String codigo;
  @override
  final num quantidade;
  @override
  final String medida;
  @override
  final int valorCentavos;
  @override
  final int subtotalCentavos;
  @override
  final int totalCentavos;
  @override
  final String comandaId;
  @override
  final String comandaCodigo;

  @override
  String toString() {
    return 'ItemAtendimento(id: $id, itemId: $itemId, sequencial: $sequencial, nome: $nome, codigo: $codigo, quantidade: $quantidade, medida: $medida, valorCentavos: $valorCentavos, subtotalCentavos: $subtotalCentavos, totalCentavos: $totalCentavos, comandaId: $comandaId, comandaCodigo: $comandaCodigo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemAtendimentoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.sequencial, sequencial) ||
                other.sequencial == sequencial) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.quantidade, quantidade) ||
                other.quantidade == quantidade) &&
            (identical(other.medida, medida) || other.medida == medida) &&
            (identical(other.valorCentavos, valorCentavos) ||
                other.valorCentavos == valorCentavos) &&
            (identical(other.subtotalCentavos, subtotalCentavos) ||
                other.subtotalCentavos == subtotalCentavos) &&
            (identical(other.totalCentavos, totalCentavos) ||
                other.totalCentavos == totalCentavos) &&
            (identical(other.comandaId, comandaId) ||
                other.comandaId == comandaId) &&
            (identical(other.comandaCodigo, comandaCodigo) ||
                other.comandaCodigo == comandaCodigo));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      itemId,
      sequencial,
      nome,
      codigo,
      quantidade,
      medida,
      valorCentavos,
      subtotalCentavos,
      totalCentavos,
      comandaId,
      comandaCodigo);

  /// Create a copy of ItemAtendimento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemAtendimentoImplCopyWith<_$ItemAtendimentoImpl> get copyWith =>
      __$$ItemAtendimentoImplCopyWithImpl<_$ItemAtendimentoImpl>(
          this, _$identity);
}

abstract class _ItemAtendimento implements ItemAtendimento {
  const factory _ItemAtendimento(
      {required final String id,
      final String itemId,
      required final int sequencial,
      required final String nome,
      required final String codigo,
      required final num quantidade,
      required final String medida,
      required final int valorCentavos,
      required final int subtotalCentavos,
      required final int totalCentavos,
      required final String comandaId,
      required final String comandaCodigo}) = _$ItemAtendimentoImpl;

  @override
  String get id;

  /// Id do item no cadastro (`item.id`) — chave de `recurso/item/{id}`,
  /// de onde vem a foto. Diferente do `id` da linha do atendimento.
  @override
  String get itemId;
  @override
  int get sequencial;
  @override
  String get nome;
  @override
  String get codigo;
  @override
  num get quantidade;
  @override
  String get medida;
  @override
  int get valorCentavos;
  @override
  int get subtotalCentavos;
  @override
  int get totalCentavos;
  @override
  String get comandaId;
  @override
  String get comandaCodigo;

  /// Create a copy of ItemAtendimento
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemAtendimentoImplCopyWith<_$ItemAtendimentoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
