import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/icone_emoji.dart';
import '../../dominio/entidades/mensagem.dart';
import '../../dominio/entidades/tipo_mensagem.dart';
import 'avatar_bot.dart';

class BolhaMensagem extends StatelessWidget {
  const BolhaMensagem({super.key, required this.mensagem});

  final Mensagem mensagem;

  @override
  Widget build(BuildContext context) {
    final assistente = mensagem.lado == LadoMensagem.assistente;
    final bolha = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: assistente ? Colors.white : CoresApp.lilasBolha,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(assistente ? 4 : 18),
          topRight: const Radius.circular(18),
          bottomLeft: const Radius.circular(18),
          bottomRight: Radius.circular(assistente ? 18 : 4),
        ),
        boxShadow: [
          BoxShadow(
            color: CoresApp.textoPrincipal.withValues(alpha: .07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mensagem.emoji != null) ...[
            IconeEmoji(mensagem.emoji!, tamanho: 24),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mensagem.texto ?? '',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: CoresApp.textoPrincipal,
                    height: 1.5,
                  ),
                ),
                if (mensagem.subtexto != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      mensagem.subtexto!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: CoresApp.textoSecundario,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (assistente) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AvatarBot(),
          const SizedBox(width: 8),
          Flexible(child: bolha),
          const SizedBox(width: 40),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 60),
        Flexible(child: bolha),
      ],
    );
  }
}
