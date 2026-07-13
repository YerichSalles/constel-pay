import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../../nucleo/formatadores/formatador_percentual.dart';
import '../../../leitura_cartao/dominio/entidades/cartao_consumo.dart';
import '../../../leitura_cartao/dominio/entidades/item_consumo.dart';

/// Comanda lida: cabeçalho, itens (sempre visíveis, com a foto do cadastro) e
/// os valores que a API já calculou — subtotal, serviço e total.
class CardComanda extends StatelessWidget {
  const CardComanda({super.key, required this.cartao});

  final CartaoConsumo cartao;

  /// A API manda `nome` como "Cartão 510" e `referencia` como "510"; repetir os
  /// dois vira "Cartão 510 · 510". Só mostra a pessoa quando ela acrescenta algo.
  String? get _complemento {
    final pessoa = cartao.pessoa.trim();
    if (pessoa.isEmpty || cartao.nome.contains(pessoa)) return null;
    return pessoa;
  }

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    final marcado = cartao.selecionado || cartao.pago;
    return Opacity(
      opacity: cartao.pago ? .6 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cartao.pago ? const Color(0xFFF6F6F8) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: marcado && !cartao.pago ? primaria : CoresApp.bordaCard,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaria.withValues(
                  alpha: marcado && !cartao.pago ? .2 : .05),
              blurRadius: marcado ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: marcado ? primaria : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: marcado ? primaria : const Color(0xFFDCDBE1),
                        width: 2),
                  ),
                  alignment: Alignment.center,
                  child: marcado
                      ? const Text('✓',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800))
                      : null,
                ),
                const SizedBox(width: 11),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: CoresApp.lilasClaro,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child:
                      Text(cartao.emoji, style: const TextStyle(fontSize: 25)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: cartao.nome,
                          style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: CoresApp.textoPrincipal),
                          children: [
                            if (_complemento != null)
                              TextSpan(
                                text: ' · $_complemento',
                                style: const TextStyle(
                                    color: CoresApp.textoSecundario,
                                    fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cartao.pago ? 'Pago ✓' : cartao.resumo,
                        style: const TextStyle(
                            fontSize: 12,
                            color: CoresApp.textoSecundario,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (cartao.itens.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...cartao.itens.map((item) => _LinhaItem(item: item)),
            ],
            const SizedBox(height: 10),
            _linhaValor(
                'Subtotal', FormatadorMoeda.formatar(cartao.subtotalCentavos)),
            if (cartao.servicoCentavos > 0)
              _linhaValor(
                'Taxa de serviço (${FormatadorPercentual.formatar(cartao.servicoPercentual)})',
                FormatadorMoeda.formatar(cartao.servicoCentavos),
              ),
            if (cartao.descontoCentavos > 0)
              _linhaValor('Desconto',
                  '- ${FormatadorMoeda.formatar(cartao.descontoCentavos)}'),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total da comanda',
                    style: TextStyle(
                        fontSize: 13,
                        color: CoresApp.textoSecundario,
                        fontWeight: FontWeight.w700)),
                Text(
                  FormatadorMoeda.formatar(cartao.totalCentavos),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: primaria),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _linhaValor(String rotulo, String valor) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(rotulo,
                style: const TextStyle(
                    fontSize: 12.5,
                    color: CoresApp.textoSecundario,
                    fontWeight: FontWeight.w600)),
            Text(valor,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _LinhaItem extends StatelessWidget {
  const _LinhaItem({required this.item});

  final ItemConsumo item;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: CoresApp.bordaCard)),
        ),
        child: Row(
          children: [
            _FotoItem(item: item),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nome,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700)),
                  Text(
                    '${item.quantidade} un · ${FormatadorMoeda.formatar(item.valorCentavos)} cada',
                    style: const TextStyle(
                        fontSize: 11.5,
                        color: CoresApp.textoSecundario,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Text(FormatadorMoeda.formatar(item.totalCentavos),
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

/// Foto do item vinda do cadastro da loja. Sem foto, imagem quebrada ou offline
/// → mostra o emoji, nunca um espaço vazio nem erro na tela.
class _FotoItem extends StatelessWidget {
  const _FotoItem({required this.item});

  final ItemConsumo item;

  static const double _lado = 44;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: _lado,
        height: _lado,
        color: CoresApp.fundoPadrao,
        alignment: Alignment.center,
        child: item.imagemUrl.isEmpty
            ? _emoji()
            : Image.network(
                item.imagemUrl,
                width: _lado,
                height: _lado,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _emoji(),
                frameBuilder: (_, filho, quadro, jaCarregada) =>
                    quadro == null && !jaCarregada ? _emoji() : filho,
              ),
      ),
    );
  }

  Widget _emoji() => Text(item.emoji, style: const TextStyle(fontSize: 23));
}
