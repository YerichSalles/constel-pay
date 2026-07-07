import 'package:flutter/material.dart';

import '../../aplicativo/tema/cores_app.dart';

class EstadoVazio extends StatelessWidget {
  const EstadoVazio(
      {super.key,
      required this.emoji,
      required this.titulo,
      this.mensagem,
      this.acao});

  final String emoji;
  final String titulo;
  final String? mensagem;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(titulo,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            if (mensagem != null) ...[
              const SizedBox(height: 6),
              Text(
                mensagem!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: CoresApp.textoSecundario,
                    fontWeight: FontWeight.w500),
              ),
            ],
            if (acao != null) ...[const SizedBox(height: 18), acao!],
          ],
        ),
      ),
    );
  }
}
