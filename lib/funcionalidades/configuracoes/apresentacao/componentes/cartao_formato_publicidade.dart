import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';

/// Card de seleção de formato de publicidade (1A/1B/1C). Controlado: recebe
/// valor + callback, sem estado próprio.
class CartaoFormatoPublicidade extends StatelessWidget {
  const CartaoFormatoPublicidade({
    super.key,
    required this.codigo,
    required this.nome,
    required this.descricao,
    required this.complemento,
    required this.miniatura,
    required this.selecionado,
    required this.aoTocar,
  });

  final String codigo;
  final String nome;
  final String descricao;
  final String complemento;
  final Widget miniatura;
  final bool selecionado;
  final VoidCallback aoTocar;

  /// 1A: barra com blocos (banners) + indicadores ● ○ ○.
  static Widget miniaturaCarrossel() => Container(
        height: 64,
        color: CoresApp.lilasClaro,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 30,
                    height: 20,
                    color: CoresApp.primariaPadrao.withValues(alpha: .55)),
                const SizedBox(width: 4),
                Container(
                    width: 30,
                    height: 20,
                    color: CoresApp.primariaPadrao.withValues(alpha: .25)),
              ],
            ),
            const SizedBox(height: 6),
            const Text('● ○ ○',
                style: TextStyle(fontSize: 10, color: CoresApp.primariaPadrao)),
          ],
        ),
      );

  /// 1B: mensagem estática representando o letreiro em movimento.
  static Widget miniaturaLetreiro() => Container(
        height: 64,
        color: CoresApp.lilasClaro,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: const Text(
          'Constel Pay · pague sem fila 😊',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      );

  /// 1C: bloco fixo do parceiro.
  static Widget miniaturaParceiro() => Container(
        height: 64,
        color: CoresApp.lilasClaro,
        alignment: Alignment.center,
        child: const Text(
          'SEU ANÚNCIO AQUI',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selecionado ? CoresApp.primariaPadrao : CoresApp.bordaCard,
              width: selecionado ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(codigo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: CoresApp.textoSecundario)),
                  const Spacer(),
                  if (selecionado)
                    const Icon(Icons.check_circle,
                        color: CoresApp.primariaPadrao, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                  borderRadius: BorderRadius.circular(10), child: miniatura),
              const SizedBox(height: 8),
              Text(nome,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 2),
              Text(descricao,
                  style: const TextStyle(
                      fontSize: 11.5, color: CoresApp.textoSecundario)),
              const SizedBox(height: 2),
              Text(complemento,
                  style: const TextStyle(
                      fontSize: 10.5,
                      color: CoresApp.textoSecundario,
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }
}
