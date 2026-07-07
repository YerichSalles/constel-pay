import '../entidades/midia_propaganda.dart';

abstract interface class RepositorioPropaganda {
  Future<List<MidiaPropaganda>> obterTodas();

  Future<List<MidiaPropaganda>> obterAtivasOrdenadas();

  Future<void> salvarTodas(List<MidiaPropaganda> midias);
}
