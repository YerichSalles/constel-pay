import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/aba_aparencia.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/seletor_cor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SeletorCor propaga o hex digitado', (tester) async {
    var recebido = '';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SeletorCor(
            rotulo: 'Cor primária',
            valorHex: '#5E52D6',
            aoMudar: (hex) => recebido = hex),
      ),
    ));
    await tester.enterText(find.byType(TextFormField), '#112233');
    expect(recebido, '#112233');
  });

  testWidgets('Aplicar tema atualiza o provedorTema', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    late final ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: AbaAparencia())),
      ),
    );
    await tester.pump();
    container =
        ProviderScope.containerOf(tester.element(find.byType(AbaAparencia)));

    await tester.enterText(find.byType(TextFormField).first, '#112233');
    await tester.pumpAndSettle();

    // Scroll to ensure button is visible
    final listView = find.byType(ListView);
    await tester.drag(listView, const Offset(0, -1000));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aplicar tema'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(container.read(provedorTema).corPrimaria, '#112233');
  });
}
