import '../../../../nucleo/utils/json_leniente.dart';
import '../../../leitura_cartao/dominio/entidades/atendimento.dart';
import '../../dominio/entidades/configuracao_faturamento.dart';
import '../../dominio/entidades/fatura_enums.dart';
import '../modelos/requisicao_fatura.dart';
import '../modelos/requisicao_fatura_item.dart';
import '../modelos/requisicao_fatura_modalidade.dart';
import '../modelos/requisicao_fatura_pagamento.dart';
import '../modelos/requisicao_fatura_resultado.dart';
import '../modelos/valores_fatura.dart';

/// Monta a `RequisicaoFatura` a partir dos atendimentos (JSON bruto da API),
/// da configuração de faturamento e da forma de pagamento escolhida.
///
/// Regras do contrato:
/// - valores SEMPRE consolidados do atendimento/resumos — nunca recalculados;
/// - itens vêm de `atendimentoResumos` com sequencial global crescente;
/// - uma modalidade por atendimento (referencia/numero/referenciaId
///   separados: número visual, numérico e id real);
/// - `momento` é o instante UTC; emissão/competência/baixa são a data
///   operacional (data civil local à meia-noite UTC).
abstract final class MapeadorFatura {
  static RequisicaoFatura montar({
    required List<Atendimento> atendimentos,
    required ConfiguracaoFaturamento configuracao,
    required FormaFaturamento formaPagamento,
    required String identificador,
    required DateTime momentoUtc,
    required DateTime dataOperacional,
    int trocoCentavos = 0,
  }) {
    final brutos = [for (final a in atendimentos) a.bruto];
    final primeiro = brutos.first;

    final itens = _itens(brutos, configuracao);
    final totalCentavos = _soma(brutos, 'total');

    return RequisicaoFatura(
      identificador: identificador,
      situacao: FaturaSituacao.autorizada.valor,
      tipo: FaturaTipo.venda.valor,
      natureza: FaturaNatureza.entrada.valor,
      estabelecimento: _mapa(primeiro['estabelecimento']),
      estabelecimentoDepartamento: _departamento(configuracao, brutos),
      parceiro: _mapa(primeiro['parceiro']),
      historico: configuracao.historico,
      operacao: configuracao.operacao,
      moeda: configuracao.moeda,
      modalidade: configuracao.modalidade,
      preco: _mapa(primeiro['preco']),
      corretor: _mapa(primeiro['corretor']),
      vendedor: _mapa(primeiro['vendedor']),
      momento: momentoUtc,
      emissao: dataOperacional,
      competencia: dataOperacional,
      baixa: dataOperacional,
      itens: itens,
      subtotalCentavos: _soma(brutos, 'subtotal'),
      acrescimoCentavos: _soma(brutos, 'acrescimo'),
      freteCentavos: _soma(brutos, 'frete'),
      servicoCentavos: _soma(brutos, 'servico'),
      descontoCentavos: _soma(brutos, 'desconto'),
      abatimentoCentavos: _soma(brutos, 'abatimento'),
      deducaoCentavos: _soma(brutos, 'deducao'),
      totalCentavos: totalCentavos,
      dispositivo: configuracao.dispositivo,
      resultados: [
        RequisicaoFaturaResultado(resultado: configuracao.resultado),
      ],
      modalidades: _modalidades(atendimentos, momentoUtc),
      pagamentos: [
        RequisicaoFaturaPagamento(
          forma: formaPagamento.forma,
          plano: formaPagamento.plano,
          conta: formaPagamento.conta,
          subtotalCentavos: totalCentavos,
          trocoCentavos: trocoCentavos,
          totalCentavos: totalCentavos,
        ),
      ],
      pessoas: brutos.fold(0, (soma, b) => soma + _inteiro(b['pessoas'])),
      sessaoId: atendimentos.first.sessaoId,
    );
  }

  static List<RequisicaoFaturaItem> _itens(
    List<Map<String, dynamic>> brutos,
    ConfiguracaoFaturamento configuracao,
  ) {
    var sequencial = 0;
    return [
      for (final bruto in brutos)
        for (final resumo in _lista(bruto['atendimentoResumos']))
          RequisicaoFaturaItem(
            sequencial: ++sequencial,
            resultado: configuracao.resultado,
            modalidade: _mapa(resumo['modalidade']),
            corretor: _mapa(resumo['corretor']),
            vendedor: _mapa(resumo['vendedor']),
            item: _mapa(resumo['item']),
            preco: _mapa(resumo['preco']),
            estabelecimentoDepartamento:
                _mapa(resumo['estabelecimentoDepartamento']),
            valorCentavos: ValoresFatura.centavos(resumo['valor']),
            quantidade:
                resumo['quantidade'] is num ? resumo['quantidade'] as num : 0,
            subtotalCentavos: ValoresFatura.centavos(resumo['subtotal']),
            acrescimoCentavos: ValoresFatura.centavos(resumo['acrescimo']),
            freteCentavos: ValoresFatura.centavos(resumo['frete']),
            servicoCentavos: ValoresFatura.centavos(resumo['servico']),
            descontoCentavos: ValoresFatura.centavos(resumo['desconto']),
            abatimentoCentavos: ValoresFatura.centavos(resumo['abatimento']),
            deducaoCentavos: ValoresFatura.centavos(resumo['deducao']),
            totalCentavos: ValoresFatura.centavos(resumo['total']),
            comissiona: resumo['comissiona'] == true,
            ocupacao: resumo['ocupacao'] is Map<String, dynamic>
                ? resumo['ocupacao'] as Map<String, dynamic>
                : null,
          ),
    ];
  }

  static List<RequisicaoFaturaModalidade> _modalidades(
    List<Atendimento> atendimentos,
    DateTime conclusao,
  ) =>
      [
        for (final (indice, atendimento) in atendimentos.indexed)
          RequisicaoFaturaModalidade(
            sequencial: indice + 1,
            modalidade: _mapa(atendimento.bruto['modalidade']),
            localizador:
                atendimento.bruto['localizador'] is Map<String, dynamic>
                    ? atendimento.bruto['localizador'] as Map<String, dynamic>
                    : null,
            referencia: atendimento.referencia,
            numero: _numeroCartao(atendimento),
            subtotalCentavos:
                ValoresFatura.centavos(atendimento.bruto['subtotal']),
            acrescimoCentavos:
                ValoresFatura.centavos(atendimento.bruto['acrescimo']),
            freteCentavos: ValoresFatura.centavos(atendimento.bruto['frete']),
            servicoCentavos:
                ValoresFatura.centavos(atendimento.bruto['servico']),
            descontoCentavos:
                ValoresFatura.centavos(atendimento.bruto['desconto']),
            abatimentoCentavos:
                ValoresFatura.centavos(atendimento.bruto['abatimento']),
            deducaoCentavos:
                ValoresFatura.centavos(atendimento.bruto['deducao']),
            totalCentavos: ValoresFatura.centavos(atendimento.bruto['total']),
            pessoas: _inteiro(atendimento.bruto['pessoas']),
            referenciaId: atendimento.id,
            inicio: atendimento.bruto['inicio'] is String
                ? atendimento.bruto['inicio'] as String
                : null,
            conclusao: conclusao,
          ),
      ];

  /// Número visual do cartão/comanda: o código do localizador (ex.: "512").
  /// Nunca usa o id — `referenciaId` carrega o id real do atendimento.
  static int _numeroCartao(Atendimento atendimento) {
    final localizador = _mapa(atendimento.bruto['localizador']);
    return int.tryParse(_texto(localizador['codigo'])) ??
        int.tryParse(atendimento.referencia) ??
        0;
  }

  static Map<String, dynamic> _departamento(
    ConfiguracaoFaturamento configuracao,
    List<Map<String, dynamic>> brutos,
  ) {
    if (configuracao.estabelecimentoDepartamento['id'] is String) {
      return configuracao.estabelecimentoDepartamento;
    }
    for (final bruto in brutos) {
      for (final resumo in _lista(bruto['atendimentoResumos'])) {
        final departamento = _mapa(resumo['estabelecimentoDepartamento']);
        if (departamento.isNotEmpty) return departamento;
      }
    }
    return const {};
  }

  static int _soma(List<Map<String, dynamic>> brutos, String campo) =>
      brutos.fold(0, (soma, b) => soma + ValoresFatura.centavos(b[campo]));

  static int _inteiro(dynamic v) => JsonLeniente.inteiro(v);

  static String _texto(dynamic v) => JsonLeniente.texto(v);

  static Map<String, dynamic> _mapa(dynamic v) => JsonLeniente.mapa(v);

  static List<Map<String, dynamic>> _lista(dynamic v) => JsonLeniente.lista(v);
}
