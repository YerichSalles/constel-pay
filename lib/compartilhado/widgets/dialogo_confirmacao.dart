import 'package:flutter/material.dart';

import '../../aplicativo/tema/cores_app.dart';

Future<bool> mostrarDialogoConfirmacao(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String confirmar = 'Confirmar',
  String cancelar = 'Cancelar',
  bool destrutivo = false,
}) async {
  final resposta = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(contexto).pop(false),
          child: Text(cancelar),
        ),
        FilledButton(
          style: destrutivo
              ? FilledButton.styleFrom(backgroundColor: CoresApp.erro)
              : null,
          onPressed: () => Navigator.of(contexto).pop(true),
          child: Text(confirmar),
        ),
      ],
    ),
  );
  return resposta ?? false;
}
