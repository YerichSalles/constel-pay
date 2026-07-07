enum MetodoPagamento { pix, credito, debito, tef, pos, voucher, dinheiro }

extension MetodoPagamentoInfo on MetodoPagamento {
  String get rotulo => switch (this) {
        MetodoPagamento.pix => 'Pix',
        MetodoPagamento.credito => 'Crédito',
        MetodoPagamento.debito => 'Débito',
        MetodoPagamento.tef => 'TEF',
        MetodoPagamento.pos => 'POS',
        MetodoPagamento.voucher => 'Voucher',
        MetodoPagamento.dinheiro => 'Dinheiro',
      };

  String get descricao => switch (this) {
        MetodoPagamento.pix => 'Aprovação na hora',
        MetodoPagamento.credito => 'Em até 12x',
        MetodoPagamento.debito => 'À vista',
        MetodoPagamento.tef => 'Terminal integrado',
        MetodoPagamento.pos => 'Maquininha',
        MetodoPagamento.voucher => 'Vale-refeição',
        MetodoPagamento.dinheiro => 'No caixa',
      };

  String get emoji => switch (this) {
        MetodoPagamento.pix => '⚡',
        MetodoPagamento.credito => '💳',
        MetodoPagamento.debito => '🏧',
        MetodoPagamento.tef => '🖥️',
        MetodoPagamento.pos => '📟',
        MetodoPagamento.voucher => '🎫',
        MetodoPagamento.dinheiro => '💵',
      };
}
