import 'package:shared_preferences/shared_preferences.dart';

import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../../nucleo/utils/validadores.dart';
import '../repositorios/repositorio_configuracao.dart';

class CasoUsoTestarConexao {
  CasoUsoTestarConexao({
    required ClienteApi clienteApi,
    required RepositorioConfiguracao repositorioConfiguracao,
    required SharedPreferences preferencias,
  })  : _clienteApi = clienteApi,
        _repositorioConfiguracao = repositorioConfiguracao,
        _preferencias = preferencias;

  final ClienteApi _clienteApi;
  final RepositorioConfiguracao _repositorioConfiguracao;
  final SharedPreferences _preferencias;

  Future<Resultado<DateTime>> executar() async {
    final configuracao = await _repositorioConfiguracao.obter();
    if (!Validadores.urlValida(configuracao.urlBaseAtiva)) {
      return const Erro(
          FalhaValidacao('Configure uma URL válida para o ambiente ativo.'));
    }
    final resposta = await _clienteApi.get('/');
    switch (resposta) {
      case Sucesso():
        final agora = DateTime.now();
        await _preferencias.setString(
          ConstantesApp.chaveUltimaSincronizacao,
          agora.toIso8601String(),
        );
        return Sucesso(agora);
      case Erro(:final falha):
        return Erro(falha);
    }
  }
}
