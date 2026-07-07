import 'package:flutter/material.dart';

class BotaoSecundario extends StatelessWidget {
  const BotaoSecundario({
    super.key,
    required this.rotulo,
    this.aoTocar,
    this.icone,
    this.expandido = true,
  });

  final String rotulo;
  final VoidCallback? aoTocar;
  final Widget? icone;
  final bool expandido;

  @override
  Widget build(BuildContext context) {
    final botao = OutlinedButton(
      onPressed: aoTocar,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icone != null) ...[icone!, const SizedBox(width: 10)],
          Flexible(child: Text(rotulo, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
    return expandido ? SizedBox(width: double.infinity, child: botao) : botao;
  }
}
