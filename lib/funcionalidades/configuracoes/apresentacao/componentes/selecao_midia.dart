import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

/// Copia o arquivo escolhido para a pasta `propaganda` dos documentos do
/// app, com um nome novo (uuid) para nunca colidir com outro import.
Future<String> _copiarParaDiretorioApp(String caminhoOrigem) async {
  final documentos = await getApplicationDocumentsDirectory();
  final diretorio =
      Directory('${documentos.path}${Platform.pathSeparator}propaganda');
  await diretorio.create(recursive: true);
  final nomeOriginal = caminhoOrigem.split(RegExp(r'[\\/]')).last;
  final extensao =
      nomeOriginal.contains('.') ? '.${nomeOriginal.split('.').last}' : '';
  final destino =
      File('${diretorio.path}${Platform.pathSeparator}${_uuid.v4()}$extensao');
  await File(caminhoOrigem).copy(destino.path);
  return destino.path;
}

/// Abre o seletor de arquivos do sistema restrito a [extensoes] e copia os
/// arquivos escolhidos para a pasta de mídias do app, devolvendo os novos
/// caminhos já persistentes (mesma mecânica usada por `SecaoConteudoTela` e
/// pela seção da barra superior). Arquivos que falharem ao copiar são
/// simplesmente ignorados no resultado.
Future<List<String>> escolherECopiarMidias({
  required List<String> extensoes,
  bool multiplas = true,
}) async {
  final resultado = await FilePicker.platform.pickFiles(
    allowMultiple: multiplas,
    type: FileType.custom,
    allowedExtensions: extensoes,
  );
  final caminhos =
      resultado?.files.map((f) => f.path).whereType<String>().toList() ??
          const [];
  final copiados = <String>[];
  for (final caminho in caminhos) {
    try {
      copiados.add(await _copiarParaDiretorioApp(caminho));
    } catch (_) {
      // Arquivo ilegível ou removido entre a escolha e a cópia: ignora e
      // segue com os demais.
    }
  }
  return copiados;
}
