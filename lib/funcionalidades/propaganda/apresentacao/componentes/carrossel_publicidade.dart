import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../dominio/entidades/midia_propaganda.dart';
import '../../dominio/entidades/publicidade_barra.dart';
import '../ajuste_tela.dart';

/// Diametro das bolinhas indicadoras de posicao do carrossel.
const double _diametroIndicador = 5;

/// Renderiza uma unica midia de publicidade com o mesmo enquadramento do
/// editor (BoxFit/alinhamento/zoom, via `ajuste_tela.dart`). Usado tanto pelo
/// carrossel (cada banner) quanto pelo formato parceiro (midia unica, sem
/// timer) — mesmo render, sem duplicar a logica de enquadramento.
class BannerPublicidade extends StatelessWidget {
  const BannerPublicidade({super.key, required this.midia});

  final MidiaPropaganda midia;

  @override
  Widget build(BuildContext context) {
    final fit = resolverBoxFit(midia.ajuste);
    final alinhamento = resolverAlinhamento(midia.ancora);
    final escala = resolverEscala(midia.zoomPercentual);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Transform.scale(
        scale: escala,
        alignment: alinhamento,
        child: Image.file(
          File(midia.caminho),
          fit: fit,
          alignment: alinhamento,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// Carrossel de banners da publicidade da barra superior. Avanca sozinho por
/// `Timer.periodic` (indice circular) quando ha mais de um banner ativo e
/// `reproduzindo` esta ligado; com um unico banner nao ha timer nem
/// indicadores.
class CarrosselPublicidade extends StatefulWidget {
  const CarrosselPublicidade({
    super.key,
    required this.banners,
    required this.intervaloSegundos,
    required this.transicao,
    required this.corIndicadores,
    this.reproduzindo = true,
  });

  final List<MidiaPropaganda> banners;
  final int intervaloSegundos;
  final TransicaoCarrossel transicao;
  final Color corIndicadores;

  /// Pausavel na previa (edicao); no atendimento fica sempre true.
  final bool reproduzindo;

  @override
  State<CarrosselPublicidade> createState() => _CarrosselPublicidadeState();
}

class _CarrosselPublicidadeState extends State<CarrosselPublicidade> {
  Timer? _temporizador;
  int _indice = 0;

  @override
  void initState() {
    super.initState();
    _agendar();
  }

  @override
  void didUpdateWidget(covariant CarrosselPublicidade anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.intervaloSegundos != widget.intervaloSegundos ||
        anterior.reproduzindo != widget.reproduzindo ||
        anterior.banners.length != widget.banners.length) {
      _agendar();
    }
  }

  void _agendar() {
    _temporizador?.cancel();
    _temporizador = null;
    if (!widget.reproduzindo || widget.banners.length <= 1) return;
    _temporizador = Timer.periodic(
      Duration(seconds: widget.intervaloSegundos),
      (_) {
        if (!mounted) return;
        setState(() => _indice = (_indice + 1) % widget.banners.length);
      },
    );
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  Widget _transicao(Widget child, Animation<double> animation) {
    switch (widget.transicao) {
      case TransicaoCarrossel.suave:
        return FadeTransition(opacity: animation, child: child);
      case TransicaoCarrossel.deslizar:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case TransicaoCarrossel.semAnimacao:
        return child;
    }
  }

  Widget _indicadores(int indiceAtual) => Positioned(
        bottom: 6,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.banners.length; i++)
              Container(
                key: ValueKey('indicador-carrossel-$i'),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _diametroIndicador,
                height: _diametroIndicador,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == indiceAtual
                      ? widget.corIndicadores
                      : widget.corIndicadores.withValues(alpha: .35),
                ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();
    final indiceSeguro = _indice % widget.banners.length;
    final banner = widget.banners[indiceSeguro];
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: _transicao,
            child: BannerPublicidade(
              key: ValueKey('banner-carrossel-${banner.id}'),
              midia: banner,
            ),
          ),
        ),
        if (widget.banners.length > 1) _indicadores(indiceSeguro),
      ],
    );
  }
}
