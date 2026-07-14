import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/feedback/estado_vazio.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../propaganda/dominio/entidades/publicidade_barra.dart';

/// Editor do formato "Espaço fixo de parceiro" (1C). Controlado: recebe o
/// rascunho da publicidade + callbacks, sem estado próprio de domínio.
/// Diferente do carrossel/letreiro: nunca mostra lista, ordenação, tempo ou
/// indicadores — só a mídia única do parceiro.
class EditorParceiro extends StatelessWidget {
  const EditorParceiro({
    super.key,
    required this.publicidade,
    required this.aoAlterarMidia,
    required this.aoRemoverMidia,
    required this.aoAjustarMidia,
  });

  final PublicidadeBarra publicidade;
  final VoidCallback aoAlterarMidia;
  final VoidCallback aoRemoverMidia;
  final VoidCallback aoAjustarMidia;

  Widget _rotulo(String texto) => Text(texto,
      style: const TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario));

  @override
  Widget build(BuildContext context) {
    final midia = publicidade.midiaParceiro;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configure o espaço fixo',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        const Text(
          'Exiba uma única publicidade continuamente durante o atendimento.',
          style: TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
        ),
        const SizedBox(height: 12),
        // Dicas de geração da arte sempre visíveis — inclusive antes de
        // adicionar a mídia, que é quando o operador produz o arquivo.
        Container(
          key: const Key('dicas_parceiro'),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CoresApp.lilasClaro,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _rotulo('Recomendado: 1040 × 128 px.'),
              const SizedBox(height: 4),
              _rotulo('Formatos aceitos: JPG, PNG, WebP e GIF '
                  '(o GIF anima em loop contínuo).'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (midia == null)
          EstadoVazio(
            emoji: '🎯',
            titulo: 'Nenhum conteúdo configurado.',
            acao: BotaoSecundario(
                rotulo: 'Alterar mídia',
                aoTocar: aoAlterarMidia,
                expandido: false),
          )
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1040 / 128,
              child: Image.file(
                File(midia.caminho),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: CoresApp.lilasClaro,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _InfoMidiaParceiro(caminho: midia.caminho),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BotaoPrimario(
                  rotulo: 'Alterar mídia',
                  aoTocar: aoAlterarMidia,
                  expandido: false),
              TextButton(
                onPressed: aoAjustarMidia,
                child: const Text('Ajustar…'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: CoresApp.erro),
                onPressed: aoRemoverMidia,
                child: const Text('Remover mídia'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Linha de informações da mídia do parceiro: prioriza o que é útil ao
/// operador ("GIF carregado • 1040 × 128 px") e rebaixa o nome técnico do
/// arquivo a texto secundário com tooltip. As dimensões são resolvidas do
/// próprio arquivo; se ele não decodificar, a linha fica só com o tipo.
class _InfoMidiaParceiro extends StatefulWidget {
  const _InfoMidiaParceiro({required this.caminho});

  final String caminho;

  @override
  State<_InfoMidiaParceiro> createState() => _InfoMidiaParceiroState();
}

class _InfoMidiaParceiroState extends State<_InfoMidiaParceiro> {
  Size? _dimensoes;
  ImageStream? _stream;
  ImageStreamListener? _ouvinte;

  @override
  void initState() {
    super.initState();
    _resolver();
  }

  @override
  void didUpdateWidget(covariant _InfoMidiaParceiro antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.caminho != widget.caminho) {
      _pararDeOuvir();
      setState(() => _dimensoes = null);
      _resolver();
    }
  }

  void _resolver() {
    final stream =
        FileImage(File(widget.caminho)).resolve(ImageConfiguration.empty);
    final ouvinte = ImageStreamListener(
      (info, _) {
        if (mounted) {
          setState(() => _dimensoes =
              Size(info.image.width.toDouble(), info.image.height.toDouble()));
        }
        info.dispose();
      },
      // Arquivo ausente ou inválido: sem dimensões, sem erro na tela (a
      // prévia acima já mostra o placeholder de imagem quebrada).
      onError: (_, __) {},
    );
    stream.addListener(ouvinte);
    _stream = stream;
    _ouvinte = ouvinte;
  }

  void _pararDeOuvir() {
    final ouvinte = _ouvinte;
    if (ouvinte != null) _stream?.removeListener(ouvinte);
    _stream = null;
    _ouvinte = null;
  }

  @override
  void dispose() {
    _pararDeOuvir();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nomeArquivo = widget.caminho.split(RegExp(r'[\\/]')).last;
    final ehGif = widget.caminho.toLowerCase().endsWith('.gif');
    final tipo = ehGif ? 'GIF carregado' : 'Imagem carregada';
    final dimensoes = _dimensoes;
    final principal = dimensoes == null
        ? tipo
        : '$tipo • ${dimensoes.width.round()} × ${dimensoes.height.round()} px';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(principal,
            style:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Tooltip(
          message: nomeArquivo,
          child: Text(nomeArquivo,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 10.5, color: CoresApp.textoSecundario)),
        ),
      ],
    );
  }
}
