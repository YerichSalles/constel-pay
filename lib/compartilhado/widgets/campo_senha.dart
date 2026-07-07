import 'package:flutter/material.dart';

class CampoSenha extends StatefulWidget {
  const CampoSenha(
      {super.key, required this.rotulo, this.controlador, this.validador});

  final String rotulo;
  final TextEditingController? controlador;
  final String? Function(String?)? validador;

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _oculto = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controlador,
      obscureText: _oculto,
      validator: widget.validador,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.rotulo,
        suffixIcon: IconButton(
          icon: Icon(_oculto ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _oculto = !_oculto),
        ),
      ),
    );
  }
}
