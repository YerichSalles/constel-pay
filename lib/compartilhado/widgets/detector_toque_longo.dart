import 'dart:async';

import 'package:flutter/material.dart';

/// Detecta um toque contínuo de [duracao] (padrão 3s) sobre [filho].
/// Usado para o acesso discreto às configurações do terminal.
class DetectorToqueLongo extends StatefulWidget {
  const DetectorToqueLongo({
    super.key,
    required this.filho,
    required this.aoCompletar,
    this.duracao = const Duration(seconds: 3),
  });

  final Widget filho;
  final VoidCallback aoCompletar;
  final Duration duracao;

  @override
  State<DetectorToqueLongo> createState() => _DetectorToqueLongoState();
}

class _DetectorToqueLongoState extends State<DetectorToqueLongo> {
  Timer? _temporizador;

  void _iniciar(_) {
    _temporizador?.cancel();
    _temporizador = Timer(widget.duracao, widget.aoCompletar);
  }

  void _cancelar([dynamic _]) {
    _temporizador?.cancel();
    _temporizador = null;
  }

  @override
  void dispose() {
    _cancelar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _iniciar,
      onPointerUp: _cancelar,
      onPointerCancel: _cancelar,
      behavior: HitTestBehavior.opaque,
      child: widget.filho,
    );
  }
}
