import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/seletor_ajuste_midia.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('seletor mostra o modo atual e devolve o modo escolhido',
      (tester) async {
    AjusteMidia? escolhido;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SeletorAjusteMidia(
          valor: AjusteMidia.automatico,
          aoMudar: (ajuste) => escolhido = ajuste,
        ),
      ),
    ));
    expect(find.text('Automático'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<AjusteMidia>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Encaixar (tarja)').last);
    await tester.pumpAndSettle();

    expect(escolhido, AjusteMidia.encaixar);
  });

  test('todo modo de ajuste tem rotulo em pt-BR', () {
    for (final ajuste in AjusteMidia.values) {
      expect(SeletorAjusteMidia.rotulos[ajuste], isNotNull,
          reason: 'sem rotulo para $ajuste');
    }
  });
}
