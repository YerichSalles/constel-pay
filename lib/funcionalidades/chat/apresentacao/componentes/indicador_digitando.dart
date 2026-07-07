import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import 'avatar_bot.dart';

class IndicadorDigitando extends StatefulWidget {
  const IndicadorDigitando({super.key});

  @override
  State<IndicadorDigitando> createState() => _IndicadorDigitandoState();
}

class _IndicadorDigitandoState extends State<IndicadorDigitando>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AvatarBot(),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CoresApp.textoPrincipal.withValues(alpha: .06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _controlador,
            builder: (contexto, _) => Row(
              children: List.generate(3, (indice) {
                final fase = (_controlador.value * 3 - indice).clamp(0.0, 1.0);
                final opacidade =
                    0.3 + 0.7 * (1 - (fase - 0.5).abs() * 2).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Opacity(
                    opacity: opacidade,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: CoresApp.textoSecundario,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
