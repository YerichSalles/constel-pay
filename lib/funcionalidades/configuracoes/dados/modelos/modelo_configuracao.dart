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
    @Default('') String idDispositivo,
    required Ambiente ambiente,
    required String urlBaseProducao,
    required String urlBaseHomologacao,
    @Default('') String urlNuvemProducao,
    @Default('') String urlNuvemHomologacao,
  }) = _ModeloConfiguracao;

  factory ModeloConfiguracao.fromJson(Map<String, dynamic> json) =>
      _$ModeloConfiguracaoFromJson(json);

  factory ModeloConfiguracao.deEntidade(ConfiguracaoTerminal entidade) =>
      ModeloConfiguracao(
        nomeRestaurante: entidade.nomeRestaurante,
        identificadorDispositivo: entidade.identificadorDispositivo,
        idDispositivo: entidade.idDispositivo,
        ambiente: entidade.ambiente,
        urlBaseProducao: entidade.urlBaseProducao,
        urlBaseHomologacao: entidade.urlBaseHomologacao,
        urlNuvemProducao: entidade.urlNuvemProducao,
        urlNuvemHomologacao: entidade.urlNuvemHomologacao,
      );

  ConfiguracaoTerminal paraEntidade() => ConfiguracaoTerminal(
        nomeRestaurante: nomeRestaurante,
        identificadorDispositivo: identificadorDispositivo,
        idDispositivo: idDispositivo,
        ambiente: ambiente,
        urlBaseProducao: urlBaseProducao,
        urlBaseHomologacao: urlBaseHomologacao,
        urlNuvemProducao: urlNuvemProducao,
        urlNuvemHomologacao: urlNuvemHomologacao,
      );
}
