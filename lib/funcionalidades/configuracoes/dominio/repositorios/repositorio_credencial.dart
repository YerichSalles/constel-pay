import '../entidades/credencial.dart';

abstract interface class RepositorioCredencial {
  Future<Credencial?> obter();

  Future<void> salvar(Credencial credencial);

  Future<void> remover();
}
