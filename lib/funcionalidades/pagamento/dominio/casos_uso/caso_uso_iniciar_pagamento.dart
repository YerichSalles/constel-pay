import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../entidades/metodo_pagamento.dart';
import '../entidades/parametros_adquirente.dart';
import '../entidades/resultado_transacao.dart';
import '../repositorios/gateway_pagamento.dart';

/// Cobrança no terminal físico da adquirente ativa.
class CasoUsoIniciarPagamento {
  CasoUsoIniciarPagamento(this._gateway);

  final GatewayPagamento _gateway;

  /// Métodos que a adquirente ativa cobra de fato. A UI precisa disso para
  /// escolher entre a maquininha e o caminho do PIX por QR Code na tela.
  Set<MetodoPagamento> get metodosSuportados => _gateway.metodosSuportados;

  Future<Resultado<ResultadoTransacao>> executar({
    required String chaveIdempotencia,
    required int valorCentavos,
    required MetodoPagamento metodo,
    int parcelas = 1,
    ParametrosAdquirente parametros = const ParametrosAdquirente.nenhum(),
  }) async {
    // Sem chave não há proteção contra cobrança dupla: recusar antes de tocar
    // no terminal.
    if (chaveIdempotencia.trim().isEmpty) {
      return const Erro(FalhaValidacao(
          'Não foi possível identificar esta operação. Reinicie o atendimento '
          'e tente novamente.'));
    }
    if (valorCentavos <= 0) {
      return const Erro(
          FalhaValidacao('O valor do pagamento deve ser maior que zero.'));
    }
    if (!_gateway.metodosSuportados.contains(metodo)) {
      return const Erro(FalhaValidacao(
          'Esta forma de pagamento não está disponível neste terminal.'));
    }
    if (parcelas < 1 || parcelas > ConstantesApp.parcelasMaximasCredito) {
      return const Erro(
          FalhaValidacao('Número de parcelas inválido para esta cobrança.'));
    }
    return _gateway.iniciarPagamento(
      chaveIdempotencia: chaveIdempotencia,
      valorCentavos: valorCentavos,
      metodo: metodo,
      parcelas: parcelas,
      parametros: parametros,
    );
  }
}
