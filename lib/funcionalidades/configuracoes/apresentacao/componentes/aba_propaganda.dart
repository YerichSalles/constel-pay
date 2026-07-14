import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/feedback/estado_vazio.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../../propaganda/apresentacao/paginas/pagina_propaganda.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';
import '../controladores/controlador_midias.dart';
import 'dialogo_ajuste_midia.dart';

class AbaPropaganda extends ConsumerWidget {
  const AbaPropaganda({super.key});

  static const Uuid _uuid = Uuid();

  Future<String> _copiarParaDiretorioApp(String caminhoOrigem) async {
    final documentos = await getApplicationDocumentsDirectory();
    final diretorio =
        Directory('${documentos.path}${Platform.pathSeparator}propaganda');
    await diretorio.create(recursive: true);
    final nomeOriginal = caminhoOrigem.split(RegExp(r'[\\/]')).last;
    final extensao =
        nomeOriginal.contains('.') ? '.${nomeOriginal.split('.').last}' : '';
    final destino = File(
        '${diretorio.path}${Platform.pathSeparator}${_uuid.v4()}$extensao');
    await File(caminhoOrigem).copy(destino.path);
    return destino.path;
  }

  Future<void> _adicionar(BuildContext context, WidgetRef ref) async {
    final resultado = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'gif',
        'mp4',
        'mov',
        'webm',
        'mkv'
      ],
    );
    final caminhos =
        resultado?.files.map((f) => f.path).whereType<String>().toList() ??
            const [];
    if (caminhos.isEmpty) return;
    final copiados = <String>[];
    var houveFalha = false;
    for (final caminho in caminhos) {
      try {
        copiados.add(await _copiarParaDiretorioApp(caminho));
      } catch (_) {
        houveFalha = true;
      }
    }
    if (houveFalha && context.mounted) {
      mostrarSnackbarPadrao(
          context, 'Não foi possível importar um dos arquivos.',
          erro: true);
    }
    if (copiados.isNotEmpty) {
      await ref.read(provedorMidias.notifier).adicionarArquivos(copiados);
    }
  }

  void _abrirAjuste(
      BuildContext context, WidgetRef ref, MidiaPropaganda midia) {
    final tema = ref.read(provedorTema);
    final corTema = TemaConstel.corDeHex(
        tema.corPrimaria, Theme.of(context).colorScheme.primary);
    final controlador = ref.read(provedorMidias.notifier);
    showDialog<void>(
      context: context,
      builder: (_) => DialogoAjusteMidia(
        midia: midia,
        corTema: corTema,
        aoSalvar: ({
          required AjusteMidia ajuste,
          required FundoMidia fundo,
          required AncoraMidia ancora,
          required int zoomPercentual,
        }) =>
            controlador.definirEnquadramento(midia.id,
                ajuste: ajuste,
                fundo: fundo,
                ancora: ancora,
                zoomPercentual: zoomPercentual),
      ),
    );
  }

  Widget _cardMidia(
      BuildContext context, WidgetRef ref, MidiaPropaganda midia) {
    final controlador = ref.read(provedorMidias.notifier);
    final nomeArquivo = midia.caminho.split(RegExp(r'[\\/]')).last;
    return Container(
      key: ValueKey(midia.id),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CoresApp.bordaCard),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CoresApp.lilasClaro,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(midia.tipo == TipoMidia.video ? '🎬' : '🖼️',
                style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nomeArquivo,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  children: [
                    if (midia.tipo == TipoMidia.imagem)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: const Text('Duração:',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: CoresApp.textoSecundario)),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: SizedBox(
                              width: 44,
                              child: TextFormField(
                                initialValue: '${midia.duracaoSegundos}',
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 6)),
                                onFieldSubmitted: (valor) =>
                                    controlador.definirDuracao(
                                        midia.id,
                                        int.tryParse(valor) ??
                                            midia.duracaoSegundos),
                              ),
                            ),
                          ),
                          const Text(' s',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: CoresApp.textoSecundario)),
                        ],
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(resumoEnquadramento(midia),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  color: CoresApp.textoSecundario)),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8)),
                          onPressed: () => _abrirAjuste(context, ref, midia),
                          child: const Text('Ajustar…',
                              style: TextStyle(fontSize: 11.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
              icon: const Icon(Icons.arrow_upward, size: 18),
              onPressed: () => controlador.mover(midia.id, -1)),
          IconButton(
              icon: const Icon(Icons.arrow_downward, size: 18),
              onPressed: () => controlador.mover(midia.id, 1)),
          Switch(
              value: midia.ativo,
              onChanged: (_) => controlador.alternarAtivo(midia.id)),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: CoresApp.erro, size: 20),
            onPressed: () async {
              final confirmar = await mostrarDialogoConfirmacao(
                context,
                titulo: 'Remover mídia?',
                mensagem: '"$nomeArquivo" sairá da playlist de propaganda.',
                confirmar: 'Remover',
                destrutivo: true,
              );
              if (confirmar) await controlador.remover(midia.id);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(provedorMidias);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Ideal: mídia em pé (retrato), 1080 x 1920 px. Vídeos em MP4 com '
          'codec H.264, 30 fps e no máximo 6 Mbps. GIF é aceito e roda em '
          'loop até a duração acabar. No ajuste Automático a mídia aparece '
          'inteira, sem corte: a sobra vira um fundo borrado da própria '
          'imagem (vídeos usam a cor primária do tema). Toque em "Ajustar…" '
          'para trocar o modo, o fundo da sobra, o corte e o zoom.',
          style: TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
        ),
        const SizedBox(height: 14),
        if (estado.midias.isEmpty && !estado.carregando)
          const EstadoVazio(
            emoji: '🎬',
            titulo: 'Nenhuma mídia configurada',
            mensagem: 'Sem mídias, a tela de espera mostra a logo, o nome '
                'do restaurante e a faixa de pagamento.',
          )
        else
          ...estado.midias.map((midia) => _cardMidia(context, ref, midia)),
        const SizedBox(height: 12),
        BotaoPrimario(
            rotulo: 'Adicionar mídias',
            aoTocar: () => _adicionar(context, ref)),
        const SizedBox(height: 10),
        BotaoSecundario(
          rotulo: 'Visualizar',
          aoTocar: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
                builder: (_) => const PaginaPropaganda(preview: true)),
          ),
        ),
      ],
    );
  }
}
