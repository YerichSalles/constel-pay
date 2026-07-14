import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../dominio/entidades/midia_propaganda.dart';
import '../ajuste_tela.dart';

/// Sigma suficiente para descaracterizar a borda sem custo excessivo.
const double _sigmaFundoBorrado = 24;

/// O fundo do video e pintado reduzido por este fator e ampliado de volta:
/// o blur roda numa textura 16x menor, cortando o custo por frame.
const double _reducaoFundoVideo = 4;

class PlayerPropaganda extends StatefulWidget {
  const PlayerPropaganda({
    super.key,
    required this.midia,
    required this.corFundo,
    required this.aoTerminar,
  });

  final MidiaPropaganda midia;

  /// Pinta a sobra dos modos automatico e encaixar (quando o fundo e cor) e o
  /// intervalo em que a midia ainda esta carregando. Vem da cor primaria do
  /// tema da loja.
  final Color corFundo;

  final VoidCallback aoTerminar;

  @override
  State<PlayerPropaganda> createState() => _PlayerPropagandaState();
}

class _PlayerPropagandaState extends State<PlayerPropaganda> {
  Timer? _temporizador;
  VideoPlayerController? _video;
  bool _terminado = false;

  @override
  void initState() {
    super.initState();
    _preparar();
  }

  @override
  void didUpdateWidget(covariant PlayerPropaganda anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.midia.id != widget.midia.id) {
      _limpar();
      _preparar();
    }
  }

  /// O listener do video dispara varias vezes no fim da reproducao; sem esta
  /// guarda a playlist pularia midias.
  void _terminar() {
    if (_terminado) return;
    _terminado = true;
    widget.aoTerminar();
  }

  void _preparar() {
    _terminado = false;
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) {
      _temporizador = Timer(const Duration(seconds: 1), _terminar);
      return;
    }
    if (widget.midia.tipo == TipoMidia.imagem) {
      _temporizador =
          Timer(Duration(seconds: widget.midia.duracaoSegundos), _terminar);
      return;
    }
    final controlador = VideoPlayerController.file(arquivo);
    _video = controlador;
    controlador.addListener(_aoAtualizarVideo);
    controlador.initialize().then((_) {
      if (!mounted) return;
      // O tamanho do video so existe depois do initialize: este rebuild
      // troca o SizedBox vazio pela textura.
      setState(() {});
      controlador.play();
    }).catchError((Object _) {
      // Arquivo corrompido ou codec nao suportado: segue para a proxima midia
      // em vez de deixar a tela parada.
      if (mounted) _temporizador = Timer(const Duration(seconds: 1), _terminar);
    });
  }

  void _aoAtualizarVideo() {
    final valor = _video?.value;
    if (valor == null) return;
    if (valor.hasError) {
      _terminar();
      return;
    }
    if (valor.isInitialized &&
        valor.duration > Duration.zero &&
        valor.position >= valor.duration) {
      _terminar();
    }
  }

  void _limpar() {
    _temporizador?.cancel();
    _temporizador = null;
    _video?.removeListener(_aoAtualizarVideo);
    _video?.dispose();
    _video = null;
  }

  @override
  void dispose() {
    _limpar();
    super.dispose();
  }

  bool get _mostraFundoBorrado {
    if (!modoDeixaSobra(widget.midia.ajuste)) return false;
    final fundo =
        fundoEfetivo(tipo: widget.midia.tipo, fundo: widget.midia.fundo);
    if (fundo != FundoMidia.borrado) return false;
    // Sem midia pronta nao ha o que borrar: fica na cor de fundo.
    if (widget.midia.tipo == TipoMidia.imagem) {
      return File(widget.midia.caminho).existsSync();
    }
    return _video?.value.isInitialized ?? false;
  }

  Widget _fundoBorrado() {
    if (widget.midia.tipo == TipoMidia.imagem) {
      // Estatico: o RepaintBoundary rasteriza o blur uma vez e reaproveita.
      return RepaintBoundary(
        key: const ValueKey('fundo-borrado'),
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
              sigmaX: _sigmaFundoBorrado,
              sigmaY: _sigmaFundoBorrado,
              tileMode: ui.TileMode.clamp),
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: RotatedBox(
              quarterTurns: resolverQuartosDeVolta(widget.midia.rotacaoGraus),
              child: Image.file(File(widget.midia.caminho)),
            ),
          ),
        ),
      );
    }
    final video = _video!;
    // Mesma textura do video nitido (nenhum segundo decoder): a copia e
    // pintada reduzida, borrada em baixa resolucao e ampliada de volta.
    return LayoutBuilder(
      key: const ValueKey('fundo-borrado'),
      builder: (context, restricoes) {
        final caixa = restricoes.biggest;
        return ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Transform.scale(
              scale: _reducaoFundoVideo,
              child: SizedBox(
                width: caixa.width / _reducaoFundoVideo,
                height: caixa.height / _reducaoFundoVideo,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                      sigmaX: _sigmaFundoBorrado / _reducaoFundoVideo,
                      sigmaY: _sigmaFundoBorrado / _reducaoFundoVideo,
                      tileMode: ui.TileMode.clamp),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: RotatedBox(
                      quarterTurns:
                          resolverQuartosDeVolta(widget.midia.rotacaoGraus),
                      child: SizedBox(
                        width: video.value.size.width,
                        height: video.value.size.height,
                        child: VideoPlayer(video),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _conteudo() {
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) return const SizedBox.expand();
    final ajuste = widget.midia.ajuste;
    final fit = resolverBoxFit(ajuste);
    final alinhamento = ajuste == AjusteMidia.preencher
        ? resolverAlinhamento(widget.midia.ancora)
        : Alignment.center;
    final Widget midia;
    if (widget.midia.tipo == TipoMidia.imagem) {
      midia = Image.file(arquivo);
    } else {
      final video = _video;
      if (video == null || !video.value.isInitialized) {
        return const SizedBox.expand();
      }
      midia = SizedBox(
        width: video.value.size.width,
        height: video.value.size.height,
        child: VideoPlayer(video),
      );
    }
    // A rotacao acontece antes do fit: o RotatedBox gira o layout e o
    // FittedBox enquadra a midia ja girada com a razao certa.
    final Widget conteudo = FittedBox(
      key: const ValueKey('midia-nitida'),
      fit: fit,
      alignment: alinhamento,
      clipBehavior: Clip.hardEdge,
      child: RotatedBox(
        quarterTurns: resolverQuartosDeVolta(widget.midia.rotacaoGraus),
        child: midia,
      ),
    );
    if (ajuste != AjusteMidia.preencher) return conteudo;
    // Zoom so existe no preencher: amplia a partir da ancora e corta a sobra.
    return ClipRect(
      child: Transform.scale(
        scale: resolverEscala(widget.midia.zoomPercentual),
        alignment: alinhamento,
        child: conteudo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.corFundo,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_mostraFundoBorrado) _fundoBorrado(),
          _conteudo(),
        ],
      ),
    );
  }
}
