import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../nucleo/configuracao/ambiente.dart';
import '../controladores/controlador_configuracoes.dart';
import 'secao_configuracoes.dart';

const Color _ambarVerificando = Color(0xFFB26A00);

/// Linha de status de uma conexão: ponto colorido + rótulo textual, nunca só
/// cor. Usada nas seções do formulário e no painel lateral.
class LinhaStatusConexao extends StatelessWidget {
  const LinhaStatusConexao({
    super.key,
    required this.status,
    required this.rotuloConectado,
    this.detalhe,
  });

  final StatusConexao status;

  /// Texto do estado positivo ("Conectada", "Autenticada"...).
  final String rotuloConectado;

  /// Complemento à direita (latência, usuário...).
  final String? detalhe;

  @override
  Widget build(BuildContext context) {
    final (cor, rotulo) = switch (status) {
      StatusConexao.desconhecido => (
          CoresApp.textoSecundario,
          'Não verificada',
        ),
      StatusConexao.verificando => (_ambarVerificando, 'Verificando...'),
      StatusConexao.conectado => (CoresApp.sucesso, rotuloConectado),
      StatusConexao.erro => (CoresApp.erro, 'Falhou'),
    };
    return Row(
      children: [
        Icon(Icons.circle, size: 9, color: cor),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            rotulo,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: cor),
          ),
        ),
        if (detalhe != null && detalhe!.isNotEmpty)
          Text(
            detalhe!,
            style:
                const TextStyle(fontSize: 12, color: CoresApp.textoSecundario),
          ),
      ],
    );
  }
}

/// Painel lateral com o resumo da comunicação do terminal: status das duas
/// APIs, ambiente selecionado, última verificação e o teste geral.
class PainelStatusComunicacao extends StatelessWidget {
  const PainelStatusComunicacao({
    super.key,
    required this.estado,
    required this.ambienteSelecionado,
    required this.aoVerificarTodas,
  });

  final EstadoConfiguracoes estado;
  final Ambiente ambienteSelecionado;
  final VoidCallback? aoVerificarTodas;

  String _ultimaVerificacao() {
    final quando = estado.ultimaVerificacao;
    if (quando == null) return '—';
    final diferenca = DateTime.now().difference(quando);
    if (diferenca.inSeconds < 60) return 'Agora';
    if (diferenca.inMinutes < 60) return 'Há ${diferenca.inMinutes} min';
    final hora = quando.hour.toString().padLeft(2, '0');
    final minuto = quando.minute.toString().padLeft(2, '0');
    return 'Às $hora:$minuto';
  }

  Widget _item(String titulo, Widget conteudo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: CoresApp.textoSecundario)),
        const SizedBox(height: 4),
        conteudo,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final verificando = estado.testandoLocal || estado.testandoNuvem;
    return SecaoConfiguracoes(
      titulo: 'Status da comunicação',
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _item(
            'API local',
            LinhaStatusConexao(
              status: estado.statusLocal,
              rotuloConectado: 'Conectada',
              detalhe: estado.latenciaLocalMs != null
                  ? '${estado.latenciaLocalMs} ms'
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          _item(
            'Nuvem',
            LinhaStatusConexao(
              status: estado.statusNuvem,
              rotuloConectado: 'Autenticada',
              detalhe: [
                if (estado.usuarioNuvem.isNotEmpty) estado.usuarioNuvem,
                if (estado.latenciaNuvemMs != null)
                  '${estado.latenciaNuvemMs} ms',
              ].join(' · '),
            ),
          ),
          const SizedBox(height: 14),
          _item(
            'Ambiente',
            Text(ambienteSelecionado.rotulo,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 14),
          _item(
            'Última verificação',
            Text(_ultimaVerificacao(),
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 18),
          BotaoPrimario(
            rotulo:
                verificando ? 'Verificando...' : 'Verificar todas as conexões',
            aoTocar: verificando ? null : aoVerificarTodas,
          ),
        ],
      ),
    );
  }
}
