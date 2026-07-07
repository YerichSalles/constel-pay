import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';

class BannerBoasVindas extends StatelessWidget {
  const BannerBoasVindas({super.key, required this.nomeRestaurante});

  final String nomeRestaurante;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 18),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
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
            alignment: Alignment.center,
            child: const Text('🍽️', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 10),
          Text(nomeRestaurante,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          const Text(
            'Autoatendimento · Pagamento na mesa',
            style: TextStyle(fontSize: 12.5, color: CoresApp.textoSecundario),
          ),
        ],
      ),
    );
  }
}
