import '../../dominio/entidades/dados_pix.dart';
import '../../dominio/entidades/pagamento.dart';
import '../../dominio/entidades/status_pagamento.dart';

/// Fonte MOCK de pagamento. Sempre aprova após um atraso simulado.
/// O payload Pix é claramente rotulado como MOCK — não é um Pix real.
class FontePagamentoMock {
  FontePagamentoMock({this.atraso = const Duration(milliseconds: 900)});

  final Duration atraso;

  final Map<String, Pagamento> _processados = {};

  int execucoesProcessar = 0;

  Future<DadosPix> gerarPix({
    required String chaveIdempotencia,
    required int valorCentavos,
  }) async {
    await Future<void>.delayed(atraso);
    final payload =
        '00020126-CONSTEL-PAY-MOCK-$chaveIdempotencia-$valorCentavos';
    return DadosPix(
      qrCode: payload,
      copiaCola: payload,
      valorCentavos: valorCentavos,
      expiraEm: DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  Future<Pagamento> processar(Pagamento pagamento) async {
    final existente = _processados[pagamento.id];
    if (existente != null) return existente;
    execucoesProcessar++;
    await Future<void>.delayed(atraso);
    final aprovado = pagamento.copyWith(
      status: StatusPagamento.aprovado,
      atualizadoEm: DateTime.now(),
    );
    _processados[pagamento.id] = aprovado;
    return aprovado;
  }

  StatusPagamento consultarStatus(String pagamentoId) =>
      _processados[pagamentoId]?.status ?? StatusPagamento.aguardando;
}
