import 'dart:math';

import 'package:constel_pay/nucleo/utils/gerador_identificador.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gera 17 caracteres A-Z/0-9 (formato do caixa)', () {
    final identificador = GeradorIdentificador().gerar();
    expect(identificador.length, 17);
    expect(RegExp(r'^[A-Z0-9]{17}$').hasMatch(identificador), isTrue,
        reason: 'gerado: $identificador');
  });

  test('com a mesma semente o resultado é determinístico', () {
    expect(GeradorIdentificador(Random(7)).gerar(),
        GeradorIdentificador(Random(7)).gerar());
  });

  test('identificadores consecutivos são diferentes', () {
    final gerador = GeradorIdentificador();
    expect(gerador.gerar(), isNot(gerador.gerar()));
  });
}
