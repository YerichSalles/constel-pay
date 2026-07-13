/// Identifica hosts de rede local/privada: loopback, faixas RFC 1918,
/// link-local e ULA IPv6. Usado para aceitar o certificado self-signed do
/// servidor APL da loja — hosts públicos nunca entram aqui.
bool hostRedeLocal(String host) {
  final normalizado =
      host.toLowerCase().replaceAll('[', '').replaceAll(']', '');
  if (normalizado == 'localhost') return true;
  if (normalizado.contains(':')) {
    return normalizado == '::1' ||
        normalizado.startsWith('fe80:') ||
        normalizado.startsWith('fc') ||
        normalizado.startsWith('fd');
  }
  final octetos = normalizado.split('.').map(int.tryParse).toList();
  if (octetos.length != 4 ||
      octetos.any((o) => o == null || o < 0 || o > 255)) {
    return false;
  }
  final a = octetos[0]!;
  final b = octetos[1]!;
  return a == 127 ||
      a == 10 ||
      (a == 192 && b == 168) ||
      (a == 172 && b >= 16 && b <= 31) ||
      (a == 169 && b == 254);
}
