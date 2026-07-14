import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../../../nucleo/formatadores/formatador_data.dart';
import '../controladores/controlador_diagnostico.dart';

class AbaDiagnostico extends ConsumerWidget {
  const AbaDiagnostico({super.key});

  Widget _linha(String rotulo, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(rotulo,
                  style: const TextStyle(
                      fontSize: 13,
                      color: CoresApp.textoSecundario,
                      fontWeight: FontWeight.w600)),
            ),
            Text(valor,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(provedorDiagnostico);
    final controlador = ref.read(provedorDiagnostico.notifier);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Cartao(
          filho: Column(
            children: [
              _linha('Versão do aplicativo', estado.versaoApp),
              _linha('Ambiente atual', estado.ambienteRotulo),
              _linha('IP', estado.ip),
              _linha(
                'Última sincronização',
                estado.ultimaSincronizacao != null
                    ? FormatadorData.dataHora(estado.ultimaSincronizacao!)
                    : 'nunca',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        BotaoSecundario(
          rotulo: 'Limpar dados locais',
          aoTocar: () async {
            final confirmar = await mostrarDialogoConfirmacao(
              context,
              titulo: 'Limpar dados locais?',
              mensagem:
                  'Todas as configurações, tema, mídias e credenciais serão apagados. O PIN precisará ser criado de novo.',
              confirmar: 'Apagar tudo',
              destrutivo: true,
            );
            if (!confirmar || !context.mounted) return;
            await controlador
                .limparDadosLocais(ref.read(provedorArmazenamentoSeguro));
            if (context.mounted) context.go('/pin');
          },
        ),
      ],
    );
  }
}
