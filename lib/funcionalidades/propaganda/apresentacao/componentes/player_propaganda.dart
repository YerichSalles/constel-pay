import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../dominio/entidades/midia_propaganda.dart';

class PlayerPropaganda extends StatefulWidget {
  const PlayerPropaganda(
      {super.key, required this.midia, required this.aoTerminar});

  final MidiaPropaganda midia;
  final VoidCallback aoTerminar;

  @override
  State<PlayerPropaganda> createState() => _PlayerPropagandaState();
}

class _PlayerPropagandaState extends State<PlayerPropaganda> {
  Timer? _temporizador;
  VideoPlayerController? _video;

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

  void _preparar() {
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) {
      _temporizador = Timer(const Duration(seconds: 1), widget.aoTerminar);
      return;
    }
    if (widget.midia.tipo == TipoMidia.imagem) {
      _temporizador = Timer(
          Duration(seconds: widget.midia.duracaoSegundos), widget.aoTerminar);
    } else {
      final controlador = VideoPlayerController.file(arquivo);
      _video = controlador;
      controlador.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        controlador.play();
      });
      controlador.addListener(() {
        final valor = controlador.value;
        if (valor.isInitialized &&
            !valor.isPlaying &&
            valor.position >= valor.duration &&
            valor.duration > Duration.zero) {
          widget.aoTerminar();
        }
      });
    }
  }

  void _limpar() {
    _temporizador?.cancel();
    _temporizador = null;
    _video?.dispose();
    _video = null;
  }

  @override
  void dispose() {
    _limpar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) {
      return const ColoredBox(color: Colors.black);
    }
    if (widget.midia.tipo == TipoMidia.imagem) {
      return Image.file(arquivo,
          fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }
    final video = _video;
    if (video == null || !video.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: video.value.size.width,
        height: video.value.size.height,
        child: VideoPlayer(video),
      ),
    );
  }
}
