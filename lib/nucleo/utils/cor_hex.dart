final RegExp _hexSeisDigitos = RegExp(r'^[0-9A-F]{6}$');

/// Normaliza uma cor hexadecimal digitada pelo operador: aceita com ou sem
/// `#`, maiúsculas ou minúsculas, e devolve sempre `#RRGGBB` em maiúsculas.
/// Devolve null quando o valor não é uma cor válida.
String? normalizarCorHex(String entrada) {
  final limpo = entrada.trim().replaceAll('#', '').toUpperCase();
  if (!_hexSeisDigitos.hasMatch(limpo)) return null;
  return '#$limpo';
}
