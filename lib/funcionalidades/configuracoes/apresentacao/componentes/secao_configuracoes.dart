import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';

/// Card de grupo das abas de Configurações: título, descrição curta opcional
/// e o conteúdo do grupo, com o mesmo acabamento dos cards do app.
class SecaoConfiguracoes extends StatelessWidget {
  const SecaoConfiguracoes({
    super.key,
    required this.titulo,
    this.descricao,
    required this.filho,
  });

  final String titulo;
  final String? descricao;
  final Widget filho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CoresApp.bordaCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          if (descricao != null) ...[
            const SizedBox(height: 2),
            Text(
              descricao!,
              style: const TextStyle(
                  fontSize: 11.5, color: CoresApp.textoSecundario),
            ),
          ],
          const SizedBox(height: 14),
          filho,
        ],
      ),
    );
  }
}
