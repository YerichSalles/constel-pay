import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

/// Resultado da seleção: caminhos copiados + indicação de falha parcial.
class ResultadoSelecaoMidia {
  const ResultadoSelecaoMidia(
      {required this.copiados, required this.houveFalha});

  final List<String> copiados;
  final bool houveFalha;
}

/// Copia cada arquivo de [origens] para dentro de [destino], com um nome
/// novo (uuid) para nunca colidir com outro import. Puro (sem FilePicker),
/// o que permite testar a lógica de cópia/falha parcial isoladamente.
/// Arquivos ilegíveis ou removidos entre a escolha e a cópia são ignorados
/// no resultado, mas sinalizados em [ResultadoSelecaoMidia.houveFalha].
Future<ResultadoSelecaoMidia> copiarArquivos(
    List<String> origens, Directory destino) async {
  await destino.create(recursive: true);
  final copiados = <String>[];
  var houveFalha = false;
  for (final origem in origens) {
    try {
      final nomeOriginal = origem.split(RegExp(r'[\\/]')).last;
      final extensao =
          nomeOriginal.contains('.') ? '.${nomeOriginal.split('.').last}' : '';
      final caminhoDestino =
          '${destino.path}${Platform.pathSeparator}${_uuid.v4()}$extensao';
      await File(origem).copy(caminhoDestino);
      copiados.add(caminhoDestino);
    } catch (_) {
      houveFalha = true;
    }
  }
  return ResultadoSelecaoMidia(copiados: copiados, houveFalha: houveFalha);
}

/// Abre o seletor de arquivos do sistema restrito a [extensoes] e copia os
/// arquivos escolhidos para a pasta `propaganda` dos documentos do app,
/// devolvendo os novos caminhos já persistentes (mesma mecânica usada por
/// `SecaoConteudoTela` e pela seção da barra superior).
Future<ResultadoSelecaoMidia> escolherECopiarMidias({
  required List<String> extensoes,
  bool multiplas = true,
}) async {
  // lockParentWindow: no Windows o pickFiles bloqueia a UI e, sem janela
  // pai, o diálogo nativo pode abrir ATRÁS do app (quase tela cheia no
  // totem) — o app parece congelado para sempre. Preso à janela pai, o
  // diálogo vem modal e na frente.
  final resultado = await FilePicker.platform.pickFiles(
    allowMultiple: multiplas,
    type: FileType.custom,
    allowedExtensions: extensoes,
    lockParentWindow: true,
  );
  final caminhos =
      resultado?.files.map((f) => f.path).whereType<String>().toList() ??
          const [];
  if (caminhos.isEmpty) {
    return const ResultadoSelecaoMidia(copiados: [], houveFalha: false);
  }
  final documentos = await getApplicationDocumentsDirectory();
  final diretorio =
      Directory('${documentos.path}${Platform.pathSeparator}propaganda');
  return copiarArquivos(caminhos, diretorio);
}
