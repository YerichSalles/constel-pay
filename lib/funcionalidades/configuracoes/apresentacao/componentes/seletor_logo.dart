import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../../compartilhado/widgets/imagem_logo.dart';

class SeletorLogo extends ConsumerWidget {
  const SeletorLogo({super.key});

  Future<void> _escolher(BuildContext context, WidgetRef ref) async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensoesLogoAceitas,
    );
    final caminhoOrigem = resultado?.files.single.path;
    if (caminhoOrigem == null) return;
    try {
      final documentos = await getApplicationDocumentsDirectory();
      final nomeOriginal = caminhoOrigem.split(RegExp(r'[\\/]')).last;
      final extensao =
          nomeOriginal.contains('.') ? '.${nomeOriginal.split('.').last}' : '';
      final destino =
          File('${documentos.path}${Platform.pathSeparator}logo$extensao');
      await File(caminhoOrigem).copy(destino.path);
      final tema = ref.read(provedorTema);
      await ref
          .read(provedorTema.notifier)
          .atualizar(tema.copyWith(logoPath: destino.path));
    } catch (_) {
      if (context.mounted) {
        mostrarSnackbarPadrao(
            context, 'Não foi possível importar um dos arquivos.',
            erro: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = ref.watch(provedorTema);
    final logoPath = tema.logoPath;
    final temLogo = logoPath != null && File(logoPath).existsSync();
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: CoresApp.lilasClaro,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: temLogo
              ? ImagemLogo(
                  caminho: logoPath,
                  reserva: const Text('🍽️', style: TextStyle(fontSize: 28)),
                )
              : const Text('🍽️', style: TextStyle(fontSize: 28)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: BotaoSecundario(
              rotulo: 'Escolher logo', aoTocar: () => _escolher(context, ref)),
        ),
        if (temLogo) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: CoresApp.erro),
            onPressed: () => ref
                .read(provedorTema.notifier)
                .atualizar(tema.copyWith(logoPath: null)),
          ),
        ],
      ],
    );
  }
}
