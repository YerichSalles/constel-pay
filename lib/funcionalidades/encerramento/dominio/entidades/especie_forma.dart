import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';

/// Mapeia a `especie` da forma de pagamento do retaguarda para o método do
/// terminal. Valores OBSERVADOS em faturas reais: Dinheiro = 1, PIX = 230.
/// Crédito = 110 e Débito = 120 confirmados pelo time; são os mesmos códigos
/// que a camada nativa usa como tipo de transação da adquirente.
/// Espécie desconhecida fica de fora — nunca chutar forma em dado financeiro.
abstract final class EspecieForma {
  static const Map<int, MetodoPagamento> paraMetodo = {
    1: MetodoPagamento.dinheiro,
    110: MetodoPagamento.credito,
    120: MetodoPagamento.debito,
    230: MetodoPagamento.pix,
  };

  /// Espécie do retaguarda correspondente ao método — usada para localizar a
  /// forma no cadastro (`financeiro/forma`). `null` para método sem espécie
  /// conhecida.
  static int? deMetodo(MetodoPagamento metodo) {
    for (final entrada in paraMetodo.entries) {
      if (entrada.value == metodo) return entrada.key;
    }
    return null;
  }
}
