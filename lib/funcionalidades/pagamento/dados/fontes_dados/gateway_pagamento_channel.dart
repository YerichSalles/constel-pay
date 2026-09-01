import 'package:flutter/services.dart';

import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/entidades/metodo_pagamento.dart';
import '../../dominio/entidades/parametros_adquirente.dart';
import '../../dominio/entidades/resultado_transacao.dart';
import '../../dominio/entidades/tipo_adquirente.dart';
import '../../dominio/repositorios/gateway_pagamento.dart';
import '../adaptadores/mapa_transacao_nativa.dart';

/// Cobrança pela camada nativa embarcada na build.
///
/// Implementação ÚNICA: serve qualquer adquirente que responda ao mesmo canal.
/// A adquirente entra pelo construtor como dado — não há subclasse por
/// adquirente, porque do lado Dart o contrato é idêntico.
class GatewayPagamentoChannel implements GatewayPagamento {
  GatewayPagamentoChannel({
    required this.adquirente,
    required this.metodosSuportados,
    MethodChannel? canal,
    this.tempoLimite = ConstantesApp.tempoLimitePagamentoNativo,
  }) : _canal =
            canal ?? const MethodChannel(ConstantesApp.canalPagamentoNativo);

  @override
  final TipoAdquirente adquirente;

  @override
  final Set<MetodoPagamento> metodosSuportados;

  final MethodChannel _canal;
  final Duration tempoLimite;

  @override
  Future<Resultado<ResultadoTransacao>> iniciarPagamento({
    required String chaveIdempotencia,
    required int valorCentavos,
    required MetodoPagamento metodo,
    int parcelas = 1,
    ParametrosAdquirente parametros = const ParametrosAdquirente.nenhum(),
  }) async {
    final tipoTransacao = MapaTransacaoNativa.tipoDe(metodo);
    if (tipoTransacao == null) {
      return const Erro(FalhaValidacao(
          'Esta forma de pagamento não está disponível neste terminal.'));
    }
    try {
      final resposta = await _canal.invokeMethod<Object?>('iniciarPagamento', {
        'chaveIdempotencia': chaveIdempotencia,
        'valorCentavos': valorCentavos,
        'tipoTransacao': tipoTransacao,
        'parcelas': parcelas,
        ..._extras(parametros),
      }).timeout(tempoLimite);
      return MapaTransacaoNativa.deResposta(
        resposta,
        metodo: metodo,
        valorCentavos: valorCentavos,
      );
    } catch (erro) {
      // Sem `rethrow`: uma exceção escapando daqui viraria crash no meio de
      // uma cobrança. Tudo é traduzido para Falha, e o que não se sabe
      // classificar vira indeterminado, nunca recusa.
      return Erro(MapaTransacaoNativa.falhaDeExcecao(erro));
    }
  }

  /// Argumentos que só uma adquirente exige. O `switch` exaustivo garante que
  /// uma adquirente nova não passe despercebida aqui.
  Map<String, Object?> _extras(ParametrosAdquirente parametros) =>
      switch (parametros) {
        SemParametrosAdquirente() => const {},
      };
}
