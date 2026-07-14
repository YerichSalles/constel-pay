import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/estilos_texto.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/widgets/imagem_logo.dart';
import '../../../propaganda/apresentacao/componentes/conteudo_publicidade.dart';
import '../../../propaganda/dominio/entidades/publicidade_barra.dart';
import '../../dominio/entidades/tema_personalizado.dart';
import 'secao_configuracoes.dart';

/// Réplica em miniatura da `BarraSuperior` real (mesmo gradiente e
/// estrutura: ← + logo/avatar + nome), com a publicidade renderizada ao
/// vivo por [ConteudoPublicidade]. Único lugar do editor com controle de
/// reprodução — no atendimento a publicidade sempre anima.
class PreviaPublicidade extends StatelessWidget {
  const PreviaPublicidade({
    super.key,
    required this.publicidade,
    required this.tema,
    required this.nomeEstabelecimento,
    this.logoPath,
    required this.reproduzindo,
    required this.aoAlternarReproducao,
  });

  final PublicidadeBarra publicidade;
  final TemaPersonalizado tema;
  final String nomeEstabelecimento;
  final String? logoPath;
  final bool reproduzindo;
  final VoidCallback aoAlternarReproducao;

  /// Mesma fração usada pela `BarraSuperior` real como teto da área do nome
  /// quando há publicidade.
  static const double _fracaoMaximaNome = 0.45;

  /// Mesmo ajuste de luminosidade (HSL) usado pela `BarraSuperior` real, para
  /// o gradiente da prévia ficar idêntico ao do atendimento.
  Color _ajustarLuminosidade(Color cor, double delta) {
    final hsl = HSLColor.fromColor(cor);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }

  Widget _avatar() {
    final caminho = logoPath;
    final temLogo = caminho != null && File(caminho).existsSync();
    return Container(
      width: 30,
      height: 30,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: temLogo
          ? ImagemLogo(
              caminho: caminho,
              reserva: const Text('🍽️', style: TextStyle(fontSize: 14)))
          : const Text('🍽️', style: TextStyle(fontSize: 14)),
    );
  }

  /// Publicidade ativa mas sem conteúdo para o formato selecionado: nada
  /// seria exibido de verdade no atendimento, então a prévia avisa o
  /// operador em vez de ficar em branco (o que pareceria um bug).
  Widget _areaConteudo() {
    if (publicidade.ativa && !publicidade.formatoTemConteudo) {
      return const Text(
        'Adicione conteúdo para visualizar.',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
      );
    }
    return ConteudoPublicidade(
        publicidade: publicidade, tema: tema, reproduzindo: reproduzindo);
  }

  @override
  Widget build(BuildContext context) {
    final primaria =
        TemaConstel.corDeHex(tema.corPrimaria, CoresApp.primariaPadrao);
    final nome =
        nomeEstabelecimento.isEmpty ? 'Estabelecimento' : nomeEstabelecimento;
    return SecaoConfiguracoes(
      titulo: 'Pré-visualização',
      descricao: 'Veja como a publicidade será exibida na barra superior '
          'durante o atendimento.',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _ajustarLuminosidade(primaria, .05),
                    _ajustarLuminosidade(primaria, -.04),
                  ],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, restricoes) {
                  final tetoNome = restricoes.maxWidth * _fracaoMaximaNome;
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 12, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      _avatar(),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: tetoNome),
                        child: Text(
                          nome,
                          overflow: TextOverflow.ellipsis,
                          style: EstilosTexto.estilo(
                            tema.fonte,
                            const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 1,
                        height: 18,
                        color: Colors.white.withValues(alpha: .25),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: _areaConteudo()),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: aoAlternarReproducao,
              child: Text(reproduzindo ? '⏸ Pausar' : '▶ Reproduzir'),
            ),
          ),
        ],
      ),
    );
  }
}
