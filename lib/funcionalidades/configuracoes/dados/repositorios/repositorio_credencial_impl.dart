import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../dominio/entidades/credencial.dart';
import '../../dominio/repositorios/repositorio_credencial.dart';

class RepositorioCredencialImpl implements RepositorioCredencial {
  RepositorioCredencialImpl(this._armazenamento);

  final FlutterSecureStorage _armazenamento;

  static const String _chaveUsuario = 'credencial_usuario';
  static const String _chaveSenha = 'credencial_senha';

  @override
  Future<Credencial?> obter() async {
    final usuario = await _armazenamento.read(key: _chaveUsuario);
    final senha = await _armazenamento.read(key: _chaveSenha);
    if (usuario == null || senha == null) return null;
    return Credencial(usuario: usuario, senha: senha);
  }

  @override
  Future<void> salvar(Credencial credencial) async {
    await _armazenamento.write(key: _chaveUsuario, value: credencial.usuario);
    await _armazenamento.write(key: _chaveSenha, value: credencial.senha);
  }

  @override
  Future<void> remover() async {
    await _armazenamento.delete(key: _chaveUsuario);
    await _armazenamento.delete(key: _chaveSenha);
  }
}
