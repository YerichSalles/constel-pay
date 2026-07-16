import '../../../../nucleo/utils/json_leniente.dart';
import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';

/// Dados de faturamento que NÃO existem no atendimento: histórico contábil,
/// operação fiscal, moeda, dispositivo e a forma/plano/conta de cada método
/// de pagamento. O cabeçalho fiscal vem do documento do dispositivo
/// (`estrutura/dispositivo/<id>`) e a forma/plano/conta do cadastro de formas
/// (`financeiro/forma`) — nada disso exige venda anterior. A `modalidade` de
/// cabeçalho e o `resultado`/rateio NÃO ficam aqui: o retaguarda os completa
/// no POST da fatura. Os sub-objetos são ecoados na fatura exatamente como
/// vieram (mapas brutos); o app não valida a semântica interna, só exige `id`.
class ConfiguracaoFaturamento {
  const ConfiguracaoFaturamento({
    required this.historico,
    required this.operacao,
    required this.moeda,
    required this.dispositivo,
    this.estabelecimentoDepartamento = const {},
    this.formasPagamento = const {},
    this.dispositivoOrigem = '',
  });

  final Map<String, dynamic> historico;
  final Map<String, dynamic> operacao;
  final Map<String, dynamic> moeda;
  final Map<String, dynamic> dispositivo;

  /// Opcional: quando ausente, a fatura usa o departamento do primeiro
  /// resumo do atendimento.
  final Map<String, dynamic> estabelecimentoDepartamento;

  /// Forma/plano/conta por método de pagamento (`MetodoPagamento.name`).
  final Map<String, FormaFaturamento> formasPagamento;

  /// Dispositivo do qual esta configuração foi montada. Dispositivo diferente
  /// → montar de novo (o cache antigo continua como reserva se o cadastro
  /// falhar).
  final String dispositivoOrigem;

  /// Cópia com as formas de [outra] preservadas quando esta configuração não
  /// conhece o método — resolver só o PIX não pode apagar a forma Dinheiro já
  /// aprendida antes.
  ConfiguracaoFaturamento mesclandoFormasDe(ConfiguracaoFaturamento? outra) {
    if (outra == null) return this;
    return ConfiguracaoFaturamento(
      historico: historico,
      operacao: operacao,
      moeda: moeda,
      dispositivo: dispositivo,
      estabelecimentoDepartamento: estabelecimentoDepartamento,
      formasPagamento: {...outra.formasPagamento, ...formasPagamento},
      dispositivoOrigem: dispositivoOrigem,
    );
  }

  static ConfiguracaoFaturamento? deJson(Map<String, dynamic> json) {
    final base = ConfiguracaoFaturamento(
      historico: _mapa(json['historico']),
      operacao: _mapa(json['operacao']),
      moeda: _mapa(json['moeda']),
      dispositivo: _mapa(json['dispositivo']),
      estabelecimentoDepartamento: _mapa(json['estabelecimentoDepartamento']),
      formasPagamento: {
        for (final entrada in _mapa(json['formasPagamento']).entries)
          if (entrada.value is Map<String, dynamic>)
            entrada.key:
                FormaFaturamento.deJson(entrada.value as Map<String, dynamic>),
      },
      dispositivoOrigem: JsonLeniente.texto(json['dispositivoOrigem']),
    );
    return base._basicaValida ? base : null;
  }

  Map<String, dynamic> paraJson() => {
        'historico': historico,
        'operacao': operacao,
        'moeda': moeda,
        'dispositivo': dispositivo,
        'estabelecimentoDepartamento': estabelecimentoDepartamento,
        'formasPagamento': {
          for (final entrada in formasPagamento.entries)
            entrada.key: entrada.value.paraJson(),
        },
        'dispositivoOrigem': dispositivoOrigem,
      };

  bool get _basicaValida =>
      _temId(historico) &&
      _temId(operacao) &&
      _temId(moeda) &&
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
