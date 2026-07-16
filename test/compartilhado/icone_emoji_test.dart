import 'package:constel_pay/compartilhado/widgets/icone_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> montar(WidgetTester tester, String emoji) =>
      tester.pumpWidget(MaterialApp(
        home: Scaffold(body: IconeEmoji(emoji, tamanho: 32)),
      ));

  testWidgets('emoji conhecido vira icone Material com sua cor',
      (tester) async {
    await montar(tester, '💳');
    final icone = tester.widget<Icon>(find.byType(Icon));
    expect(icone.icon, Icons.credit_card_outlined);
    expect(icone.color, const Color(0xFF1565C0));
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('emoji desconhecido continua renderizado como texto',
      (tester) async {
    await montar(tester, '🧀');
    expect(find.text('🧀'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('parametro cor sobrepoe a cor padrao do icone', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: IconeEmoji('💳', tamanho: 32, cor: Colors.white)),
    ));
    expect(tester.widget<Icon>(find.byType(Icon)).color, Colors.white);
  });
}
