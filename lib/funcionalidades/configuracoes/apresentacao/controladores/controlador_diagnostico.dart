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

/// Nomes (em minúsculas) de adaptadores virtuais que não representam a rede
/// da loja: Hyper-V/WSL criam um "vEthernet (Default Switch)" que costuma
/// vir ANTES do adaptador físico na enumeração do Windows.
const List<String> _nomesAdaptadoresVirtuais = [
  'vethernet',
  'default switch',
  'wsl',
  'hyper-v',
  'virtualbox',
  'vmware',
  'docker',
  'loopback',
  'tap',
  'tun',
  'zerotier',
  'tailscale',
];

/// Escolhe o IPv4 mais provável da rede local real: adaptador físico vence
/// virtual e endereço de rede vence APIPA (169.254.x, auto-atribuído quando
/// o DHCP falhou). O virtual só sai como último recurso.
@visibleForTesting
String? escolherIpPreferido(List<NetworkInterface> interfaces) {
  String? melhor;
  var melhorPontuacao = -1;
  for (final interface in interfaces) {
    final nome = interface.name.toLowerCase();
    final virtual = _nomesAdaptadoresVirtuais.any(nome.contains);
    for (final endereco in interface.addresses) {
      if (endereco.isLoopback) continue;
      final apipa = endereco.address.startsWith('169.254.');
      final pontuacao = (virtual ? 0 : 2) + (apipa ? 0 : 1);
      if (pontuacao > melhorPontuacao) {
        melhorPontuacao = pontuacao;
        melhor = endereco.address;
      }
    }
  }
  return melhor;
}

Future<String> _ipPadrao() async {
  try {
    final interfaces =
        await NetworkInterface.list(type: InternetAddressType.IPv4);
    return escolherIpPreferido(interfaces) ?? '—';
  } catch (_) {
    return '—';
  }
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

  /// Limpa tudo, EXCETO as chaves protegidas (registros transacionais):
  /// apagar uma transação pendente entre a criação da fatura e a ação 30
  /// deixaria fatura órfã no retaguarda sem recuperação local.
  Future<void> limparDadosLocais(FlutterSecureStorage armazenamento) async {
    final protegidos = {
      for (final chave in ConstantesApp.chavesProtegidasNaLimpeza)
        if (_preferencias.getString(chave) case final String valor
            when valor.isNotEmpty)
          chave: valor,
    };
    await _preferencias.clear();
    for (final entrada in protegidos.entries) {
      await _preferencias.setString(entrada.key, entrada.value);
    }
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
