import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../dominio/entidades/configuracao_faturamento.dart';
import '../../dominio/repositorios/repositorio_configuracao_faturamento.dart';

/// Configuração de faturamento em `SharedPreferences`, gravada como o JSON
/// cru fornecido pelo retaguarda. A validação estrutural acontece no `salvar`
/// para o operador ver o erro na hora, e de novo no `obter` por segurança.
class RepositorioConfiguracaoFaturamentoImpl
    implements RepositorioConfiguracaoFaturamento {
  RepositorioConfiguracaoFaturamentoImpl(this._preferencias);

  static const String chave = 'configuracao_faturamento';

  final SharedPreferences _preferencias;

  @override
  Future<ConfiguracaoFaturamento?> obter() async {
    final texto = _preferencias.getString(chave);
    if (texto == null || texto.isEmpty) return null;
    try {
      final json = jsonDecode(texto);
      if (json is! Map<String, dynamic>) return null;
      return ConfiguracaoFaturamento.deJson(json);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> salvar(String jsonBruto) async {
    final Object? json;
    try {
      json = jsonDecode(jsonBruto);
    } on FormatException {
      // A mensagem original do parser é técnica e em inglês — o operador
      // precisa de instrução, não de posição de caractere.
      throw const FormatException(
          'O texto colado não é um JSON válido. Copie novamente o conteúdo '
          'completo fornecido pelo retaguarda.');
    }
    if (json is! Map<String, dynamic>) {
      throw const FormatException('O conteúdo precisa ser um objeto JSON.');
    }
    final configuracao = ConfiguracaoFaturamento.deJson(json);
    if (configuracao == null) {
      throw const FormatException(
          'Configuração incompleta: histórico, operação, moeda, modalidade, '
          'resultado e dispositivo precisam existir e ter "id".');
    }
    await _preferencias.setString(chave, jsonBruto);
  }

  @override
  Future<void> remover() async {
    await _preferencias.remove(chave);
  }
}
