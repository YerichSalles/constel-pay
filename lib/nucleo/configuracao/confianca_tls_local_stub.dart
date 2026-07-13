import 'package:dio/dio.dart';

/// No web quem valida TLS é o navegador; não há o que configurar no Dio.
void permitirCertificadoLocalAutoAssinado(Dio dio) {}
