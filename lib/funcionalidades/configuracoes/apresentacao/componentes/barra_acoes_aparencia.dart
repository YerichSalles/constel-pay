import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';

const Color _ambarAlteracao = Color(0xFFB26A00);

/// Barra fixa de ações da aba Aparência. Sinaliza alterações não salvas com
/// ponto + texto (nunca só cor) e desabilita "Aplicar alterações" quando não
/// há o que aplicar.
class BarraAcoesAparencia extends StatelessWidget {
  const BarraAcoesAparencia({
    super.key,
    required this.alteracoesPendentes,
    required this.aoRestaurar,
    required this.aoAplicar,
  });

  final bool alteracoesPendentes;
  final VoidCallback aoRestaurar;
  final VoidCallback aoAplicar;

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
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 9, color: _ambarAlteracao),
                        SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Alterações não salvas',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
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
                rotulo: 'Restaurar padrão',
                aoTocar: aoRestaurar,
                expandido: false,
              );
              final aplicar = BotaoPrimario(
                rotulo: 'Aplicar alterações',
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
                              rotulo: 'Restaurar padrão', aoTocar: aoRestaurar),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BotaoPrimario(
                            rotulo: 'Aplicar alterações',
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
