import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/paginas/pagina_configuracoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('pagina de configuracoes mostra as 5 abas e salva a aba Geral',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final roteador = GoRouter(
      initialLocation: '/configuracoes',
      routes: [
        GoRoute(
            path: '/configuracoes',
            builder: (_, __) => const PaginaConfiguracoes()),
        GoRoute(
            path: '/splash',
            builder: (_, __) => const Scaffold(body: Text('SPLASH'))),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: MaterialApp.router(routerConfig: roteador),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Geral'), findsOneWidget);
    expect(find.text('Comunicação'), findsOneWidget);
    expect(find.text('Aparência'), findsOneWidget);
    expect(find.text('Propaganda'), findsOneWidget);
    expect(find.text('Diagnóstico'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do restaurante'),
        'Durango Burgers');
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final repositorio = ProviderScope.containerOf(
            tester.element(find.byType(PaginaConfiguracoes)))
        .read(provedorRepositorioConfiguracao);
    expect((await repositorio.obter()).nomeRestaurante, 'Durango Burgers');
  });
}
