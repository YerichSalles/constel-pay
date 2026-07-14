import 'valores_fatura.dart';

/// Item da fatura, montado a partir de um `atendimentoResumo` (valores já
/// consolidados pelo retaguarda — nunca recalculados aqui). Sub-objetos são
/// ecos dos mapas originais do resumo/configuração.
class RequisicaoFaturaItem {
  const RequisicaoFaturaItem({
    required this.sequencial,
    required this.resultado,
    required this.modalidade,
    required this.corretor,
    required this.vendedor,
    required this.item,
    required this.preco,
    required this.estabelecimentoDepartamento,
    required this.valorCentavos,
    required this.quantidade,
    this.fator = 1.0,
    required this.subtotalCentavos,
    this.acrescimoCentavos = 0,
    this.freteCentavos = 0,
    required this.servicoCentavos,
    this.descontoCentavos = 0,
    this.abatimentoCentavos = 0,
    this.deducaoCentavos = 0,
    required this.totalCentavos,
    required this.comissiona,
    this.ocupacao,
  });

  final int sequencial;
  final Map<String, dynamic> resultado;
  final Map<String, dynamic> modalidade;
  final Map<String, dynamic> corretor;
  final Map<String, dynamic> vendedor;
  final Map<String, dynamic> item;
  final Map<String, dynamic> preco;
  final Map<String, dynamic> estabelecimentoDepartamento;
  final int valorCentavos;
  final num quantidade;
  final num fator;
  final int subtotalCentavos;
  final int acrescimoCentavos;
  final int freteCentavos;
  final int servicoCentavos;
  final int descontoCentavos;
  final int abatimentoCentavos;
  final int deducaoCentavos;
  final int totalCentavos;
  final bool comissiona;
  final Map<String, dynamic>? ocupacao;

  Map<String, dynamic> paraJson() => {
        'sequencial': sequencial,
        'resultado': resultado,
        'modalidade': modalidade,
        'corretor': corretor,
        'vendedor': vendedor,
        'item': item,
        'preco': preco,
        'estabelecimentoDepartamento': estabelecimentoDepartamento,
        'valor': ValoresFatura.reais(valorCentavos),
        'quantidade': quantidade,
        'fator': fator,
        'subtotal': ValoresFatura.reais(subtotalCentavos),
        'acrescimo': ValoresFatura.reais(acrescimoCentavos),
        'frete': ValoresFatura.reais(freteCentavos),
        'servico': ValoresFatura.reais(servicoCentavos),
        'desconto': ValoresFatura.reais(descontoCentavos),
        'abatimento': ValoresFatura.reais(abatimentoCentavos),
        'deducao': ValoresFatura.reais(deducaoCentavos),
        'icmsBc': 0.0,
        'icmsAliquota': 0.0,
        'icmsValor': 0.0,
        'icmsAliquotaMVA': 0.0,
        'icmsStBc': 0.0,
        'icmsStAliquota': 0.0,
        'icmsStValor': 0.0,
        'ipiBc': 0.0,
        'ipiAliquota': 0.0,
        'ipiValor': 0.0,
        'total': ValoresFatura.reais(totalCentavos),
        'comissiona': comissiona,
        'integradora': null,
        'promocao': null,
        'ocupacao': ocupacao,
        'montagem': false,
      };
}
