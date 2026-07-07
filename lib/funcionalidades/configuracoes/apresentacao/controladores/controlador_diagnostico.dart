import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../nucleo/configuracao/ambiente.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/utils/registrador.dart';
import '../../dominio/casos_uso/caso_uso_testar_conexao.dart';
import '../../dominio/repositorios/repositorio_configuracao.dart';

part 'controlador_diagnostico.freezed.dart';

@freezed
class EstadoDiagnostico with _$EstadoDiagnostico {
  const factory EstadoDiagnostico({
    @Default('—') String versaoApp,
    @Default('não disponível (mock)') String versaoApi,
    @Default('') String ambienteRotulo,
    @Default('') String identificador,
    @Default('—') String ip,
    @Default(false) bool conectado,
    DateTime? ultimaSincronizacao,
    @Default(false) bool testando,
    String? mensagem,
    @Default(false) bool mensagemErro,
  }) = _EstadoDiagnostico;
}

Future<String> _versaoAppPadrao() async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
}

Future<String> _ipPadrao() async {
  try {
    final interfaces =
        await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final interface in interfaces) {
      for (final endereco in interface.addresses) {
        if (!endereco.isLoopback) return endereco.address;
      }
    }
  } catch (_) {}
  return '—';
}

Stream<bool> _conectividadePadrao() => Connectivity()
    .onConnectivityChanged
    .map((resultados) => !resultados.contains(ConnectivityResult.none));

class ControladorDiagnostico extends StateNotifier<EstadoDiagnostico> {
  ControladorDiagnostico({
    required RepositorioConfiguracao repositorioConfiguracao,
    required CasoUsoTestarConexao casoUsoTestarConexao,
    required SharedPreferences preferencias,
    Future<String> Function()? obterVersaoApp,
    Future<String> Function()? obterIp,
    Stream<bool>? fluxoConectividade,
  })  : _repositorioConfiguracao = repositorioConfiguracao,
        _casoUsoTestarConexao = casoUsoTestarConexao,
        _preferencias = preferencias,
        _obterVersaoApp = obterVersaoApp ?? _versaoAppPadrao,
        _obterIp = obterIp ?? _ipPadrao,
        super(const EstadoDiagnostico()) {
    _assinatura = (fluxoConectividade ?? _conectividadePadrao())
        .listen((conectado) => state = state.copyWith(conectado: conectado));
  }

  final RepositorioConfiguracao _repositorioConfiguracao;
  final CasoUsoTestarConexao _casoUsoTestarConexao;
  final SharedPreferences _preferencias;
  final Future<String> Function() _obterVersaoApp;
  final Future<String> Function() _obterIp;
  late final StreamSubscription<bool> _assinatura;

  @override
  void dispose() {
    _assinatura.cancel();
    super.dispose();
  }

  Future<void> carregar() async {
    final configuracao = await _repositorioConfiguracao.obter();
    final versao = await _obterVersaoApp();
    final ip = await _obterIp();
    final sincronizacaoTexto =
        _preferencias.getString(ConstantesApp.chaveUltimaSincronizacao);
    state = state.copyWith(
      versaoApp: versao,
      ambienteRotulo: configuracao.ambiente.rotulo,
      identificador: configuracao.identificadorDispositivo,
      ip: ip,
      ultimaSincronizacao: sincronizacaoTexto != null
          ? DateTime.tryParse(sincronizacaoTexto)
          : null,
    );
  }

  Future<void> testarApi() async {
    state = state.copyWith(testando: true, mensagem: null);
    final resultado = await _casoUsoTestarConexao.executar();
    state = resultado.quando(
      sucesso: (momento) => state.copyWith(
          testando: false,
          ultimaSincronizacao: momento,
          mensagem: 'API respondeu com sucesso.',
          mensagemErro: false),
      erro: (falha) => state.copyWith(
          testando: false, mensagem: falha.mensagem, mensagemErro: true),
    );
  }

  Future<String?> exportarLogs(
      [Future<String> Function()? obterDiretorio]) async {
    try {
      final diretorio = obterDiretorio != null
          ? await obterDiretorio()
          : (await getApplicationDocumentsDirectory()).path;
      final arquivo = File(
          '$diretorio${Platform.pathSeparator}constel-pay-logs-${DateTime.now().millisecondsSinceEpoch}.txt');
      await arquivo.writeAsString(saidaMemoria.linhas.join('\n'));
      state = state.copyWith(
          mensagem: 'Logs exportados: ${arquivo.path}', mensagemErro: false);
      return arquivo.path;
    } catch (_) {
      state = state.copyWith(
          mensagem: 'Não foi possível exportar os logs.', mensagemErro: true);
      return null;
    }
  }

  Future<void> limparDadosLocais(FlutterSecureStorage armazenamento) async {
    await _preferencias.clear();
    await armazenamento.deleteAll();
    registrador.i('Dados locais limpos pelo operador');
  }
}

final provedorDiagnostico = StateNotifierProvider.autoDispose<
    ControladorDiagnostico, EstadoDiagnostico>((ref) {
  final controlador = ControladorDiagnostico(
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    casoUsoTestarConexao: ref.watch(provedorCasoUsoTestarConexao),
    preferencias: ref.watch(provedorSharedPreferences),
  );
  controlador.carregar();
  return controlador;
});
