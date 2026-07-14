import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_diagnostico.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ControladorDiagnostico> criar() async {
    SharedPreferences.setMockInitialValues(
        {'ultima_sincronizacao': '2026-07-06T10:00:00.000'});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioConfiguracaoImpl(preferencias);
    await repositorio.salvar(
        const ConfiguracaoTerminal(identificadorDispositivo: 'TOTEM-07'));
    final controlador = ControladorDiagnostico(
      repositorioConfiguracao: repositorio,
      preferencias: preferencias,
      obterVersaoApp: () async => '1.0.0+1',
      obterIp: () async => '192.168.1.50',
    );
    await controlador.carregar();
    return controlador;
  }

  test('carregar preenche versao, ambiente, ip e sincronizacao', () async {
    final controlador = await criar();
    final estado = controlador.state;
    expect(estado.versaoApp, '1.0.0+1');
    expect(estado.ambienteRotulo, 'Homologação');
    expect(estado.ip, '192.168.1.50');
    expect(estado.ultimaSincronizacao, DateTime(2026, 7, 6, 10));
  });

  test('sem sincronizacao gravada o estado fica nulo (tela mostra "nunca")',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioConfiguracaoImpl(preferencias);
    final controlador = ControladorDiagnostico(
      repositorioConfiguracao: repositorio,
      preferencias: preferencias,
      obterVersaoApp: () async => '1.0.0+1',
      obterIp: () async => '192.168.1.50',
    );
    await controlador.carregar();
    expect(controlador.state.ultimaSincronizacao, isNull);
  });
}
