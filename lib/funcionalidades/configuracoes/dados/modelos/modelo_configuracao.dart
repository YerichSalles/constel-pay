import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../nucleo/configuracao/ambiente.dart';
import '../../dominio/entidades/configuracao_terminal.dart';

part 'modelo_configuracao.freezed.dart';
part 'modelo_configuracao.g.dart';

@freezed
class ModeloConfiguracao with _$ModeloConfiguracao {
  const ModeloConfiguracao._();

  const factory ModeloConfiguracao({
    required String nomeRestaurante,
    required String identificadorDispositivo,
    required Ambiente ambiente,
    required String urlBaseProducao,
    required String urlBaseHomologacao,
    required String pinHash,
  }) = _ModeloConfiguracao;

  factory ModeloConfiguracao.fromJson(Map<String, dynamic> json) =>
      _$ModeloConfiguracaoFromJson(json);

  factory ModeloConfiguracao.deEntidade(ConfiguracaoTerminal entidade) =>
      ModeloConfiguracao(
        nomeRestaurante: entidade.nomeRestaurante,
        identificadorDispositivo: entidade.identificadorDispositivo,
        ambiente: entidade.ambiente,
        urlBaseProducao: entidade.urlBaseProducao,
        urlBaseHomologacao: entidade.urlBaseHomologacao,
        pinHash: entidade.pinHash,
      );

  ConfiguracaoTerminal paraEntidade() => ConfiguracaoTerminal(
        nomeRestaurante: nomeRestaurante,
        identificadorDispositivo: identificadorDispositivo,
        ambiente: ambiente,
        urlBaseProducao: urlBaseProducao,
        urlBaseHomologacao: urlBaseHomologacao,
        pinHash: pinHash,
      );
}
