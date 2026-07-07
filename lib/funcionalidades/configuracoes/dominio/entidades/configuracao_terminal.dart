import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../nucleo/configuracao/ambiente.dart';

part 'configuracao_terminal.freezed.dart';

@freezed
class ConfiguracaoTerminal with _$ConfiguracaoTerminal {
  const ConfiguracaoTerminal._();

  const factory ConfiguracaoTerminal({
    @Default('Constel Pay') String nomeRestaurante,
    @Default('TERMINAL-01') String identificadorDispositivo,
    @Default(Ambiente.homologacao) Ambiente ambiente,
    @Default('') String urlBaseProducao,
    @Default('') String urlBaseHomologacao,
    @Default('') String pinHash,
  }) = _ConfiguracaoTerminal;

  String get urlBaseAtiva =>
      ambiente == Ambiente.producao ? urlBaseProducao : urlBaseHomologacao;
}
