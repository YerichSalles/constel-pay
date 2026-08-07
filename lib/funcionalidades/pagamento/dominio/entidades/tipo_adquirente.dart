/// Adquirente embarcada na build atual.
///
/// O canal nativo tem nome fixo em qualquer build, então o app NÃO descobre a
/// adquirente pelo canal: ela circula como estado explícito, porque o
/// comportamento de negócio diverge (na Stone o PIX é cobrado na maquininha;
/// na genérica é QR Code na tela).
enum TipoAdquirente {
  stone,
  generico;

  /// Único ponto do app que lê `--dart-define=ADQUIRENTE=...`. Daqui em diante
  /// o valor circula pelo `provedorAdquirente`; nenhum outro arquivo consulta
  /// a flag de build.
  ///
  /// Sem flag cai em [generico] — a build em produção e a dos testes. Nunca
  /// assumir uma adquirente real por omissão.
  static TipoAdquirente doAmbiente() => switch (const String.fromEnvironment(
        'ADQUIRENTE',
        defaultValue: 'generico',
      )) {
        'stone' => TipoAdquirente.stone,
        _ => TipoAdquirente.generico,
      };

  String get rotulo => switch (this) {
        TipoAdquirente.stone => 'Stone',
        TipoAdquirente.generico => 'Genérico',
      };
}
