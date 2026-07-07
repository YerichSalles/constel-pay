import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../pagamento/dominio/entidades/dados_pix.dart';

class CardPix extends StatelessWidget {
  const CardPix({
    super.key,
    required this.dadosPix,
    required this.copiado,
    required this.aoCopiar,
    required this.aoConfirmar,
    this.habilitado = true,
  });

  final DadosPix dadosPix;
  final bool copiado;
  final VoidCallback aoCopiar;
  final VoidCallback aoConfirmar;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Cartao(
      preenchimento: const EdgeInsets.all(18),
      filho: Column(
        children: [
          const Text('Pague com Pix',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(
            FormatadorMoeda.formatar(dadosPix.valorCentavos),
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: primaria),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEBF1)),
            ),
            child: QrImageView(data: dadosPix.copiaCola, size: 172),
          ),
          const SizedBox(height: 6),
          const Text('Válido por 5 minutos',
              style: TextStyle(
                  fontSize: 11.5,
                  color: CoresApp.textoSecundario,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Material(
            color: CoresApp.lilasClaro,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: aoCopiar,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  copiado ? 'Código copiado ✓' : '📋 Copiar código Pix',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: primaria),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          BotaoPrimario(
            rotulo: 'Já fiz o pagamento',
            aoTocar: habilitado ? aoConfirmar : null,
          ),
        ],
      ),
    );
  }
}
