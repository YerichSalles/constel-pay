enum StatusPagamento {
  aguardando,
  processando,
  aprovado,
  recusado,
  cancelado,
  expirado,
  erro
}

extension StatusPagamentoRotulo on StatusPagamento {
  String get rotulo => switch (this) {
        StatusPagamento.aguardando => 'Aguardando',
        StatusPagamento.processando => 'Processando',
        StatusPagamento.aprovado => 'Aprovado',
        StatusPagamento.recusado => 'Recusado',
        StatusPagamento.cancelado => 'Cancelado',
        StatusPagamento.expirado => 'Expirado',
        StatusPagamento.erro => 'Erro',
      };
}
