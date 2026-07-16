import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../../../compartilhado/widgets/icone_emoji.dart';
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

  Future<void> _remover(BuildContext context, WidgetRef ref) async {
    final confirmado = await mostrarDialogoConfirmacao(
      context,
      titulo: 'Remover a logo?',
      mensagem: 'A logo atual deixará de ser exibida nas telas do terminal.',
      confirmar: 'Remover',
      destrutivo: true,
    );
    if (!confirmado) return;
    final tema = ref.read(provedorTema);
    await ref
        .read(provedorTema.notifier)
        .atualizar(tema.copyWith(logoPath: null));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = ref.watch(provedorTema);
    final logoPath = tema.logoPath;
    final temLogo = logoPath != null && File(logoPath).existsSync();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Logo do estabelecimento',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Fundo neutro cinza-claro: deixa visíveis tanto logos claras
            // quanto escuras, sem cortar a imagem.
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CoresApp.bordaCard),
              ),
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: temLogo
                  ? ImagemLogo(
                      caminho: logoPath,
                      reserva: const IconeEmoji('🍽️', tamanho: 30),
                    )
                  : const IconeEmoji('🍽️', tamanho: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  BotaoSecundario(
                    rotulo: temLogo ? 'Alterar logo' : 'Adicionar logo',
                    aoTocar: () => _escolher(context, ref),
                    expandido: false,
                  ),
                  if (temLogo)
                    TextButton.icon(
                      onPressed: () => _remover(context, ref),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Remover logo'),
                      style: TextButton.styleFrom(
                        foregroundColor: CoresApp.erro,
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Recomendado: imagem quadrada de 512 × 512 px, em PNG ou SVG com '
          'fundo transparente.',
          style: TextStyle(fontSize: 11, color: CoresApp.textoSecundario),
        ),
      ],
    );
  }
}
