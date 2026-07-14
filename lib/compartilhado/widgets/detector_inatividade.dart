import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../aplicativo/injecao.dart';
import '../../funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart';
import '../../nucleo/constantes/constantes_app.dart';

/// Após inatividade prolongada, avisa o usuário com contagem regressiva;
/// sem resposta, descarta a operação e volta para o splash.
class DetectorInatividade extends ConsumerStatefulWidget {
  const DetectorInatividade({super.key, required this.filho});

  final Widget filho;

  @override
  ConsumerState<DetectorInatividade> createState() =>
      _DetectorInatividadeState();
}

class _DetectorInatividadeState extends ConsumerState<DetectorInatividade> {
  Timer? _temporizador;
  bool _avisoAberto = false;

  @override
  void initState() {
    super.initState();
    _reiniciar();
  }

  void _reiniciar() {
    _temporizador?.cancel();
    _temporizador = Timer(ConstantesApp.tempoInatividade, _mostrarAviso);
  }

  Future<void> _mostrarAviso() async {
    if (!mounted || _avisoAberto) return;
    _avisoAberto = true;
    var segundos = ConstantesApp.tempoAvisoInatividade.inSeconds;
    Timer? contagem;

    final continuar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (contexto) => StatefulBuilder(
        builder: (contexto, atualizar) {
          contagem ??=
              Timer.periodic(const Duration(seconds: 1), (temporizador) {
            segundos--;
            if (segundos <= 0) {
              temporizador.cancel();
              Navigator.of(contexto).pop(false);
            } else {
              atualizar(() {});
            }
          });
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Você ainda está aí?',
                style: TextStyle(fontWeight: FontWeight.w800)),
            content:
                Text('Sem atividade há algum tempo. Voltaremos à tela inicial '
                    'em $segundos segundo${segundos == 1 ? '' : 's'}.'),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(contexto).pop(true),
                child: const Text('Continuar aqui'),
              ),
            ],
          );
        },
      ),
    );

    contagem?.cancel();
    _avisoAberto = false;
    if (!mounted) return;
    if (continuar == true) {
      _reiniciar();
    } else {
      ref.read(provedorFluxoPagamento.notifier).novaOperacao();
      ref.read(provedorIdioma.notifier).resetar();
      context.go('/splash');
    }
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        if (!_avisoAberto) _reiniciar();
      },
      behavior: HitTestBehavior.translucent,
      child: widget.filho,
    );
  }
}
