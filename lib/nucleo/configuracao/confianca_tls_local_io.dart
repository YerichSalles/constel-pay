import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../utils/rede_local.dart';

/// Aceita certificado TLS não confiável somente quando o host é de rede
/// local/privada (servidor APL da loja usa certificado self-signed).
/// Hosts públicos (API na nuvem) mantêm a validação TLS completa.
/// Preserva adaptadores customizados (fakes de teste) intactos.
void permitirCertificadoLocalAutoAssinado(Dio dio) {
  final adaptador = dio.httpClientAdapter;
  if (adaptador is! IOHttpClientAdapter) return;
  adaptador.createHttpClient = () => HttpClient()
    ..badCertificateCallback =
        (X509Certificate certificado, String host, int porta) =>
            hostRedeLocal(host);
}
