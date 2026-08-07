import 'package:flutter/material.dart';

import '../../aplicativo/tema/cores_app.dart';
import '../../l10n/app_localizations.dart';

/// Selo "homologação" + atalho de digitação manual do código, para telas de
/// leitura sem leitor físico à mão (código de barras, câmera, NFC). Deixa
/// claro que digitar o código é recurso de homologação, não parte do
/// atendimento normal.
class RodapeLeituraHomologacao extends StatelessWidget {
  const RodapeLeituraHomologacao({
    super.key,
    required this.corPrimaria,
    required this.aoDigitarManual,
  });

  final Color corPrimaria;
  final VoidCallback? aoDigitarManual;

  Widget _selo(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: CoresApp.textoPrincipal.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        t.homologationBadge.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
          color: CoresApp.textoPrincipal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _selo(t),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('botao_digitar_codigo_manual'),
            onPressed: aoDigitarManual,
            icon: const Icon(Icons.keyboard_alt_outlined, size: 18),
            label: Text(t.manualEntryButton),
            style: OutlinedButton.styleFrom(
              foregroundColor: corPrimaria,
              side: BorderSide(
                  color: corPrimaria.withValues(alpha: .4), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}
