import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';

class CardSucesso extends StatelessWidget {
  const CardSucesso(
      {super.key, required this.valorCentavos, required this.comandas});

  final int valorCentavos;
  final List<String> comandas;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF4F1FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDD5FB)),
        boxShadow: [
          BoxShadow(
              color: primaria.withValues(alpha: .18),
              blurRadius: 30,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (contexto, escala, filho) =>
                Transform.scale(scale: escala, child: filho),
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [primaria.withValues(alpha: .85), primaria]),
                boxShadow: [
                  BoxShadow(
                      color: primaria.withValues(alpha: .4),
                      blurRadius: 24,
                      offset: const Offset(0, 10)),
                ],
              ),
              alignment: Alignment.center,
              child: const Text('✓',
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Pagamento aprovado! 🎉',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            FormatadorMoeda.formatar(valorCentavos),
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, color: primaria),
          ),
          const SizedBox(height: 12),
          const Text('COMANDAS QUITADAS',
              style: TextStyle(
                  fontSize: 11,
                  color: CoresApp.textoSecundario,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .4)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: comandas
                .map(
                  (nome) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: CoresApp.lilasClaro,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('✓ $nome',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primaria)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
