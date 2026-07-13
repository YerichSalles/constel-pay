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
    // O total é o saldo devido informado pela API — pode ser menor que
    // subtotal + serviço - desconto quando houver pagamento parcial, mas nunca
    // maior: acima disso significa valor inflado pelo app.
    final tetoCentavos = pagamento.valorCentavos +
        pagamento.servicoCentavos -
        pagamento.descontoCentavos;
    if (pagamento.totalCentavos > tetoCentavos) {
      return const Erro(
          FalhaValidacao('Os valores do pagamento não conferem.'));
    }
    return _repositorio.processarPagamento(pagamento);
  }
}
