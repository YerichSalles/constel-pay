import 'dart:io';

/// Instala um [HttpOverrides] global que faz o app aceitar QUALQUER
/// certificado TLS em todas as conexões `dart:io` — inclusive as fotos dos
/// itens carregadas por `Image.network`, que não passam pelo cliente Dio e
/// por isso não eram cobertas pelo bypass anterior.
///
/// AVISO DE SEGURANÇA: sem validar o certificado, o app não garante a
/// identidade do servidor. A conexão continua criptografada, mas fica exposta
/// a man-in-the-middle. Adotado a pedido para o terminal comunicar (API na
/// nuvem e imagens no S3) em máquinas cujo repositório de raízes está
/// desatualizado; a alternativa segura é corrigir o certificado (SAN/cadeia)
/// ou instalar as raízes no PC.
void instalarConfiancaTlsGlobal() {
  HttpOverrides.global = _AceitaQualquerCertificado();
}

class _AceitaQualquerCertificado extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate certificado, String host, int porta) => true;
  }
}
