import 'package:shared_preferences/shared_preferences.dart';

import '../../../../nucleo/configuracao/cliente_api.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../../nucleo/utils/validadores.dart';
import '../repositorios/repositorio_configuracao.dart';

/// Testa a comunicação com as duas APIs que o app usa: a da loja (consumo do
/// cartão) e a da nuvem (login). Falha em qualquer uma reprova o teste — as
/// duas precisam responder para o fluxo de pagamento funcionar.
class CasoUsoTestarConexao {
  CasoUsoTestarConexao({
    required ClienteApi clienteLoja,
    required ClienteApi clienteNuvem,
    required RepositorioConfiguracao repositorioConfiguracao,
    required SharedPreferences preferencias,
  })  : _clienteLoja = clienteLoja,
        _clienteNuvem = clienteNuvem,
        _repositorioConfiguracao = repositorioConfiguracao,
        _preferencias = preferencias;

  final ClienteApi _clienteLoja;
  final ClienteApi _clienteNuvem;
  final RepositorioConfiguracao _repositorioConfiguracao;
  final SharedPreferences _preferencias;

  /// Testa as duas APIs (usado no diagnóstico geral).
  Future<Resultado<DateTime>> executar() async {
    final loja = await executarLoja();
    if (loja is Erro<DateTime>) return loja;
    return executarNuvem();
  }

  Future<Resultado<DateTime>> executarLoja() async {
    final configuracao = await _repositorioConfiguracao.obter();
    final falha = await _verificar(
      cliente: _clienteLoja,
      url: configuracao.urlBaseAtiva,
      rotulo: 'API Local',
    );
    return falha != null ? Erro(falha) : _registrarSucesso();
  }

  Future<Resultado<DateTime>> executarNuvem() async {
    final configuracao = await _repositorioConfiguracao.obter();
    final falha = await _verificar(
      cliente: _clienteNuvem,
      url: configuracao.urlNuvemAtiva,
      rotulo: 'API Nuvem',
    );
    return falha != null ? Erro(falha) : _registrarSucesso();
  }

  /// Devolve `null` quando o servidor está acessível. Resposta HTTP de erro
  /// (404/401/500) ainda prova acesso — aqui se testa conectividade, não rota.
  Future<Falha?> _verificar({
    required ClienteApi cliente,
    required String url,
    required String rotulo,
  }) async {
    if (!Validadores.urlValida(url)) {
      return FalhaValidacao('Configure uma URL válida para $rotulo.');
    }
    final resposta = await cliente.get('/');
    return switch (resposta) {
      Sucesso() => null,
      Erro(falha: FalhaServidor() || FalhaNaoAutorizado()) => null,
      Erro(:final falha) => FalhaRede('$rotulo: ${falha.mensagem}'),
    };
  }

  Future<Resultado<DateTime>> _registrarSucesso() async {
    final agora = DateTime.now();
    await _preferencias.setString(
      ConstantesApp.chaveUltimaSincronizacao,
      agora.toIso8601String(),
    );
    return Sucesso(agora);
  }
}
