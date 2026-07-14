import 'dart:io';

import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_diagnostico.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interface de rede falsa para exercitar a escolha do IP sem depender dos
/// adaptadores reais da máquina de teste.
class _InterfaceFake implements NetworkInterface {
  _InterfaceFake(this.name, List<String> ips)
      : addresses = [for (final ip in ips) InternetAddress(ip)];

  @override
  final String name;

  @override
  final List<InternetAddress> addresses;

  @override
  int get index => 0;
}

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

  group('escolherIpPreferido', () {
    test('pula o vEthernet do Hyper-V mesmo vindo primeiro na lista', () {
      // Cenário real da máquina da loja (print do ipconfig): o adaptador
      // virtual do Default Switch aparece antes do Ethernet físico.
      final interfaces = [
        _InterfaceFake('vEthernet (Default Switch)', ['172.19.160.1']),
        _InterfaceFake('Ethernet', ['192.168.0.4']),
      ];
      expect(escolherIpPreferido(interfaces), '192.168.0.4');
    });

    test('endereco real vence APIPA (169.254.x) de outro adaptador', () {
      final interfaces = [
        _InterfaceFake('Ethernet', ['169.254.10.7']),
        _InterfaceFake('Wi-Fi', ['10.0.0.12']),
      ];
      expect(escolherIpPreferido(interfaces), '10.0.0.12');
    });

    test('so adaptador virtual disponivel: usa ele como ultimo recurso', () {
      final interfaces = [
        _InterfaceFake('vEthernet (WSL)', ['172.22.0.1']),
      ];
      expect(escolherIpPreferido(interfaces), '172.22.0.1');
    });

    test('sem interface utilizavel devolve null', () {
      expect(escolherIpPreferido([]), isNull);
    });
  });
}
