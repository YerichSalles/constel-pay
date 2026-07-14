import 'package:constel_pay/aplicativo/constel_pay_app.dart';
import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;
  late GoRouter roteador;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
    );
    roteador = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SizedBox()),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<void> montar(WidgetTester tester) => tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ConstelPayApp(roteador: roteador),
        ),
      );

  MaterialApp materialApp(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp));

  testWidgets('locale inicial do MaterialApp e pt-BR', (tester) async {
    await montar(tester);
    expect(materialApp(tester).locale, const Locale('pt', 'BR'));
  });

  testWidgets('MaterialApp.locale acompanha o provedorIdioma', (tester) async {
    await montar(tester);
    container.read(provedorIdioma.notifier).selecionar(const Locale('en'));
    await tester.pump();
    expect(materialApp(tester).locale, const Locale('en'));
  });

  testWidgets('MaterialApp.locale reflete espanhol', (tester) async {
    await montar(tester);
    container.read(provedorIdioma.notifier).selecionar(const Locale('es'));
    await tester.pump();
    expect(materialApp(tester).locale, const Locale('es'));
  });

  testWidgets('resetar volta o locale para pt-BR', (tester) async {
    await montar(tester);
    container.read(provedorIdioma.notifier).selecionar(const Locale('en'));
    await tester.pump();
    container.read(provedorIdioma.notifier).resetar();
    await tester.pump();
    expect(materialApp(tester).locale, const Locale('pt', 'BR'));
  });

  testWidgets(
      'supportedLocales inclui pt, en e es (pt-BR resolve para pt via resolucao padrao)',
      (tester) async {
    await montar(tester);
    expect(materialApp(tester).supportedLocales, contains(const Locale('pt')));
    expect(materialApp(tester).supportedLocales, contains(const Locale('en')));
    expect(materialApp(tester).supportedLocales, contains(const Locale('es')));
  });

  testWidgets('localizationsDelegates inclui os delegates gerados',
      (tester) async {
    await montar(tester);
    expect(materialApp(tester).localizationsDelegates, isNotNull);
    expect(materialApp(tester).localizationsDelegates!.length,
        greaterThanOrEqualTo(4));
  });
}
