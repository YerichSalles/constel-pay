import 'package:flutter/material.dart';

import '../../aplicativo/tema/cores_app.dart';

class IndicadorCarregamento extends StatelessWidget {
  const IndicadorCarregamento({super.key, this.mensagem});

  final String? mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (mensagem != null) ...[
            const SizedBox(height: 14),
            Text(
              mensagem!,
              style: const TextStyle(
                  color: CoresApp.textoSecundario, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
