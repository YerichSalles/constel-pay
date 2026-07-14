import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secao_conteudo_tela.dart';

/// Aba "Propaganda" de Configurações: navegação interna entre o conteúdo
/// exibido na tela de espera e a futura configuração da barra superior.
class AbaPropaganda extends ConsumerStatefulWidget {
  const AbaPropaganda({super.key});

  @override
  ConsumerState<AbaPropaganda> createState() => _AbaPropagandaState();
}

class _AbaPropagandaState extends ConsumerState<AbaPropaganda>
    with AutomaticKeepAliveClientMixin<AbaPropaganda> {
  int _secaoSelecionada = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<int>(
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: const [
                ButtonSegment(value: 0, label: Text('Conteúdo da tela')),
                ButtonSegment(value: 1, label: Text('Barra superior')),
              ],
              selected: {_secaoSelecionada},
              onSelectionChanged: (selecao) =>
                  setState(() => _secaoSelecionada = selecao.first),
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _secaoSelecionada,
            // Índice 1 é um placeholder temporário: a Task 7 substitui por
            // SecaoBarraSuperior().
            children: const [
              SecaoConteudoTela(),
              Center(child: Text('Em construção')),
            ],
          ),
        ),
      ],
    );
  }
}
