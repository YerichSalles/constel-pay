import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';

class SeletorAjusteMidia extends StatelessWidget {
  const SeletorAjusteMidia({
    super.key,
    required this.valor,
    required this.aoMudar,
  });

  final AjusteMidia valor;
  final void Function(AjusteMidia ajuste) aoMudar;

  static const Map<AjusteMidia, String> rotulos = {
    AjusteMidia.automatico: 'Automático',
    AjusteMidia.preencher: 'Preencher (corta)',
    AjusteMidia.encaixar: 'Encaixar (tarja)',
    AjusteMidia.esticar: 'Esticar (distorce)',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Ajuste:',
            style: TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario)),
        const SizedBox(width: 6),
        DropdownButtonHideUnderline(
          child: DropdownButton<AjusteMidia>(
            value: valor,
            isDense: true,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: CoresApp.textoPrincipal,
            ),
            items: [
              for (final entrada in rotulos.entries)
                DropdownMenuItem<AjusteMidia>(
                  value: entrada.key,
                  child: Text(entrada.value),
                ),
            ],
            onChanged: (novo) {
              if (novo != null) aoMudar(novo);
            },
          ),
        ),
      ],
    );
  }
}
