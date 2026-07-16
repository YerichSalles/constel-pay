abstract final class Validadores {
  static bool urlValida(String valor) {
    final uri = Uri.tryParse(valor.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static bool uuidValido(String valor) => RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}'
        r'-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(valor.trim());
}
