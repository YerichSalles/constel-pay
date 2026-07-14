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
    AjusteMidia.encaixar: 'Encaixar (mostra tudo)',
    AjusteMidia.esticar: 'Esticar (distorce)',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: const Text('Ajuste:',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style:
                  TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario)),
        ),
        const SizedBox(width: 6),
        Flexible(
          // IntrinsicWidth mede a largura que o dropdown realmente precisa e
          // a usa como teto: com espaco sobrando ele fica do tamanho do
          // conteudo (visual identico ao anterior); apertado, encolhe ate o
          // limite oferecido pelo Row em vez de estourar.
          child: IntrinsicWidth(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AjusteMidia>(
                value: valor,
                isDense: true,
                isExpanded: true,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: CoresApp.textoPrincipal,
                ),
                items: [
                  for (final entrada in rotulos.entries)
                    DropdownMenuItem<AjusteMidia>(
                      value: entrada.key,
                      child: Text(entrada.value,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ),
                ],
                onChanged: (novo) {
                  if (novo != null) aoMudar(novo);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
