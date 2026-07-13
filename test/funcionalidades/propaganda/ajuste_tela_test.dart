import 'package:constel_pay/funcionalidades/propaganda/apresentacao/ajuste_tela.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Tela do totem em pe: 9:16 = 0,5625.
  const razaoRetrato = 9 / 16;

  BoxFit fit(AjusteMidia ajuste, double? razaoMidia,
          [double razaoTela = razaoRetrato]) =>
      resolverBoxFit(
          ajuste: ajuste, razaoMidia: razaoMidia, razaoTela: razaoTela);

  test('modos explicitos ignoram as razoes', () {
    expect(fit(AjusteMidia.preencher, 16 / 9), BoxFit.cover);
    expect(fit(AjusteMidia.encaixar, 9 / 16), BoxFit.contain);
    expect(fit(AjusteMidia.esticar, 16 / 9), BoxFit.fill);
    expect(fit(AjusteMidia.preencher, null), BoxFit.cover);
  });

  test('automatico preenche quando a midia acompanha a tela', () {
    expect(fit(AjusteMidia.automatico, 9 / 16), BoxFit.cover); // 1,00
    expect(fit(AjusteMidia.automatico, 3 / 4), BoxFit.cover); // 0,75: no limite
  });

  test('automatico encaixa quando o corte destruiria a midia', () {
    expect(fit(AjusteMidia.automatico, 1), BoxFit.contain); // 0,56
    expect(fit(AjusteMidia.automatico, 16 / 9), BoxFit.contain); // 0,32
  });

  test('automatico tambem decide com a tela deitada', () {
    const razaoPaisagem = 16 / 9;
    expect(fit(AjusteMidia.automatico, 16 / 9, razaoPaisagem), BoxFit.cover);
    expect(fit(AjusteMidia.automatico, 9 / 16, razaoPaisagem), BoxFit.contain);
  });

  test('automatico nao corta o que ainda nao mediu', () {
    expect(fit(AjusteMidia.automatico, null), BoxFit.contain);
  });

  test('automatico trata razao invalida como desconhecida', () {
    expect(fit(AjusteMidia.automatico, 0), BoxFit.contain);
    expect(fit(AjusteMidia.automatico, -1), BoxFit.contain);
    expect(fit(AjusteMidia.automatico, double.nan), BoxFit.contain);
    expect(fit(AjusteMidia.automatico, 9 / 16, 0), BoxFit.contain);
  });
}
