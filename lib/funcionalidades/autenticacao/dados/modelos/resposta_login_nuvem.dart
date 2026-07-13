import 'dart:convert';

import '../../dominio/entidades/sessao_nuvem.dart';

/// Converte a resposta crua da API de nuvem (`POST auth/login`) na entidade
/// [SessaoNuvem], extraindo apenas os campos usados pelo app.
abstract final class RespostaLoginNuvem {
  static SessaoNuvem paraEntidade(Map<String, dynamic> json) {
    final usuario = (json['usuario'] as Map<String, dynamic>?) ?? const {};
    final empresa = (json['empresa'] as Map<String, dynamic>?) ?? const {};
    final dispositivo =
        (json['dispositivo'] as Map<String, dynamic>?) ?? const {};
    final estabelecimento =
        (json['estabelecimento'] as Map<String, dynamic>?) ?? const {};
    final ambientesJson =
        (estabelecimento['estabelecimentoAmbientes'] as List<dynamic>?) ??
            const [];
    final token = json['token'] as String? ?? '';

    return SessaoNuvem(
      token: token,
      validade: _validadeDoToken(token),
      usuario: UsuarioSessao(
        nome: usuario['nome'] as String? ?? '',
        imagem: usuario['imagem'] as String? ?? '',
      ),
      empresa: EmpresaSessao(
        id: empresa['id'] as String? ?? '',
        nome: empresa['nome'] as String? ?? '',
      ),
      dispositivo: DispositivoSessao(
        id: dispositivo['id'] as String? ?? '',
        nome: dispositivo['nome'] as String? ?? '',
      ),
      estabelecimento: EstabelecimentoSessao(
        id: estabelecimento['id'] as String? ?? '',
        nome: estabelecimento['nome'] as String? ?? '',
        ambientes: ambientesJson.map((item) {
          final mapa = item as Map<String, dynamic>;
          return AmbienteSessao(
            id: mapa['id'] as String? ?? '',
            nome: mapa['nome'] as String? ?? '',
            padrao: mapa['padrao'] as bool? ?? false,
          );
        }).toList(),
      ),
    );
  }

  /// Extrai a validade da sessão do claim `exp` do JWT (segundos desde a época,
  /// em UTC). A API de nuvem não envia a validade no corpo da resposta.
  ///
  /// Lança [FormatException] se o token não for um JWT válido ou não tiver o
  /// claim `exp`; a fonte captura e converte em falha de login.
  static DateTime _validadeDoToken(String token) {
    final partes = token.split('.');
    if (partes.length != 3) {
      throw const FormatException('Token de login inválido.');
    }
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(partes[1]))),
    ) as Map<String, dynamic>;
    final exp = payload['exp'];
    if (exp is! int) {
      throw const FormatException('Token de login sem expiração.');
    }
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
  }
}
