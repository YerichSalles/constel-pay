import '../../../../nucleo/erros/resultado.dart';
import '../entidades/status_pagamento.dart';
import '../repositorios/repositorio_pagamento.dart';

class CasoUsoVerificarPagamento {
  CasoUsoVerificarPagamento(this._repositorio);

  final RepositorioPagamento _repositorio;

  Future<Resultado<StatusPagamento>> executar(String pagamentoId) =>
      _repositorio.verificarPagamento(pagamentoId);
}
