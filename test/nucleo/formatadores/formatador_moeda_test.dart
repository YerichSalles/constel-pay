import 'package:constel_pay/nucleo/formatadores/formatador_moeda.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormatadorMoeda', () {
    test('formata zero', () => expect(FormatadorMoeda.formatar(0), r'R$ 0,00'));
    test('formata centavos',
        () => expect(FormatadorMoeda.formatar(5), r'R$ 0,05'));
    test('formata valor simples',
        () => expect(FormatadorMoeda.formatar(31800), r'R$ 318,00'));
    test('formata com separador de milhar',
        () => expect(FormatadorMoeda.formatar(1234567), r'R$ 12.345,67'));
    test('formata milhões',
        () => expect(FormatadorMoeda.formatar(100000000), r'R$ 1.000.000,00'));
    test('formata negativo',
        () => expect(FormatadorMoeda.formatar(-500), r'-R$ 5,00'));
  });
}
