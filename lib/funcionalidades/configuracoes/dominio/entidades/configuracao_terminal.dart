import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../nucleo/configuracao/ambiente.dart';

part 'configuracao_terminal.freezed.dart';

@freezed
class ConfiguracaoTerminal with _$ConfiguracaoTerminal {
  const ConfiguracaoTerminal._();

  const factory ConfiguracaoTerminal({
    @Default('Constel Pay') String nomeRestaurante,
    @Default('TERMINAL-01') String identificadorDispositivo,
    @Default('') String idDispositivo,
    @Default(Ambiente.homologacao) Ambiente ambiente,
    // URLs da API local (consumo do cartão no estabelecimento).
    @Default('') String urlBaseProducao,
    @Default('') String urlBaseHomologacao,
    // URLs da API na nuvem (login/autenticação).
    @Default('') String urlNuvemProducao,
    @Default('') String urlNuvemHomologacao,
    @Default('') String pinHash,
  }) = _ConfiguracaoTerminal;

  /// Base da API local (consumo), conforme o ambiente ativo.
  String get urlBaseAtiva =>
      ambiente == Ambiente.producao ? urlBaseProducao : urlBaseHomologacao;

  /// Base da API na nuvem (login), conforme o ambiente ativo.
  String get urlNuvemAtiva =>
      ambiente == Ambiente.producao ? urlNuvemProducao : urlNuvemHomologacao;
}
