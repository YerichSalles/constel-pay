import 'package:flutter/material.dart';

enum ModoDispositivo { celular, tablet, totem }

ModoDispositivo modoPorLargura(double largura) {
  if (largura >= 1024) return ModoDispositivo.totem;
  if (largura >= 600) return ModoDispositivo.tablet;
  return ModoDispositivo.celular;
}

class ConteudoCentralizado extends StatelessWidget {
  const ConteudoCentralizado(
      {super.key, required this.filho, this.larguraMaxima = 620});

  final Widget filho;
  final double larguraMaxima;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: larguraMaxima),
        child: filho,
      ),
    );
  }
}
