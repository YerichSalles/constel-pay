import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/imagem_logo.dart';
import '../../../../l10n/app_localizations.dart';

class BannerBoasVindas extends ConsumerWidget {
  const BannerBoasVindas({super.key, required this.nomeRestaurante});

  final String nomeRestaurante;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoPath = ref.watch(provedorTema).logoPath;
    final temLogo = logoPath != null && File(logoPath).existsSync();
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 18),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              gradient: temLogo
                  ? null
                  : const LinearGradient(
                      colors: [CoresApp.lilasBolha, CoresApp.lilasClaro],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: .18),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: temLogo
                ? ImagemLogo(
                    caminho: logoPath,
                    reserva: const Text('🍽️', style: TextStyle(fontSize: 40)),
                  )
                : const Text('🍽️', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 10),
          Text(nomeRestaurante,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            t.selfCheckoutSubtitle,
            style: const TextStyle(
                fontSize: 12.5, color: CoresApp.textoSecundario),
          ),
        ],
      ),
    );
  }
}
