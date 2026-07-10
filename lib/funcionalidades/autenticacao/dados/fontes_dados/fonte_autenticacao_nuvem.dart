import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/entidades/sessao_nuvem.dart';
import '../modelos/requisicao_login_nuvem.dart';
import '../modelos/resposta_login_nuvem.dart';

class FonteAutenticacaoNuvem {
  FonteAutenticacaoNuvem(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<Resultado<SessaoNuvem>> login(RequisicaoLoginNuvem requisicao) async {
    final resposta = await _clienteApi.post(
      ConstantesApp.caminhoLoginNuvem,
      dados: requisicao.paraJson(),
    );
    try {
      return switch (resposta) {
        Sucesso(:final valor) => Sucesso(
            RespostaLoginNuvem.paraEntidade(valor.data as Map<String, dynamic>)),
        Erro(:final falha) => Erro(falha),
      };
    } catch (_) {
      return const Erro(FalhaServidor('Resposta de login inválida.'));
    }
  }
}
