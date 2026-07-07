import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';

class SeletorLogo extends ConsumerWidget {
  const SeletorLogo({super.key});

  Future<void> _escolher(WidgetRef ref) async {
    final resultado = await FilePicker.platform.pickFiles(type: FileType.image);
    final caminho = resultado?.files.single.path;
    if (caminho == null) return;
    final tema = ref.read(provedorTema);
    await ref
        .read(provedorTema.notifier)
        .atualizar(tema.copyWith(logoPath: caminho));
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
              ? Image.file(File(logoPath), fit: BoxFit.cover)
              : const Text('🍽️', style: TextStyle(fontSize: 28)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: BotaoSecundario(
              rotulo: 'Escolher logo', aoTocar: () => _escolher(ref)),
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
