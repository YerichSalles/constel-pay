import 'package:flutter/material.dart';

import '../../../../compartilhado/widgets/icone_emoji.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';

class CardMetodosPagamento extends StatelessWidget {
  const CardMetodosPagamento({
    super.key,
    required this.metodos,
    required this.aoSelecionar,
    this.habilitado = true,
  });

  final List<MetodoPagamento> metodos;
  final void Function(MetodoPagamento) aoSelecionar;
  final bool habilitado;

  static String _rotulo(AppLocalizations t, MetodoPagamento metodo) =>
      switch (metodo) {
        MetodoPagamento.pix => t.paymentMethodPix,
        MetodoPagamento.credito => t.paymentMethodCredit,
        MetodoPagamento.debito => t.paymentMethodDebit,
        MetodoPagamento.tef => t.paymentMethodTef,
        MetodoPagamento.pos => t.paymentMethodPos,
        MetodoPagamento.voucher => t.paymentMethodVoucher,
        MetodoPagamento.dinheiro => t.paymentMethodCash,
      };

  /// Ícone Material e cor usual de cada método (Pix teal, crédito azul,
  /// débito roxo, dinheiro verde...), para reconhecimento imediato no
  /// terminal — crédito e débito precisam de cores bem distintas entre si.
  static (IconData, Color) _icone(MetodoPagamento metodo) => switch (metodo) {
        MetodoPagamento.pix => (Icons.pix, IconeEmoji.corPix),
        MetodoPagamento.credito => (
            Icons.credit_card_outlined,
            IconeEmoji.corCartao
          ),
        MetodoPagamento.debito => (
            Icons.contactless_outlined,
            Color(0xFF7B1FA2)
          ),
        MetodoPagamento.tef => (
            Icons.desktop_windows_outlined,
            Color(0xFF455A64)
          ),
        MetodoPagamento.pos => (
            Icons.point_of_sale_outlined,
            Color(0xFF455A64)
          ),
        MetodoPagamento.voucher => (
            Icons.confirmation_number_outlined,
            Color(0xFFEF6C00)
          ),
        MetodoPagamento.dinheiro => (
            Icons.payments_outlined,
            Color(0xFF2E7D32)
          ),
      };

  Widget _cartao(AppLocalizations t, MetodoPagamento metodo) {
    final (icone, cor) = _icone(metodo);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: habilitado ? () => aoSelecionar(metodo) : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFECEBF1), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Icon(icone, size: 36, color: cor),
              ),
              const SizedBox(height: 10),
              Text(_rotulo(t, metodo),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Todos os métodos lado a lado, na ordem recebida.
    final filhos = <Widget>[];
    for (final metodo in metodos) {
      if (filhos.isNotEmpty) filhos.add(const SizedBox(width: 10));
      filhos.add(Expanded(child: _cartao(t, metodo)));
    }
    return Row(children: filhos);
  }
}
