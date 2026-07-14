/// Fonte central de horário do app. Injetável para que testes e payloads
/// financeiros usem tempo determinístico em vez de `DateTime.now()` solto.
class Relogio {
  const Relogio();

  /// Horário local do dispositivo.
  DateTime agora() => DateTime.now();

  /// Horário atual em UTC — usado no `momento` da fatura e nas conclusões.
  DateTime agoraUtc() => agora().toUtc();

  /// Data operacional: a data civil LOCAL serializada como meia-noite UTC.
  /// O retaguarda registra `emissao`/`competencia`/`baixa` assim — às 21:44
  /// locais do dia 13 (00:44Z do dia 14) o caixa envia `2026-07-13T00:00:00Z`.
  /// Não é a meia-noite local convertida para UTC (isso deslocaria o fuso).
  DateTime dataOperacional() {
    final local = agora();
    return DateTime.utc(local.year, local.month, local.day);
  }
}

/// Relógio fixo para testes: todos os métodos derivam de [instanteLocal].
class RelogioFixo extends Relogio {
  const RelogioFixo(this.instanteLocal);

  final DateTime instanteLocal;

  @override
  DateTime agora() => instanteLocal;
}
