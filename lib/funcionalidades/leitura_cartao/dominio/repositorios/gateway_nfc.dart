import '../../../../nucleo/erros/resultado.dart';

/// Contrato de leitura do código de atendimento pela antena NFC da
/// maquininha. Espelha `GatewayPagamento`: uma única implementação de canal
/// serve qualquer adquirente que responda ao mesmo `MethodChannel`.
abstract interface class GatewayNfc {
  /// Arma a antena e aguarda um cartão. Devolve o identificador lido (hex),
  /// usado como referência — o mesmo caminho da digitação manual e da
  /// câmera.
  Future<Resultado<String>> ler();

  /// Cancela uma leitura em andamento (troca de tela, rearme manual).
  Future<void> cancelar();
}
