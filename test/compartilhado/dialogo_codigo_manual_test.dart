import 'package:constel_pay/compartilhado/widgets/dialogo_codigo_manual.dart';
import 'package:constel_pay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _campo = Key('campo_codigo_manual');

/// Abre o diálogo; [aoFechar] recebe o que ele devolveu ao ser fechado.
Future<void> _abrir(WidgetTester tester, ValueChanged<String?> aoFechar) async {
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('pt', 'BR'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (contexto) => Scaffold(
        body: TextButton(
          onPressed: () async =>
              aoFechar(await mostrarDialogoCodigoManual(contexto)),
          child: const Text('abrir'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('confirmar so libera com codigo preenchido e devolve sem espacos',
      (tester) async {
    String? devolvido;
    var fechou = false;
    await _abrir(tester, (codigo) {
      devolvido = codigo;
      fechou = true;
    });

    final confirmar = find.widgetWithText(FilledButton, 'Consultar');
    expect(tester.widget<FilledButton>(confirmar).onPressed, isNull);

    await tester.enterText(find.byKey(_campo), '  ');
    await tester.pump();
    expect(tester.widget<FilledButton>(confirmar).onPressed, isNull);

    await tester.enterText(find.byKey(_campo), '  12345 ');
    await tester.pump();
    await tester.tap(confirmar);
    await tester.pumpAndSettle();

    expect(fechou, isTrue);
    expect(devolvido, '12345');
  });

  testWidgets('cancelar fecha sem devolver codigo', (tester) async {
    String? devolvido;
    var fechou = false;
    await _abrir(tester, (codigo) {
      devolvido = codigo;
      fechou = true;
    });

    await tester.enterText(find.byKey(_campo), '12345');
    await tester.pump();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(fechou, isTrue);
    expect(devolvido, isNull);
    expect(find.byKey(_campo), findsNothing);
  });
}
