import 'valores_fatura.dart';

/// Modalidade da fatura: uma por atendimento encerrado, com os totais
/// consolidados dele. Mantém a separação exigida pelo contrato entre
/// `referencia` (número visual, ex.: "512"), `numero` (numérico) e
/// `referenciaId` (id do atendimento).
class RequisicaoFaturaModalidade {
  const RequisicaoFaturaModalidade({
    required this.sequencial,
    required this.modalidade,
    required this.localizador,
    required this.referencia,
    required this.numero,
    required this.subtotalCentavos,
    this.acrescimoCentavos = 0,
    this.freteCentavos = 0,
    required this.servicoCentavos,
    this.descontoCentavos = 0,
    this.abatimentoCentavos = 0,
    this.deducaoCentavos = 0,
    required this.totalCentavos,
    required this.pessoas,
    required this.referenciaId,
    required this.inicio,
    required this.conclusao,
  });

  final int sequencial;
  final Map<String, dynamic> modalidade;
  final Map<String, dynamic>? localizador;
  final String referencia;
  final int numero;
  final int subtotalCentavos;
  final int acrescimoCentavos;
  final int freteCentavos;
  final int servicoCentavos;
  final int descontoCentavos;
  final int abatimentoCentavos;
  final int deducaoCentavos;
  final int totalCentavos;
  final int pessoas;
  final String referenciaId;

  /// Início real do atendimento — ecoado cru, como veio da API.
  final String? inicio;

  /// Horário do encerramento (UTC).
  final DateTime conclusao;

  Map<String, dynamic> paraJson() => {
        'sequencial': sequencial,
        'modalidade': modalidade,
        'localizador': localizador,
        'referencia': referencia,
        'numero': numero,
        'subtotal': ValoresFatura.reais(subtotalCentavos),
        'acrescimo': ValoresFatura.reais(acrescimoCentavos),
        'frete': ValoresFatura.reais(freteCentavos),
        'servico': ValoresFatura.reais(servicoCentavos),
        'desconto': ValoresFatura.reais(descontoCentavos),
        'abatimento': ValoresFatura.reais(abatimentoCentavos),
        'deducao': ValoresFatura.reais(deducaoCentavos),
        'total': ValoresFatura.reais(totalCentavos),
        'pessoas': pessoas,
        'integradora': null,
        'entregador': null,
        'ocupacao': null,
        'referenciaId': referenciaId,
        'inicio': inicio,
        'conclusao': conclusao.toIso8601String(),
      };
}
