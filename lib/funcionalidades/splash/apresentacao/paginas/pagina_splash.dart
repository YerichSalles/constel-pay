import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/widgets/detector_toque_longo.dart';
import '../../../../compartilhado/widgets/imagem_logo.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/utils/registrador.dart';

class PaginaSplash extends ConsumerStatefulWidget {
  const PaginaSplash({super.key});

  @override
  ConsumerState<PaginaSplash> createState() => _PaginaSplashState();
}

class _PaginaSplashState extends ConsumerState<PaginaSplash>
    with TickerProviderStateMixin {
  Timer? _temporizador;
  Timer? _temporizadorBarra;
  String _nomeRestaurante = '';

  late final AnimationController _entrada;
  late final AnimationController _barra;
  late final Animation<double> _opacidadeLogo;
  late final Animation<double> _escalaLogo;
  late final Animation<double> _opacidadeNome;
  late final Animation<Offset> _deslocamentoNome;
  late final Animation<double> _opacidadeSubtitulo;
  late final Animation<Offset> _deslocamentoSubtitulo;
  late final Animation<double> _opacidadeBarra;

  @override
  void initState() {
    super.initState();
    _configurarAnimacoes();
    _temporizador = Timer(ConstantesApp.duracaoSplash, _avancar);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final configuracao =
          await ref.read(provedorRepositorioConfiguracao).obter();
      if (mounted) {
        setState(() => _nomeRestaurante = configuracao.nomeRestaurante);
      }
    });
    _autenticarEmSegundoPlano();
  }

  /// Entrada escalonada em 650ms: logo (0-350), nome (200-550) e
  /// subtítulo (300-650). A barra de carregamento anima em loop a partir
  /// de ~500ms.
  void _configurarAnimacoes() {
    _entrada = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _barra = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

    Animation<double> intervalo(double inicio, double fim) => CurvedAnimation(
        parent: _entrada, curve: Interval(inicio, fim, curve: Curves.easeOut));

    _opacidadeLogo = intervalo(0, .54);
    _escalaLogo = Tween<double>(begin: .92, end: 1).animate(intervalo(0, .54));
    _opacidadeNome = intervalo(.31, .85);
    _deslocamentoNome =
        Tween<Offset>(begin: const Offset(0, .25), end: Offset.zero)
            .animate(intervalo(.31, .85));
    _opacidadeSubtitulo = intervalo(.46, 1);
    _deslocamentoSubtitulo =
        Tween<Offset>(begin: const Offset(0, .25), end: Offset.zero)
            .animate(intervalo(.46, 1));
    _opacidadeBarra = intervalo(.62, 1);

    _entrada.forward();
    _temporizadorBarra = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _barra.repeat();
    });
  }

  /// Login automático na nuvem sem bloquear a navegação. Falhas apenas
  /// registram no log; a URL/credencial inválida não dispara chamada de rede.
  /// No sucesso, o nome do estabelecimento retornado pelo login é refletido
  /// imediatamente na tela.
  void _autenticarEmSegundoPlano() {
    unawaited(
      ref.read(provedorCasoUsoGarantirSessao).executar().then(
            (resultado) => resultado.quando(
              sucesso: (sessao) {
                if (mounted && sessao.estabelecimento.nome.isNotEmpty) {
                  setState(
                      () => _nomeRestaurante = sessao.estabelecimento.nome);
                }
              },
              erro: (falha) =>
                  registrador.w('Login automático: ${falha.mensagem}'),
            ),
          ),
    );
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    _temporizadorBarra?.cancel();
    _entrada.dispose();
    _barra.dispose();
    super.dispose();
  }

  void _avancar() {
    _temporizador?.cancel();
    if (mounted) context.go('/propaganda');
  }

  void _abrirConfiguracoes() {
    _temporizador?.cancel();
    if (mounted) context.go('/pin?destino=/configuracoes');
  }

  Color _ajustarLuminosidade(Color cor, double delta) {
    final hsl = HSLColor.fromColor(cor);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final tema = ref.watch(provedorTema);
    final primaria = TemaConstel.corDeHex(
        tema.corPrimaria, Theme.of(context).colorScheme.primary);
    final logoPath = tema.logoPath;
    final temLogo = logoPath != null && File(logoPath).existsSync();

    // Luminância relativa (linearizada) decide entre elementos claros ou
    // escuros para qualquer cor configurada por hexadecimal.
    final fundoEscuro = primaria.computeLuminance() < .5;
    final corConteudo = fundoEscuro ? Colors.white : const Color(0xFF1E1E1E);
    final corSubtitulo = corConteudo.withValues(alpha: fundoEscuro ? .85 : .72);

    return GestureDetector(
      onTap: _avancar,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _ajustarLuminosidade(primaria, .04),
                primaria,
                _ajustarLuminosidade(primaria, -.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _opacidadeLogo,
                child: ScaleTransition(
                  scale: _escalaLogo,
                  child: _logoComBrilho(primaria, temLogo, logoPath),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _opacidadeNome,
                child: SlideTransition(
                  position: _deslocamentoNome,
                  child: Text(
                    _nomeRestaurante,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: corConteudo),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FadeTransition(
                opacity: _opacidadeSubtitulo,
                child: SlideTransition(
                  position: _deslocamentoSubtitulo,
                  child: Text(
                    'Terminal de AutoPagamento',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: corSubtitulo),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _opacidadeBarra,
                child: _BarraCarregamento(animacao: _barra, cor: corConteudo),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo com brilho radial discreto atrás, gerando profundidade sem
  /// desenhar um círculo visível. O brilho extrapola o tamanho do logo via
  /// OverflowBox para não alterar o layout da coluna.
  Widget _logoComBrilho(Color primaria, bool temLogo, String? logoPath) {
    final brilho = _ajustarLuminosidade(primaria, .22);
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IgnorePointer(
          child: SizedBox(
            width: 130,
            height: 130,
            child: OverflowBox(
              maxWidth: 320,
              maxHeight: 320,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      brilho.withValues(alpha: .28),
                      brilho.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        DetectorToqueLongo(
          aoCompletar: _abrirConfiguracoes,
          filho: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: .25),
                    blurRadius: 40,
                    offset: const Offset(0, 16)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: temLogo
                ? ImagemLogo(
                    caminho: logoPath!,
                    reserva: const Text('🍽️', style: TextStyle(fontSize: 60)),
                  )
                : const Text('🍽️', style: TextStyle(fontSize: 60)),
          ),
        ),
      ],
    );
  }
}

/// Barra de carregamento indeterminada: trilho fino com segmento que
/// desliza continuamente de um lado ao outro.
class _BarraCarregamento extends StatelessWidget {
  const _BarraCarregamento({required this.animacao, required this.cor});

  final Animation<double> animacao;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: 120,
        height: 3.5,
        child: Stack(
          children: [
            Container(color: cor.withValues(alpha: .22)),
            AnimatedBuilder(
              animation: animacao,
              builder: (_, __) {
                final t = Curves.easeInOut.transform(animacao.value);
                // Alinhamento além de ±1 leva o segmento para fora do
                // trilho nas pontas; o ClipRRect corta o excedente.
                final x = -1.7 + 3.4 * t;
                return Align(
                  alignment: Alignment(x, 0),
                  child: FractionallySizedBox(
                    widthFactor: .38,
                    heightFactor: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: cor.withValues(alpha: .95),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
