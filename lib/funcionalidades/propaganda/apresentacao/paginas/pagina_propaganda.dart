import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/widgets/faixa_pagamento.dart';
import '../../../../compartilhado/widgets/imagem_logo.dart';
import '../componentes/player_propaganda.dart';
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
                      reserva:
                          const Text('🍽️', style: TextStyle(fontSize: 60)),
                    )
                  : const Text('🍽️', style: TextStyle(fontSize: 60)),
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
      fundo = PlayerPropaganda(
        // A chave inclui o indice: repetir a mesma midia recria o player e
        // reinicia a reproducao do zero.
        key: ValueKey('${estado.indice}_${estado.midiaAtual!.id}'),
        midia: estado.midiaAtual!,
        corFundo: primaria,
        aoTerminar: () => ref.read(provedorPropaganda.notifier).avancar(),
      );
    }

    final conteudo = Column(
      children: [
        Expanded(child: SizedBox(width: double.infinity, child: fundo)),
        if (!estado.carregando)
          FaixaPagamento(
            texto: tema.textoFaixaEfetivo,
            corFundo: TemaConstel.corDeHex(tema.corFaixaEfetiva, primaria),
            corTexto: TemaConstel.corDeHex(tema.corTextoFaixa, Colors.white),
            fonte: tema.fonte,
          ),
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
          // Botao temporario de acesso as configuracoes.
          if (!widget.preview)
            Positioned(
              top: 12,
              right: 12,
              child: SafeArea(
                child: IconButton(
                  onPressed: _abrirConfiguracoes,
                  tooltip: 'Configurações',
                  icon: const Icon(Icons.settings, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: .45),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
