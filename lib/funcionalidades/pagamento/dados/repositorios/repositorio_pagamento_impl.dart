import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/entidades/dados_pix.dart';
import '../../dominio/entidades/pagamento.dart';
import '../../dominio/entidades/status_pagamento.dart';
import '../../dominio/repositorios/repositorio_pagamento.dart';
import '../fontes_dados/fonte_pagamento_mock.dart';

class RepositorioPagamentoImpl implements RepositorioPagamento {
  RepositorioPagamentoImpl(this._fonte);

  final FontePagamentoMock _fonte;

  @override
  Future<Resultado<DadosPix>> gerarPix({
    required String chaveIdempotencia,
    required int valorCentavos,
  }) async {
    try {
      return Sucesso(await _fonte.gerarPix(
        chaveIdempotencia: chaveIdempotencia,
        valorCentavos: valorCentavos,
      ));
    } catch (_) {
      return const Erro(FalhaDesconhecida());
    }
  }

  @override
  Future<Resultado<Pagamento>> processarPagamento(Pagamento pagamento) async {
    try {
      return Sucesso(await _fonte.processar(pagamento));
    } catch (_) {
      return const Erro(FalhaDesconhecida());
    }
  }

  @override
  Future<Resultado<StatusPagamento>> verificarPagamento(
      String pagamentoId) async {
    return Sucesso(_fonte.consultarStatus(pagamentoId));
  }
}
