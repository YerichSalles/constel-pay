import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/cartao_consumo.dart';
import 'package:flutter_test/flutter_test.dart';

CartaoConsumo _cartao(String id) => CartaoConsumo(
      id: id,
      codigo: '00$id',
      nome: 'Comanda $id',
      pessoa: 'Mesa 1',
      emoji: '🧾',
      resumo: '',
      itens: const [],
      subtotalCentavos: 1000,
      servicoCentavos: 0,
      descontoCentavos: 0,
      totalCentavos: 1000,
      saldoCentavos: 1000,
      selecionado: true,
    );

void main() {
  test('rotuloCartoesAdicionados usa singular com 1 cartao', () {
    final estado = EstadoFluxoPagamento(cartoes: [_cartao('c1')]);
    expect(estado.rotuloCartoesAdicionados, '1 cartão adicionado');
  });

  test('rotuloCartoesAdicionados usa plural com 2 cartoes', () {
    final estado =
        EstadoFluxoPagamento(cartoes: [_cartao('c1'), _cartao('c2')]);
    expect(estado.rotuloCartoesAdicionados, '2 cartões adicionados');
  });

  test('rotuloCartoesAdicionados ignora cartoes pagos', () {
    final estado = EstadoFluxoPagamento(
        cartoes: [_cartao('c1'), _cartao('c2').copyWith(pago: true)]);
    expect(estado.rotuloCartoesAdicionados, '1 cartão adicionado');
  });

  test('enum possui as etapas de saida do modo de inclusao', () {
    expect(EtapaFluxo.values, contains(EtapaFluxo.semConsumo));
    expect(EtapaFluxo.values, contains(EtapaFluxo.erroLeitura));
  });
}
