import 'package:constel_pay/nucleo/utils/contraste.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preto contra branco e o contraste maximo', () {
    expect(razaoDeContraste(Colors.black, Colors.white), closeTo(21, 0.01));
  });

  test('cor contra ela mesma nao tem contraste', () {
    expect(razaoDeContraste(Colors.white, Colors.white), closeTo(1, 0.001));
    expect(razaoDeContraste(Colors.black, Colors.black), closeTo(1, 0.001));
  });

  test('a ordem das cores nao muda a razao', () {
    const roxo = Color(0xFF5E52D6);
    expect(razaoDeContraste(roxo, Colors.white),
        closeTo(razaoDeContraste(Colors.white, roxo), 0.0001));
  });

  test('o padrao do app passa no minimo, branco no branco nao', () {
    // Faixa padrao: texto branco sobre a cor primaria do tema.
    const primaria = Color(0xFF5E52D6);
    expect(razaoDeContraste(primaria, Colors.white),
        greaterThan(contrasteMinimoTexto));
    expect(razaoDeContraste(Colors.white, Colors.white),
        lessThan(contrasteMinimoTexto));
  });
}
