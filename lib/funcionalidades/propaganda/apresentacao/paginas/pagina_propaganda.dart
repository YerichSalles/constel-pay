import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/widgets/botao_primario.dart';
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

  Widget _passo(String emoji, String titulo, String subtitulo) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CoresApp.bordaCard),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: CoresApp.lilasClaro,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 19)),
            ),
            const SizedBox(height: 7),
            Text(titulo,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            Text(subtitulo,
                style: const TextStyle(
                    fontSize: 10,
                    color: CoresApp.textoSecundario,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
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
      child: Column(
        children: [
          Expanded(
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
                        ? Image.file(File(logoPath), fit: BoxFit.cover)
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
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
            decoration: const BoxDecoration(
              color: CoresApp.fundoPadrao,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pague sua conta sem chamar o garçom',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text(
                    'Escaneie o cartão de consumo da sua mesa e pague em segundos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color: CoresApp.textoSecundario,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _passo('📷', 'Escaneie', 'o cartão'),
                      const SizedBox(width: 8),
                      _passo('💳', 'Pague', 'com Pix'),
                      const SizedBox(width: 8),
                      _passo('✅', 'Pronto', 'sem fila'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  BotaoPrimario(
                      rotulo: 'Toque para pagar', aoTocar: _prosseguir),
                  const SizedBox(height: 12),
                  const Text('🔒 Pagamento seguro · Autoatendimento',
                      style: TextStyle(
                          fontSize: 11.5,
                          color: CoresApp.textoSecundario,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorPropaganda);
    final tema = ref.watch(provedorTema);
    final primaria = TemaConstel.corDeHex(
        tema.corPrimaria, Theme.of(context).colorScheme.primary);

    final Widget conteudo;
    if (estado.carregando) {
      conteudo = ColoredBox(color: primaria);
    } else if (estado.midiaAtual == null) {
      conteudo = _telaChamada(primaria, tema.logoPath);
    } else {
      conteudo = Stack(
        fit: StackFit.expand,
        children: [
          PlayerPropaganda(
            midia: estado.midiaAtual!,
            aoTerminar: () => ref.read(provedorPropaganda.notifier).avancar(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .55),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  '👆 Toque na tela para pagar',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      );
    }

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
                  tooltip: 'Configuracoes',
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
