import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../leitura_cartao/dominio/entidades/cartao_consumo.dart';

class CardDetalheComanda extends StatelessWidget {
  const CardDetalheComanda({super.key, required this.cartao});

  final CartaoConsumo cartao;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Cartao(
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${cartao.nome} · ${cartao.pessoa}',
              style:
                  const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...cartao.itens.map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CoresApp.bordaCard)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CoresApp.fundoPadrao,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child:
                        Text(item.emoji, style: const TextStyle(fontSize: 23)),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.nome,
                            style: const TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.w700)),
                        Text(
                          '${item.quantidade} un · ${FormatadorMoeda.formatar(item.valorCentavos)} cada',
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: CoresApp.textoSecundario,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Text(FormatadorMoeda.formatar(item.totalCentavos),
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total da comanda',
                  style: TextStyle(
                      fontSize: 13,
                      color: CoresApp.textoSecundario,
                      fontWeight: FontWeight.w700)),
              Text(
                FormatadorMoeda.formatar(cartao.subtotalCentavos),
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: primaria),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
