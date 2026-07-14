import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../modelos/requisicao_encerramento.dart';

/// Envia as ações de encerramento (`10` iniciar, `30` confirmar) para a API
/// da LOJA (`venda/atendimento/encerra`). O corpo da resposta não é usado —
/// sucesso HTTP conclui a etapa.
///
/// SEM `Idempotency-Key`: as duas ações usam o mesmo endpoint e o caixa não
/// envia o header; uma chave repetida poderia fazer um servidor com dedupe
/// responder a ação 30 com o replay da ação 10 sem confirmar nada.
class FonteEncerramentoAtendimento {
  FonteEncerramentoAtendimento(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<Resultado<void>> enviar(RequisicaoEncerramento requisicao) async {
    final resposta = await _clienteApi.post(
      ConstantesApp.caminhoEncerraAtendimento,
      dados: requisicao.paraJson(),
    );
    return switch (resposta) {
      Sucesso() => const Sucesso(null),
      Erro(:final falha) => Erro(falha),
    };
  }
}
