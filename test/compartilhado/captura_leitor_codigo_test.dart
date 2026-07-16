import 'package:constel_pay/compartilhado/widgets/captura_leitor_codigo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// O leitor de código de barras (keyboard wedge) chega como uma sequência
/// rápida de teclas terminada em Enter. Estes testes exercitam o
/// reconhecimento sem depender de hardware físico.
void main() {
  const mapaDigitos = <String, LogicalKeyboardKey>{
    '0': LogicalKeyboardKey.digit0,
    '1': LogicalKeyboardKey.digit1,
    '2': LogicalKeyboardKey.digit2,
    '3': LogicalKeyboardKey.digit3,
    '4': LogicalKeyboardKey.digit4,
    '5': LogicalKeyboardKey.digit5,
    '6': LogicalKeyboardKey.digit6,
    '7': LogicalKeyboardKey.digit7,
    '8': LogicalKeyboardKey.digit8,
    '9': LogicalKeyboardKey.digit9,
  };

  Future<void> montar(
    WidgetTester tester,
    ValueChanged<String> aoLer, {
    bool ativo = true,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: CapturaLeitorCodigo(
        ativo: ativo,
        aoLer: aoLer,
        filho: const Scaffold(body: SizedBox.expand()),
      ),
    ));
    await tester.pump();
  }

  Future<void> digitar(WidgetTester tester, String texto) async {
    for (final caractere in texto.split('')) {
      final tecla = mapaDigitos[caractere]!;
      await simulateKeyDownEvent(tecla, character: caractere);
      await simulateKeyUpEvent(tecla);
    }
  }

  Future<void> enter(WidgetTester tester) async {
    await simulateKeyDownEvent(LogicalKeyboardKey.enter);
    await simulateKeyUpEvent(LogicalKeyboardKey.enter);
  }

  testWidgets('rajada de dígitos seguida de Enter dispara a leitura',
      (tester) async {
    String? lido;
    await montar(tester, (valor) => lido = valor);

    await digitar(tester, '789100000001');
    await enter(tester);

    expect(lido, '789100000001');
  });

  testWidgets('Enter sem dígitos não dispara leitura', (tester) async {
    var chamou = false;
    await montar(tester, (_) => chamou = true);

    await enter(tester);

    expect(chamou, isFalse);
  });

  testWidgets('código abaixo do tamanho mínimo é ignorado', (tester) async {
    var chamou = false;
    await montar(tester, (_) => chamou = true);

    await digitar(tester, '12');
    await enter(tester);

    expect(chamou, isFalse);
  });

  testWidgets('quando inativo, ignora o teclado', (tester) async {
    var chamou = false;
    await montar(tester, (_) => chamou = true, ativo: false);

    await digitar(tester, '789100000001');
    await enter(tester);

    expect(chamou, isFalse);
  });
}
