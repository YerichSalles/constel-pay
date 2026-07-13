import '../../dominio/entidades/atendimento.dart';
import '../../dominio/entidades/cartao_consumo.dart';
import '../../dominio/entidades/item_consumo.dart';

/// Converte o `Atendimento` real da API da loja nos modelos que a UI do chat
/// já consome. Campos decorativos (emoji) recebem padrões neutros.
abstract final class AdaptadorAtendimento {
  static CartaoConsumo paraCartao(Atendimento atendimento) => CartaoConsumo(
        id: atendimento.id,
        codigo: atendimento.codigo,
        nome: atendimento.nome,
        pessoa: atendimento.referencia,
        emoji: '🧾',
        resumo: _resumo(atendimento.itens.length),
        itens: atendimento.itens.map(_item).toList(),
        subtotalCentavos: atendimento.subtotalCentavos,
        servicoCentavos: atendimento.servicoCentavos,
        servicoPercentual: atendimento.servicoPercentual,
        descontoCentavos: atendimento.descontoCentavos,
        totalCentavos: atendimento.totalCentavos,
        saldoCentavos: atendimento.saldoCentavos,
      );

  static String _resumo(int quantidade) =>
      quantidade == 1 ? '1 item' : '$quantidade itens';

  static ItemConsumo _item(ItemAtendimento item) => ItemConsumo(
        emoji: '🍽️',
        nome: item.nome,
        quantidade: item.quantidade.round(),
        valorCentavos: item.valorCentavos,
        itemId: item.itemId,
      );
}
