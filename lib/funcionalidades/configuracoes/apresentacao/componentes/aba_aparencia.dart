import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/botao_secundario.dart';
import '../../dominio/entidades/tema_personalizado.dart';
import 'seletor_cor.dart';
import 'seletor_logo.dart';

class AbaAparencia extends ConsumerStatefulWidget {
  const AbaAparencia({super.key});

  @override
  ConsumerState<AbaAparencia> createState() => _AbaAparenciaState();
}

class _AbaAparenciaState extends ConsumerState<AbaAparencia> {
  TemaPersonalizado? _rascunho;

  TemaPersonalizado get _tema => _rascunho ?? ref.read(provedorTema);

  Future<void> _aplicar() async {
    final atual = ref.read(provedorTema);
    await ref
        .read(provedorTema.notifier)
        .atualizar(_tema.copyWith(logoPath: atual.logoPath));
    if (mounted) mostrarSnackbarPadrao(context, 'Tema aplicado.');
  }

  Future<void> _restaurar() async {
    final atual = ref.read(provedorTema);
    setState(() => _rascunho = TemaPersonalizado(logoPath: atual.logoPath));
    await ref.read(provedorTema.notifier).atualizar(_tema);
    if (mounted) mostrarSnackbarPadrao(context, 'Cores padrão restauradas.');
  }

  @override
  Widget build(BuildContext context) {
    final tema = _tema;
    final primaria =
        TemaConstel.corDeHex(tema.corPrimaria, CoresApp.primariaPadrao);
    final botoes = TemaConstel.corDeHex(tema.corBotoes, CoresApp.botoesPadrao);
    final fundo = TemaConstel.corDeHex(tema.corFundo, CoresApp.fundoPadrao);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SeletorCor(
          rotulo: 'Cor principal',
          valorHex: tema.corPrimaria,
          aoMudar: (hex) =>
              setState(() => _rascunho = tema.copyWith(corPrimaria: hex)),
        ),
        const SizedBox(height: 18),
        SeletorCor(
          rotulo: 'Cor secundária',
          valorHex: tema.corSecundaria,
          aoMudar: (hex) =>
              setState(() => _rascunho = tema.copyWith(corSecundaria: hex)),
        ),
        const SizedBox(height: 18),
        SeletorCor(
          rotulo: 'Cor de fundo',
          valorHex: tema.corFundo,
          aoMudar: (hex) =>
              setState(() => _rascunho = tema.copyWith(corFundo: hex)),
        ),
        const SizedBox(height: 18),
        SeletorCor(
          rotulo: 'Cor dos botões',
          valorHex: tema.corBotoes,
          aoMudar: (hex) =>
              setState(() => _rascunho = tema.copyWith(corBotoes: hex)),
        ),
        const SizedBox(height: 20),
        const Text('Logo',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const SeletorLogo(),
        const SizedBox(height: 24),
        const Text('Pré-visualização',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: fundo,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CoresApp.bordaCard),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: CoresApp.bordaCard),
                ),
                child: Text(
                  'Exemplo de card',
                  style:
                      TextStyle(fontWeight: FontWeight.w800, color: primaria),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: botoes,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: const Text('Exemplo de botão',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        BotaoPrimario(rotulo: 'Aplicar tema', aoTocar: _aplicar),
        const SizedBox(height: 10),
        BotaoSecundario(rotulo: 'Restaurar padrão', aoTocar: _restaurar),
      ],
    );
  }
}
