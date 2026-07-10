import '../entidades/sessao_nuvem.dart';

abstract interface class RepositorioSessaoNuvem {
  Future<SessaoNuvem?> obter();

  Future<void> salvar(SessaoNuvem sessao);

  Future<void> remover();
}
