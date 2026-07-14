import 'package:flutter/material.dart';

class ChipAcao extends StatelessWidget {
  const ChipAcao(
      {super.key,
      required this.rotulo,
      required this.aoTocar,
      this.primario = false,
      this.discreto = false});

  final String rotulo;
  final VoidCallback aoTocar;
  final bool primario;

  /// Ação de baixa prioridade (ex.: desistir da inclusão): sem fundo,
  /// sem borda e sem sombra, só o texto na cor primária.
  final bool discreto;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Material(
      color: primario
          ? primaria
          : discreto
              ? Colors.transparent
              : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: primario || discreto
                ? null
                : Border.all(
                    color: primaria.withValues(alpha: .4), width: 1.5),
            boxShadow: primario
                ? [
                    BoxShadow(
                        color: primaria.withValues(alpha: .35),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ]
                : null,
          ),
          child: Text(
            rotulo,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: discreto ? FontWeight.w700 : FontWeight.w800,
              color: primario ? Colors.white : primaria,
            ),
          ),
        ),
      ),
    );
  }
}
