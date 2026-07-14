import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/estilos_texto.dart';
import '../../dominio/entidades/publicidade_barra.dart';

/// Altura fixa do letreiro, com o container ja arredondado.
const double _alturaLetreiro = 40;

/// Espaco entre uma repeticao do texto e a proxima, para o loop nao parecer
/// que o texto "colou" nele mesmo.
const double _espacamentoRepeticao = 48;

/// Padding horizontal da linha estatica (`_linhaEstatica`), de cada lado.
/// Entra na decisao de animar: sem descontar essa folga, um texto que cabe
/// em `restricoes.maxWidth` mas nao em `maxWidth - 2 * _preenchimentoEstatico`
/// ficaria estatico e cortado.
const double _preenchimentoEstatico = 12;

/// Velocidade de translacao do letreiro em pixels por segundo.
const Map<VelocidadeLetreiro, double> _pxPorSegundo = {
  VelocidadeLetreiro.lenta: 40,
  VelocidadeLetreiro.normal: 70,
  VelocidadeLetreiro.rapida: 110,
};

/// Letreiro de mensagens da publicidade da barra superior. Mede o texto
/// composto (mensagens unidas pelo separador); se couber na largura
/// disponivel fica estatico e centralizado, senao translada continuamente.
class LetreiroPublicidade extends StatefulWidget {
  const LetreiroPublicidade({
    super.key,
    required this.mensagens,
    required this.separador,
    required this.velocidade,
    required this.corFundo,
    required this.corTexto,
    required this.corSeparador,
    required this.fonte,
    this.animar = true,
  });

  /// Mensagens ja ativas e ordenadas — o chamador decide o que entra.
  final List<String> mensagens;
  final String separador;
  final VelocidadeLetreiro velocidade;

  /// Variacao da cor primaria, calculada pelo chamador.
  final Color corFundo;
  final Color corTexto;
  final Color corSeparador;

  /// Nome da fonte escolhida na aba Aparencia.
  final String fonte;

  /// Falso na previa pausada e em testes: nunca anima, mesmo se o texto nao
  /// couber (fica estatico, podendo cortar).
  final bool animar;

  @override
  State<LetreiroPublicidade> createState() => _LetreiroPublicidadeState();
}

class _LetreiroPublicidadeState extends State<LetreiroPublicidade>
    with TickerProviderStateMixin {
  AnimationController? _controlador;
  int? _duracaoMsAtual;

  TextStyle get _estilo => EstilosTexto.estilo(
        widget.fonte,
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ).copyWith(color: widget.corTexto);

  /// Spans do texto composto: mensagens em `corTexto`, separadores
  /// (` <separador> `) em `corSeparador`, ambos com o mesmo estilo base.
  List<InlineSpan> get _spans {
    final estiloSeparador = _estilo.copyWith(color: widget.corSeparador);
    final spans = <InlineSpan>[];
    for (var i = 0; i < widget.mensagens.length; i++) {
      if (i > 0) {
        spans.add(TextSpan(
          text: ' ${widget.separador} ',
          style: estiloSeparador,
        ));
      }
      spans.add(TextSpan(text: widget.mensagens[i], style: _estilo));
    }
    return spans;
  }

  double _medirLargura() {
    final painter = TextPainter(
      text: TextSpan(style: _estilo, children: _spans),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  void _prepararControlador(double periodoPx) {
    final velocidade = _pxPorSegundo[widget.velocidade]!;
    final duracaoMs = (periodoPx / velocidade * 1000).round().clamp(1, 1 << 30);
    if (_controlador != null && _duracaoMsAtual == duracaoMs) return;
    _controlador?.dispose();
    _duracaoMsAtual = duracaoMs;
    _controlador = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duracaoMs),
    )..repeat();
  }

  void _pararControlador() {
    if (_controlador == null) return;
    _controlador!.dispose();
    _controlador = null;
    _duracaoMsAtual = null;
  }

  @override
  void dispose() {
    _controlador?.dispose();
    super.dispose();
  }

  Widget _linhaEstatica() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _preenchimentoEstatico,
          ),
          child: Text.rich(
            TextSpan(style: _estilo, children: _spans),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );

  Widget _linhaAnimada(double largura) {
    final periodo = largura + _espacamentoRepeticao;
    _prepararControlador(periodo);
    final controlador = _controlador!;
    final spans = _spans;
    return AnimatedBuilder(
      animation: controlador,
      builder: (context, _) {
        final deslocamento = -(controlador.value * periodo);
        return Stack(
          children: [
            for (final offset in [deslocamento, deslocamento + periodo])
              Positioned(
                left: offset,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: _espacamentoRepeticao),
                    child: Text.rich(
                      TextSpan(style: _estilo, children: spans),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _alturaLetreiro,
      decoration: BoxDecoration(
        color: widget.corFundo,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, restricoes) {
            final largura = _medirLargura();
            final larguraUtil =
                restricoes.maxWidth - 2 * _preenchimentoEstatico;
            final anima = widget.animar && largura > larguraUtil;
            if (!anima) {
              _pararControlador();
              return _linhaEstatica();
            }
            return _linhaAnimada(largura);
          },
        ),
      ),
    );
  }
}
