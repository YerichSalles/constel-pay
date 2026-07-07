import 'package:flutter/material.dart';

class BotaoPrimario extends StatelessWidget {
  const BotaoPrimario({
    super.key,
    required this.rotulo,
    this.aoTocar,
    this.icone,
    this.carregando = false,
    this.expandido = true,
  });

  final String rotulo;
  final VoidCallback? aoTocar;
  final Widget? icone;
  final bool carregando;
  final bool expandido;

  @override
  Widget build(BuildContext context) {
    final filho = carregando
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icone != null) ...[icone!, const SizedBox(width: 10)],
              Flexible(child: Text(rotulo, overflow: TextOverflow.ellipsis)),
            ],
          );
    final botao =
        ElevatedButton(onPressed: carregando ? null : aoTocar, child: filho);
    return expandido ? SizedBox(width: double.infinity, child: botao) : botao;
  }
}
