import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../compartilhado/widgets/cartao.dart';
import '../../../../compartilhado/widgets/rodape_leitura_homologacao.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../leitura_cartao/dominio/repositorios/gateway_nfc.dart';

enum _EstadoNfc { armado, lendo, erro }

/// Visor de leitura por NFC (antena da maquininha). Arma sozinho quando
/// [ativo] fica `true`, lê pelo `GatewayNfc` injetado e chama [aoLer] com o
/// identificador — o mesmo contrato de `CardScanner.aoLerPorCamera`, então o
/// identificador segue para `consultarPorCodigo` como qualquer outra leitura.
///
/// Timeout e erro rearmam sozinhos (o cliente só vê "aproxime de novo"); sem
/// leitura nenhuma o operador precisa trocar para outro método de leitura.
class CardNfc extends ConsumerStatefulWidget {
  const CardNfc({
    super.key,
    required this.ativo,
    required this.aoLer,
    this.aoDigitarManual,
  });

  /// Arma a antena só enquanto este card é o atual e a etapa é de leitura —
  /// mesmo papel de `CardScanner.cameraAtiva`.
  final bool ativo;

  final ValueChanged<String> aoLer;

  /// Só preenchido em homologação, igual ao `CardScanner`.
  final VoidCallback? aoDigitarManual;

  @override
  ConsumerState<CardNfc> createState() => _CardNfcState();
}

class _CardNfcState extends ConsumerState<CardNfc>
    with SingleTickerProviderStateMixin {
  static const double _altura = 176;
  static const Duration _atrasoRearme = Duration(seconds: 2);

  late final AnimationController _pulso = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800))
    ..repeat();

  /// Lido uma vez e guardado: `ref` não pode ser usado em `dispose()` depois
  /// que o widget já foi desmontado.
  late final GatewayNfc _gateway = ref.read(provedorGatewayNfc);

  _EstadoNfc _estado = _EstadoNfc.armado;
  String? _mensagemErro;

  /// Invalida leituras/rearmes de uma rodada anterior quando o card deixa de
  /// estar ativo antes deles responderem.
  int _geracao = 0;

  @override
  void initState() {
    super.initState();
    if (widget.ativo) _armar();
  }

  @override
  void didUpdateWidget(covariant CardNfc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ativo && !oldWidget.ativo) {
      _armar();
    } else if (!widget.ativo && oldWidget.ativo) {
      _geracao++;
      _gateway.cancelar();
    }
  }

  @override
  void dispose() {
    _pulso.dispose();
    if (widget.ativo) _gateway.cancelar();
    super.dispose();
  }

  Future<void> _armar() async {
    final minhaGeracao = ++_geracao;
    setState(() {
      _estado = _EstadoNfc.armado;
      _mensagemErro = null;
    });
    final resultado = await _gateway.ler();
    if (!mounted || minhaGeracao != _geracao) return;
    switch (resultado) {
      case Sucesso(:final valor):
        setState(() => _estado = _EstadoNfc.lendo);
        widget.aoLer(valor);
      case Erro(:final falha):
        setState(() {
          _estado = _EstadoNfc.erro;
          _mensagemErro = falha.mensagem;
        });
        await Future<void>.delayed(_atrasoRearme);
        if (!mounted || minhaGeracao != _geracao || !widget.ativo) return;
        await _armar();
    }
  }

  Widget _icone(Color primaria) {
    return Icon(
      _estado == _EstadoNfc.erro ? Icons.nfc_outlined : Icons.contactless,
      size: 46,
      color: _estado == _EstadoNfc.erro
          ? Colors.white.withValues(alpha: .55)
          : Colors.white,
    );
  }

  Widget _legenda(AppLocalizations t) {
    final texto = switch (_estado) {
      _EstadoNfc.armado || _EstadoNfc.lendo => t.nfcApproachCardHint,
      _EstadoNfc.erro => _mensagemErro ?? t.nfcApproachCardHint,
    };
    return Text(
      texto,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: .2,
        color: Colors.white.withValues(alpha: .82),
      ),
    );
  }

  Widget _visor(Color primaria, AppLocalizations t) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: _altura,
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
            if (_estado != _EstadoNfc.erro)
              Center(
                child: AnimatedBuilder(
                  animation: _pulso,
                  builder: (contexto, _) => CustomPaint(
                    size: const Size(140, 140),
                    painter: _OndasNfcPainter(
                        progresso: _pulso.value, cor: primaria),
                  ),
                ),
              ),
            Center(child: _icone(primaria)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: _altura * .4,
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
                child: _legenda(t),
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
    final visor = _visor(primaria, t);
    return Cartao(
      preenchimento: const EdgeInsets.all(16),
      filho: widget.aoDigitarManual == null
          ? visor
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                visor,
                RodapeLeituraHomologacao(
                    corPrimaria: primaria,
                    aoDigitarManual: widget.aoDigitarManual),
              ],
            ),
    );
  }
}

/// Ondas concêntricas pulsando para fora do ícone — feito em `CustomPainter`
/// puro, seguindo o precedente já estabelecido pela linha de varredura do
/// `CardScanner` (sem Lottie/Rive, dependências que o projeto não tem).
class _OndasNfcPainter extends CustomPainter {
  const _OndasNfcPainter({required this.progresso, required this.cor});

  final double progresso;
  final Color cor;

  static const _aneis = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final raioMaximo = size.shortestSide / 2;
    for (var anel = 0; anel < _aneis; anel++) {
      final fase = (progresso + anel / _aneis) % 1.0;
      final raio = raioMaximo * fase;
      final opacidade = (1 - fase).clamp(0.0, 1.0);
      final pincel = Paint()
        ..color = cor.withValues(alpha: opacidade * .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(centro, raio, pincel);
    }
  }

  @override
  bool shouldRepaint(covariant _OndasNfcPainter oldDelegate) =>
      oldDelegate.progresso != progresso || oldDelegate.cor != cor;
}
