import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../dominio/entidades/midia_propaganda.dart';
import '../ajuste_tela.dart';

class PlayerPropaganda extends StatefulWidget {
  const PlayerPropaganda({
    super.key,
    required this.midia,
    required this.corFundo,
    required this.aoTerminar,
  });

  final MidiaPropaganda midia;

  /// Pinta a sobra do modo encaixar (quando o fundo e cor) e o intervalo em
  /// que a midia ainda esta carregando. Vem da cor primaria do tema da loja.
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

  Widget _conteudo(BoxFit fit) {
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) return const SizedBox.expand();
    if (widget.midia.tipo == TipoMidia.imagem) {
      return Image.file(arquivo,
          fit: fit, width: double.infinity, height: double.infinity);
    }
    final video = _video;
    if (video == null || !video.value.isInitialized) {
      return const SizedBox.expand();
    }
    return FittedBox(
      fit: fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: video.value.size.width,
        height: video.value.size.height,
        child: VideoPlayer(video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.corFundo,
      child: SizedBox.expand(
        child: _conteudo(resolverBoxFit(widget.midia.ajuste)),
      ),
    );
  }
}
