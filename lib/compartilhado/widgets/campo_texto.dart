import 'package:flutter/material.dart';

class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.rotulo,
    this.controlador,
    this.dica,
    this.validador,
    this.tipoTeclado,
    this.aoMudar,
    this.habilitado = true,
    this.linhas = 1,
  });

  final String rotulo;
  final TextEditingController? controlador;
  final String? dica;
  final String? Function(String?)? validador;
  final TextInputType? tipoTeclado;
  final void Function(String)? aoMudar;
  final bool habilitado;

  /// Número de linhas visíveis; acima de 1 vira área de texto (ex.: JSON).
  final int linhas;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      enabled: habilitado,
      keyboardType: tipoTeclado,
      validator: validador,
      onChanged: aoMudar,
      maxLines: linhas,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(labelText: rotulo, hintText: dica),
    );
  }
}
