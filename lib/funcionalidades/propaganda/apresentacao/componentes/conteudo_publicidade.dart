import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../nucleo/utils/contraste.dart';
import '../../../configuracoes/dominio/entidades/tema_personalizado.dart';
import '../../dominio/entidades/publicidade_barra.dart';
import 'carrossel_publicidade.dart';
import 'letreiro_publicidade.dart';

/// Ajusta a luminosidade (HSL) de uma cor, com clamp em [0, 1]. Mesmo padrao
/// de `_ajustarLuminosidade` da `BarraSuperior`.
Color _ajustarLuminosidade(Color cor, double delta) {
  final hsl = HSLColor.fromColor(cor);
  return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
}

/// Cores derivadas do tema para a area publicitaria da barra superior
/// (funcao pura, testavel sem montar widget).
class CoresPublicidade {
  const CoresPublicidade({
    required this.fundo,
    required this.texto,
    required this.destaque,
  });

  /// Variacao HSL da cor primaria.
  final Color fundo;

  /// Branco ou `#1E1E1E`, escolhida pela luminancia do fundo.
  final Color texto;

  /// Cor secundaria quando o contraste com o fundo e suficiente para texto
  /// grande; senao cai na mesma cor do texto (separador do letreiro,
  /// indicadores do carrossel).
  final Color destaque;
}

/// Deriva as cores da area publicitaria a partir do tema personalizado:
/// fundo = cor primaria clareada (se escura) ou escurecida (se clara) em
/// 0,10 de lightness HSL; texto = branco ou `#1E1E1E` pela luminancia do
/// fundo; destaque = cor secundaria se o contraste com o fundo atingir o
/// minimo de texto grande (3.0), senao a propria cor do texto.
CoresPublicidade calcularCoresPublicidade(TemaPersonalizado tema) {
  final primaria = TemaConstel.corDeHex(
    tema.corPrimaria,
    CoresApp.primariaPadrao,
  );
  final secundaria = TemaConstel.corDeHex(
    tema.corSecundaria,
    CoresApp.secundariaPadrao,
  );
  final delta = primaria.computeLuminance() < 0.5 ? 0.10 : -0.10;
  final fundo = _ajustarLuminosidade(primaria, delta);
  final texto =
      fundo.computeLuminance() < 0.5 ? Colors.white : const Color(0xFF1E1E1E);
  final destaque =
      razaoDeContraste(fundo, secundaria) >= contrasteMinimoTextoGrande
          ? secundaria
          : texto;
  return CoresPublicidade(fundo: fundo, texto: texto, destaque: destaque);
}

/// Despachante puro (stateless) da publicidade da barra superior: escolhe o
/// widget certo pelo formato configurado, ja com as cores derivadas do tema.
class ConteudoPublicidade extends StatelessWidget {
  const ConteudoPublicidade({
    super.key,
    required this.publicidade,
    required this.tema,
    this.reproduzindo = true,
  });

  final PublicidadeBarra publicidade;
  final TemaPersonalizado tema;

  /// Pausavel na previa (edicao); no atendimento fica sempre true.
  final bool reproduzindo;

  /// Altura padrão da área publicitária. O letreiro já tem essa altura no
  /// próprio container; carrossel e parceiro (Stack/imagem sem tamanho
  /// intrínseco) PRECISAM dela para nunca receber constraints sem limite
  /// (ex.: prévia dentro de coluna rolável) — sem isso o Stack do carrossel
  /// estoura `size.isFinite` e nada é exibido.
  static const double alturaPublicidade = 40;

  @override
  Widget build(BuildContext context) {
    if (!publicidade.exibivel) return const SizedBox.shrink();
    final cores = calcularCoresPublicidade(tema);
    switch (publicidade.formato) {
      case FormatoPublicidade.carrossel:
        return SizedBox(
          height: alturaPublicidade,
          child: CarrosselPublicidade(
            banners: publicidade.bannersAtivos,
            intervaloSegundos: publicidade.intervaloSegundos,
            transicao: publicidade.transicao,
            corIndicadores: cores.destaque,
            reproduzindo: reproduzindo,
          ),
        );
      case FormatoPublicidade.letreiro:
        return LetreiroPublicidade(
          mensagens: publicidade.mensagensAtivas.map((m) => m.texto).toList(),
          separador: publicidade.separador,
          velocidade: publicidade.velocidade,
          corFundo: cores.fundo,
          corTexto: cores.texto,
          corSeparador: cores.destaque,
          fonte: tema.fonte,
          animar: reproduzindo,
        );
      case FormatoPublicidade.parceiro:
        // Mesmo render do banner do carrossel, sem timer nem indicadores.
        return SizedBox(
          height: alturaPublicidade,
          child: BannerPublicidade(midia: publicidade.midiaParceiro!),
        );
    }
  }
}
