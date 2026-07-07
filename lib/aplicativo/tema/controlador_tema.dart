import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import '../../funcionalidades/configuracoes/dominio/repositorios/repositorio_tema.dart';

class ControladorTema extends StateNotifier<TemaPersonalizado> {
  ControladorTema(this._repositorio) : super(const TemaPersonalizado());

  final RepositorioTema _repositorio;

  Future<void> carregar() async {
    state = await _repositorio.obter();
  }

  Future<void> atualizar(TemaPersonalizado novoTema) async {
    await _repositorio.salvar(novoTema);
    state = novoTema;
  }
}
