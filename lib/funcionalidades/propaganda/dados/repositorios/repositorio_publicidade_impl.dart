import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../dominio/entidades/publicidade_barra.dart';
import '../../dominio/repositorios/repositorio_publicidade.dart';
import '../modelos/modelo_publicidade.dart';

class RepositorioPublicidadeImpl implements RepositorioPublicidade {
  RepositorioPublicidadeImpl(this._preferencias);

  final SharedPreferences _preferencias;

  static const String _chave = 'publicidade_barra';

  @override
  Future<PublicidadeBarra> obter() async {
    final texto = _preferencias.getString(_chave);
    if (texto == null) return const PublicidadeBarra();
    try {
      final json = jsonDecode(texto) as Map<String, dynamic>;
      return ModeloPublicidade.fromJson(json).paraEntidade();
    } catch (_) {
      return const PublicidadeBarra();
    }
  }

  @override
  Future<void> salvar(PublicidadeBarra publicidade) async {
    final json = jsonEncode(ModeloPublicidade.deEntidade(publicidade).toJson());
    await _preferencias.setString(_chave, json);
  }
}
