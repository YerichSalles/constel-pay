import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/campo_texto.dart';
import '../controladores/controlador_configuracoes.dart';
import 'seletor_logo.dart';

class AbaGeral extends ConsumerStatefulWidget {
  const AbaGeral({super.key});

  @override
  ConsumerState<AbaGeral> createState() => _AbaGeralState();
}

class _AbaGeralState extends ConsumerState<AbaGeral> {
  final _nome = TextEditingController();
  final _identificador = TextEditingController();
  bool _preenchido = false;

  @override
  void dispose() {
    _nome.dispose();
    _identificador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorConfiguracoes);
    if (!estado.carregando && !_preenchido) {
      _nome.text = estado.configuracao.nomeRestaurante;
      _identificador.text = estado.configuracao.identificadorDispositivo;
      _preenchido = true;
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CampoTexto(rotulo: 'Nome do restaurante', controlador: _nome),
        const SizedBox(height: 14),
        CampoTexto(
            rotulo: 'Identificador do dispositivo',
            controlador: _identificador),
        const SizedBox(height: 18),
        const SeletorLogo(),
        const SizedBox(height: 24),
        BotaoPrimario(
          rotulo: 'Salvar',
          carregando: estado.salvando,
          aoTocar: () =>
              ref.read(provedorConfiguracoes.notifier).salvarConfiguracao(
                    estado.configuracao.copyWith(
                      nomeRestaurante: _nome.text.trim(),
                      identificadorDispositivo: _identificador.text.trim(),
                    ),
                  ),
        ),
      ],
    );
  }
}
