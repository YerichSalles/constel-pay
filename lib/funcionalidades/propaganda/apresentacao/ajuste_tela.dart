import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../dominio/entidades/midia_propaganda.dart';

/// Fracao minima da midia que precisa sobreviver ao corte do `cover` para que o
/// modo automatico prefira preencher a tela em vez de encaixar com tarjas.
const double aproveitamentoMinimoParaPreencher = 0.75;

/// Traduz o modo escolhido pelo operador no `BoxFit` que o player aplica.
///
/// [razaoMidia] e nulo enquanto as dimensoes da midia nao foram medidas (video
/// inicializando, imagem decodificando). Nesse caso o modo automatico nunca
/// corta: so decide preencher depois de saber o que estaria cortando.
BoxFit resolverBoxFit({
  required AjusteMidia ajuste,
  required double? razaoMidia,
  required double razaoTela,
}) {
  switch (ajuste) {
    case AjusteMidia.preencher:
      return BoxFit.cover;
    case AjusteMidia.encaixar:
      return BoxFit.contain;
    case AjusteMidia.esticar:
      return BoxFit.fill;
    case AjusteMidia.automatico:
      if (razaoMidia == null ||
          !razaoMidia.isFinite ||
          razaoMidia <= 0 ||
          !razaoTela.isFinite ||
          razaoTela <= 0) {
        return BoxFit.contain;
      }
      final maior = math.max(razaoMidia, razaoTela);
      final menor = math.min(razaoMidia, razaoTela);
      return menor / maior >= aproveitamentoMinimoParaPreencher
          ? BoxFit.cover
          : BoxFit.contain;
  }
}
