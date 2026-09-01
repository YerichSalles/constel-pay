import 'package:flutter/services.dart';

import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/repositorios/gateway_nfc.dart';
import '../adaptadores/mapa_nfc_nativo.dart';

/// Leitura por NFC pela camada nativa embarcada na build.
class GatewayNfcChannel implements GatewayNfc {
  GatewayNfcChannel({
    MethodChannel? canal,
    this.tempoLimite = ConstantesApp.tempoLimiteLeituraNfc,
  }) : _canal = canal ?? const MethodChannel(ConstantesApp.canalNfcNativo);

  final MethodChannel _canal;
  final Duration tempoLimite;

  @override
  Future<Resultado<String>> ler() async {
    try {
      final resposta =
          await _canal.invokeMethod<Object?>('lerNfc').timeout(tempoLimite);
      final identificador = resposta is Map ? resposta['identificador'] : null;
      if (identificador is! String || identificador.isEmpty) {
        return const Erro(
            FalhaTerminalPagamento('Não foi possível ler o cartão.'));
      }
      return Sucesso(identificador);
    } catch (erro) {
      // Sem `rethrow`: uma exceção escapando daqui derrubaria o card de NFC.
      return Erro(MapaNfcNativo.falhaDeExcecao(erro));
    }
  }

  @override
  Future<void> cancelar() async {
    try {
      await _canal.invokeMethod<void>('cancelarNfc');
    } catch (_) {
      // Cancelamento é best-effort: nada a fazer se o canal não existir ou
      // já não houver leitura em andamento.
    }
  }
}
