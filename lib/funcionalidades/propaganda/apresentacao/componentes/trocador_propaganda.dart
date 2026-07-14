import 'package:flutter/material.dart';

import '../../dominio/entidades/midia_propaganda.dart';
import 'player_propaganda.dart';

/// Mantem dois players: o atual, tocando, e o seguinte, preparando invisivel.
/// A troca so acontece quando o seguinte avisa que esta pronto — ate la o
/// atual segura o ultimo frame. E o que impede a cor de fundo de piscar
/// entre midias (o initialize de video e lento e o loop do backend nao e
/// gapless).
class TrocadorPropaganda extends StatefulWidget {
  const TrocadorPropaganda({
    super.key,
    required this.indice,
    required this.midiaAtual,
    required this.midiaSeguinte,
    required this.corFundo,
    required this.aoAvancar,
  });

  /// Posicao absoluta na playlist (cresce sempre). Identifica a exibicao:
  /// com midia unica, atual e seguinte tem o mesmo id mas sao exibicoes
  /// distintas, cada uma com seu player.
  final int indice;

  final MidiaPropaganda midiaAtual;
  final MidiaPropaganda midiaSeguinte;
  final Color corFundo;

  /// Chamado quando o atual terminou E o seguinte esta pronto. O controlador
  /// avanca o indice e o rebuild faz o swap: o slot do seguinte mantem a key
  /// e so vira ativo — o player nao e recriado.
  final VoidCallback aoAvancar;

  @override
  State<TrocadorPropaganda> createState() => _TrocadorPropagandaState();
}

class _TrocadorPropagandaState extends State<TrocadorPropaganda> {
  bool _seguintePronto = false;
  bool _aguardandoSeguinte = false;

  @override
  void didUpdateWidget(covariant TrocadorPropaganda anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.indice != widget.indice) {
      // Swap consumado: quem era seguinte virou atual; o novo seguinte
      // comeca a preparar do zero.
      _seguintePronto = false;
      _aguardandoSeguinte = false;
    }
  }

  void _aoTerminarAtual() {
    if (_seguintePronto) {
      widget.aoAvancar();
    } else {
      // Segura no ultimo frame do atual ate o seguinte sinalizar.
      _aguardandoSeguinte = true;
    }
  }

  void _aoPrepararSeguinte() {
    _seguintePronto = true;
    if (_aguardandoSeguinte) {
      _aguardandoSeguinte = false;
      widget.aoAvancar();
    }
  }

  Widget _slot(int indiceExibicao, MidiaPropaganda midia) {
    final ativo = indiceExibicao == widget.indice;
    return Offstage(
      offstage: !ativo,
      child: PlayerPropaganda(
        // A key por exibicao faz o slot reciclado (indice + 2) nascer como
        // player novo, e o slot promovido manter o State de quando preparava.
        key: ValueKey('exibicao-$indiceExibicao'),
        midia: midia,
        corFundo: widget.corFundo,
        ativo: ativo,
        aoPreparado: ativo ? null : _aoPrepararSeguinte,
        aoTerminar: ativo ? _aoTerminarAtual : _ignorarFim,
      ),
    );
  }

  static void _ignorarFim() {}

  @override
  Widget build(BuildContext context) {
    final atual = widget.indice;
    final seguinte = atual + 1;
    // Slots em posicao fixa (par embaixo, impar em cima — irrelevante, o
    // offstage nao pinta): sem reordenacao nem re-parenting, o Element do
    // player sobrevive ao swap.
    final exibicaoPar = atual.isEven ? atual : seguinte;
    final exibicaoImpar = atual.isOdd ? atual : seguinte;
    return Stack(
      fit: StackFit.expand,
      children: [
        _slot(exibicaoPar,
            exibicaoPar == atual ? widget.midiaAtual : widget.midiaSeguinte),
        _slot(exibicaoImpar,
            exibicaoImpar == atual ? widget.midiaAtual : widget.midiaSeguinte),
      ],
    );
  }
}
