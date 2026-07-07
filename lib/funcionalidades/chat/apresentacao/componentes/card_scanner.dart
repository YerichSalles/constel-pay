import 'package:flutter/material.dart';

import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/cartao.dart';

class CardScanner extends StatefulWidget {
  const CardScanner(
      {super.key, required this.aoEscanear, this.habilitado = true});

  final VoidCallback aoEscanear;
  final bool habilitado;

  @override
  State<CardScanner> createState() => _CardScannerState();
}

class _CardScannerState extends State<CardScanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Widget _canto({required Alignment alinhamento, required Color cor}) {
    const lado = BorderSide(width: 3);
    final superior = alinhamento.y < 0;
    final esquerdo = alinhamento.x < 0;
    return Align(
      alignment: alinhamento,
      child: Container(
        margin: const EdgeInsets.all(12),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border(
            top: superior ? lado.copyWith(color: cor) : BorderSide.none,
            bottom: !superior ? lado.copyWith(color: cor) : BorderSide.none,
            left: esquerdo ? lado.copyWith(color: cor) : BorderSide.none,
            right: !esquerdo ? lado.copyWith(color: cor) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return Cartao(
      preenchimento: const EdgeInsets.all(14),
      filho: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 152,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFF16181A)),
                  Center(
                    child: Container(
                      width: 180,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.transparent,
                            Colors.white
                          ],
                          stops: [0, .5, 1],
                        ),
                      ),
                      child: const Opacity(
                        opacity: .9,
                        child: Text(''),
                      ),
                    ),
                  ),
                  _canto(alinhamento: Alignment.topLeft, cor: primaria),
                  _canto(alinhamento: Alignment.topRight, cor: primaria),
                  _canto(alinhamento: Alignment.bottomLeft, cor: primaria),
                  _canto(alinhamento: Alignment.bottomRight, cor: primaria),
                  AnimatedBuilder(
                    animation: _controlador,
                    builder: (contexto, _) => Positioned(
                      left: 20,
                      right: 20,
                      top: 14 + (152 - 30 - 14) * _controlador.value,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: primaria,
                          boxShadow: [
                            BoxShadow(
                              color: primaria.withValues(alpha: .9),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          BotaoPrimario(
            rotulo: '📷 Simular leitura do código',
            aoTocar: widget.habilitado ? widget.aoEscanear : null,
          ),
        ],
      ),
    );
  }
}
