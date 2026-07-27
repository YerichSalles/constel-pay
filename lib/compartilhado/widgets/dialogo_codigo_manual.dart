import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Digitação manual do código do cartão, usada quando o terminal está em
/// homologação e não há leitor físico à mão. Retorna o código digitado, ou
/// `null` se o operador fechar sem confirmar.
Future<String?> mostrarDialogoCodigoManual(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (contexto) => const _DialogoCodigoManual(),
  );
}

class _DialogoCodigoManual extends StatefulWidget {
  const _DialogoCodigoManual();

  @override
  State<_DialogoCodigoManual> createState() => _DialogoCodigoManualState();
}

class _DialogoCodigoManualState extends State<_DialogoCodigoManual> {
  final TextEditingController _codigo = TextEditingController();

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  void _confirmar() {
    final codigo = _codigo.text.trim();
    if (codigo.isEmpty) return;
    Navigator.of(context).pop(codigo);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(t.manualEntryTitle,
          style: const TextStyle(fontWeight: FontWeight.w800)),
      content: TextField(
        key: const Key('campo_codigo_manual'),
        controller: _codigo,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _confirmar(),
        decoration: InputDecoration(labelText: t.manualEntryFieldLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.manualEntryCancel),
        ),
        FilledButton(
          onPressed: _codigo.text.trim().isEmpty ? null : _confirmar,
          child: Text(t.manualEntryConfirm),
        ),
      ],
    );
  }
}
