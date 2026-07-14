import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/feedback/estado_vazio.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../propaganda/dominio/entidades/publicidade_barra.dart';
import 'secao_configuracoes.dart';

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
    return SecaoConfiguracoes(
      titulo: 'Espaço fixo de parceiro',
      descricao:
          'Exiba uma única publicidade continuamente durante o atendimento.',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Publicidade atual',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 10),
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
            Text(midia.caminho.split(RegExp(r'[\\/]')).last,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            _rotulo('Recomendado: 1040 × 128 px.'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                BotaoSecundario(
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
      ),
    );
  }
}
