import 'valores_fatura.dart';

/// Pagamento da fatura. Forma, plano e conta vêm da configuração de
/// faturamento do método escolhido — nunca de IDs fixos no código.
/// À vista: 1 parcela, `subtotal` = total da fatura, `total` = valor
/// recebido aplicado, `pago`/`saldo` zerados no envio (o retaguarda calcula).
class RequisicaoFaturaPagamento {
  const RequisicaoFaturaPagamento({
    this.sequencial = 1,
    required this.forma,
    required this.plano,
    required this.conta,
    this.edita = false,
    this.parcelas = 1,
    required this.subtotalCentavos,
    this.trocoCentavos = 0,
    required this.totalCentavos,
  });

  final int sequencial;
  final Map<String, dynamic> forma;
  final Map<String, dynamic> plano;
  final Map<String, dynamic> conta;
  final bool edita;
  final int parcelas;
  final int subtotalCentavos;
  final int trocoCentavos;
  final int totalCentavos;

  Map<String, dynamic> paraJson() => {
        'sequencial': sequencial,
        'forma': forma,
        'plano': plano,
        'conta': conta,
        'edita': edita,
        'parcelas': parcelas,
        'subtotal': ValoresFatura.reais(subtotalCentavos),
        'troco': ValoresFatura.reais(trocoCentavos),
        'total': ValoresFatura.reais(totalCentavos),
        'pago': 0.0,
        'saldo': 0.0,
        'referenciaClasse': 0,
        'adiantamento': null,
        'online': false,
        'faturaPagamentoEletronico': null,
      };
}
