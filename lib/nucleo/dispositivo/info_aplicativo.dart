import 'package:package_info_plus/package_info_plus.dart';

/// Fornece metadados do aplicativo (ex.: versão) para o payload de login.
abstract interface class InfoAplicativo {
  Future<String> versao();
}

class InfoAplicativoImpl implements InfoAplicativo {
  @override
  Future<String> versao() async => (await PackageInfo.fromPlatform()).version;
}
