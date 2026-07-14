import 'package:constel_pay/compartilhado/widgets/barra_superior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget montar({VoidCallback? aoVoltar}) {
    return MaterialApp(
      home: Scaffold(
        appBar: BarraSuperior(
          titulo: 'Dionísio Torres',
          avatar: const CircleAvatar(radius: 20),
          aoVoltar: aoVoltar,
        ),
        body: const SizedBox(),
      ),
    );
  }

  testWidgets('exibe titulo com hierarquia reforcada', (tester) async {
    await tester.pumpWidget(montar());

    final texto = tester.widget<Text>(find.text('Dionísio Torres'));
    expect(texto.style?.fontSize, 18);
    expect(texto.style?.fontWeight, FontWeight.w800);
  });

  testWidgets('botao voltar aparece e dispara callback', (tester) async {
    var voltou = false;
    await tester.pumpWidget(montar(aoVoltar: () => voltou = true));

    final botao = find.widgetWithIcon(IconButton, Icons.arrow_back_ios_new);
    expect(botao, findsOneWidget);

    await tester.tap(botao);
    expect(voltou, isTrue);
  });

  testWidgets('sem aoVoltar nao mostra botao voltar', (tester) async {
    await tester.pumpWidget(montar());

    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
  });
}
