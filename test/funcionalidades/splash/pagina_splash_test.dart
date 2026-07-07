import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/compartilhado/widgets/detector_toque_longo.dart';
import 'package:constel_pay/funcionalidades/splash/apresentacao/paginas/pagina_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<GoRouter> _roteador() async {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const PaginaSplash()),
      GoRoute(
          path: '/propaganda',
          builder: (_, __) => const Scaffold(body: Text('PROPAGANDA'))),
      GoRoute(
          path: '/pin', builder: (_, __) => const Scaffold(body: Text('PIN'))),
    ],
  );
}

Future<void> _montar(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final preferencias = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
      child: MaterialApp.router(routerConfig: await _roteador()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('avanca automaticamente para a propaganda apos o timer',
      (tester) async {
    await _montar(tester);
    expect(find.byType(PaginaSplash), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(find.text('PROPAGANDA'), findsOneWidget);
  });

  testWidgets('toque simples tambem avanca', (tester) async {
    await _montar(tester);
    await tester.tap(find.byType(PaginaSplash));
    await tester.pump();
    await tester.pump();
    expect(find.text('PROPAGANDA'), findsOneWidget);
  });

  testWidgets('toque longo de 3s no logo abre o PIN', (tester) async {
    await _montar(tester);
    final gesto = await tester
        .startGesture(tester.getCenter(find.byType(DetectorToqueLongo)));
    await tester.pump(const Duration(milliseconds: 3200));
    await gesto.up();
    await tester.pump();
    await tester.pump();
    expect(find.text('PIN'), findsOneWidget);
  });
}
