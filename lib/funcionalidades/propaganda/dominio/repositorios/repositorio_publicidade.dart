import '../entidades/publicidade_barra.dart';

abstract interface class RepositorioPublicidade {
  Future<PublicidadeBarra> obter();

  Future<void> salvar(PublicidadeBarra publicidade);
}
