import 'package:flutter/material.dart';

import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../compartilhado/widgets/leitor_camera.dart';
import '../../../../l10n/app_localizations.dart';

/// Visor de leitura. Por padrão só orienta o cliente a posicionar o código: a
/// leitura chega pelo leitor de hardware, capturado no nível da página.
///
/// Com [aoLerPorCamera], o visor vira a prévia da câmera — usado nos totens
/// Android sem leitor, conforme a configuração do terminal.
class CardScanner extends StatefulWidget {
  const CardScanner({
    super.key,
    this.aoLerPorCamera,
    this.cameraAtiva = false,
  });

  /// Quando informado, o card lê pela câmera em vez de exibir só a animação.
  final ValueChanged<String>? aoLerPorCamera;

  /// Mantém a câmera aberta apenas durante a fase de leitura.
  final bool cameraAtiva;

  @override
  State<CardScanner> createState() => _CardScannerState();
}

class _CardScannerState extends State<CardScanner>
    with SingleTickerProviderStateMixin {
  static const double _alturaVisor = 176;

  late final AnimationController _controlador = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Widget _canto({required Alignment alinhamento, required Color cor}) {
    final lado = BorderSide(width: 3, color: cor);
    final superior = alinhamento.y < 0;
    final esquerdo = alinhamento.x < 0;
    return Align(
      alignment: alinhamento,
      child: Container(
        margin: const EdgeInsets.all(14),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft:
                superior && esquerdo ? const Radius.circular(7) : Radius.zero,
            topRight:
                superior && !esquerdo ? const Radius.circular(7) : Radius.zero,
            bottomLeft:
                !superior && esquerdo ? const Radius.circular(7) : Radius.zero,
            bottomRight:
                !superior && !esquerdo ? const Radius.circular(7) : Radius.zero,
          ),
          border: Border(
            top: superior ? lado : BorderSide.none,
            bottom: !superior ? lado : BorderSide.none,
            left: esquerdo ? lado : BorderSide.none,
            right: !esquerdo ? lado : BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// Ilustração estilizada de código de barras dentro do visor.
  Widget _codigoBarras() {
    const larguras = <double>[
      3,
      2,
      5,
      2,
      3,
      6,
      2,
      4,
      2,
      5,
      3,
      2,
      6,
      3,
      2,
      4,
      2,
      5,
      3,
      2,
      4,
      2,
      6,
      3
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: .12),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final largura in larguras)
            Container(
              width: largura,
              height: 58,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .82),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _linhaVarredura(Color primaria) {
    return AnimatedBuilder(
      animation: _controlador,
      builder: (contexto, _) => Positioned(
        left: 26,
        right: 26,
        top: 18 + (_alturaVisor - 36) * _controlador.value,
        child: Container(
          height: 2.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                primaria.withValues(alpha: 0),
                primaria,
                primaria.withValues(alpha: 0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaria.withValues(alpha: .7),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Visor escuro com a animação de varredura do código de barras.
  Widget _visor(Color primaria, AppLocalizations t) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: _alturaVisor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF262A35), Color(0xFF12141A)],
                ),
              ),
            ),
            // Brilho suave no topo do visor.
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: _alturaVisor * .5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaria.withValues(alpha: .18),
                      primaria.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Center(child: _codigoBarras()),
            _canto(alinhamento: Alignment.topLeft, cor: primaria),
            _canto(alinhamento: Alignment.topRight, cor: primaria),
            _canto(alinhamento: Alignment.bottomLeft, cor: primaria),
            _canto(alinhamento: Alignment.bottomRight, cor: primaria),
            _linhaVarredura(primaria),
            // Sombreado inferior para destacar a legenda sobre o visor.
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: _alturaVisor * .4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x0012141A), Color(0xCC0E1015)],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 13, left: 18, right: 18),
                child: Text(
                  t.scanPositionHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .2,
                    color: Colors.white.withValues(alpha: .82),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    final t = AppLocalizations.of(context);
    return Cartao(
      preenchimento: const EdgeInsets.all(16),
      filho: widget.aoLerPorCamera == null
          ? _visor(primaria, t)
          : LeitorCamera(
              aoLer: widget.aoLerPorCamera!,
              ativo: widget.cameraAtiva,
              altura: _alturaVisor,
              reserva: _visor(primaria, t),
            ),
    );
  }
}
