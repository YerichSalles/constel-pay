import 'package:constel_pay/compartilhado/widgets/barra_creditos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Material _material(WidgetTester tester) =>
    tester.widget<Material>(find.descendant(
        of: find.byType(BarraCreditos), matching: find.byType(Material)));

Future<void> _montar(WidgetTester tester, BarraCreditos barra) =>
    tester.pumpWidget(MaterialApp(
      theme: ThemeData(
          colorScheme: const ColorScheme.light(primary: Color(0xFF5E52D6))),
      home: Scaffold(bottomNavigationBar: barra),
    ));

void main() {
  testWidgets('sem cor própria a barra usa a primária do tema', (tester) async {
    await _montar(tester, const BarraCreditos());
    expect(_material(tester).color, const Color(0xFF5E52D6));
  });

  testWidgets('corFundo pinta a barra com a cor escolhida', (tester) async {
    await _montar(tester, const BarraCreditos(corFundo: Color(0xFF1B7F3B)));
    expect(_material(tester).color, const Color(0xFF1B7F3B));
  });

  testWidgets('sobreposta a barra não pinta fundo próprio', (tester) async {
    await _montar(tester, const BarraCreditos(sobreCor: Color(0xFF1B7F3B)));
    expect(_material(tester).color, Colors.transparent);
  });

  testWidgets('o texto ganha contraste conforme a cor de fundo escolhida',
      (tester) async {
    // Fundo claro: o texto precisa escurecer para continuar legível.
    await _montar(tester, const BarraCreditos(corFundo: Color(0xFFFFD166)));
    expect(tester.widget<Text>(find.text('Constel Pay')).style!.color,
        const Color(0xFF1E1E1E));

    await _montar(tester, const BarraCreditos(corFundo: Color(0xFF1B2F3B)));
    expect(tester.widget<Text>(find.text('Constel Pay')).style!.color,
        Colors.white);
  });
}
