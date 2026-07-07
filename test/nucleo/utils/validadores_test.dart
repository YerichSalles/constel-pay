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

  group('Validadores.pinValido', () {
    test('aceita 4 digitos',
        () => expect(Validadores.pinValido('1234'), isTrue));
    test('aceita 6 digitos',
        () => expect(Validadores.pinValido('123456'), isTrue));
    test('rejeita 3 digitos',
        () => expect(Validadores.pinValido('123'), isFalse));
    test('rejeita 7 digitos',
        () => expect(Validadores.pinValido('1234567'), isFalse));
    test(
        'rejeita letras', () => expect(Validadores.pinValido('12a4'), isFalse));
  });
}
