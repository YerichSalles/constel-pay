import 'package:flutter/material.dart';

class AvatarBot extends StatelessWidget {
  const AvatarBot({super.key, this.tamanho = 34});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaria.withValues(alpha: .85), primaria],
        ),
        boxShadow: [
          BoxShadow(
              color: primaria.withValues(alpha: .4),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(Icons.payments_rounded,
          color: Colors.white, size: tamanho * .58),
    );
  }
}
