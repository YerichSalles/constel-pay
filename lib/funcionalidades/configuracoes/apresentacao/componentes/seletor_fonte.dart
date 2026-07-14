import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/estilos_texto.dart';

class SeletorFonte extends StatelessWidget {
  const SeletorFonte({
    super.key,
    required this.valor,
    required this.aoMudar,
    this.textoPrevia,
  });

  final String valor;
  final void Function(String fonte) aoMudar;

  /// Frase mostrada como prévia na fonte selecionada. Nada aparece quando
  /// nulo.
  final String? textoPrevia;

  @override
  Widget build(BuildContext context) {
    final atual = EstilosTexto.fontesDisponiveis.contains(valor)
        ? valor
        : EstilosTexto.fontePadrao;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fonte',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: atual,
              isExpanded: true,
              items: [
                for (final fonte in EstilosTexto.fontesDisponiveis)
                  DropdownMenuItem<String>(
                    value: fonte,
                    child: Text(
                      fonte,
                      style: EstilosTexto.estilo(
                          fonte, const TextStyle(fontSize: 15)),
                    ),
                  ),
              ],
              onChanged: (nova) {
                if (nova != null) aoMudar(nova);
              },
            ),
          ),
        ),
        if (textoPrevia != null) ...[
          const SizedBox(height: 8),
          Text(
            textoPrevia!,
            overflow: TextOverflow.ellipsis,
            style: EstilosTexto.estilo(
              atual,
              const TextStyle(fontSize: 13, color: CoresApp.textoSecundario),
            ),
          ),
        ],
      ],
    );
  }
}
