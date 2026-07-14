import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../nucleo/utils/contraste.dart';

const Color _ambarAtencao = Color(0xFFB26A00);

/// Mostra a razão de contraste entre o fundo e o texto da faixa em três
/// níveis, com ícone e texto — nunca só cor. Orienta o operador sem
/// bloquear o salvamento.
class IndicadorContraste extends StatelessWidget {
  const IndicadorContraste({
    super.key,
    required this.corFundo,
    required this.corTexto,
  });

  final Color corFundo;
  final Color corTexto;

  @override
  Widget build(BuildContext context) {
    final razao = razaoDeContraste(corFundo, corTexto);
    final nivel = nivelDeContraste(razao);
    final razaoTexto = '${razao.toStringAsFixed(1).replaceAll('.', ',')}:1';

    final (icone, cor, titulo) = switch (nivel) {
      NivelContraste.adequado => (
          Icons.check_circle_outline,
          CoresApp.sucesso,
          'Boa legibilidade',
        ),
      NivelContraste.atencao => (
          Icons.info_outline,
          _ambarAtencao,
          'Adequado para textos grandes',
        ),
      NivelContraste.insuficiente => (
          Icons.warning_amber_outlined,
          CoresApp.erro,
          'Contraste baixo',
        ),
    };

    return Container(
      key: const Key('indicador_contraste'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 18, color: cor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700, color: cor),
                ),
              ),
              Text(
                'Contraste: $razaoTexto',
                style: TextStyle(fontSize: 12, color: cor),
              ),
            ],
          ),
          if (nivel == NivelContraste.insuficiente) ...[
            const SizedBox(height: 6),
            const Text(
              'Recomendamos escurecer a faixa ou utilizar uma cor de texto '
              'mais contrastante.',
              style: TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
            ),
          ],
        ],
      ),
    );
  }
}
