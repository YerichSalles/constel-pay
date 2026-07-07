import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../entidades/dados_pix.dart';
import '../repositorios/repositorio_pagamento.dart';

class CasoUsoGerarPix {
  CasoUsoGerarPix(this._repositorio);

  final RepositorioPagamento _repositorio;

  Future<Resultado<DadosPix>> executar({
    required String chaveIdempotencia,
    required int valorCentavos,
  }) async {
    if (valorCentavos <= 0) {
      return const Erro(
          FalhaValidacao('O valor do pagamento deve ser maior que zero.'));
    }
    return _repositorio.gerarPix(
      chaveIdempotencia: chaveIdempotencia,
      valorCentavos: valorCentavos,
    );
  }
}
