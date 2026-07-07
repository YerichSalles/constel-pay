abstract final class Validadores {
  static bool urlValida(String valor) {
    final uri = Uri.tryParse(valor.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static bool pinValido(String valor) => RegExp(r'^\d{4,6}$').hasMatch(valor);
}
