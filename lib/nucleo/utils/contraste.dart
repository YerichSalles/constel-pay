import 'dart:math' as math;
import 'dart:ui';

/// Contraste minimo da WCAG AA para texto normal. Abaixo disso o texto da faixa
/// fica ilegivel no totem.
const double contrasteMinimoTexto = 4.5;

/// Contraste minimo da WCAG AA para textos grandes (>= 18pt ou 14pt bold).
const double contrasteMinimoTextoGrande = 3.0;

/// Classificacao da razao de contraste para orientar o operador sem bloquear
/// a personalizacao.
enum NivelContraste { adequado, atencao, insuficiente }

NivelContraste nivelDeContraste(double razao) {
  if (razao >= contrasteMinimoTexto) return NivelContraste.adequado;
  if (razao >= contrasteMinimoTextoGrande) return NivelContraste.atencao;
  return NivelContraste.insuficiente;
}

/// Razao de contraste da WCAG entre duas cores: 1,0 quando sao identicas e 21,0
/// entre preto e branco.
double razaoDeContraste(Color a, Color b) {
  final luminanciaA = a.computeLuminance();
  final luminanciaB = b.computeLuminance();
  final maior = math.max(luminanciaA, luminanciaB);
  final menor = math.min(luminanciaA, luminanciaB);
  return (maior + 0.05) / (menor + 0.05);
}
