/// Utilitário de fuso horário para o payload de login.
abstract final class FusoHorario {
  /// Formata o deslocamento em relação ao GMT como `GMT-03` / `GMT+05`.
  /// Deriva do dispositivo por padrão; aceita um deslocamento explícito em teste.
  static String gmt([Duration? deslocamento]) {
    final offset = deslocamento ?? DateTime.now().timeZoneOffset;
    final horas = offset.inMinutes ~/ 60;
    final sinal = horas < 0 ? '-' : '+';
    final absoluto = horas.abs().toString().padLeft(2, '0');
    return 'GMT$sinal$absoluto';
  }
}
