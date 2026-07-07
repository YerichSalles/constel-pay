import 'dart:convert';

import 'package:crypto/crypto.dart';

abstract final class HasherPin {
  static const String _sal = 'constel-pay';

  static String gerar(String pin) =>
      sha256.convert(utf8.encode('$_sal:$pin')).toString();

  static bool verificar(String pin, String hash) => gerar(pin) == hash;
}
