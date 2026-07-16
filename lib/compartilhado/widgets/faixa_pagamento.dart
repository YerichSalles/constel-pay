import 'package:flutter/material.dart';

import '../../aplicativo/tema/estilos_texto.dart';

/// Chamada para pagar, no rodape da tela de espera.
///
/// Nao tem gesto proprio: a pagina ja embrulha a tela inteira num
/// GestureDetector opaco e a faixa mora dentro dele, entao tocar nela ja paga.
/// Recebe primitivos em vez do TemaPersonalizado para `compartilhado/` nao
/// passar a depender de `funcionalidades/`.
class FaixaPagamento extends StatelessWidget {
  const FaixaPagamento({
    super.key,
    required this.texto,
    required this.corFundo,
    required this.corTexto,
    required this.fonte,
  });

  final String texto;
  final Color corFundo;
  final Color corTexto;
  final String fonte;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: corFundo,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: EstilosTexto.estilo(
              fonte,
              TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: corTexto,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
