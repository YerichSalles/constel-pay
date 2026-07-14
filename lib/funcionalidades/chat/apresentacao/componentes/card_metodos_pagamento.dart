import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
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

  static String _descricao(AppLocalizations t, MetodoPagamento metodo) =>
      switch (metodo) {
        MetodoPagamento.pix => t.paymentMethodPixDescription,
        MetodoPagamento.credito => t.paymentMethodCreditDescription,
        MetodoPagamento.debito => t.paymentMethodDebitDescription,
        MetodoPagamento.tef => t.paymentMethodTefDescription,
        MetodoPagamento.pos => t.paymentMethodPosDescription,
        MetodoPagamento.voucher => t.paymentMethodVoucherDescription,
        MetodoPagamento.dinheiro => t.paymentMethodCashDescription,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: metodos
          .map(
            (metodo) => Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: habilitado ? () => aoSelecionar(metodo) : null,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border:
                        Border.all(color: const Color(0xFFECEBF1), width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: CoresApp.lilasClaro,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        alignment: Alignment.center,
                        child: Text(metodo.emoji,
                            style: const TextStyle(fontSize: 21)),
                      ),
                      const SizedBox(height: 8),
                      Text(_rotulo(t, metodo),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800)),
                      Text(
                        _descricao(t, metodo),
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: CoresApp.textoSecundario,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
