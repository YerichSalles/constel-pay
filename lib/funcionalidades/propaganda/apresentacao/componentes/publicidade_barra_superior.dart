import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../aplicativo/injecao.dart';
import '../../dominio/entidades/publicidade_barra.dart';
import 'conteudo_publicidade.dart';

/// Slot de publicidade da barra superior do atendimento: carrega a
/// publicidade salva (SharedPreferences) e delega o render ao
/// [ConteudoPublicidade]. Enquanto carrega — ou quando não há nada
/// configurado/ativo — o próprio [ConteudoPublicidade] já resolve para
/// `SizedBox.shrink()` (mesmo default `PublicidadeBarra()` usado aqui),
/// então a barra fica idêntica à de hoje sem caixa vazia nem mudança de
/// altura.
class PublicidadeBarraSuperior extends ConsumerStatefulWidget {
  const PublicidadeBarraSuperior({super.key});

  @override
  ConsumerState<PublicidadeBarraSuperior> createState() =>
      _PublicidadeBarraSuperiorState();
}

class _PublicidadeBarraSuperiorState
    extends ConsumerState<PublicidadeBarraSuperior> {
  PublicidadeBarra _publicidade = const PublicidadeBarra();

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final publicidade = await ref.read(provedorRepositorioPublicidade).obter();
    if (!mounted) return;
    setState(() => _publicidade = publicidade);
  }

  @override
  Widget build(BuildContext context) {
    final tema = ref.watch(provedorTema);
    return ConteudoPublicidade(publicidade: _publicidade, tema: tema);
  }
}
