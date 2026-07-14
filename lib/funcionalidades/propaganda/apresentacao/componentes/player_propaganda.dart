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
    this.emLoop = false,
    this.ativo = true,
    this.aoPreparado,
  });

  final MidiaPropaganda midia;

  /// Com midia unica na playlist (e no preview do dialogo), o video repete no
  /// proprio decoder: recriar o player a cada volta pisca a cor de fundo
  /// durante o initialize. Em loop, [aoTerminar] nao dispara no fim do video.
  final bool emLoop;

  /// Falso enquanto o player e o "proximo" da fila: prepara a midia (decode,
  /// initialize) sem tocar nem agendar avanco. O trocador vira a chave quando
  /// chega a vez.
  final bool ativo;

  /// Dispara uma unica vez, quando a midia esta tao pronta quanto vai ficar:
  /// video inicializado, imagem decodificada — ou falha que vai pintar a cor
  /// de fundo. E o sinal de que a troca pode acontecer sem piscar.
  final VoidCallback? aoPreparado;

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
  ImageStream? _fluxoImagem;
  ImageStreamListener? _ouvinteImagem;
  bool _preparado = false;
  bool _falhou = false;

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
      return;
    }
    if (!anterior.ativo && widget.ativo) _comecar();
  }

  /// O listener do video dispara varias vezes no fim da reproducao; sem esta
  /// guarda a playlist pularia midias. Inativo nunca termina: latchar aqui
  /// deixaria o totem preso quando este player fosse promovido.
  void _terminar() {
    if (!widget.ativo || _terminado) return;
    _terminado = true;
    widget.aoTerminar();
  }

  void _preparar() {
    _terminado = false;
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) {
      if (widget.ativo) _agendarAvancoDeErro();
      _sinalizarPreparado();
      return;
    }
    if (widget.midia.tipo == TipoMidia.imagem) {
      if (widget.ativo) _agendarTimerDaImagem();
      _decodificarImagem(arquivo);
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
      controlador.setLooping(widget.emLoop);
      if (widget.ativo) controlador.play();
      _sinalizarPreparado();
    }).catchError((Object _) {
      // Arquivo corrompido ou codec nao suportado: descarta o controller e
      // avanca como erro — na vez deste player, nao antes.
      if (!mounted) return;
      _video?.removeListener(_aoAtualizarVideo);
      _video?.dispose();
      _video = null;
      _falhou = true;
      if (widget.ativo) _agendarAvancoDeErro();
      _sinalizarPreparado();
    });
  }

  void _agendarAvancoDeErro() {
    _temporizador = Timer(const Duration(seconds: 1), _terminar);
  }

  void _agendarTimerDaImagem() {
    _temporizador =
        Timer(Duration(seconds: widget.midia.duracaoSegundos), _terminar);
  }

  /// O decode do primeiro frame e o "pronto" da imagem (e povoa o cache: na
  /// vez dela, pinta sem atraso). Erro tambem sinaliza — a cor de fundo cobre.
  void _decodificarImagem(File arquivo) {
    final fluxo = FileImage(arquivo).resolve(ImageConfiguration.empty);
    final ouvinte = ImageStreamListener(
      (_, __) => _sinalizarPreparado(),
      onError: (Object _, StackTrace? __) => _sinalizarPreparado(),
    );
    _fluxoImagem = fluxo;
    _ouvinteImagem = ouvinte;
    fluxo.addListener(ouvinte);
  }

  void _sinalizarPreparado() {
    if (_preparado) return;
    _preparado = true;
    widget.aoPreparado?.call();
  }

  /// Chegou a vez deste player: o que estava so preparado passa a rodar.
  void _comecar() {
    final arquivo = File(widget.midia.caminho);
    if (!arquivo.existsSync()) {
      _agendarAvancoDeErro();
      return;
    }
    if (widget.midia.tipo == TipoMidia.imagem) {
      _agendarTimerDaImagem();
      return;
    }
    final video = _video;
    if (video == null) {
      if (_falhou) _agendarAvancoDeErro();
      return;
    }
    if (video.value.hasError) {
      // Erro que chegou enquanto era o seguinte: avancar como erro em vez de
      // dar play num controller morto (travaria o totem no frame congelado).
      _agendarAvancoDeErro();
      return;
    }
    if (video.value.isInitialized) {
      video.play();
    }
    // Se o initialize ainda esta em andamento, o proprio then da o play:
    // ele le widget.ativo na hora em que termina.
  }

  void _aoAtualizarVideo() {
    final valor = _video?.value;
    if (valor == null) return;
    if (valor.hasError) {
      _terminar();
      return;
    }
    // Em loop o decoder reinicia sozinho; disparar o fim aqui recriaria o
    // player e traria de volta a piscada que o loop existe para evitar.
    if (!widget.emLoop &&
        valor.isInitialized &&
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
    _preparado = false;
    _falhou = false;
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
    if (!modoDeixaSobra(widget.midia.ajuste, widget.midia.zoomPercentual)) {
      return false;
    }
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
