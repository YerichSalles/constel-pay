import '../entidades/tema_personalizado.dart';

abstract interface class RepositorioTema {
  Future<TemaPersonalizado> obter();

  Future<void> salvar(TemaPersonalizado tema);
}
