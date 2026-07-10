import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/dispositivo/info_aplicativo.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../../nucleo/utils/fuso_horario.dart';
import '../../../configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import '../../../configuracoes/dominio/repositorios/repositorio_credencial.dart';
import '../../dados/fontes_dados/fonte_autenticacao_nuvem.dart';
import '../../dados/modelos/requisicao_login_nuvem.dart';
import '../entidades/sessao_nuvem.dart';
import '../repositorios/repositorio_sessao_nuvem.dart';

/// Orquestra o login na nuvem: valida credencial e configuração local,
/// monta a requisição, chama a fonte remota e persiste a sessão obtida.
class CasoUsoLoginNuvem {
  CasoUsoLoginNuvem({
    required FonteAutenticacaoNuvem fonte,
    required RepositorioConfiguracao repositorioConfiguracao,
    required RepositorioCredencial repositorioCredencial,
    required RepositorioSessaoNuvem repositorioSessao,
    required InfoAplicativo infoAplicativo,
  })  : _fonte = fonte,
        _repositorioConfiguracao = repositorioConfiguracao,
        _repositorioCredencial = repositorioCredencial,
        _repositorioSessao = repositorioSessao,
        _infoAplicativo = infoAplicativo;

  final FonteAutenticacaoNuvem _fonte;
  final RepositorioConfiguracao _repositorioConfiguracao;
  final RepositorioCredencial _repositorioCredencial;
  final RepositorioSessaoNuvem _repositorioSessao;
  final InfoAplicativo _infoAplicativo;

  Future<Resultado<SessaoNuvem>> executar() async {
    final credencial = await _repositorioCredencial.obter();
    if (credencial == null ||
        credencial.usuario.isEmpty ||
        credencial.senha.isEmpty) {
      return const Erro(
          FalhaValidacao('Configure usuário e senha nas configurações.'));
    }

    final configuracao = await _repositorioConfiguracao.obter();
    if (configuracao.urlNuvemAtiva.isEmpty) {
      return const Erro(
          FalhaValidacao('Configure a URL da nuvem nas configurações.'));
    }

    final requisicao = RequisicaoLoginNuvem(
      username: credencial.usuario,
      password: credencial.senha,
      timezone: FusoHorario.gmt(),
      nomeAplicativo: ConstantesApp.nomeAplicativoLogin,
      versaoAplicativo: await _infoAplicativo.versao(),
      dataAplicativo: ConstantesApp.dataVersaoAplicativo,
      caminhoApi: configuracao.urlBaseAtiva,
      idDispositivo: configuracao.idDispositivo,
      nomeDispositivo: configuracao.identificadorDispositivo,
    );

    final resultado = await _fonte.login(requisicao);
    if (resultado case Sucesso(:final valor)) {
      await _repositorioSessao.salvar(valor);
    }
    return resultado;
  }
}
