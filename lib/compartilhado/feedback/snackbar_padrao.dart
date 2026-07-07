import 'package:flutter/material.dart';

import '../../aplicativo/tema/cores_app.dart';

void mostrarSnackbarPadrao(BuildContext context, String mensagem,
    {bool erro = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content:
            Text(mensagem, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: erro ? CoresApp.erro : CoresApp.textoPrincipal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
}
