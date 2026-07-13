import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../compartilhado/widgets/detector_toque_longo.dart';
import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/utils/registrador.dart';

class PaginaSplash extends ConsumerStatefulWidget {
  const PaginaSplash({super.key});

  @override
  ConsumerState<PaginaSplash> createState() => _PaginaSplashState();
}

class _PaginaSplashState extends ConsumerState<PaginaSplash> {
  Timer? _temporizador;
  String _nomeRestaurante = '';

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final tema = ref.watch(provedorTema);
    final primaria = TemaConstel.corDeHex(
        tema.corPrimaria, Theme.of(context).colorScheme.primary);
    final logoPath = tema.logoPath;
    final temLogo = logoPath != null && File(logoPath).existsSync();

    return GestureDetector(
      onTap: _avancar,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaria.withValues(alpha: .9), primaria],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                      ? Image.file(File(logoPath), fit: BoxFit.cover)
                      : const Text('🍽️', style: TextStyle(fontSize: 60)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _nomeRestaurante,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Terminal de autoatendimento',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: .85)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white.withValues(alpha: .8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
