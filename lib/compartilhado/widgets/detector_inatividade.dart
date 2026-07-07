import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart';
import '../../nucleo/constantes/constantes_app.dart';

/// Volta para o splash e descarta a operação após inatividade prolongada.
class DetectorInatividade extends ConsumerStatefulWidget {
  const DetectorInatividade({super.key, required this.filho});

  final Widget filho;

  @override
  ConsumerState<DetectorInatividade> createState() =>
      _DetectorInatividadeState();
}

class _DetectorInatividadeState extends ConsumerState<DetectorInatividade> {
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _reiniciar();
  }

  void _reiniciar() {
    _temporizador?.cancel();
    _temporizador = Timer(ConstantesApp.tempoInatividade, _expirar);
  }

  void _expirar() {
    if (!mounted) return;
    ref.read(provedorFluxoPagamento.notifier).novaOperacao();
    context.go('/splash');
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _reiniciar(),
      behavior: HitTestBehavior.translucent,
      child: widget.filho,
    );
  }
}
