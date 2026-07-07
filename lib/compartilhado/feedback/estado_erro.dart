import 'package:flutter/material.dart';

import '../widgets/botao_secundario.dart';
import 'estado_vazio.dart';

class EstadoErro extends StatelessWidget {
  const EstadoErro({super.key, required this.mensagem, this.aoTentarNovamente});

  final String mensagem;
  final VoidCallback? aoTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return EstadoVazio(
      emoji: '⚠️',
      titulo: 'Algo deu errado',
      mensagem: mensagem,
      acao: aoTentarNovamente != null
          ? BotaoSecundario(
              rotulo: 'Tentar novamente',
              aoTocar: aoTentarNovamente,
              expandido: false)
          : null,
    );
  }
}
