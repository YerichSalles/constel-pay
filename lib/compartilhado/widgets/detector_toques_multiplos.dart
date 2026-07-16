import 'dart:async';

import 'package:flutter/material.dart';

/// Detecta [toques] toques rápidos e consecutivos sobre [filho], contanto que
/// o intervalo entre eles não passe de [intervalo]. Usado para o acesso
/// discreto às configurações do terminal, sem um botão visível.
class DetectorToquesMultiplos extends StatefulWidget {
  const DetectorToquesMultiplos({
    super.key,
    required this.filho,
    required this.aoCompletar,
    this.toques = 4,
    this.intervalo = const Duration(milliseconds: 800),
  });

  final Widget filho;
  final VoidCallback aoCompletar;

  /// Quantidade de toques necessária para disparar [aoCompletar].
  final int toques;

  /// Tempo máximo entre dois toques; se estourar, a contagem recomeça.
  final Duration intervalo;

  @override
  State<DetectorToquesMultiplos> createState() =>
      _DetectorToquesMultiplosState();
}

class _DetectorToquesMultiplosState extends State<DetectorToquesMultiplos> {
  int _contagem = 0;
  Timer? _temporizador;

  void _registrar() {
    _temporizador?.cancel();
    _contagem++;
    if (_contagem >= widget.toques) {
      _contagem = 0;
      widget.aoCompletar();
      return;
    }
    _temporizador = Timer(widget.intervalo, () => _contagem = 0);
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _registrar,
      behavior: HitTestBehavior.opaque,
      child: widget.filho,
    );
  }
}
