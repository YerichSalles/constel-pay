import 'package:flutter/material.dart';

/// Ícone Material (Google) no lugar dos emojis usados como ícone pela UI.
///
/// Emojis chegam de entidades e de dados da API; os conhecidos viram ícones
/// do Material com sua cor usual (Pix teal, cartão azul etc.). Um emoji
/// desconhecido continua renderizado como texto — conteúdo dinâmico da API
/// nunca quebra a tela.
class IconeEmoji extends StatelessWidget {
  const IconeEmoji(this.emoji, {super.key, required this.tamanho, this.cor});

  final String emoji;

  /// Tamanho do ícone (o fallback em texto é levemente menor, porque o glifo
  /// de emoji ocupa mais caixa que um ícone do mesmo tamanho nominal).
  final double tamanho;

  /// Sobrepõe a cor padrão do ícone (ex.: branco sobre fundo colorido).
  final Color? cor;

  /// Teal oficial do Pix (Banco Central).
  static const Color corPix = Color(0xFF32BCAD);

  /// Azul usual de cartão; público para o grid de métodos usar o mesmo tom.
  static const Color corCartao = Color(0xFF1565C0);

  // Âmbar escurecido: os tons claros (#F9A825) não alcançam o contraste
  // mínimo de 3:1 sobre os fundos claros do app (chips lilás, #F7F7FB).
  static const Color _ambar = Color(0xFFE65100);
  static const Color _cinzaNeutro = Color(0xFF546E7A);
  static const Color _laranja = Color(0xFFEF6C00);
  static const Color _marromComida = Color(0xFF8D6E63);

  static (IconData, Color)? _resolver(String emoji) => switch (emoji.trim()) {
        '⚠️' => (Icons.warning_amber_rounded, _ambar),
        '❌' => (Icons.cancel_outlined, Color(0xFFD32F2F)),
        'ℹ️' => (Icons.info_outline_rounded, Color(0xFF1976D2)),
        '🔎' => (Icons.search_rounded, _cinzaNeutro),
        '🔁' => (Icons.autorenew_rounded, _cinzaNeutro),
        '💳' => (Icons.credit_card_outlined, corCartao),
        '📲' => (Icons.qr_code_2_rounded, corPix),
        '🧾' => (Icons.receipt_long_outlined, _cinzaNeutro),
        '🥳' => (Icons.celebration_outlined, _laranja),
        '🙏' => (Icons.volunteer_activism_outlined, Color(0xFFD81B60)),
        '🍽️' => (Icons.restaurant_rounded, _marromComida),
        '🍲' => (Icons.ramen_dining_outlined, _marromComida),
        '🥩' => (Icons.kebab_dining_outlined, _marromComida),
        '🦐' => (Icons.set_meal_outlined, _laranja),
        '🍚' => (Icons.rice_bowl_outlined, _marromComida),
        '🍮' => (Icons.cake_outlined, _marromComida),
        '🥤' => (Icons.local_drink_outlined, Color(0xFFC62828)),
        '🍊' => (Icons.local_drink_outlined, _laranja),
        '🍹' => (Icons.local_bar_outlined, Color(0xFFD81B60)),
        '💧' => (Icons.water_drop_outlined, Color(0xFF0277BD)),
        '🍺' => (Icons.sports_bar_outlined, _ambar),
        '🔒' => (Icons.lock_outline_rounded, _cinzaNeutro),
        '🖼️' => (Icons.image_outlined, _cinzaNeutro),
        '🎬' => (Icons.movie_outlined, _cinzaNeutro),
        '📢' => (Icons.campaign_outlined, _laranja),
        '🎯' => (Icons.track_changes_rounded, _cinzaNeutro),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final resolvido = _resolver(emoji);
    if (resolvido == null) {
      return Text(emoji, style: TextStyle(fontSize: tamanho * .9));
    }
    return Icon(resolvido.$1, size: tamanho, color: cor ?? resolvido.$2);
  }
}
