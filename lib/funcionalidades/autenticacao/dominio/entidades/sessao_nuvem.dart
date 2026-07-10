import 'package:freezed_annotation/freezed_annotation.dart';

part 'sessao_nuvem.freezed.dart';
part 'sessao_nuvem.g.dart';

@freezed
class SessaoNuvem with _$SessaoNuvem {
  const SessaoNuvem._();

  const factory SessaoNuvem({
    required String token,
    required DateTime validade,
    required UsuarioSessao usuario,
    required EmpresaSessao empresa,
    required DispositivoSessao dispositivo,
    required EstabelecimentoSessao estabelecimento,
  }) = _SessaoNuvem;

  factory SessaoNuvem.fromJson(Map<String, dynamic> json) =>
      _$SessaoNuvemFromJson(json);

  /// Considera a sessão expirada quando a data atual ultrapassa `validade`.
  bool get expirada => DateTime.now().isAfter(validade);
}

@freezed
class UsuarioSessao with _$UsuarioSessao {
  const factory UsuarioSessao({
    required String nome,
    required String imagem,
  }) = _UsuarioSessao;

  factory UsuarioSessao.fromJson(Map<String, dynamic> json) =>
      _$UsuarioSessaoFromJson(json);
}

@freezed
class EmpresaSessao with _$EmpresaSessao {
  const factory EmpresaSessao({
    required String id,
    required String nome,
  }) = _EmpresaSessao;

  factory EmpresaSessao.fromJson(Map<String, dynamic> json) =>
      _$EmpresaSessaoFromJson(json);
}

@freezed
class DispositivoSessao with _$DispositivoSessao {
  const factory DispositivoSessao({
    required String id,
    required String nome,
  }) = _DispositivoSessao;

  factory DispositivoSessao.fromJson(Map<String, dynamic> json) =>
      _$DispositivoSessaoFromJson(json);
}

@freezed
class AmbienteSessao with _$AmbienteSessao {
  const factory AmbienteSessao({
    required String id,
    required String nome,
    required bool padrao,
  }) = _AmbienteSessao;

  factory AmbienteSessao.fromJson(Map<String, dynamic> json) =>
      _$AmbienteSessaoFromJson(json);
}

@freezed
class EstabelecimentoSessao with _$EstabelecimentoSessao {
  const factory EstabelecimentoSessao({
    required String id,
    required String nome,
    @Default(<AmbienteSessao>[]) List<AmbienteSessao> ambientes,
  }) = _EstabelecimentoSessao;

  factory EstabelecimentoSessao.fromJson(Map<String, dynamic> json) =>
      _$EstabelecimentoSessaoFromJson(json);
}
