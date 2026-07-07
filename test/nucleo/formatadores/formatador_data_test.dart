import 'package:constel_pay/nucleo/formatadores/formatador_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormatadorData', () {
    final data = DateTime(2026, 7, 6, 19, 42);
    test('dataHora',
        () => expect(FormatadorData.dataHora(data), '06/07/2026 19:42'));
    test('hora', () => expect(FormatadorData.hora(data), '19:42'));
  });
}
