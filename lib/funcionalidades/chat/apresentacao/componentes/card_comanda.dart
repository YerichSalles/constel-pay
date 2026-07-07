import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../leitura_cartao/dominio/entidades/cartao_consumo.dart';

class CardComanda extends StatelessWidget {
  const CardComanda({super.key, required this.cartao, this.aoVerItens});

  final CartaoConsumo cartao;
  final void Function(String comandaId)? aoVerItens;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    final marcado = cartao.selecionado || cartao.pago;
    return Opacity(
      opacity: cartao.pago ? .6 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cartao.pago ? const Color(0xFFF6F6F8) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: marcado && !cartao.pago ? primaria : CoresApp.bordaCard,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaria.withValues(
                  alpha: marcado && !cartao.pago ? .2 : .05),
              blurRadius: marcado ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: marcado ? primaria : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: marcado ? primaria : const Color(0xFFDCDBE1),
                    width: 2),
              ),
              alignment: Alignment.center,
              child: marcado
                  ? const Text('✓',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800))
                  : null,
            ),
            const SizedBox(width: 11),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: CoresApp.lilasClaro,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Text(cartao.emoji, style: const TextStyle(fontSize: 25)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: cartao.nome,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: CoresApp.textoPrincipal),
                      children: [
                        TextSpan(
                          text: ' · ${cartao.pessoa}',
                          style: const TextStyle(
                              color: CoresApp.textoSecundario,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cartao.pago ? 'Pago ✓' : cartao.resumo,
                    style: const TextStyle(
                        fontSize: 12,
                        color: CoresApp.textoSecundario,
                        fontWeight: FontWeight.w600),
                  ),
                  if (aoVerItens != null)
                    GestureDetector(
                      onTap: () => aoVerItens!(cartao.id),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          '👁️ ver itens',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaria),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              FormatadorMoeda.formatar(cartao.subtotalCentavos),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
