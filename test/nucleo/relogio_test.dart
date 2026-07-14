import 'package:constel_pay/nucleo/utils/relogio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dataOperacional usa a data civil LOCAL como meia-noite UTC', () {
    // 21:44 locais do dia 13 — mesmo instante em que o caixa registrou
    // emissao = 2026-07-13T00:00:00.000Z (00:44Z já do dia 14 em UTC-3).
    final relogio = RelogioFixo(DateTime(2026, 7, 13, 21, 44));
    expect(relogio.dataOperacional(), DateTime.utc(2026, 7, 13));
    expect(relogio.dataOperacional().toIso8601String(),
        '2026-07-13T00:00:00.000Z');
  });

  test('virada de dia local muda a data operacional', () {
    final relogio = RelogioFixo(DateTime(2026, 7, 14, 0, 10));
    expect(relogio.dataOperacional(), DateTime.utc(2026, 7, 14));
  });

  test('agoraUtc converte o instante local para UTC', () {
    final local = DateTime(2026, 7, 13, 21, 44, 25);
    final relogio = RelogioFixo(local);
    expect(relogio.agoraUtc(), local.toUtc());
    expect(relogio.agoraUtc().isUtc, isTrue);
  });
}
