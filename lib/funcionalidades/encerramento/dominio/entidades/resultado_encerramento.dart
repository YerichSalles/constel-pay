import 'fatura_referencia.dart';

/// Desfecho de um encerramento concluído: a fatura persistida e os
/// atendimentos que foram fechados com ela.
class ResultadoEncerramento {
  const ResultadoEncerramento({
    required this.fatura,
    required this.atendimentoIds,
  });

  final FaturaReferencia fatura;
  final List<String> atendimentoIds;
}
