import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../utils/registrador.dart';

/// Faz o app aceitar QUALQUER certificado TLS, mesmo não confiável: cadeia sem
/// a raiz no repositório do Windows, certificado self-signed do APL local ou
/// certificado sem SAN / com host divergente.
///
/// AVISO DE SEGURANÇA: sem validar o certificado, o app não garante a
/// identidade do servidor. A conexão continua criptografada, mas fica exposta
/// a man-in-the-middle. Adotado a pedido para o terminal comunicar em máquinas
/// cujo repositório de raízes está desatualizado; a alternativa segura é
/// corrigir o certificado (SAN) ou instalar as raízes no PC.
/// Preserva adaptadores customizados (fakes de teste) intactos.
void aceitarQualquerCertificado(Dio dio) {
  final adaptador = dio.httpClientAdapter;
  if (adaptador is! IOHttpClientAdapter) return;
  adaptador.createHttpClient = () => HttpClient()
    ..badCertificateCallback =
        (X509Certificate certificado, String host, int porta) {
      registrador.w('TLS: certificado não confiável aceito para $host:$porta');
      return true;
    };
}
