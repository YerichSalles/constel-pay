import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../dominio/entidades/midia_propaganda.dart';
import '../../dominio/repositorios/repositorio_propaganda.dart';
import '../modelos/modelo_midia.dart';

class RepositorioPropagandaImpl implements RepositorioPropaganda {
  RepositorioPropagandaImpl(this._preferencias);

  final SharedPreferences _preferencias;

  static const String _chave = 'midias_propaganda';

  @override
  Future<List<MidiaPropaganda>> obterTodas() async {
    final texto = _preferencias.getString(_chave);
    if (texto == null) return const [];
    try {
      final lista = jsonDecode(texto) as List<dynamic>;
      return lista
          .map((item) =>
              ModeloMidia.fromJson(item as Map<String, dynamic>).paraEntidade())
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<MidiaPropaganda>> obterAtivasOrdenadas() async {
    final todas = await obterTodas();
    final ativas = todas.where((midia) => midia.ativo).toList()
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
    return ativas;
  }

  @override
  Future<void> salvarTodas(List<MidiaPropaganda> midias) async {
    final json = jsonEncode(
        midias.map((m) => ModeloMidia.deEntidade(m).toJson()).toList());
    await _preferencias.setString(_chave, json);
  }
}
