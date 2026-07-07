import 'dart:io';

import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_diagnostico.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/casos_uso/caso_uso_testar_conexao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/nucleo/configuracao/cliente_api.dart';
import 'package:constel_pay/nucleo/utils/registrador.dart';
import 'package:dio/dio.dart';
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
      casoUsoTestarConexao: CasoUsoTestarConexao(
        clienteApi:
            ClienteApi(repositorioConfiguracao: repositorio, dio: Dio()),
        repositorioConfiguracao: repositorio,
        preferencias: preferencias,
      ),
      preferencias: preferencias,
      obterVersaoApp: () async => '1.0.0+1',
      obterIp: () async => '192.168.1.50',
      fluxoConectividade: Stream<bool>.value(true),
    );
    await controlador.carregar();
    return controlador;
  }

  test('carregar preenche versao, ip, identificador, ambiente e sincronizacao',
      () async {
    final controlador = await criar();
    final estado = controlador.state;
    expect(estado.versaoApp, '1.0.0+1');
    expect(estado.ip, '192.168.1.50');
    expect(estado.identificador, 'TOTEM-07');
    expect(estado.ambienteRotulo, 'Homologação');
    expect(estado.ultimaSincronizacao, DateTime(2026, 7, 6, 10));
    expect(estado.versaoApi, contains('mock'));
  });

  test('testarApi sem URL valida marca mensagem de erro', () async {
    final controlador = await criar();
    await controlador.testarApi();
    expect(controlador.state.mensagemErro, isTrue);
  });

  test('exportarLogs grava arquivo com as linhas do registrador', () async {
    final controlador = await criar();
    registrador.i('linha de teste do diagnostico');
    final diretorio = Directory.systemTemp.createTempSync('constel_logs');
    final caminho = await controlador.exportarLogs(() async => diretorio.path);
    expect(caminho, isNotNull);
    final conteudo = File(caminho!).readAsStringSync();
    expect(conteudo, contains('linha de teste do diagnostico'));
  });
}
