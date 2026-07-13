import '../../dominio/entidades/cartao_consumo.dart';
import '../../dominio/entidades/item_consumo.dart';
import '../../dominio/entidades/mesa.dart';

/// Fonte MOCK de leitura de cartões. Simula a mesa 12 com 3 comandas.
/// Será substituída pela integração real (scanner/API) trocando o provider.
/// Os valores imitam o que a API da loja devolve pronto (serviço de 10% aqui é
/// só do mock; na API real o percentual vem no campo `servicoPercentual`).
class FonteLeituraMock {
  FonteLeituraMock({this.atraso = const Duration(milliseconds: 900)});

  final Duration atraso;

  static const List<CartaoConsumo> _cartoes = [
    CartaoConsumo(
      id: 'c1',
      codigo: '789100000001',
      nome: 'Comanda 01',
      pessoa: 'João',
      emoji: '🍲',
      resumo: '2 pratos · 3 bebidas',
      subtotalCentavos: 13600,
      servicoCentavos: 1360,
      servicoPercentual: 10,
      descontoCentavos: 0,
      totalCentavos: 14960,
      saldoCentavos: 14960,
      itens: [
        ItemConsumo(
            emoji: '🍲',
            nome: 'Feijoada individual',
            quantidade: 1,
            valorCentavos: 4600),
        ItemConsumo(
            emoji: '🥩',
            nome: 'Picanha na chapa',
            quantidade: 1,
            valorCentavos: 6400),
        ItemConsumo(
            emoji: '🍺',
            nome: 'Chopp 300ml',
            quantidade: 2,
            valorCentavos: 900),
        ItemConsumo(
            emoji: '🥤',
            nome: 'Guaraná lata',
            quantidade: 1,
            valorCentavos: 800),
      ],
    ),
    CartaoConsumo(
      id: 'c2',
      codigo: '789100000002',
      nome: 'Comanda 02',
      pessoa: 'Maria',
      emoji: '🦐',
      resumo: '1 prato · 3 bebidas',
      subtotalCentavos: 10200,
      servicoCentavos: 1020,
      servicoPercentual: 10,
      descontoCentavos: 0,
      totalCentavos: 11220,
      saldoCentavos: 11220,
      itens: [
        ItemConsumo(
            emoji: '🦐',
            nome: 'Moqueca de camarão',
            quantidade: 1,
            valorCentavos: 7200),
        ItemConsumo(
            emoji: '🍹',
            nome: 'Caipirinha',
            quantidade: 2,
            valorCentavos: 1200),
        ItemConsumo(
            emoji: '💧',
            nome: 'Água com gás',
            quantidade: 1,
            valorCentavos: 600),
      ],
    ),
    CartaoConsumo(
      id: 'c3',
      codigo: '789100000003',
      nome: 'Comanda 03',
      pessoa: 'Ana',
      emoji: '🍚',
      resumo: '1 prato · 1 sobremesa · 1 bebida',
      subtotalCentavos: 8000,
      servicoCentavos: 800,
      servicoPercentual: 10,
      descontoCentavos: 0,
      totalCentavos: 8800,
      saldoCentavos: 8800,
      itens: [
        ItemConsumo(
            emoji: '🍚',
            nome: 'Risoto de funghi',
            quantidade: 1,
            valorCentavos: 5200),
        ItemConsumo(
            emoji: '🍊',
            nome: 'Suco de laranja',
            quantidade: 1,
            valorCentavos: 1200),
        ItemConsumo(
            emoji: '🍮',
            nome: 'Pudim de leite',
            quantidade: 1,
            valorCentavos: 1600),
      ],
    ),
  ];

  final Set<String> _lidos = {};

  Mesa obterMesa() => Mesa(
        numero: 12,
        abertoEm: DateTime.now().subtract(const Duration(minutes: 24)),
        totalComandas: _cartoes.length,
        totalCentavos:
            _cartoes.fold(0, (acumulado, c) => acumulado + c.subtotalCentavos),
      );

  Future<CartaoConsumo?> lerProximo() async {
    await Future<void>.delayed(atraso);
    for (final cartao in _cartoes) {
      if (!_lidos.contains(cartao.id)) {
        _lidos.add(cartao.id);
        return cartao;
      }
    }
    return null;
  }

  int get restantes => _cartoes.length - _lidos.length;

  void reiniciar() => _lidos.clear();
}
