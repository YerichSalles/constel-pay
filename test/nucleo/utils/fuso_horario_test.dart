import 'package:constel_pay/nucleo/utils/fuso_horario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gmt formata deslocamento negativo com dois dígitos', () {
    expect(FusoHorario.gmt(const Duration(hours: -3)), 'GMT-03');
  });

  test('gmt formata deslocamento positivo', () {
    expect(FusoHorario.gmt(const Duration(hours: 5)), 'GMT+05');
  });

  test('gmt trata deslocamento zero', () {
    expect(FusoHorario.gmt(Duration.zero), 'GMT+00');
  });

  test('gmt trunca minutos para a hora', () {
    expect(FusoHorario.gmt(const Duration(hours: -3, minutes: -30)), 'GMT-03');
  });
}
