import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/layout/layout_responsivo.dart';
import '../controladores/estado_fluxo_pagamento.dart';
import 'barra_total.dart';
import 'chip_acao.dart';

class AreaAcoes extends StatelessWidget {
  const AreaAcoes({
    super.key,
    required this.estado,
    required this.aoLerOutro,
    required this.aoIrPagamento,
    required this.aoPagarRestante,
    required this.aoEncerrar,
    required this.aoNovaOperacao,
    required this.aoTentarNovamente,
    required this.aoContinuarComCartoes,
  });

  final EstadoFluxoPagamento estado;
  final VoidCallback aoLerOutro;
  final VoidCallback aoIrPagamento;
  final VoidCallback aoPagarRestante;
  final VoidCallback aoEncerrar;
  final VoidCallback aoNovaOperacao;
  final VoidCallback aoTentarNovamente;
  final VoidCallback aoContinuarComCartoes;

  List<Widget> _chips() {
    if (estado.digitando) return const [];
    final temCartoes = estado.selecionados.isNotEmpty;
    switch (estado.etapa) {
      case EtapaFluxo.lendo:
        // Só na leitura adicional: na primeira leitura ainda não há como
        // continuar sem localizar uma comanda válida.
        if (!temCartoes) return const [];
        return [
          ChipAcao(
              rotulo: 'Continuar com os cartões já adicionados',
              aoTocar: aoContinuarComCartoes,
              discreto: true),
        ];
      case EtapaFluxo.aguardandoMaisCartoes:
        return [
          // Sempre disponível: com a API real o app não sabe quantas comandas
          // ainda estão abertas na mesa (`cartoesRestantes` só existe no mock).
          ChipAcao(rotulo: 'Adicionar outro cartão', aoTocar: aoLerOutro),
          ChipAcao(
              rotulo: 'Continuar para pagamento',
              aoTocar: aoIrPagamento,
              primario: true),
        ];
      case EtapaFluxo.semConsumo:
      case EtapaFluxo.erroLeitura:
        return [
          ChipAcao(
              rotulo: estado.etapa == EtapaFluxo.semConsumo
                  ? 'Tentar outro cartão'
                  : 'Tentar novamente',
              aoTocar: aoTentarNovamente,
              primario: !temCartoes),
          if (temCartoes)
            ChipAcao(
                rotulo: 'Continuar com ${estado.rotuloCartoesAdicionados}',
                aoTocar: aoContinuarComCartoes,
                primario: true),
        ];
      case EtapaFluxo.sucessoComRestante:
        return [
          ChipAcao(
              rotulo: 'Pagar restante',
              aoTocar: aoPagarRestante,
              primario: true),
          ChipAcao(rotulo: 'Encerrar', aoTocar: aoEncerrar),
        ];
      case EtapaFluxo.sucessoCompleto:
        return [
          ChipAcao(rotulo: 'Encerrar', aoTocar: aoEncerrar, primario: true)
        ];
      case EtapaFluxo.encerramento:
        return [
          ChipAcao(
              rotulo: 'Novo pagamento', aoTocar: aoNovaOperacao, primario: true)
        ];
      default:
        return const [];
    }
  }

  bool get _mostraTotal =>
      const [
        EtapaFluxo.lendo,
        EtapaFluxo.aguardandoMaisCartoes,
        EtapaFluxo.semConsumo,
        EtapaFluxo.erroLeitura,
        EtapaFluxo.escolhaMetodo,
        EtapaFluxo.pixAguardando,
      ].contains(estado.etapa) &&
      estado.selecionados.isNotEmpty;

  bool get _mostraDica =>
      !estado.digitando &&
      const [
        EtapaFluxo.lendo,
        EtapaFluxo.escolhaMetodo,
        EtapaFluxo.pixAguardando
      ].contains(estado.etapa);

  @override
  Widget build(BuildContext context) {
    final chips = _chips();
    final selecionados = estado.selecionados.length;
    final rotuloBarra =
        '$selecionados ${selecionados > 1 ? 'cartões' : 'cartão'}'
        '${estado.servicoCentavos > 0 ? ' · inclui serviço' : ''}';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: CoresApp.bordaCard)),
        boxShadow: [
          BoxShadow(
              color: CoresApp.textoPrincipal.withValues(alpha: .06),
              blurRadius: 20,
              offset: const Offset(0, -6)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: SafeArea(
        top: false,
        child: ConteudoCentralizado(
          filho: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_mostraTotal) ...[
                BarraTotal(
                    rotulo: rotuloBarra, valorCentavos: estado.totalCentavos),
                const SizedBox(height: 10),
              ],
              if (chips.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: chips,
                      ),
                    ),
                  ],
                )
              else if (_mostraDica)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '👆 Toque em uma opção acima para continuar',
                    style: TextStyle(
                        fontSize: 12.5,
                        color: CoresApp.textoSecundario,
                        fontWeight: FontWeight.w600),
                  ),
                )
              else
                const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
