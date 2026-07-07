import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../dominio/entidades/tema_personalizado.dart';
import '../../dominio/repositorios/repositorio_tema.dart';
import '../modelos/modelo_tema_personalizado.dart';

class RepositorioTemaImpl implements RepositorioTema {
  RepositorioTemaImpl(this._preferencias);

  final SharedPreferences _preferencias;

  static const String _chave = 'tema_personalizado';

  @override
  Future<TemaPersonalizado> obter() async {
    final texto = _preferencias.getString(_chave);
    if (texto == null) return const TemaPersonalizado();
    try {
      final json = jsonDecode(texto) as Map<String, dynamic>;
      return ModeloTemaPersonalizado.fromJson(json).paraEntidade();
    } catch (_) {
      return const TemaPersonalizado();
    }
  }

  @override
  Future<void> salvar(TemaPersonalizado tema) async {
    final json = jsonEncode(ModeloTemaPersonalizado.deEntidade(tema).toJson());
    await _preferencias.setString(_chave, json);
  }
}
