import 'package:flutter/material.dart';

import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../l10n/app_localizations.dart';

class CardScanner extends StatefulWidget {
  const CardScanner({
    super.key,
    required this.aoEscanear,
    this.aoInformarCodigo,
    this.habilitado = true,
  });

  final VoidCallback aoEscanear;

  /// Fallback manual: digitar o número da comanda quando o código de barras
  /// estiver ilegível/danificado. O leitor de hardware entra pela captura de
  /// teclado, sem passar por este campo.
  final ValueChanged<String>? aoInformarCodigo;
  final bool habilitado;

  @override
  State<CardScanner> createState() => _CardScannerState();
}

class _CardScannerState extends State<CardScanner>
    with SingleTickerProviderStateMixin {
  static const double _alturaVisor = 176;

  late final AnimationController _controlador = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200))
    ..repeat(reverse: true);
  final TextEditingController _comanda = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    _comanda.dispose();
    super.dispose();
  }

  void _enviarComanda() {
    final texto = _comanda.text.trim();
    if (texto.isEmpty) return;
    widget.aoInformarCodigo?.call(texto);
    _comanda.clear();
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
      filho: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _visor(primaria, t),
          const SizedBox(height: 14),
          BotaoPrimario(
            rotulo: t.simulateScanButton,
            aoTocar: widget.habilitado ? widget.aoEscanear : null,
          ),
          // Fallback manual: digitação da comanda quando o código não lê.
          if (widget.aoInformarCodigo != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _comanda,
                    enabled: widget.habilitado,
                    keyboardType: TextInputType.number,
                    onSubmitted:
                        widget.habilitado ? (_) => _enviarComanda() : null,
                    decoration: InputDecoration(
                      hintText: t.cardNumberHint,
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF4F3F8),
                      prefixIcon: const Icon(Icons.tag, size: 18),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: widget.habilitado ? _enviarComanda : null,
                  child: Text(t.searchButton),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
