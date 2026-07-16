import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aplicativo/constel_pay_app.dart';
import 'aplicativo/injecao.dart';
import 'aplicativo/rotas.dart';
import 'nucleo/configuracao/confianca_tls_stub.dart'
    if (dart.library.io) 'nucleo/configuracao/confianca_tls_io.dart';
import 'nucleo/janela/servico_janela_totem.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Aceita qualquer certificado TLS em todo o app (API na nuvem e fotos dos
  // itens no S3), para funcionar em PCs sem as raizes no repositorio.
  instalarConfiancaTlsGlobal();
  // Modo totem: janela em tela cheia sem controles no Windows; imersivo no
  // Android. Aplicado antes de exibir a UI para nao piscar a janela normal.
  await ServicoJanelaTotem.iniciar();
  // O terminal opera em pe: as telas e as midias sao pensadas em retrato.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final preferencias = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
  );
  await container.read(provedorTema.notifier).carregar();
  final roteador = criarRoteador(localInicial: '/splash');
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: ConstelPayApp(roteador: roteador),
    ),
  );
}
