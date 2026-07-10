/// Garante que a base URL termine com '/', para concatenar caminhos
/// relativos (ex.: 'auth/login') sem perder o último segmento.
/// Preserva string vazia (não configurada) — appendar '/' a '' quebraria
/// as validações de "URL não configurada".
String comBarraFinal(String url) {
  if (url.isEmpty || url.endsWith('/')) return url;
  return '$url/';
}
