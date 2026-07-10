import '../../dominio/entidades/sessao_nuvem.dart';

/// Converte a resposta crua da API de nuvem (`POST auth/login`) na entidade
/// [SessaoNuvem], extraindo apenas os campos usados pelo app.
abstract final class RespostaLoginNuvem {
  static SessaoNuvem paraEntidade(Map<String, dynamic> json) {
    final estabelecimento =
        (json['estabelecimento'] as Map<String, dynamic>?) ?? const {};
    final empresa = (json['empresa'] as Map<String, dynamic>?) ?? const {};
    final dispositivo = (json['dispositivo'] as Map<String, dynamic>?) ?? const {};
    final ambientesJson =
        (estabelecimento['estabelecimentoAmbientes'] as List<dynamic>?) ??
            const [];

    return SessaoNuvem(
      token: json['token'] as String? ?? '',
      validade: DateTime.parse(json['validade'] as String),
      usuario: UsuarioSessao(
        nome: json['nome'] as String? ?? '',
        credencial: json['credencial'] as String? ?? '',
        imagem: json['imagem'] as String? ?? '',
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
}
