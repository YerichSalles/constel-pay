import '../../../../nucleo/utils/json_leniente.dart';

/// Etapa já concluída (ou em andamento) de um encerramento interrompido.
/// A ordem importa: a recuperação retoma a operação do ponto exato.
enum EtapaTransacao {
  /// Pendência gravada antes da ação 10 — nada financeiro aconteceu ainda.
  preparacaoEnviada,

  /// `POST movimento/fatura` foi disparado com o payload persistido; a
  /// resposta pode não ter chegado (timeout). Retomada exige reconciliação.
  faturaEnviada,

  /// Fatura persistida no retaguarda (temos id e código). Falta a ação 30.
  faturaCriada,

  /// Ação 30 disparada; resposta pode ter se perdido. Retomada reconfirma.
  confirmacaoEnviada,
}

/// Registro local de um encerramento em andamento. Gravado ANTES de cada
/// passo crítico e removido SÓ depois da ação 30 confirmada — é o que
/// garante que falha de rede não gere fatura duplicada nem fatura órfã.
class TransacaoPendente {
  const TransacaoPendente({
    required this.identificador,
    required this.atendimentoIds,
    required this.sessaoId,
    required this.sessaoCodigo,
    required this.etapa,
    required this.dataTentativa,
    required this.atendimentosBrutos,
    this.metodo = '',
    this.trocoCentavos = 0,
    this.faturaJson = const {},
    this.faturaId = '',
    this.faturaCodigo = '',
  });

  /// Identificador único da fatura — o MESMO em qualquer retry.
  final String identificador;
  final List<String> atendimentoIds;
  final String sessaoId;
  final String sessaoCodigo;
  final EtapaTransacao etapa;
  final DateTime dataTentativa;

  /// Eco integral dos atendimentos (payload das ações 10 e 30).
  final List<Map<String, dynamic>> atendimentosBrutos;

  /// `MetodoPagamento.name` usado na operação.
  final String metodo;

  /// Troco em centavos (dinheiro). Preservado para retomadas antes do
  /// payload da fatura ser congelado.
  final int trocoCentavos;

  /// Payload canônico da fatura, congelado antes do POST: um retry reenvia
  /// exatamente estes bytes (mesmos horários, mesma configuração).
  final Map<String, dynamic> faturaJson;

  final String faturaId;
  final String faturaCodigo;

  TransacaoPendente copiarCom({
    EtapaTransacao? etapa,
    Map<String, dynamic>? faturaJson,
    String? faturaId,
    String? faturaCodigo,
    DateTime? dataTentativa,
  }) =>
      TransacaoPendente(
        identificador: identificador,
        atendimentoIds: atendimentoIds,
        sessaoId: sessaoId,
        sessaoCodigo: sessaoCodigo,
        etapa: etapa ?? this.etapa,
        dataTentativa: dataTentativa ?? this.dataTentativa,
        atendimentosBrutos: atendimentosBrutos,
        metodo: metodo,
        trocoCentavos: trocoCentavos,
        faturaJson: faturaJson ?? this.faturaJson,
        faturaId: faturaId ?? this.faturaId,
        faturaCodigo: faturaCodigo ?? this.faturaCodigo,
      );

  factory TransacaoPendente.deJson(Map<String, dynamic> json) =>
      TransacaoPendente(
        identificador: JsonLeniente.texto(json['identificador']),
        atendimentoIds: json['atendimentoIds'] is List
            ? (json['atendimentoIds'] as List).whereType<String>().toList()
            : const [],
        sessaoId: JsonLeniente.texto(json['sessaoId']),
        sessaoCodigo: JsonLeniente.texto(json['sessaoCodigo']),
        etapa: EtapaTransacao.values
                .asNameMap()[JsonLeniente.texto(json['etapa'])] ??
            EtapaTransacao.preparacaoEnviada,
        dataTentativa:
            DateTime.tryParse(JsonLeniente.texto(json['dataTentativa'])) ??
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        atendimentosBrutos: JsonLeniente.lista(json['atendimentosBrutos']),
        metodo: JsonLeniente.texto(json['metodo']),
        trocoCentavos: JsonLeniente.inteiro(json['trocoCentavos']),
        faturaJson: JsonLeniente.mapa(json['faturaJson']),
        faturaId: JsonLeniente.texto(json['faturaId']),
        faturaCodigo: JsonLeniente.texto(json['faturaCodigo']),
      );

  Map<String, dynamic> paraJson() => {
        'identificador': identificador,
        'atendimentoIds': atendimentoIds,
        'sessaoId': sessaoId,
        'sessaoCodigo': sessaoCodigo,
        'etapa': etapa.name,
        'dataTentativa': dataTentativa.toIso8601String(),
        'atendimentosBrutos': atendimentosBrutos,
        'metodo': metodo,
        'trocoCentavos': trocoCentavos,
        'faturaJson': faturaJson,
        'faturaId': faturaId,
        'faturaCodigo': faturaCodigo,
      };
}
