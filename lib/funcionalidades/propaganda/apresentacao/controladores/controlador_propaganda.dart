import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../aplicativo/injecao.dart';
import '../../dominio/entidades/midia_propaganda.dart';
import '../../dominio/repositorios/repositorio_propaganda.dart';

part 'controlador_propaganda.freezed.dart';

@freezed
class EstadoPropaganda with _$EstadoPropaganda {
  const EstadoPropaganda._();

  const factory EstadoPropaganda({
    @Default([]) List<MidiaPropaganda> midias,
    @Default(0) int indice,
    @Default(true) bool carregando,
  }) = _EstadoPropaganda;

  MidiaPropaganda? get midiaAtual =>
      midias.isEmpty ? null : midias[indice % midias.length];

  /// Proxima exibicao da fila (circular): e o que o trocador pre-carrega.
  /// Com midia unica, e a propria midia — outra exibicao, outro player.
  MidiaPropaganda? get midiaSeguinte =>
      midias.isEmpty ? null : midias[(indice + 1) % midias.length];
}

class ControladorPropaganda extends StateNotifier<EstadoPropaganda> {
  ControladorPropaganda(this._repositorio) : super(const EstadoPropaganda());

  final RepositorioPropaganda _repositorio;

  Future<void> carregar() async {
    final midias = await _repositorio.obterAtivasOrdenadas();
    state = state.copyWith(midias: midias, indice: 0, carregando: false);
  }

  /// O indice cresce sempre; `midiaAtual` aplica o modulo. Assim, com uma unica
  /// midia na playlist o estado ainda muda e o player reinicia a reproducao.
  void avancar() {
    if (state.midias.isEmpty) return;
    state = state.copyWith(indice: state.indice + 1);
  }
}

final provedorPropaganda =
    StateNotifierProvider.autoDispose<ControladorPropaganda, EstadoPropaganda>(
  (ref) => ControladorPropaganda(ref.watch(provedorRepositorioPropaganda)),
);
