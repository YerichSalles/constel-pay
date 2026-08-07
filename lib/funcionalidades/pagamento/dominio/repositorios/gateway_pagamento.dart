import '../../../../nucleo/erros/resultado.dart';
import '../entidades/metodo_pagamento.dart';
import '../entidades/parametros_adquirente.dart';
import '../entidades/resultado_transacao.dart';
import '../entidades/tipo_adquirente.dart';

/// Contrato de cobrança no terminal físico.
///
/// A adquirente entra como DADO ([adquirente]), não como subclasse: uma única
/// implementação de canal serve qualquer adquirente que responda ao mesmo
/// MethodChannel.
abstract interface class GatewayPagamento {
  /// Adquirente que esta instância representa.
  TipoAdquirente get adquirente;

  /// Métodos que esta adquirente cobra de fato. Vazio significa que nenhuma
  /// cobrança passa por aqui — é o caso da build genérica, em que o PIX segue
  /// pelo QR Code na tela e o cartão não está disponível.
  Set<MetodoPagamento> get metodosSuportados;

  /// Executa a cobrança. [chaveIdempotencia] é a MESMA UUID v4 gerada na
  /// escolha do método e viaja até a adquirente, para que uma repetição
  /// acidental não vire cobrança dupla.
  Future<Resultado<ResultadoTransacao>> iniciarPagamento({
    required String chaveIdempotencia,
    required int valorCentavos,
    required MetodoPagamento metodo,
    int parcelas,
    ParametrosAdquirente parametros,
  });
}
