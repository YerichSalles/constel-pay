import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/compartilhado/widgets/seletor_idioma.dart';
import 'package:constel_pay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  // O locale do MaterialApp acompanha o provedorIdioma, exatamente como no
  // ConstelPayApp real — sem isso, o AppLocalizations.of(context) resolveria
  // pelo locale do dispositivo/ambiente de teste, ignorando o provider.
  Future<void> montar(WidgetTester tester) => tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) => MaterialApp(
              locale: ref.watch(provedorIdioma),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: Center(child: SeletorIdioma())),
            ),
          ),
        ),
      );

  testWidgets('mostra a sigla do idioma atual (PT por padrao)', (tester) async {
    await montar(tester);
    expect(find.text('PT'), findsOneWidget);
  });

  testWidgets('tem semantics/tooltip com a frase traduzida do idioma atual',
      (tester) async {
    await montar(tester);
    expect(
      find.byTooltip('Alterar idioma. Idioma atual: Português.'),
      findsOneWidget,
    );
  });

  testWidgets('toque abre o dialogo com titulo e as tres opcoes de idioma',
      (tester) async {
    await montar(tester);

    await tester.tap(find.byType(SeletorIdioma));
    await tester.pumpAndSettle();

    expect(find.text('Escolha o idioma'), findsOneWidget);
    expect(find.text('Português'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
  });

  testWidgets(
      'selecionar English muda o provider para Locale(en) e fecha o dialogo',
      (tester) async {
    await montar(tester);

    await tester.tap(find.byType(SeletorIdioma));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(container.read(provedorIdioma), const Locale('en'));
    expect(find.text('Escolha o idioma'), findsNothing);
  });

  testWidgets('apos selecionar espanhol, a sigla do botao vira ES',
      (tester) async {
    await montar(tester);

    await tester.tap(find.byType(SeletorIdioma));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('ES'), findsOneWidget);
    expect(container.read(provedorIdioma), const Locale('es'));
  });
}
