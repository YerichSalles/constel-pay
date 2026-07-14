import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/aplicativo/tema/controlador_tema.dart';
import 'package:constel_pay/compartilhado/widgets/detector_toque_longo.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:constel_pay/funcionalidades/splash/apresentacao/paginas/pagina_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ControladorTemaFixo extends ControladorTema {
  _ControladorTemaFixo(super.repositorio, TemaPersonalizado tema) {
    state = tema;
  }
}

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

Future<void> _montar(WidgetTester tester, {String? corPrimaria}) async {
  SharedPreferences.setMockInitialValues({});
  final preferencias = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        provedorSharedPreferences.overrideWithValue(preferencias),
        if (corPrimaria != null)
          provedorTema.overrideWith(
            (ref) => _ControladorTemaFixo(
              ref.watch(provedorRepositorioTema),
              TemaPersonalizado(corPrimaria: corPrimaria),
            ),
          ),
      ],
      child: MaterialApp.router(routerConfig: await _roteador()),
    ),
  );
  await tester.pump();
}

Color? _corDoTexto(WidgetTester tester, String texto) =>
    tester.widget<Text>(find.text(texto)).style?.color;

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

  testWidgets('usa barra de carregamento fina no lugar do spinner',
      (tester) async {
    await _montar(tester);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
  });

  testWidgets('fundo escuro usa textos claros', (tester) async {
    await _montar(tester, corPrimaria: '#1B1B2F');
    await tester.pump(const Duration(milliseconds: 700));
    expect(_corDoTexto(tester, 'Terminal de AutoPagamento')?.a, lessThan(1.0));
    expect(
        tester
            .widget<Text>(find.text('Terminal de AutoPagamento'))
            .style
            ?.color
            ?.computeLuminance(),
        greaterThan(.5));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
  });

  testWidgets('fundo claro usa textos escuros', (tester) async {
    await _montar(tester, corPrimaria: '#F2F2F2');
    await tester.pump(const Duration(milliseconds: 700));
    expect(_corDoTexto(tester, 'Terminal de AutoPagamento')?.computeLuminance(),
        lessThan(.5));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
  });

  testWidgets('cor saturada escura mantem texto claro', (tester) async {
    await _montar(tester, corPrimaria: '#E91E63');
    await tester.pump(const Duration(milliseconds: 700));
    expect(_corDoTexto(tester, 'Terminal de AutoPagamento')?.computeLuminance(),
        greaterThan(.5));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
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
