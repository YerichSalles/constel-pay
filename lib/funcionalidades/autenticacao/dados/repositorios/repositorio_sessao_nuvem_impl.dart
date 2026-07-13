import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../dominio/entidades/sessao_nuvem.dart';
import '../../dominio/repositorios/repositorio_sessao_nuvem.dart';

class RepositorioSessaoNuvemImpl implements RepositorioSessaoNuvem {
  /// [chave] separa as sessões por servidor: o JWT é assinado por quem o
  /// emitiu, então o token da nuvem não vale na API da loja e vice-versa.
  RepositorioSessaoNuvemImpl(this._armazenamento,
      {String chave = 'sessao_nuvem'})
      : _chave = chave;

  final FlutterSecureStorage _armazenamento;

  final String _chave;

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
