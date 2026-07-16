import 'package:constel_pay/nucleo/utils/validadores.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validadores.urlValida', () {
    test(
        'aceita https',
        () => expect(
            Validadores.urlValida('https://api.constel.com.br'), isTrue));
    test('aceita http com porta',
        () => expect(Validadores.urlValida('http://10.0.0.5:8080'), isTrue));
    test('rejeita vazio', () => expect(Validadores.urlValida(''), isFalse));
    test('rejeita sem esquema',
        () => expect(Validadores.urlValida('api.constel.com.br'), isFalse));
    test('rejeita esquema errado',
        () => expect(Validadores.urlValida('ftp://x.com'), isFalse));
  });

  group('Validadores.uuidValido', () {
    test(
        'aceita UUID v4',
        () => expect(
            Validadores.uuidValido('b47ac10b-58cc-4372-a567-0e02b2c3d479'),
            isTrue));
    test(
        'aceita maiúsculas e espaços nas pontas',
        () => expect(
            Validadores.uuidValido(' B47AC10B-58CC-4372-A567-0E02B2C3D479 '),
            isTrue));
    test('rejeita vazio', () => expect(Validadores.uuidValido(''), isFalse));
    test(
        'rejeita sem hifens',
        () => expect(Validadores.uuidValido('b47ac10b58cc4372a5670e02b2c3d479'),
            isFalse));
    test('rejeita curto',
        () => expect(Validadores.uuidValido('b47ac10b-58cc'), isFalse));
  });
}
