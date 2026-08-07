import '../../dominio/entidades/dados_pix.dart';
import '../../dominio/entidades/pagamento.dart';
import '../../dominio/entidades/status_pagamento.dart';

/// Fonte do PIX por QR Code na tela — o caminho da build genérica, em que a
/// cobrança não passa por maquininha.
///
/// Existe como interface para que `RepositorioPagamentoImpl` dependa de uma
/// abstração e não da classe concreta do mock.
abstract interface class FontePagamento {
  Future<DadosPix> gerarPix({
    required String chaveIdempotencia,
    required int valorCentavos,
  });

  Future<Pagamento> processar(Pagamento pagamento);

  StatusPagamento consultarStatus(String pagamentoId);
}
