import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';

/// Mapeia a `especie` da forma de pagamento do retaguarda para o método do
/// terminal. Valores OBSERVADOS em faturas reais: Dinheiro = 1, PIX = 230.
/// Espécie desconhecida fica de fora — nunca chutar forma em dado financeiro.
abstract final class EspecieForma {
  static const Map<int, MetodoPagamento> paraMetodo = {
    1: MetodoPagamento.dinheiro,
    230: MetodoPagamento.pix,
  };
}
