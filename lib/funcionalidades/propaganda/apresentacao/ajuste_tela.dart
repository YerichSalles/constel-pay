import 'package:flutter/painting.dart';

import '../dominio/entidades/midia_propaganda.dart';

/// Faixa valida do zoom do modo preencher, em percentual.
const int zoomMinimo = 100;
const int zoomMaximo = 300;

/// Borrar video custa GPU a cada frame. So libera depois que a medicao em
/// profile build provar 60fps no totem (gate da spec de enquadramento);
/// enquanto false, video cai na cor do tema e a UI esconde a opcao.
const bool fundoBorradoLiberadoParaVideo = false;

/// Traduz o modo escolhido pelo operador no `BoxFit` que o player aplica.
/// O automatico nunca corta: encaixa sempre, e a sobra vira fundo borrado.
BoxFit resolverBoxFit(AjusteMidia ajuste) {
  switch (ajuste) {
    case AjusteMidia.preencher:
      return BoxFit.cover;
    case AjusteMidia.encaixar:
    case AjusteMidia.automatico:
      return BoxFit.contain;
    case AjusteMidia.esticar:
      return BoxFit.fill;
  }
}

/// Qual parte da midia sobrevive ao corte do modo preencher.
Alignment resolverAlinhamento(AncoraMidia ancora) {
  switch (ancora) {
    case AncoraMidia.topoEsquerda:
      return Alignment.topLeft;
    case AncoraMidia.topo:
      return Alignment.topCenter;
    case AncoraMidia.topoDireita:
      return Alignment.topRight;
    case AncoraMidia.esquerda:
      return Alignment.centerLeft;
    case AncoraMidia.centro:
      return Alignment.center;
    case AncoraMidia.direita:
      return Alignment.centerRight;
    case AncoraMidia.baseEsquerda:
      return Alignment.bottomLeft;
    case AncoraMidia.base:
      return Alignment.bottomCenter;
    case AncoraMidia.baseDireita:
      return Alignment.bottomRight;
  }
}

/// Converte o zoom percentual em escala. O clamp corrige JSON adulterado em
/// vez de estourar.
double resolverEscala(int zoomPercentual) =>
    zoomPercentual.clamp(zoomMinimo, zoomMaximo) / 100;

/// Converte os graus da midia em quartos de volta para o RotatedBox. JSON
/// adulterado (45, -90, 999) cai no quarto de volta valido abaixo; nunca
/// estoura.
int resolverQuartosDeVolta(int rotacaoGraus) =>
    ((rotacaoGraus % 360) + 360) % 360 ~/ 90;

/// So automatico e encaixar deixam sobra; preencher e esticar cobrem tudo.
bool modoDeixaSobra(AjusteMidia ajuste) =>
    ajuste == AjusteMidia.automatico || ajuste == AjusteMidia.encaixar;

/// Fundo que o player realmente pinta, respeitando o gate do video.
FundoMidia fundoEfetivo({required TipoMidia tipo, required FundoMidia fundo}) =>
    tipo == TipoMidia.video && !fundoBorradoLiberadoParaVideo
        ? FundoMidia.cor
        : fundo;
