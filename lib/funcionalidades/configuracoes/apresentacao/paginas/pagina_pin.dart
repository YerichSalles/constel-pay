import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../compartilhado/widgets/barra_creditos.dart';
import '../../../../compartilhado/widgets/icone_emoji.dart';
import '../componentes/teclado_numerico.dart';
import '../controladores/controlador_pin.dart';

class PaginaPin extends ConsumerStatefulWidget {
  const PaginaPin({super.key, this.destino});

  final String? destino;

  @override
  ConsumerState<PaginaPin> createState() => _PaginaPinState();
}

class _PaginaPinState extends ConsumerState<PaginaPin> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => ref.read(provedorPin.notifier).iniciar());
  }

  String _titulo(ModoPin modo) => switch (modo) {
        ModoPin.criar => 'Crie o PIN de acesso',
        ModoPin.confirmar => 'Confirme o novo PIN',
        ModoPin.verificar => 'Digite o PIN',
      };

  String _subtitulo(ModoPin modo) => switch (modo) {
        ModoPin.criar =>
          'De 4 a 6 dígitos. Ele protege as configurações do terminal.',
        ModoPin.confirmar => 'Digite o mesmo PIN novamente.',
        ModoPin.verificar => 'Acesso restrito ao administrador.',
      };

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(provedorPin);
    final controlador = ref.read(provedorPin.notifier);
    ref.listen(provedorPin.select((e) => e.concluido), (_, concluido) {
      if (!concluido) return;
      final criacao = estado.modo != ModoPin.verificar;
      context.go(widget.destino ?? (criacao ? '/splash' : '/configuracoes'));
    });

    if (estado.carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: BarraCreditos(),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IconeEmoji('🔒', tamanho: 52),
                const SizedBox(height: 12),
                Text(_titulo(estado.modo),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  _subtitulo(estado.modo),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: CoresApp.textoSecundario,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (indice) {
                    final preenchida = indice < estado.digitos.length;
                    return Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: preenchida
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                            color: preenchida
                                ? Theme.of(context).colorScheme.primary
                                : CoresApp.textoSecundario),
                      ),
                    );
                  }),
                ),
                SizedBox(
                  height: 34,
                  child: Center(
                    child: estado.erro != null
                        ? Text(estado.erro!,
                            style: const TextStyle(
                                color: CoresApp.erro,
                                fontWeight: FontWeight.w700))
                        : null,
                  ),
                ),
                TecladoNumerico(
                  aoDigitar: controlador.digitar,
                  aoApagar: controlador.apagar,
                  aoConfirmar: controlador.confirmar,
                  confirmarHabilitado: estado.digitos.length >= 4,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BarraCreditos(),
    );
  }
}
