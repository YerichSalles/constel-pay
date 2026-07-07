import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../entidades/pagamento.dart';
import '../repositorios/repositorio_pagamento.dart';

class CasoUsoProcessarPagamento {
  CasoUsoProcessarPagamento(this._repositorio);

  final RepositorioPagamento _repositorio;

  Future<Resultado<Pagamento>> executar(Pagamento pagamento) async {
    if (pagamento.totalCentavos <= 0) {
      return const Erro(
          FalhaValidacao('O valor do pagamento deve ser maior que zero.'));
    }
    if (pagamento.totalCentavos !=
        pagamento.valorCentavos + pagamento.gorjetaCentavos) {
      return const Erro(
          FalhaValidacao('Os valores do pagamento não conferem.'));
    }
    return _repositorio.processarPagamento(pagamento);
  }
}
