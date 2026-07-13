import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/entidades/atendimento.dart';
import '../modelos/resposta_consumo_atendimento.dart';

/// Lê o consumo real de um cartão/mesa na API da loja. Lista vazia significa
/// que não há consumo em aberto para a referência (não é erro).
class FonteConsumoAtendimento {
  FonteConsumoAtendimento(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<Resultado<List<Atendimento>>> consultar(
      {required String referencia}) async {
    final resposta = await _clienteApi.get(
      ConstantesApp.caminhoColecaoAtendimento,
      parametros: {
        'classe': ConstantesApp.classeAtendimentoConsumo,
        'situacao': ConstantesApp.situacaoAtendimentoAberto,
        'referencia': referencia,
      },
    );
    try {
      return switch (resposta) {
        Sucesso(:final valor) => Sucesso(RespostaConsumoAtendimento.paraLista(
            (valor.data as List<dynamic>?) ?? const [])),
        Erro(:final falha) => Erro(falha),
      };
    } catch (_) {
      return const Erro(FalhaServidor('Resposta de consumo inválida.'));
    }
  }
}
