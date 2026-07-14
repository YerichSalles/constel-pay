import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/estilos_texto.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/feedback/snackbar_padrao.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/dialogo_confirmacao.dart';
import '../../../../compartilhado/widgets/faixa_pagamento.dart';
import '../../../../nucleo/utils/contraste.dart';
import '../../dominio/entidades/tema_personalizado.dart';
import 'seletor_cor.dart';
import 'seletor_fonte.dart';
import 'seletor_logo.dart';

class AbaAparencia extends ConsumerStatefulWidget {
  const AbaAparencia({super.key});

  @override
  ConsumerState<AbaAparencia> createState() => _AbaAparenciaState();
}

class _AbaAparenciaState extends ConsumerState<AbaAparencia> {
  TemaPersonalizado? _rascunho;
  late final TextEditingController _controladorTextoFaixa =
      TextEditingController(text: ref.read(provedorTema).textoFaixa);

  @override
  void dispose() {
    _controladorTextoFaixa.dispose();
    super.dispose();
  }

  TemaPersonalizado get _tema => _rascunho ?? ref.read(provedorTema);

  Future<void> _aplicar() async {
    final atual = ref.read(provedorTema);
    await ref
        .read(provedorTema.notifier)
        .atualizar(_tema.copyWith(logoPath: atual.logoPath));
    if (mounted) mostrarSnackbarPadrao(context, 'Tema aplicado.');
  }

  Future<void> _restaurar() async {
    final confirmado = await mostrarDialogoConfirmacao(
      context,
      titulo: 'Restaurar aparência',
      mensagem: 'As cores, a fonte e a logo personalizadas serão removidas e '
          'o aplicativo voltará ao visual original.',
      confirmar: 'Restaurar',
      destrutivo: true,
    );
    if (!confirmado) return;
    setState(() => _rascunho = null);
    _controladorTextoFaixa.text = textoFaixaPadrao;
    await ref.read(provedorTema.notifier).atualizar(const TemaPersonalizado());
    if (mounted) {
      mostrarSnackbarPadrao(
          context, 'Aparência restaurada ao padrão original.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = _tema;
    final primaria =
        TemaConstel.corDeHex(tema.corPrimaria, CoresApp.primariaPadrao);
    final botoes = TemaConstel.corDeHex(tema.corBotoes, CoresApp.botoesPadrao);
    final fundo = TemaConstel.corDeHex(tema.corFundo, CoresApp.fundoPadrao);
    final corTexto =
        TemaConstel.corDeHex(tema.corTexto, CoresApp.textoPrincipal);
    // Reserva a primaria da propria loja, e nao a padrao hardcoded: assim o
    // preview nunca resolve uma cor que o totem nao pintaria.
    final faixaFundo = TemaConstel.corDeHex(tema.corFaixaEfetiva, primaria);
    final faixaTexto = TemaConstel.corDeHex(tema.corTextoFaixa, Colors.white);
    final semContraste =
        razaoDeContraste(faixaFundo, faixaTexto) < contrasteMinimoTexto;
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
        const SizedBox(height: 18),
        SeletorCor(
          rotulo: 'Cor do texto',
          valorHex: tema.corTexto,
          aoMudar: (hex) =>
              setState(() => _rascunho = tema.copyWith(corTexto: hex)),
        ),
        const SizedBox(height: 18),
        SeletorCor(
          key: const Key('cor_faixa'),
          rotulo: 'Cor da faixa de pagamento',
          valorHex: tema.corFaixaEfetiva,
          aoMudar: (hex) =>
              setState(() => _rascunho = tema.copyWith(corFaixa: hex)),
        ),
        const SizedBox(height: 18),
        SeletorCor(
          rotulo: 'Cor do texto da faixa',
          valorHex: tema.corTextoFaixa,
          aoMudar: (hex) =>
              setState(() => _rascunho = tema.copyWith(corTextoFaixa: hex)),
        ),
        const SizedBox(height: 18),
        const Text('Texto da faixa',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controladorTextoFaixa,
          decoration: const InputDecoration(
            isDense: true,
            hintText: textoFaixaPadrao,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onChanged: (valor) =>
              setState(() => _rascunho = tema.copyWith(textoFaixa: valor)),
        ),
        if (semContraste) ...[
          const SizedBox(height: 10),
          Container(
            key: const Key('aviso_contraste_faixa'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CoresApp.erro.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CoresApp.erro.withValues(alpha: .3)),
            ),
            child: const Text(
              'O texto da faixa está com pouco contraste sobre o fundo '
              'escolhido e pode ficar ilegível no totem.',
              style: TextStyle(fontSize: 11.5, color: CoresApp.erro),
            ),
          ),
        ],
        const SizedBox(height: 18),
        SeletorFonte(
          valor: tema.fonte,
          aoMudar: (fonte) =>
              setState(() => _rascunho = tema.copyWith(fonte: fonte)),
        ),
        const SizedBox(height: 20),
        const Text('Logo',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text(
          'Ideal: imagem quadrada de 512 x 512 px, em PNG ou SVG com fundo '
          'transparente. A logo aparece inteira, sem corte.',
          style: TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario),
        ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exemplo de card',
                      style: EstilosTexto.estilo(
                        tema.fonte,
                        TextStyle(fontWeight: FontWeight.w800, color: primaria),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Exemplo de texto na fonte e na cor escolhidas.',
                      style: EstilosTexto.estilo(
                        tema.fonte,
                        TextStyle(fontSize: 13, color: corTexto),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Usa o botao real do tema para o preview ter exatamente o
              // mesmo tamanho dos botoes de acao das telas.
              IgnorePointer(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: botoes),
                    child: Text(
                      'Exemplo de botão',
                      style: EstilosTexto.estilo(
                          tema.fonte, const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FaixaPagamento(
                  texto: tema.textoFaixaEfetivo,
                  corFundo: faixaFundo,
                  corTexto: faixaTexto,
                  fonte: tema.fonte,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        BotaoPrimario(rotulo: 'Aplicar tema', aoTocar: _aplicar),
        const SizedBox(height: 10),
        BotaoPrimario(rotulo: 'Restaurar padrão original', aoTocar: _restaurar),
      ],
    );
  }
}
