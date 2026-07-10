import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../dominio/entidades/sessao_nuvem.dart';
import '../../dominio/repositorios/repositorio_sessao_nuvem.dart';

class RepositorioSessaoNuvemImpl implements RepositorioSessaoNuvem {
  RepositorioSessaoNuvemImpl(this._armazenamento);

  final FlutterSecureStorage _armazenamento;

  static const String _chave = 'sessao_nuvem';

  @override
  Future<SessaoNuvem?> obter() async {
    final bruto = await _armazenamento.read(key: _chave);
    if (bruto == null || bruto.isEmpty) return null;
    try {
      return SessaoNuvem.fromJson(jsonDecode(bruto) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> salvar(SessaoNuvem sessao) =>
      _armazenamento.write(key: _chave, value: jsonEncode(sessao.toJson()));

  @override
  Future<void> remover() => _armazenamento.delete(key: _chave);
}
