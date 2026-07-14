import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/feedback/estado_vazio.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';
import '../../../propaganda/dominio/entidades/publicidade_barra.dart';
import 'dialogo_ajuste_midia.dart';
import 'secao_configuracoes.dart';

/// Editor do formato "Carrossel de banners" (1A). Controlado: recebe o
/// rascunho da publicidade + callbacks, sem estado próprio de domínio.
class EditorCarrossel extends StatelessWidget {
  const EditorCarrossel({
    super.key,
    required this.publicidade,
    required this.aoDefinirIntervalo,
    required this.aoDefinirTransicao,
    required this.aoAdicionarBanners,
    required this.aoAlternarBanner,
    required this.aoMoverBanner,
    required this.aoRemoverBanner,
    required this.aoAjustarBanner,
  });

  final PublicidadeBarra publicidade;
  final ValueChanged<int> aoDefinirIntervalo;
  final ValueChanged<TransicaoCarrossel> aoDefinirTransicao;
  final VoidCallback aoAdicionarBanners;
  final ValueChanged<String> aoAlternarBanner;
  final void Function(String id, int delta) aoMoverBanner;
  final ValueChanged<String> aoRemoverBanner;
  final ValueChanged<MidiaPropaganda> aoAjustarBanner;

  static const Map<TransicaoCarrossel, String> _rotulosTransicao = {
    TransicaoCarrossel.suave: 'Suave',
    TransicaoCarrossel.deslizar: 'Deslizar',
    TransicaoCarrossel.semAnimacao: 'Sem animação',
  };

  Widget _rotulo(String texto) => Text(texto,
      style: const TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario));

  Widget _dropdown<T>({
    required String rotulo,
    required T valor,
    required List<T> opcoes,
    required String Function(T) rotuloDe,
    required ValueChanged<T> aoMudar,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _rotulo(rotulo),
        const SizedBox(width: 8),
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: valor,
            isDense: true,
            items: [
              for (final opcao in opcoes)
                DropdownMenuItem<T>(value: opcao, child: Text(rotuloDe(opcao))),
            ],
            onChanged: (novo) {
              if (novo != null) aoMudar(novo);
            },
          ),
        ),
      ],
    );
  }

  Widget _cardBanner(MidiaPropaganda banner, int posicao) {
    final nomeArquivo = banner.caminho.split(RegExp(r'[\\/]')).last;
    return Container(
      key: ValueKey(banner.id),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CoresApp.bordaCard),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.file(
              File(banner.caminho),
              width: 64,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 64,
                height: 32,
                color: CoresApp.lilasClaro,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined, size: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Banner $posicao',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                Text(nomeArquivo,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10.5, color: CoresApp.textoSecundario)),
                Row(
                  children: [
                    Flexible(
                      child: Text(resumoEnquadramento(banner),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 11.5, color: CoresApp.textoSecundario)),
                    ),
                    Tooltip(
                      message: 'Ajustar enquadramento',
                      child: TextButton(
                        style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8)),
                        onPressed: () => aoAjustarBanner(banner),
                        child: const Text('Ajustar…',
                            style: TextStyle(fontSize: 11.5)),
                      ),
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
                onPressed: () => aoMoverBanner(banner.id, -1)),
          ),
          Tooltip(
            message: 'Mover para baixo',
            child: IconButton(
                icon: const Icon(Icons.arrow_downward, size: 18),
                onPressed: () => aoMoverBanner(banner.id, 1)),
          ),
          Tooltip(
            message: 'Ativar ou desativar',
            child: Switch(
                value: banner.ativo,
                onChanged: (_) => aoAlternarBanner(banner.id)),
          ),
          Tooltip(
            message: 'Remover',
            child: IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: CoresApp.erro, size: 20),
              onPressed: () => aoRemoverBanner(banner.id),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final banners = publicidade.banners;
    return SecaoConfiguracoes(
      titulo: 'Carrossel de banners',
      descricao: 'Alterne automaticamente campanhas dentro da barra superior.',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _dropdown<int>(
                rotulo: 'Tempo entre banners',
                valor: publicidade.intervaloSegundos,
                opcoes: intervalosCarrossel,
                rotuloDe: (v) => '$v segundos',
                aoMudar: aoDefinirIntervalo,
              ),
              _dropdown<TransicaoCarrossel>(
                rotulo: 'Transição',
                valor: publicidade.transicao,
                opcoes: TransicaoCarrossel.values,
                rotuloDe: (v) => _rotulosTransicao[v]!,
                aoMudar: aoDefinirTransicao,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Banners',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 8),
          if (banners.isEmpty)
            const EstadoVazio(
                emoji: '🖼️', titulo: 'Nenhum conteúdo configurado.')
          else
            ...banners
                .asMap()
                .entries
                .map((entrada) => _cardBanner(entrada.value, entrada.key + 1)),
          const SizedBox(height: 8),
          _rotulo('Recomendado: 384 × 192 px, proporção 2:1.'),
          const SizedBox(height: 4),
          _rotulo(
              'Recomendamos até 5 banners ativos para manter uma rotação rápida.'),
          const SizedBox(height: 12),
          BotaoSecundario(
              rotulo: '+ Adicionar banner', aoTocar: aoAdicionarBanners),
        ],
      ),
    );
  }
}
