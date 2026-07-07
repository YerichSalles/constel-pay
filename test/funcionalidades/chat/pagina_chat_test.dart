import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/paginas/pagina_chat.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'fluxo completo no chat: leitura -> pix -> sucesso -> comprovante',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final roteador = GoRouter(
      initialLocation: '/chat',
      routes: [
        GoRoute(path: '/chat', builder: (_, __) => const PaginaChat()),
        GoRoute(
            path: '/splash',
            builder: (_, __) => const Scaffold(body: Text('SPLASH'))),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provedorSharedPreferences.overrideWithValue(preferencias),
          provedorAtrasoBot.overrideWithValue(Duration.zero),
          provedorFonteLeituraMock
              .overrideWithValue(FonteLeituraMock(atraso: Duration.zero)),
          provedorFontePagamentoMock
              .overrideWithValue(FontePagamentoMock(atraso: Duration.zero)),
        ],
        child: MaterialApp.router(routerConfig: roteador),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    // boas-vindas + scanner
    expect(find.textContaining('cartão de consumo'), findsWidgets);
    expect(find.textContaining('Simular leitura'), findsOneWidget);

    // leitura do primeiro cartao
    await tester.tap(find.textContaining('Simular leitura'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.text('Mesa 12'), findsOneWidget);
    expect(find.textContaining('Comanda 01'), findsWidgets);

    // ir para pagamento
    await tester.tap(find.textContaining('Ir para o pagamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('10% de serviço'), findsWidgets);

    // sem taxa
    await tester.tap(find.text('Sem taxa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.text('Pix'), findsOneWidget);

    // escolher pix
    await tester.tap(find.text('Pix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.text('Já fiz o pagamento'), findsOneWidget);

    // confirmar pagamento
    await tester.tap(find.text('Já fiz o pagamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('aprovado'), findsWidgets);

    // encerrar
    await tester.ensureVisible(find.text('Encerrar'));
    await tester.tap(find.text('Encerrar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.text('Comprovante de pagamento'), findsOneWidget);
    expect(find.text('Novo pagamento'), findsOneWidget);
  });
}
