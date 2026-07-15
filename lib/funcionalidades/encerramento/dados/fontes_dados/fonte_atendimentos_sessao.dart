import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../../nucleo/utils/json_leniente.dart';
import '../../dominio/entidades/atendimento_encerrado.dart';

/// Atendimentos ENCERRADOS de uma sessão na API da LOJA
/// (`venda/atendimento/mapa?situacao=30&sessaoid=`): cada um ecoa a fatura
/// vinculada pela ação 30. É por aqui que o terminal descobre as faturas da
/// sessão — a nuvem não tem consulta de fatura por sessão. O mapa devolve
/// encerradas E estornadas juntas; as estornadas ficam de fora.
class FonteAtendimentosSessao {
  FonteAtendimentosSessao(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<Resultado<List<AtendimentoEncerrado>>> consultarEncerrados(
      String sessaoId) async {
    final resposta = await _clienteApi.get(
      ConstantesApp.caminhoMapaAtendimento,
      parametros: {
        'situacao': ConstantesApp.situacaoAtendimentoEncerrado,
        'sessaoid': sessaoId,
      },
    );
    try {
      return switch (resposta) {
        Sucesso(:final valor) => Sucesso([
            for (final bruto in (valor.data as List<dynamic>? ?? const [])
                .whereType<Map<String, dynamic>>())
              if (JsonLeniente.inteiro(bruto['situacao']) ==
                  ConstantesApp.situacaoAtendimentoEncerrado)
                AtendimentoEncerrado(
                  atendimentoId: JsonLeniente.texto(bruto['id']),
                  faturaId: JsonLeniente.texto(
                      JsonLeniente.mapa(bruto['fatura'])['id']),
                  faturaCodigo: JsonLeniente.texto(
                      JsonLeniente.mapa(bruto['fatura'])['codigo']),
                  conclusao: JsonLeniente.texto(bruto['conclusao']),
                ),
          ]),
        Erro(:final falha) => Erro(falha),
      };
    } catch (_) {
      return const Erro(FalhaDesconhecida(
          'A consulta de atendimentos da sessão veio ilegível.'));
    }
  }
}
