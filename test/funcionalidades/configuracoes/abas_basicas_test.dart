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

    // Campos do dispositivo agora moram na aba Comunicação.
    expect(find.widgetWithText(TextFormField, 'Identificador do dispositivo'),
        findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'ID do dispositivo (UUID)'),
        findsOneWidget);

    // O nome do estabelecimento vem do login; não há mais campo manual.
    expect(find.widgetWithText(TextFormField, 'Nome do restaurante'),
        findsNothing);

    // Só as URLs do ambiente selecionado aparecem (padrão: homologação).
    expect(find.widgetWithText(TextFormField, 'URL Local Homologação'),
        findsOneWidget);
    expect(
        find.widgetWithText(TextFormField, 'URL Local Produção'), findsNothing);

    await tester.tap(find.text('Produção'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'URL Local Produção'),
        findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'URL Local Homologação'),
        findsNothing);

    // A seção da nuvem fica abaixo da dobra; rola a partir de ponto neutro.
    await tester.dragFrom(
        tester.getCenter(find.text('API local (consumo do cartão)')),
        const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'URL Nuvem Produção'),
        findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'URL Nuvem Homologação'),
        findsNothing);
  });
}
