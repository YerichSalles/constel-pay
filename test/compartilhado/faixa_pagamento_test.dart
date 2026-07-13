import 'package:constel_pay/compartilhado/widgets/faixa_pagamento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> montar(WidgetTester tester, String texto, double largura) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: largura,
            child: FaixaPagamento(
              texto: texto,
              corFundo: const Color(0xFF1B7F3B),
              corTexto: const Color(0xFFFFEEDD),
              fonte: 'Inter',
            ),
          ),
        ),
      ),
    ));
  }

  testWidgets('mostra o texto com as cores recebidas', (tester) async {
    await montar(tester, 'Pague aqui', 400);
    final texto = tester.widget<Text>(find.text('Pague aqui'));
    expect(texto.style?.color, const Color(0xFFFFEEDD));

    final fundo = tester
        .widgetList<Container>(find.descendant(
          of: find.byType(FaixaPagamento),
          matching: find.byType(Container),
        ))
        .first;
    expect(fundo.color, const Color(0xFF1B7F3B));
  });

  testWidgets('frase longa nao estoura a largura', (tester) async {
    await montar(
        tester,
        'Toque em qualquer lugar desta tela para pagar a sua conta agora mesmo '
        'sem precisar chamar o garçom da sua mesa',
        300);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
