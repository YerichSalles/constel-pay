/// Atendimento encerrado da sessão, como o mapa da loja devolve: a
/// referência mínima para localizar a fatura vinculada a cada comanda.
class AtendimentoEncerrado {
  const AtendimentoEncerrado({
    required this.atendimentoId,
    required this.faturaId,
    required this.faturaCodigo,
    required this.conclusao,
  });

  final String atendimentoId;
  final String faturaId;
  final String faturaCodigo;

  /// ISO-8601 da conclusão — ordena os encerramentos mais recentes primeiro.
  final String conclusao;
}
