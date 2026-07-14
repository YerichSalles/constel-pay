import 'package:constel_pay/compartilhado/widgets/faixa_pagamento.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  testWidgets('frase longa nao passa de duas linhas de texto', (tester) async {
    await montar(
        tester,
        'Toque em qualquer lugar desta tela para pagar a sua conta agora mesmo '
        'sem precisar chamar o garçom da sua mesa',
        300);
    await tester.pump();

    final paragrafo = tester.renderObject<RenderParagraph>(find.descendant(
      of: find.byType(FaixaPagamento),
      matching: find.byType(RichText),
    ));

    // Confirma que a frase de teste e realmente longa demais para 2 linhas,
    // ou seja, que o corte por maxLines esta ativamente entrando em acao
    // (sem isso, o teste passaria mesmo com a protecao removida).
    expect(paragrafo.didExceedMaxLines, isTrue);

    // A garantia real: por mais longa que seja a frase, a altura renderizada
    // do paragrafo nunca passa da altura de 2 linhas (com folga para
    // arredondamento de fonte).
    expect(paragrafo.size.height,
        lessThanOrEqualTo(paragrafo.preferredLineHeight * 2 + 1));
  });
}
