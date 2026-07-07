import 'package:flutter/material.dart';

import '../../aplicativo/tema/cores_app.dart';

class Cartao extends StatelessWidget {
  const Cartao({
    super.key,
    required this.filho,
    this.preenchimento = const EdgeInsets.all(16),
    this.aoTocar,
    this.margem,
  });

  final Widget filho;
  final EdgeInsetsGeometry preenchimento;
  final VoidCallback? aoTocar;
  final EdgeInsetsGeometry? margem;

  @override
  Widget build(BuildContext context) {
    final borda = BorderRadius.circular(20);
    return Container(
      margin: margem,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borda,
        border: Border.all(color: CoresApp.bordaCard),
        boxShadow: [
          BoxShadow(
            color: CoresApp.textoPrincipal.withValues(alpha: .09),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: aoTocar,
          borderRadius: borda,
          child: Padding(padding: preenchimento, child: filho),
        ),
      ),
    );
  }
}
