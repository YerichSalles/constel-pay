import 'requisicao_fatura_item.dart';
import 'requisicao_fatura_modalidade.dart';
import 'requisicao_fatura_pagamento.dart';
import 'requisicao_fatura_resultado.dart';
import 'valores_fatura.dart';

/// Payload do `POST movimento/fatura`. Estrutura e ordem dos campos seguem o
/// contrato real observado no caixa. Campos exclusivos da resposta (id,
/// codigo, corporacao, versao...) não são enviados.
class RequisicaoFatura {
  const RequisicaoFatura({
    required this.identificador,
    required this.situacao,
    required this.tipo,
    required this.natureza,
    required this.estabelecimento,
    required this.estabelecimentoDepartamento,
    required this.parceiro,
    required this.historico,
    required this.operacao,
    required this.moeda,
    required this.modalidade,
    required this.preco,
    required this.corretor,
    required this.vendedor,
    required this.momento,
    required this.emissao,
    required this.competencia,
    required this.baixa,
    required this.itens,
    required this.subtotalCentavos,
    this.acrescimoCentavos = 0,
    this.freteCentavos = 0,
    required this.servicoCentavos,
    this.descontoCentavos = 0,
    this.abatimentoCentavos = 0,
    this.deducaoCentavos = 0,
    required this.totalCentavos,
    required this.dispositivo,
    required this.resultados,
    required this.modalidades,
    required this.pagamentos,
    required this.pessoas,
    required this.sessaoId,
  });

  /// Identificador único da tentativa — o mesmo em qualquer retry.
  final String identificador;
  final int situacao;
  final int tipo;
  final int natureza;
  final Map<String, dynamic> estabelecimento;
  final Map<String, dynamic> estabelecimentoDepartamento;
  final Map<String, dynamic> parceiro;
  final Map<String, dynamic> historico;
  final Map<String, dynamic> operacao;
  final Map<String, dynamic> moeda;
  final Map<String, dynamic> modalidade;
  final Map<String, dynamic> preco;
  final Map<String, dynamic> corretor;
  final Map<String, dynamic> vendedor;
  final DateTime momento;
  final DateTime emissao;
  final DateTime competencia;
  final DateTime baixa;
  final List<RequisicaoFaturaItem> itens;
  final int subtotalCentavos;
  final int acrescimoCentavos;
  final int freteCentavos;
  final int servicoCentavos;
  final int descontoCentavos;
  final int abatimentoCentavos;
  final int deducaoCentavos;
  final int totalCentavos;
  final Map<String, dynamic> dispositivo;
  final List<RequisicaoFaturaResultado> resultados;
  final List<RequisicaoFaturaModalidade> modalidades;
  final List<RequisicaoFaturaPagamento> pagamentos;
  final int pessoas;
  final String sessaoId;

  Map<String, dynamic> paraJson() => {
        'nova': false,
        'identificador': identificador,
        'situacao': situacao,
        'tipo': tipo,
        'natureza': natureza,
        'estabelecimento': estabelecimento,
        'estabelecimentoDepartamento': estabelecimentoDepartamento,
        'parceiro': parceiro,
        'historico': historico,
        'operacao': operacao,
        'moeda': moeda,
        'modalidade': modalidade,
        'preco': preco,
        'corretor': corretor,
        'vendedor': vendedor,
        'momento': momento.toIso8601String(),
        'emissao': emissao.toIso8601String(),
        'competencia': competencia.toIso8601String(),
        'baixa': baixa.toIso8601String(),
        'faturaItens': [for (final item in itens) item.paraJson()],
        'subtotal': ValoresFatura.reais(subtotalCentavos),
        'acrescimo': ValoresFatura.reais(acrescimoCentavos),
        'frete': ValoresFatura.reais(freteCentavos),
        'freteItem': null,
        'servico': ValoresFatura.reais(servicoCentavos),
        'servicoPercentual': 0.0,
        'desconto': ValoresFatura.reais(descontoCentavos),
        'descontoPercentual': 0.0,
        'abatimento': ValoresFatura.reais(abatimentoCentavos),
        'deducao': ValoresFatura.reais(deducaoCentavos),
        'icmsBc': 0.0,
        'icmsValor': 0.0,
        'icmsStBc': 0.0,
        'icmsStValor': 0.0,
        'ipiBc': 0.0,
        'ipiValor': 0.0,
        'total': ValoresFatura.reais(totalCentavos),
        'dispositivo': dispositivo,
        'faturaResultados': [for (final r in resultados) r.paraJson()],
        'faturaModalidades': [for (final m in modalidades) m.paraJson()],
        'faturaPagamentos': [for (final p in pagamentos) p.paraJson()],
        'pago': 0.0,
        'saldo': 0.0,
        'pessoas': pessoas,
        'sessao': {'id': sessaoId},
        'justificativa': null,
        'documentoFiscalSituacao': 0,
        'documentoFiscalSerie': null,
        'documentoFiscalNumero': 0,
        'carga': null,
        'rateada': true,
        'cache': false,
      };
}
