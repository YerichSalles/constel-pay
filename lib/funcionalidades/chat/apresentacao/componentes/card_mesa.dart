import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../nucleo/formatadores/formatador_data.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../leitura_cartao/dominio/entidades/mesa.dart';

class CardMesa extends StatelessWidget {
  const CardMesa({super.key, required this.mesa});

  final Mesa mesa;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Cartao(
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: CoresApp.lilasClaro,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text('🪑', style: TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mesa ${mesa.numero}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(
                      'Aberta às ${FormatadorData.hora(mesa.abertoEm)} · ${mesa.totalComandas} comandas',
                      style: const TextStyle(
                          fontSize: 12.5,
                          color: CoresApp.textoSecundario,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: CoresApp.lilasClaro,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  mesa.status == StatusMesa.aberta ? 'ABERTA' : 'FECHADA',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primaria),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: CoresApp.bordaCard),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Total consumido',
                  style: TextStyle(
                      fontSize: 12.5,
                      color: CoresApp.textoSecundario,
                      fontWeight: FontWeight.w600)),
              Text(
                FormatadorMoeda.formatar(mesa.totalCentavos),
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: primaria),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
