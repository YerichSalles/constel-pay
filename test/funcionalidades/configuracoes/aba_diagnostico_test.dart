import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/aba_diagnostico.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_diagnostico.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'aba enxuta mostra so versao, ambiente, IP, sincronizacao e limpar dados',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioConfiguracaoImpl(preferencias);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provedorSharedPreferences.overrideWithValue(preferencias),
          // Sem o override, o controlador real chamaria PackageInfo (canal de
          // plataforma) e NetworkInterface (IO real) dentro do teste.
          provedorDiagnostico.overrideWith(
            (ref) => ControladorDiagnostico(
              repositorioConfiguracao: repositorio,
              preferencias: preferencias,
              obterVersaoApp: () async => '1.0.0+1',
              obterIp: () async => '10.0.0.2',
            )..carregar(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: AbaDiagnostico())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Versão do aplicativo'), findsOneWidget);
    expect(find.text('1.0.0+1'), findsOneWidget);
    expect(find.text('Ambiente atual'), findsOneWidget);
    expect(find.text('IP'), findsOneWidget);
    expect(find.text('10.0.0.2'), findsOneWidget);
    expect(find.text('Última sincronização'), findsOneWidget);
    expect(find.text('nunca'), findsOneWidget);
    expect(find.text('Limpar dados locais'), findsOneWidget);

    expect(find.text('Versão da API'), findsNothing);
    expect(find.text('Identificador do dispositivo'), findsNothing);
    expect(find.text('Status da conexão'), findsNothing);
    expect(find.text('Testar API'), findsNothing);
    expect(find.text('Exportar logs'), findsNothing);
  });

  testWidgets('limpar dados abre a confirmacao destrutiva', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioConfiguracaoImpl(preferencias);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provedorSharedPreferences.overrideWithValue(preferencias),
          provedorDiagnostico.overrideWith(
            (ref) => ControladorDiagnostico(
              repositorioConfiguracao: repositorio,
              preferencias: preferencias,
              obterVersaoApp: () async => '1.0.0+1',
              obterIp: () async => '10.0.0.2',
            )..carregar(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: AbaDiagnostico())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Limpar dados locais'));
    await tester.pumpAndSettle();

    expect(find.text('Limpar dados locais?'), findsOneWidget);
    expect(find.text('Apagar tudo'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Limpar dados locais?'), findsNothing,
        reason: 'cancelar fecha o dialogo sem apagar nada');
  });
}
