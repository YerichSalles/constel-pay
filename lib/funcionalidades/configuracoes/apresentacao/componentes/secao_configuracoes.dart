import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';

/// Card de grupo das abas de Configurações: título, descrição curta opcional,
/// ação opcional no cabeçalho (ex.: interruptor) e o conteúdo do grupo, com o
/// mesmo acabamento dos cards do app.
class SecaoConfiguracoes extends StatelessWidget {
  const SecaoConfiguracoes({
    super.key,
    required this.titulo,
    this.descricao,
    this.acao,
    this.filho,
  });

  final String titulo;
  final String? descricao;

  /// Widget alinhado à direita do cabeçalho, na mesma linha do título.
  final Widget? acao;

  /// Conteúdo do card; opcional para cards só de cabeçalho (título + ação).
  final Widget? filho;

  @override
  Widget build(BuildContext context) {
    final cabecalho = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        if (descricao != null) ...[
          const SizedBox(height: 2),
          Text(
            descricao!,
            style: const TextStyle(
                fontSize: 11.5, color: CoresApp.textoSecundario),
          ),
        ],
      ],
    );
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
          if (acao == null)
            cabecalho
          else
            Row(
              children: [
                Expanded(child: cabecalho),
                const SizedBox(width: 12),
                // Align expande na fatia do Flexible e encosta a ação na
                // borda direita; sem ele a sobra da Row fica DEPOIS da ação
                // (Switch pararia no meio do card).
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: acao!,
                  ),
                ),
              ],
            ),
          if (filho != null) ...[
            const SizedBox(height: 14),
            filho!,
          ],
        ],
      ),
    );
  }
}
