import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/controladores/controlador_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dados/repositorios/repositorio_propaganda_impl.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('controlador carrega midias ativas e avanca circularmente', () async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioPropagandaImpl(preferencias);
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a', tipo: TipoMidia.imagem, caminho: '/x/a.png', ordem: 1),
      MidiaPropaganda(
          id: 'b', tipo: TipoMidia.imagem, caminho: '/x/b.png', ordem: 2),
    ]);
    final controlador = ControladorPropaganda(repositorio);
    await controlador.carregar();
    expect(controlador.state.midias, hasLength(2));
    expect(controlador.state.midiaAtual?.id, 'a');
    controlador.avancar();
    expect(controlador.state.midiaAtual?.id, 'b');
    controlador.avancar();
    expect(controlador.state.midiaAtual?.id, 'a');
  });

  testWidgets('sem midias mostra CTA e navega para o chat ao tocar',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final roteador = GoRouter(
      initialLocation: '/propaganda',
      routes: [
        GoRoute(
            path: '/propaganda', builder: (_, __) => const PaginaPropaganda()),
        GoRoute(
            path: '/chat',
            builder: (_, __) => const Scaffold(body: Text('CHAT'))),
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
    expect(find.text('Toque para pagar'), findsOneWidget);
    expect(find.text('Escaneie'), findsOneWidget);
    await tester.tap(find.text('Toque para pagar'));
    await tester.pump();
    await tester.pump();
    expect(find.text('CHAT'), findsOneWidget);
  });
}
