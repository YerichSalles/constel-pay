import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';
import '../../../propaganda/dominio/repositorios/repositorio_propaganda.dart';

part 'controlador_midias.freezed.dart';

@freezed
class EstadoMidias with _$EstadoMidias {
  const factory EstadoMidias({
    @Default([]) List<MidiaPropaganda> midias,
    @Default(true) bool carregando,
  }) = _EstadoMidias;
}

class ControladorMidias extends StateNotifier<EstadoMidias> {
  ControladorMidias(this._repositorio) : super(const EstadoMidias());

  final RepositorioPropaganda _repositorio;

  static const Uuid _uuid = Uuid();
  static const Set<String> _extensoesVideo = {'mp4', 'mov', 'webm', 'mkv'};

  Future<void> carregar() async {
    final midias = [...await _repositorio.obterTodas()]
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
    state = EstadoMidias(midias: midias, carregando: false);
  }

  Future<void> _persistir(List<MidiaPropaganda> midias) async {
    await _repositorio.salvarTodas(midias);
    state = state.copyWith(midias: midias);
  }

  Future<void> adicionarArquivos(List<String> caminhos) async {
    var proximaOrdem = state.midias.isEmpty
        ? 1
        : state.midias.map((m) => m.ordem).reduce((a, b) => a > b ? a : b) + 1;
    final novas = caminhos.map((caminho) {
      final extensao = caminho.split('.').last.toLowerCase();
      return MidiaPropaganda(
        id: _uuid.v4(),
        tipo: _extensoesVideo.contains(extensao)
            ? TipoMidia.video
            : TipoMidia.imagem,
        caminho: caminho,
        ordem: proximaOrdem++,
      );
    }).toList();
    await _persistir([...state.midias, ...novas]);
  }

  Future<void> alternarAtivo(String id) async {
    await _persistir([
      for (final midia in state.midias)
        midia.id == id ? midia.copyWith(ativo: !midia.ativo) : midia,
    ]);
  }

  Future<void> mover(String id, int delta) async {
    final midias = [...state.midias];
    final indice = midias.indexWhere((m) => m.id == id);
    final destino = indice + delta;
    if (indice < 0 || destino < 0 || destino >= midias.length) return;
    final ordemA = midias[indice].ordem;
    final ordemB = midias[destino].ordem;
    midias[indice] = midias[indice].copyWith(ordem: ordemB);
    midias[destino] = midias[destino].copyWith(ordem: ordemA);
    midias.sort((a, b) => a.ordem.compareTo(b.ordem));
    await _persistir(midias);
  }

  Future<void> remover(String id) async {
    final indice = state.midias.indexWhere((m) => m.id == id);
    final midia = indice >= 0 ? state.midias[indice] : null;
    await _persistir(state.midias.where((m) => m.id != id).toList());
    if (midia != null) {
      try {
        final arquivo = File(midia.caminho);
        if (await arquivo.exists()) await arquivo.delete();
      } catch (_) {}
    }
  }

  Future<void> definirDuracao(String id, int segundos) async {
    if (segundos < 1) return;
    await _persistir([
      for (final midia in state.midias)
        midia.id == id ? midia.copyWith(duracaoSegundos: segundos) : midia,
    ]);
  }

  Future<void> definirAjuste(String id, AjusteMidia ajuste) async {
    await _persistir([
      for (final midia in state.midias)
        midia.id == id ? midia.copyWith(ajuste: ajuste) : midia,
    ]);
  }
}

final provedorMidias =
    StateNotifierProvider.autoDispose<ControladorMidias, EstadoMidias>((ref) {
  final controlador =
      ControladorMidias(ref.watch(provedorRepositorioPropaganda));
  controlador.carregar();
  return controlador;
});
