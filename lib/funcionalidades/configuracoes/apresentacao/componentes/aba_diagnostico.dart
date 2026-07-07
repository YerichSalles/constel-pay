import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../../../nucleo/formatadores/formatador_data.dart';
import '../controladores/controlador_diagnostico.dart';

class AbaDiagnostico extends ConsumerWidget {
  const AbaDiagnostico({super.key});

  Widget _linha(String rotulo, String valor, {Widget? extra}) => Padding(
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
            if (extra != null) ...[extra, const SizedBox(width: 6)],
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
    ref.listen(provedorDiagnostico.select((e) => e.mensagem), (_, mensagem) {
      if (mensagem == null) return;
      mostrarSnackbarPadrao(context, mensagem,
          erro: ref.read(provedorDiagnostico).mensagemErro);
    });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Cartao(
          filho: Column(
            children: [
              _linha('Versão do aplicativo', estado.versaoApp),
              _linha('Versão da API', estado.versaoApi),
              _linha('Ambiente atual', estado.ambienteRotulo),
              _linha('Identificador do dispositivo', estado.identificador),
              _linha('IP', estado.ip),
              _linha(
                'Status da conexão',
                estado.conectado ? 'Conectado' : 'Sem conexão',
                extra: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: estado.conectado ? CoresApp.sucesso : CoresApp.erro,
                  ),
                ),
              ),
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
        BotaoPrimario(
          rotulo: 'Testar API',
          carregando: estado.testando,
          aoTocar: controlador.testarApi,
        ),
        const SizedBox(height: 10),
        BotaoSecundario(
          rotulo: 'Exportar logs',
          aoTocar: () => controlador.exportarLogs(),
        ),
        const SizedBox(height: 10),
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
