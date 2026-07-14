import 'package:flutter/material.dart';

import '../../../../compartilhado/widgets/botao_primario.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../l10n/app_localizations.dart';

class CardScanner extends StatefulWidget {
  const CardScanner({
    super.key,
    required this.aoEscanear,
    this.aoDigitarComanda,
    this.habilitado = true,
  });

  final VoidCallback aoEscanear;

  /// TEMPORÁRIO (teste da API de consumo): permite digitar o número da
  /// comanda em vez de escanear. Remover junto com o campo quando o scanner
  /// real entrar.
  final ValueChanged<String>? aoDigitarComanda;
  final bool habilitado;

  @override
  State<CardScanner> createState() => _CardScannerState();
}

class _CardScannerState extends State<CardScanner>
    with SingleTickerProviderStateMixin {
  static const double _alturaVisor = 168;

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
    widget.aoDigitarComanda?.call(texto);
    _comanda.clear();
  }

  Widget _canto({required Alignment alinhamento, required Color cor}) {
    final lado = BorderSide(width: 3.5, color: cor);
    final superior = alinhamento.y < 0;
    final esquerdo = alinhamento.x < 0;
    return Align(
      alignment: alinhamento,
      child: Container(
        margin: const EdgeInsets.all(14),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft:
                superior && esquerdo ? const Radius.circular(8) : Radius.zero,
            topRight:
                superior && !esquerdo ? const Radius.circular(8) : Radius.zero,
            bottomLeft:
                !superior && esquerdo ? const Radius.circular(8) : Radius.zero,
            bottomRight:
                !superior && !esquerdo ? const Radius.circular(8) : Radius.zero,
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
    const larguras = <double>[3, 2, 5, 2, 3, 6, 2, 4, 2, 5, 3, 2, 6, 3, 2, 4];
    return Opacity(
      opacity: .55,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final largura in larguras)
            Container(
              width: largura,
              height: 46,
              margin: const EdgeInsets.symmetric(horizontal: 1.6),
              decoration: BoxDecoration(
                color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    final t = AppLocalizations.of(context);
    return Cartao(
      preenchimento: const EdgeInsets.all(14),
      filho: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
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
                        colors: [Color(0xFF23262F), Color(0xFF14161B)],
                      ),
                    ),
                  ),
                  Center(child: _codigoBarras()),
                  _canto(alinhamento: Alignment.topLeft, cor: primaria),
                  _canto(alinhamento: Alignment.topRight, cor: primaria),
                  _canto(alinhamento: Alignment.bottomLeft, cor: primaria),
                  _canto(alinhamento: Alignment.bottomRight, cor: primaria),
                  _linhaVarredura(primaria),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        t.scanPositionHint,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: .75),
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
            rotulo: t.simulateScanButton,
            aoTocar: widget.habilitado ? widget.aoEscanear : null,
          ),
          // TEMPORÁRIO (teste da API de consumo): digitação manual da comanda.
          if (widget.aoDigitarComanda != null) ...[
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
