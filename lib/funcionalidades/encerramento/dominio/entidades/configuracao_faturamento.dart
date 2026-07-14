import '../../../../nucleo/utils/json_leniente.dart';
import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';

/// Dados de faturamento que NÃO existem no atendimento e vêm da configuração
/// do retaguarda: histórico contábil, operação fiscal, moeda, modalidade do
/// terminal, resultado, dispositivo e a forma/plano/conta de cada método de
/// pagamento. Os sub-objetos são ecoados na fatura exatamente como foram
/// configurados (mapas brutos) — o app não conhece nem valida a semântica
/// interna deles; só exige que existam e tenham `id`.
class ConfiguracaoFaturamento {
  const ConfiguracaoFaturamento({
    required this.historico,
    required this.operacao,
    required this.moeda,
    required this.modalidade,
    required this.resultado,
    required this.dispositivo,
    this.estabelecimentoDepartamento = const {},
    this.formasPagamento = const {},
  });

  final Map<String, dynamic> historico;
  final Map<String, dynamic> operacao;
  final Map<String, dynamic> moeda;
  final Map<String, dynamic> modalidade;
  final Map<String, dynamic> resultado;
  final Map<String, dynamic> dispositivo;

  /// Opcional: quando ausente, a fatura usa o departamento do primeiro
  /// resumo do atendimento.
  final Map<String, dynamic> estabelecimentoDepartamento;

  /// Forma/plano/conta por método de pagamento (`MetodoPagamento.name`).
  final Map<String, FormaFaturamento> formasPagamento;

  static ConfiguracaoFaturamento? deJson(Map<String, dynamic> json) {
    final base = ConfiguracaoFaturamento(
      historico: _mapa(json['historico']),
      operacao: _mapa(json['operacao']),
      moeda: _mapa(json['moeda']),
      modalidade: _mapa(json['modalidade']),
      resultado: _mapa(json['resultado']),
      dispositivo: _mapa(json['dispositivo']),
      estabelecimentoDepartamento: _mapa(json['estabelecimentoDepartamento']),
      formasPagamento: {
        for (final entrada in _mapa(json['formasPagamento']).entries)
          if (entrada.value is Map<String, dynamic>)
            entrada.key:
                FormaFaturamento.deJson(entrada.value as Map<String, dynamic>),
      },
    );
    return base._basicaValida ? base : null;
  }

  Map<String, dynamic> paraJson() => {
        'historico': historico,
        'operacao': operacao,
        'moeda': moeda,
        'modalidade': modalidade,
        'resultado': resultado,
        'dispositivo': dispositivo,
        'estabelecimentoDepartamento': estabelecimentoDepartamento,
        'formasPagamento': {
          for (final entrada in formasPagamento.entries)
            entrada.key: entrada.value.paraJson(),
        },
      };

  bool get _basicaValida =>
      _temId(historico) &&
      _temId(operacao) &&
      _temId(moeda) &&
      _temId(modalidade) &&
      _temId(resultado) &&
      _temId(dispositivo);

  /// Config pronta para faturar com o método informado.
  bool completaPara(MetodoPagamento metodo) {
    final forma = formasPagamento[metodo.name];
    return forma != null && forma.valida;
  }

  static bool _temId(Map<String, dynamic> mapa) =>
      mapa['id'] is String && (mapa['id'] as String).isNotEmpty;

  static Map<String, dynamic> _mapa(dynamic v) => JsonLeniente.mapa(v);
}

/// Forma de pagamento configurada para a fatura: os três objetos que o
/// contrato exige em `faturaPagamentos` (forma, plano e conta financeira).
class FormaFaturamento {
  const FormaFaturamento({
    required this.forma,
    required this.plano,
    required this.conta,
  });

  final Map<String, dynamic> forma;
  final Map<String, dynamic> plano;
  final Map<String, dynamic> conta;

  factory FormaFaturamento.deJson(Map<String, dynamic> json) =>
      FormaFaturamento(
        forma: ConfiguracaoFaturamento._mapa(json['forma']),
        plano: ConfiguracaoFaturamento._mapa(json['plano']),
        conta: ConfiguracaoFaturamento._mapa(json['conta']),
      );

  Map<String, dynamic> paraJson() =>
      {'forma': forma, 'plano': plano, 'conta': conta};

  bool get valida =>
      ConfiguracaoFaturamento._temId(forma) &&
      ConfiguracaoFaturamento._temId(plano) &&
      ConfiguracaoFaturamento._temId(conta);
}
