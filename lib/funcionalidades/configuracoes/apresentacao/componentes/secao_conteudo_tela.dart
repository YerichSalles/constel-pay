import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/feedback/estado_vazio.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../dominio/entidades/tema_personalizado.dart';
import '../../../propaganda/apresentacao/paginas/pagina_propaganda.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';
import '../controladores/controlador_midias.dart';
import 'dialogo_ajuste_midia.dart';
import 'secao_configuracoes.dart';
import 'selecao_midia.dart';

/// Extensões aceitas para o conteúdo da tela de espera: imagens, GIF e
/// vídeo (a barra superior aceita só imagem/GIF, por isso não compartilha
/// esta lista).
const List<String> _extensoesConteudoTela = [
  'jpg',
  'jpeg',
  'png',
  'webp',
  'gif',
  'mp4',
  'mov',
  'webm',
  'mkv'
];

/// Seção "Conteúdo da tela" da aba Propaganda: lista de imagens, GIFs e
/// vídeos exibidos enquanto o terminal aguarda um atendimento, com
/// orientação, ajuste de enquadramento, ordenação e ativação por item.
class SecaoConteudoTela extends ConsumerWidget {
  const SecaoConteudoTela({super.key});

  Future<void> _adicionar(BuildContext context, WidgetRef ref) async {
    final resultado =
        await escolherECopiarMidias(extensoes: _extensoesConteudoTela);
    if (resultado.houveFalha && context.mounted) {
      mostrarSnackbarPadrao(
          context, 'Não foi possível importar um dos arquivos.',
          erro: true);
    }
    if (resultado.copiados.isEmpty) return;
    await ref
        .read(provedorMidias.notifier)
        .adicionarArquivos(resultado.copiados);
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
        orientacao: tema.orientacaoTela,
        aoSalvar: ({
          required AjusteMidia ajuste,
          required FundoMidia fundo,
          required AncoraMidia ancora,
          required int zoomPercentual,
          required int rotacaoGraus,
        }) =>
            controlador.definirEnquadramento(midia.id,
                ajuste: ajuste,
                fundo: fundo,
                ancora: ancora,
                zoomPercentual: zoomPercentual,
                rotacaoGraus: rotacaoGraus),
      ),
    );
  }

  /// Nome amigável do card: `Imagem N` / `Vídeo N` / `GIF N`, onde N é a
  /// posição (1-based) na lista e GIF é detectado pela extensão do arquivo.
  String _nomeAmigavel(MidiaPropaganda midia, int posicao) {
    final ehGif = midia.caminho.toLowerCase().endsWith('.gif');
    final tipo = ehGif
        ? 'GIF'
        : midia.tipo == TipoMidia.video
            ? 'Vídeo'
            : 'Imagem';
    return '$tipo $posicao';
  }

  Widget _cardMidia(
      BuildContext context, WidgetRef ref, MidiaPropaganda midia, int posicao) {
    final controlador = ref.read(provedorMidias.notifier);
    final nomeArquivo = midia.caminho.split(RegExp(r'[\\/]')).last;
    final nomeAmigavel = _nomeAmigavel(midia, posicao);
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
                Text(nomeAmigavel,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                Text(nomeArquivo,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10.5, color: CoresApp.textoSecundario)),
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
          Tooltip(
            message: 'Mover para cima',
            child: IconButton(
                icon: const Icon(Icons.arrow_upward, size: 18),
                onPressed: () => controlador.mover(midia.id, -1)),
          ),
          Tooltip(
            message: 'Mover para baixo',
            child: IconButton(
                icon: const Icon(Icons.arrow_downward, size: 18),
                onPressed: () => controlador.mover(midia.id, 1)),
          ),
          Tooltip(
            message: 'Ativar ou desativar',
            child: Switch(
                value: midia.ativo,
                onChanged: (_) => controlador.alternarAtivo(midia.id)),
          ),
          Tooltip(
            message: 'Remover',
            child: IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: CoresApp.erro, size: 20),
              onPressed: () async {
                final confirmar = await mostrarDialogoConfirmacao(
                  context,
                  titulo: 'Remover mídia?',
                  mensagem: 'Esta mídia deixará de ser exibida no terminal.',
                  confirmar: 'Remover',
                  destrutivo: true,
                );
                if (confirmar) await controlador.remover(midia.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(provedorMidias);
    final tema = ref.watch(provedorTema);
    final deitada = tema.orientacaoTela == OrientacaoTela.horizontal;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SecaoConfiguracoes(
          titulo: 'Conteúdo da tela',
          descricao: 'Configure as imagens, GIFs e vídeos exibidos enquanto '
              'o terminal estiver aguardando um atendimento.',
          filho: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Tela do totem:',
                      style: TextStyle(
                          fontSize: 11.5, color: CoresApp.textoSecundario)),
                  SegmentedButton<OrientacaoTela>(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    segments: const [
                      ButtonSegment(
                          value: OrientacaoTela.vertical, label: Text('Em pé')),
                      ButtonSegment(
                          value: OrientacaoTela.horizontal,
                          label: Text('Deitada')),
                    ],
                    selected: {tema.orientacaoTela},
                    onSelectionChanged: (selecao) => ref
                        .read(provedorTema.notifier)
                        .atualizar(
                            tema.copyWith(orientacaoTela: selecao.single)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                deitada
                    ? 'Formato indicado para terminais horizontais.'
                    : 'Formato indicado para terminais verticais.',
                style: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Ideal: mídia ${deitada ? 'deitada (paisagem), 1920 x 1080' : 'em pé (retrato), 1080 x 1920'} px. '
                'Vídeos em MP4 com codec H.264, 30 fps e no máximo 6 Mbps. GIF é '
                'aceito e roda em loop até a duração acabar. No ajuste Automático a '
                'mídia aparece inteira, sem corte: a sobra vira um fundo borrado da '
                'própria imagem (vídeos usam a cor primária do tema). Toque em '
                '"Ajustar…" para trocar o modo, o fundo da sobra, o corte, o zoom '
                'e o giro.',
                style: const TextStyle(
                    fontSize: 11.5, color: CoresApp.textoSecundario),
              ),
              const SizedBox(height: 14),
              if (estado.midias.isEmpty && !estado.carregando)
                const EstadoVazio(
                  emoji: '🎬',
                  titulo: 'Nenhuma mídia configurada',
                  mensagem:
                      'Sem mídias, a tela de espera mostra a logo, o nome '
                      'do restaurante e a faixa de pagamento.',
                )
              else
                ...estado.midias.asMap().entries.map((entrada) =>
                    _cardMidia(context, ref, entrada.value, entrada.key + 1)),
              const SizedBox(height: 12),
              BotaoPrimario(
                  rotulo: '+ Adicionar mídia',
                  aoTocar: () => _adicionar(context, ref)),
              const SizedBox(height: 10),
              BotaoSecundario(
                rotulo: 'Visualizar sequência',
                aoTocar: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const PaginaPropaganda(preview: true)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
