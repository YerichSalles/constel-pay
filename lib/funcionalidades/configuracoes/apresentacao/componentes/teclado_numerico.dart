import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';

class TecladoNumerico extends StatelessWidget {
  const TecladoNumerico({
    super.key,
    required this.aoDigitar,
    required this.aoApagar,
    required this.aoConfirmar,
    this.confirmarHabilitado = true,
  });

  final void Function(String digito) aoDigitar;
  final VoidCallback aoApagar;
  final VoidCallback aoConfirmar;
  final bool confirmarHabilitado;

  Widget _tecla(BuildContext context, Widget filho, VoidCallback? aoTocar,
      {Color? cor}) {
    return Material(
      color: cor ?? Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(height: 62, child: Center(child: filho)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    const estiloDigito = TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
    final linhas = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        children: [
          for (final linha in linhas)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  for (final digito in linha) ...[
                    Expanded(
                        child: _tecla(
                            context,
                            Text(digito, style: estiloDigito),
                            () => aoDigitar(digito))),
                    if (digito != linha.last) const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _tecla(
                    context,
                    const Icon(Icons.backspace_outlined,
                        color: CoresApp.textoSecundario),
                    aoApagar),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: _tecla(context, const Text('0', style: estiloDigito),
                      () => aoDigitar('0'))),
              const SizedBox(width: 10),
              Expanded(
                child: _tecla(
                  context,
                  const Icon(Icons.check, color: Colors.white),
                  confirmarHabilitado ? aoConfirmar : null,
                  cor: confirmarHabilitado
                      ? primaria
                      : primaria.withValues(alpha: .4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
