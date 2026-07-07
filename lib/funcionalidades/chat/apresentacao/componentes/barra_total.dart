import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';

class BarraTotal extends StatelessWidget {
  const BarraTotal(
      {super.key, required this.rotulo, required this.valorCentavos});

  final String rotulo;
  final int valorCentavos;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: CoresApp.lilasClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rotulo,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: primaria)),
          Text(
            FormatadorMoeda.formatar(valorCentavos),
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: primaria),
          ),
        ],
      ),
    );
  }
}
