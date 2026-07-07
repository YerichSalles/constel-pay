import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'injecao.dart';
import 'tema/tema_constel.dart';

class ConstelPayApp extends ConsumerWidget {
  const ConstelPayApp({super.key, required this.roteador});

  final GoRouter roteador;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = ref.watch(provedorTema);
    return MaterialApp.router(
      title: 'Constel Pay',
      debugShowCheckedModeBanner: false,
      theme: TemaConstel.criar(tema),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: roteador,
    );
  }
}
