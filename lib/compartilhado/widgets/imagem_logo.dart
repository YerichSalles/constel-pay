import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Extensoes aceitas ao escolher a logo do estabelecimento.
const List<String> extensoesLogoAceitas = <String>[
  'png',
  'jpg',
  'jpeg',
  'webp',
  'bmp',
  'gif',
  'svg',
];

bool logoEhSvg(String caminho) => caminho.toLowerCase().endsWith('.svg');

/// Exibe a logo escolhida pelo operador, aceitando SVG ou imagem comum.
class ImagemLogo extends StatelessWidget {
  const ImagemLogo({
    super.key,
    required this.caminho,
    this.fit = BoxFit.contain,
    this.reserva,
  });

  final String caminho;
  final BoxFit fit;
  final Widget? reserva;

  @override
  Widget build(BuildContext context) {
    final arquivo = File(caminho);
    final vazio = reserva ?? const SizedBox.shrink();
    final Widget imagem = logoEhSvg(caminho)
        ? SvgPicture.file(
            arquivo,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            placeholderBuilder: (_) => vazio,
          )
        : Image.file(
            arquivo,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => vazio,
          );
    // O pai costuma usar alignment/center, o que afrouxa as constrains e faria
    // a imagem assumir o tamanho intrinseco, deixando sobra visivel no card.
    return SizedBox.expand(child: imagem);
  }
}
