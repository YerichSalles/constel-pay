import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../compartilhado/feedback/estado_vazio.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../componentes/aba_aparencia.dart';
import '../componentes/aba_comunicacao.dart';
import '../componentes/aba_geral.dart';
import '../controladores/controlador_configuracoes.dart';

class PaginaConfiguracoes extends ConsumerWidget {
  const PaginaConfiguracoes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(provedorConfiguracoes.select((e) => e.mensagem), (_, mensagem) {
      if (mensagem == null) return;
      final erro = ref.read(provedorConfiguracoes).mensagemErro;
      mostrarSnackbarPadrao(context, mensagem, erro: erro);
      ref.read(provedorConfiguracoes.notifier).limparMensagem();
    });

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configurações'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.go('/splash'),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Geral'),
              Tab(text: 'Comunicação'),
              Tab(text: 'Aparência'),
              Tab(text: 'Propaganda'),
              Tab(text: 'Diagnóstico'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const AbaGeral(),
            const AbaComunicacao(),
            // Substituídas nas Tasks 21-23:
            const AbaAparencia(),
            const EstadoVazio(
                emoji: '🎬', titulo: 'Propaganda', mensagem: 'Em construção'),
            const EstadoVazio(
                emoji: '🩺', titulo: 'Diagnóstico', mensagem: 'Em construção'),
          ],
        ),
      ),
    );
  }
}
