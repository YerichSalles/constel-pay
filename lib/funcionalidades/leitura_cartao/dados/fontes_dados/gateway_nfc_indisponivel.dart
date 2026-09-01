import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/repositorios/gateway_nfc.dart';

/// Builds sem leitor NFC (genérica / Windows): sempre indisponível, sem
/// tocar em canal nenhum.
class GatewayNfcIndisponivel implements GatewayNfc {
  const GatewayNfcIndisponivel();

  @override
  Future<Resultado<String>> ler() async => const Erro(
      FalhaTerminalPagamento('Este terminal não tem leitor NFC disponível.'));

  @override
  Future<void> cancelar() async {}
}
