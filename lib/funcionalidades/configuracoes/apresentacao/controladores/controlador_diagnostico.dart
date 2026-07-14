import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../nucleo/configuracao/ambiente.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/utils/registrador.dart';
import '../../dominio/repositorios/repositorio_configuracao.dart';

part 'controlador_diagnostico.freezed.dart';

@freezed
class EstadoDiagnostico with _$EstadoDiagnostico {
  const factory EstadoDiagnostico({
    @Default('—') String versaoApp,
    @Default('') String ambienteRotulo,
    @Default('—') String ip,
    DateTime? ultimaSincronizacao,
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

class ControladorDiagnostico extends StateNotifier<EstadoDiagnostico> {
  ControladorDiagnostico({
    required RepositorioConfiguracao repositorioConfiguracao,
    required SharedPreferences preferencias,
    Future<String> Function()? obterVersaoApp,
    Future<String> Function()? obterIp,
  })  : _repositorioConfiguracao = repositorioConfiguracao,
        _preferencias = preferencias,
        _obterVersaoApp = obterVersaoApp ?? _versaoAppPadrao,
        _obterIp = obterIp ?? _ipPadrao,
        super(const EstadoDiagnostico());

  final RepositorioConfiguracao _repositorioConfiguracao;
  final SharedPreferences _preferencias;
  final Future<String> Function() _obterVersaoApp;
  final Future<String> Function() _obterIp;

  Future<void> carregar() async {
    final configuracao = await _repositorioConfiguracao.obter();
    final versao = await _obterVersaoApp();
    final ip = await _obterIp();
    final sincronizacaoTexto =
        _preferencias.getString(ConstantesApp.chaveUltimaSincronizacao);
    state = state.copyWith(
      versaoApp: versao,
      ambienteRotulo: configuracao.ambiente.rotulo,
      ip: ip,
      ultimaSincronizacao: sincronizacaoTexto != null
          ? DateTime.tryParse(sincronizacaoTexto)
          : null,
    );
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
    preferencias: ref.watch(provedorSharedPreferences),
  );
  controlador.carregar();
  return controlador;
});
