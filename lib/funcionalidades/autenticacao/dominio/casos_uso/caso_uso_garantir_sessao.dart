import '../../../../nucleo/erros/resultado.dart';
import '../entidades/sessao_nuvem.dart';
import '../repositorios/repositorio_sessao_nuvem.dart';
import 'caso_uso_login_nuvem.dart';

class CasoUsoGarantirSessao {
  CasoUsoGarantirSessao({
    required RepositorioSessaoNuvem repositorioSessao,
    required CasoUsoLoginNuvem casoUsoLogin,
  })  : _repositorioSessao = repositorioSessao,
        _casoUsoLogin = casoUsoLogin;

  final RepositorioSessaoNuvem _repositorioSessao;
  final CasoUsoLoginNuvem _casoUsoLogin;

  Future<Resultado<SessaoNuvem>> executar() async {
    final sessao = await _repositorioSessao.obter();
    if (sessao != null && !sessao.expirada) {
      return Sucesso(sessao);
    }
    return _casoUsoLogin.executar();
  }
}
