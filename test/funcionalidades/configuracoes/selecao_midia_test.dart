import 'dart:io';

import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/selecao_midia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory origemDir;
  late Directory destinoDir;

  setUp(() async {
    origemDir =
        await Directory.systemTemp.createTemp('selecao_midia_origem_');
    destinoDir =
        await Directory.systemTemp.createTemp('selecao_midia_destino_');
  });

  tearDown(() async {
    if (await origemDir.exists()) await origemDir.delete(recursive: true);
    if (await destinoDir.exists()) await destinoDir.delete(recursive: true);
  });

  test(
      'copia arquivos existentes e sinaliza falha parcial quando um caminho '
      'nao existe', () async {
    final arquivo1 =
        File('${origemDir.path}${Platform.pathSeparator}a.png');
    final arquivo2 =
        File('${origemDir.path}${Platform.pathSeparator}b.jpg');
    await arquivo1.writeAsBytes([1, 2, 3]);
    await arquivo2.writeAsBytes([4, 5, 6]);
    final caminhoInexistente =
        '${origemDir.path}${Platform.pathSeparator}nao_existe.png';

    final resultado = await copiarArquivos(
        [arquivo1.path, arquivo2.path, caminhoInexistente], destinoDir);

    expect(resultado.copiados, hasLength(2));
    expect(resultado.houveFalha, isTrue);
    for (final caminho in resultado.copiados) {
      expect(File(caminho).existsSync(), isTrue);
    }
  });

  test('copia todos os arquivos validos sem sinalizar falha', () async {
    final arquivo1 =
        File('${origemDir.path}${Platform.pathSeparator}a.png');
    final arquivo2 =
        File('${origemDir.path}${Platform.pathSeparator}b.jpg');
    await arquivo1.writeAsBytes([1, 2, 3]);
    await arquivo2.writeAsBytes([4, 5, 6]);

    final resultado =
        await copiarArquivos([arquivo1.path, arquivo2.path], destinoDir);

    expect(resultado.copiados, hasLength(2));
    expect(resultado.houveFalha, isFalse);
  });
}
