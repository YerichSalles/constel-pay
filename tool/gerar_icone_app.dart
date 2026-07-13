import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rasteriza `assets/marca/logo.svg` em PNG, base para os icones do app.
///
/// Uso: flutter test tool/gerar_icone_app.dart
/// Depois: dart run flutter_launcher_icons
void main() {
  const int tamanho = 1024;
  const String origem = 'assets/marca/logo.svg';
  const String destino = 'assets/marca/icone_app.png';

  test('gera $destino a partir de $origem', () async {
    final svg = File(origem).readAsStringSync();
    final info = await vg.loadPicture(SvgStringLoader(svg), null);

    final gravador = ui.PictureRecorder();
    final tela = ui.Canvas(gravador);
    tela.scale(tamanho / info.size.width, tamanho / info.size.height);
    tela.drawPicture(info.picture);

    final imagem = await gravador.endRecording().toImage(tamanho, tamanho);
    final bytes = await imagem.toByteData(format: ui.ImageByteFormat.png);
    File(destino).writeAsBytesSync(bytes!.buffer.asUint8List());

    expect(File(destino).lengthSync(), greaterThan(0));
  });
}
