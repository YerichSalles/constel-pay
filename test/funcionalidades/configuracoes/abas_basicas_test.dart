import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/paginas/pagina_configuracoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'pagina de configuracoes mostra as 4 abas e os campos do dispositivo',
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

    expect(find.text('Geral'), findsNothing);
    expect(find.text('Comunicação'), findsOneWidget);
    expect(find.text('Aparência'), findsOneWidget);
    expect(find.text('Propaganda'), findsOneWidget);
    expect(find.text('Diagnóstico'), findsOneWidget);

    Future<void> rolarAte(Finder alvo) async {
      await tester.dragUntilVisible(
          alvo, find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
    }

    // Campos do dispositivo moram na seção Terminal da aba Comunicação.
    await rolarAte(
        find.widgetWithText(TextFormField, 'Identificador do terminal'));
    expect(find.widgetWithText(TextFormField, 'ID do dispositivo (UUID)'),
        findsOneWidget);

    // O nome do estabelecimento vem do login; não há mais campo manual.
    expect(find.widgetWithText(TextFormField, 'Nome do restaurante'),
        findsNothing);

    // Só as URLs do ambiente selecionado aparecem (padrão: homologação).
    await rolarAte(find.text('Produção'));
    await tester.tap(find.text('Produção'));
    await tester.pumpAndSettle();

    await rolarAte(find.widgetWithText(TextFormField, 'URL da API (Produção)'));
    expect(find.widgetWithText(TextFormField, 'URL da API (Homologação)'),
        findsNothing);

    await rolarAte(
        find.widgetWithText(TextFormField, 'URL da API local (Produção)'));
    expect(find.widgetWithText(TextFormField, 'URL da API local (Homologação)'),
        findsNothing);
  });
}
