import '../../../../nucleo/erros/resultado.dart';
import '../entidades/dados_pix.dart';
import '../entidades/pagamento.dart';
import '../entidades/status_pagamento.dart';

abstract interface class RepositorioPagamento {
  Future<Resultado<DadosPix>> gerarPix({
    required String chaveIdempotencia,
    required int valorCentavos,
  });

  Future<Resultado<Pagamento>> processarPagamento(Pagamento pagamento);

  Future<Resultado<StatusPagamento>> verificarPagamento(String pagamentoId);
}
