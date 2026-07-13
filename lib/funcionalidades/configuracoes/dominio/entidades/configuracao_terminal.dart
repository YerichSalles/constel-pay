import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../nucleo/configuracao/ambiente.dart';
import '../../../../nucleo/utils/url_base.dart';

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

  /// Base da API local (consumo), conforme o ambiente ativo. A barra final é
  /// garantida aqui porque o Dio concatena base + caminho: sem ela a URL sai
  /// colada (ex.: 'host:3001' + 'venda/...' = 'host:3001venda/...').
  String get urlBaseAtiva => comBarraFinal(
      ambiente == Ambiente.producao ? urlBaseProducao : urlBaseHomologacao);

  /// Base da API na nuvem (login), conforme o ambiente ativo.
  String get urlNuvemAtiva => comBarraFinal(
      ambiente == Ambiente.producao ? urlNuvemProducao : urlNuvemHomologacao);
}
