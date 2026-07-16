import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../compartilhado/widgets/icone_emoji.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/formatadores/formatador_data.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';

class CardComprovante extends StatelessWidget {
  const CardComprovante({
    super.key,
    required this.valorCentavos,
    required this.metodoNome,
    required this.comandas,
    required this.dataHora,
    required this.nomeRestaurante,
    required this.comprovanteId,
  });

  final int valorCentavos;
  final String metodoNome;
  final List<String> comandas;
  final DateTime dataHora;
  final String nomeRestaurante;
  final String comprovanteId;

  Widget _linha(String rotulo, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rotulo,
                style: const TextStyle(
                    fontSize: 12.5,
                    color: CoresApp.textoSecundario,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(valor,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    final t = AppLocalizations.of(context);
    return Cartao(
      preenchimento: const EdgeInsets.all(18),
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: IconeEmoji('🧾', tamanho: 36)),
          const SizedBox(height: 6),
          Center(
            child: Text(t.receiptTitle,
                style: const TextStyle(
                    fontSize: 14.5, fontWeight: FontWeight.w800)),
          ),
          Center(
            child: Text(nomeRestaurante,
                style: const TextStyle(
                    fontSize: 12.5,
                    color: CoresApp.textoSecundario,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: CoresApp.bordaCard),
          const SizedBox(height: 8),
          _linha(t.dateTimeLabel, FormatadorData.dataHora(dataHora)),
          _linha(t.ordersLabel, comandas.join(', ')),
          _linha(t.paymentMethodLabel, metodoNome),
          _linha(t.identifierLabel, comprovanteId),
          const SizedBox(height: 8),
          Container(height: 1, color: CoresApp.bordaCard),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.amountPaidLabel,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              Text(
                FormatadorMoeda.formatar(valorCentavos),
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: primaria),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
