import 'package:constel_pay/compartilhado/widgets/barra_superior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget montar({VoidCallback? aoVoltar, Widget? publicidade, String? titulo}) {
    return MaterialApp(
      home: Scaffold(
        appBar: BarraSuperior(
          titulo: titulo ?? 'Dionísio Torres',
          avatar: const CircleAvatar(radius: 20),
          aoVoltar: aoVoltar,
          publicidade: publicidade,
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

  testWidgets('com publicidade o widget aparece na barra', (tester) async {
    await tester.pumpWidget(montar(
      publicidade: const ColoredBox(
        key: Key('publicidade_teste'),
        color: Colors.red,
      ),
    ));

    expect(find.byKey(const Key('publicidade_teste')), findsOneWidget);
  });

  testWidgets('sem publicidade nao sobra espaco reservado para ela',
      (tester) async {
    await tester.pumpWidget(montar());

    expect(find.byKey(const Key('publicidade_teste')), findsNothing);
  });

  testWidgets(
      'titulo longo com publicidade em tela estreita (480px) nao estoura',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(480, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(montar(
      titulo: 'Restaurante e Choperia Dionísio Torres Nome Bem Comprido Ltda',
      publicidade: Container(
        key: const Key('publicidade_longa'),
        color: Colors.green,
        child: const Text('Promoção imperdível hoje, aproveite agora mesmo!'),
      ),
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('publicidade_longa')), findsOneWidget);
  });
}
