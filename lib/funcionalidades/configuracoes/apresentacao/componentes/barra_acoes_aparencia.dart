import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';

const Color _ambarAlteracao = Color(0xFFB26A00);

/// Barra fixa de ações de rascunho/aplicar, usada pela aba Aparência e pela
/// seção Barra superior (Propaganda). Sinaliza alterações não salvas com
/// ponto + texto (nunca só cor) e desabilita o botão primário quando não há
/// o que aplicar. Os rótulos são configuráveis (default = textos da
/// Aparência) para outras telas reaproveitarem o mesmo rodapé com o próprio
/// vocabulário.
class BarraAcoesAparencia extends StatelessWidget {
  const BarraAcoesAparencia({
    super.key,
    required this.alteracoesPendentes,
    required this.aoRestaurar,
    required this.aoAplicar,
    this.rotuloIndicador = 'Alterações não salvas',
    this.rotuloSecundario = 'Restaurar padrão',
    this.rotuloPrimario = 'Aplicar alterações',
  });

  final bool alteracoesPendentes;
  final VoidCallback aoRestaurar;
  final VoidCallback aoAplicar;
  final String rotuloIndicador;
  final String rotuloSecundario;
  final String rotuloPrimario;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: CoresApp.bordaCard)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: LayoutBuilder(
            builder: (contexto, restricoes) {
              final indicador = alteracoesPendentes
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle,
                            size: 9, color: _ambarAlteracao),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            rotuloIndicador,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _ambarAlteracao,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink();
              final restaurar = BotaoSecundario(
                rotulo: rotuloSecundario,
                aoTocar: aoRestaurar,
                expandido: false,
              );
              final aplicar = BotaoPrimario(
                rotulo: rotuloPrimario,
                aoTocar: alteracoesPendentes ? aoAplicar : null,
                expandido: false,
              );
              // Em telas estreitas os dois botões lado a lado com o
              // indicador não cabem; empilha o indicador acima e divide a
              // largura entre os botões.
              if (restricoes.maxWidth < 480) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (alteracoesPendentes) ...[
                      indicador,
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: BotaoSecundario(
                              rotulo: rotuloSecundario, aoTocar: aoRestaurar),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BotaoPrimario(
                            rotulo: rotuloPrimario,
                            aoTocar: alteracoesPendentes ? aoAplicar : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: indicador),
                  restaurar,
                  const SizedBox(width: 10),
                  aplicar,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
