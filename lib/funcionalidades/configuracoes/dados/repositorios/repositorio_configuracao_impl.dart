import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../dominio/entidades/configuracao_terminal.dart';
import '../../dominio/repositorios/repositorio_configuracao.dart';
import '../modelos/modelo_configuracao.dart';

class RepositorioConfiguracaoImpl implements RepositorioConfiguracao {
  RepositorioConfiguracaoImpl(this._preferencias);

  final SharedPreferences _preferencias;

  static const String _chave = 'configuracao_terminal';

  @override
  Future<ConfiguracaoTerminal> obter() async {
    final texto = _preferencias.getString(_chave);
    if (texto == null) return const ConfiguracaoTerminal();
    try {
      final json = jsonDecode(texto) as Map<String, dynamic>;
      return ModeloConfiguracao.fromJson(json).paraEntidade();
    } catch (_) {
      return const ConfiguracaoTerminal();
    }
  }

  @override
  Future<void> salvar(ConfiguracaoTerminal configuracao) async {
    final json =
        jsonEncode(ModeloConfiguracao.deEntidade(configuracao).toJson());
    await _preferencias.setString(_chave, json);
  }
}
