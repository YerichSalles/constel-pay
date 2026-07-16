import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'aplicativo/constel_pay_app.dart';
import 'aplicativo/injecao.dart';
import 'aplicativo/rotas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
