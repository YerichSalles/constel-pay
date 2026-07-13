import '../../../../nucleo/configuracao/cliente_api.dart';
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

/// Orquestra o login (nuvem ou loja): valida credencial e configuração local,
/// monta a requisição, chama a fonte remota e persiste a sessão obtida.
/// [seletorBase] escolhe qual URL da configuração precisa estar preenchida —
/// a mesma que o `ClienteApi` da [fonte] usa.
class CasoUsoLoginNuvem {
  CasoUsoLoginNuvem({
    required FonteAutenticacaoNuvem fonte,
    required RepositorioConfiguracao repositorioConfiguracao,
    required RepositorioCredencial repositorioCredencial,
    required RepositorioSessaoNuvem repositorioSessao,
    required InfoAplicativo infoAplicativo,
    SeletorBaseUrl? seletorBase,
    String urlAusenteMensagem = 'Configure a URL da nuvem nas configurações.',
  })  : _fonte = fonte,
        _repositorioConfiguracao = repositorioConfiguracao,
        _repositorioCredencial = repositorioCredencial,
        _repositorioSessao = repositorioSessao,
        _infoAplicativo = infoAplicativo,
        _seletorBase = seletorBase ?? ((c) => c.urlNuvemAtiva),
        _urlAusenteMensagem = urlAusenteMensagem;

  final FonteAutenticacaoNuvem _fonte;
  final RepositorioConfiguracao _repositorioConfiguracao;
  final RepositorioCredencial _repositorioCredencial;
  final RepositorioSessaoNuvem _repositorioSessao;
  final InfoAplicativo _infoAplicativo;
  final SeletorBaseUrl _seletorBase;
  final String _urlAusenteMensagem;

  Future<Resultado<SessaoNuvem>> executar() async {
    final credencial = await _repositorioCredencial.obter();
    if (credencial == null ||
        credencial.usuario.isEmpty ||
        credencial.senha.isEmpty) {
      return const Erro(
          FalhaValidacao('Configure usuário e senha nas configurações.'));
    }

    final configuracao = await _repositorioConfiguracao.obter();
    if (_seletorBase(configuracao).isEmpty) {
      return Erro(FalhaValidacao(_urlAusenteMensagem));
    }

    // O backend exige um UUID de dispositivo; vazio vira 422 no servidor.
    if (configuracao.idDispositivo.trim().isEmpty) {
      return const Erro(FalhaValidacao(
          'Configure o ID do dispositivo (UUID) na aba Comunicação.'));
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
      // O nome exibido no app vem do estabelecimento retornado pelo login;
      // o dispositivo informado identifica de qual estabelecimento ele é.
      if (valor.estabelecimento.nome.isNotEmpty) {
        await _repositorioConfiguracao.salvar(
          configuracao.copyWith(nomeRestaurante: valor.estabelecimento.nome),
        );
      }
    }
    return resultado;
  }
}
