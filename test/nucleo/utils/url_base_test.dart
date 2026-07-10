import 'package:constel_pay/nucleo/utils/url_base.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adiciona barra final quando ausente', () {
    expect(comBarraFinal('http://x/api'), 'http://x/api/');
  });

  test('mantem inalterada quando ja termina com barra', () {
    expect(comBarraFinal('http://x/api/'), 'http://x/api/');
  });

  test('mantem string vazia inalterada', () {
    expect(comBarraFinal(''), '');
  });
}
