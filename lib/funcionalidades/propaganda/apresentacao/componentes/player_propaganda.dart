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

  /// Pinta as tarjas do modo encaixar e o intervalo em que a midia ainda esta
  /// carregando. Vem da cor primaria do tema da loja.
  final Color corFundo;

  final VoidCallback aoTerminar;

  @override
  State<PlayerPropaganda> createState() => _PlayerPropagandaState();
}

class _PlayerPropagandaState extends State<PlayerPropaganda> {
  Timer? _temporizador;
  VideoPlayerController? _video;
  ImageStream? _fluxoImagem;
  ImageStreamListener? _ouvinteImagem;
  double? _razaoMidia;
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
      _medirImagem(arquivo);
      return;
    }
    final controlador = VideoPlayerController.file(arquivo);
    _video = controlador;
    controlador.addListener(_aoAtualizarVideo);
    controlador.initialize().then((_) {
      if (!mounted) return;
      setState(() => _razaoMidia = _razaoDe(controlador.value.size));
      controlador.play();
    }).catchError((Object _) {
      // Arquivo corrompido ou codec nao suportado: segue para a proxima midia
      // em vez de deixar a tela parada.
      if (mounted) _temporizador = Timer(const Duration(seconds: 1), _terminar);
    });
  }

  double? _razaoDe(Size tamanho) =>
      tamanho.height > 0 ? tamanho.width / tamanho.height : null;

  /// GIF e imagem parada nao expoem as dimensoes de forma sincrona: o modo
  /// automatico so consegue decidir o enquadramento depois que o decodificador
  /// devolve o primeiro frame.
  void _medirImagem(File arquivo) {
    final fluxo = FileImage(arquivo).resolve(ImageConfiguration.empty);
    final ouvinte = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        setState(() => _razaoMidia = _razaoDe(
            Size(info.image.width.toDouble(), info.image.height.toDouble())));
      },
      onError: (Object _, StackTrace? __) {
        // Imagem corrompida: nao ha o que enquadrar. A tela fica na cor de fundo
        // e o temporizador de duracao avanca a playlist normalmente.
      },
    );
    _fluxoImagem = fluxo;
    _ouvinteImagem = ouvinte;
    fluxo.addListener(ouvinte);
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
    final fluxo = _fluxoImagem;
    final ouvinte = _ouvinteImagem;
    if (fluxo != null && ouvinte != null) fluxo.removeListener(ouvinte);
    _fluxoImagem = null;
    _ouvinteImagem = null;
    _razaoMidia = null;
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
      // No modo automatico o enquadramento depende das dimensoes da imagem:
      // pintar antes de medi-las trocaria o enquadramento na cara do cliente.
      if (widget.midia.ajuste == AjusteMidia.automatico &&
          _razaoMidia == null) {
        return const SizedBox.expand();
      }
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
      // LayoutBuilder, e nao MediaQuery: o preview da aba Propaganda roda numa
      // caixa e nao em tela cheia, entao a razao da tela precisa vir da caixa.
      child: LayoutBuilder(
        builder: (context, restricoes) {
          final tamanho = restricoes.biggest;
          return _conteudo(resolverBoxFit(
            ajuste: widget.midia.ajuste,
            razaoMidia: _razaoMidia,
            razaoTela: _razaoDe(tamanho) ?? 0,
          ));
        },
      ),
    );
  }
}
