/// Leitura tolerante de JSON de APIs: campo ausente ou com tipo inesperado
/// vira valor neutro — nunca lança. Fonte única desses helpers; não duplicar
/// cópias locais em mappers/entidades (a leniência precisa ser idêntica em
/// leitura, faturamento e persistência para os valores não divergirem).
abstract final class JsonLeniente {
  static String texto(dynamic v) => v is String ? v : '';

  static int inteiro(dynamic v) => v is num ? v.toInt() : 0;

  static Map<String, dynamic> mapa(dynamic v) =>
      v is Map<String, dynamic> ? v : const {};

  static List<Map<String, dynamic>> lista(dynamic v) =>
      v is List ? v.whereType<Map<String, dynamic>>().toList() : const [];

  /// Dinheiro em reais (double da API) para centavos. O `.round()` corrige
  /// artefatos de ponto flutuante (ex.: 5.390000000000001 * 100 -> 539).
  static int centavos(dynamic v) => v is num ? (v * 100).round() : 0;
}
