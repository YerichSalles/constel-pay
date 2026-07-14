import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../nucleo/utils/registrador.dart';
import '../../dominio/entidades/transacao_pendente.dart';
import '../../dominio/repositorios/repositorio_transacoes_pendentes.dart';

/// Fila de transações pendentes em `SharedPreferences` (JSON). Registro
/// corrompido é descartado com log — nunca derruba a recuperação dos demais.
class RepositorioTransacoesPendentesImpl
    implements RepositorioTransacoesPendentes {
  RepositorioTransacoesPendentesImpl(this._preferencias);

  static const String chave = 'transacoes_pendentes';

  final SharedPreferences _preferencias;

  @override
  Future<List<TransacaoPendente>> obterTodas() async {
    final texto = _preferencias.getString(chave);
    if (texto == null || texto.isEmpty) return const [];
    try {
      final lista = jsonDecode(texto);
      if (lista is! List) return const [];
      return lista
          .whereType<Map<String, dynamic>>()
          .map(TransacaoPendente.deJson)
          .where((t) => t.identificador.isNotEmpty)
          .toList();
    } catch (erro) {
      registrador.w('Transações pendentes ilegíveis: $erro');
      return const [];
    }
  }

  @override
  Future<void> salvar(TransacaoPendente transacao) async {
    final todas = await obterTodas();
    final atualizadas = [
      for (final t in todas)
        if (t.identificador != transacao.identificador) t,
      transacao,
    ];
    await _gravar(atualizadas);
  }

  @override
  Future<void> remover(String identificador) async {
    final todas = await obterTodas();
    await _gravar([
      for (final t in todas)
        if (t.identificador != identificador) t
    ]);
  }

  Future<void> _gravar(List<TransacaoPendente> transacoes) async {
    await _preferencias.setString(
        chave, jsonEncode([for (final t in transacoes) t.paraJson()]));
  }
}
