import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/widgets/barra_creditos.dart';
import '../../../../compartilhado/widgets/detector_toques_multiplos.dart';
import '../../../../compartilhado/widgets/faixa_pagamento.dart';
import '../../../../compartilhado/widgets/icone_emoji.dart';
import '../../../../compartilhado/widgets/imagem_logo.dart';
import '../../../../compartilhado/widgets/seletor_idioma.dart';
import '../../../../l10n/app_localizations.dart';
import '../componentes/trocador_propaganda.dart';
import '../controladores/controlador_propaganda.dart';

class PaginaPropaganda extends ConsumerStatefulWidget {
  const PaginaPropaganda({super.key, this.preview = false});

  final bool preview;

  @override
  ConsumerState<PaginaPropaganda> createState() => _PaginaPropagandaState();
}

class _PaginaPropagandaState extends ConsumerState<PaginaPropaganda> {
  String _nomeRestaurante = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(provedorPropaganda.notifier).carregar();
      final configuracao =
          await ref.read(provedorRepositorioConfiguracao).obter();
      if (mounted) {
        setState(() => _nomeRestaurante = configuracao.nomeRestaurante);
      }
    });
  }

  void _abrirConfiguracoes() {
    context.go('/pin?destino=/configuracoes');
  }

  void _prosseguir() {
    if (widget.preview) {
      // O preview é aberto via Navigator.push (aba Propaganda), fora das rotas do GoRouter.
      Navigator.of(context).maybePop();
    } else {
      context.go('/chat');
    }
  }

  Widget _telaChamada(Color primaria, String? logoPath) {
    final temLogo = logoPath != null && File(logoPath).existsSync();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaria, primaria.withValues(alpha: .8)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: .25),
                      blurRadius: 40,
                      offset: const Offset(0, 16)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: temLogo
                  ? ImagemLogo(
                      caminho: logoPath,
                      reserva: const IconeEmoji('🍽️', tamanho: 64),
                    )
                  : const IconeEmoji('🍽️', tamanho: 64),
            ),
            const SizedBox(height: 20),
            Text(
              _nomeRestaurante,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorPropaganda);
    final tema = ref.watch(provedorTema);
    final primaria = TemaConstel.corDeHex(
        tema.corPrimaria, Theme.of(context).colorScheme.primary);

    final Widget fundo;
    if (estado.carregando) {
      fundo = ColoredBox(color: primaria);
    } else if (estado.midiaAtual == null) {
      fundo = _telaChamada(primaria, tema.logoPath);
    } else {
      fundo = TrocadorPropaganda(
        indice: estado.indice,
        midiaAtual: estado.midiaAtual!,
        midiaSeguinte: estado.midiaSeguinte!,
        corFundo: primaria,
        aoAvancar: () => ref.read(provedorPropaganda.notifier).avancar(),
      );
    }

    // Texto da faixa no idioma atual do atendimento: o operador pode
    // personalizar por idioma; sem personalização (campo vazio), cai no texto
    // padrão já traduzido pelo l10n.
    final idioma = Localizations.localeOf(context).languageCode;
    final textoFaixa = tema.textoFaixaParaIdioma(
        idioma, AppLocalizations.of(context).tapToPay);

    // A barra de créditos sobrepõe a base da faixa sem empurrá-la para cima:
    // a mensagem fica centralizada na banda inteira do rodapé e os créditos,
    // pequenos, moram nos cantos. Sobreposta, a barra não pinta fundo próprio
    // (sobreCor) para não decepar os descendentes da mensagem.
    final Widget rodape;
    if (estado.carregando) {
      rodape = widget.preview ? const SizedBox.shrink() : const BarraCreditos();
    } else {
      final corFaixa = TemaConstel.corDeHex(tema.corFaixaEfetiva, primaria);
      final faixa = FaixaPagamento(
        texto: textoFaixa,
        corFundo: corFaixa,
        corTexto: TemaConstel.corDeHex(tema.corTextoFaixa, Colors.white),
        fonte: tema.fonte,
      );
      rodape = widget.preview
          ? faixa
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [faixa, BarraCreditos(sobreCor: corFaixa)],
            );
    }

    final conteudo = Column(
      children: [
        Expanded(child: SizedBox(width: double.infinity, child: fundo)),
        rodape,
      ],
    );

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: _prosseguir,
            behavior: HitTestBehavior.opaque,
            child: conteudo,
          ),
          // Acesso discreto às configurações: 4 toques no canto superior
          // direito. Sem botão visível, para não expor a área de operação ao
          // cliente. Fica abaixo do seletor de idioma no Stack, então tocar no
          // seletor continua funcionando normalmente.
          if (!widget.preview)
            Positioned(
              top: 0,
              right: 0,
              child: DetectorToquesMultiplos(
                aoCompletar: _abrirConfiguracoes,
                filho: const SizedBox(width: 96, height: 96),
              ),
            ),
          // Seletor de idioma, visível para o cliente.
          if (!widget.preview)
            const Positioned(
              top: 12,
              right: 12,
              child: SafeArea(child: SeletorIdioma()),
            ),
        ],
      ),
    );
  }
}
