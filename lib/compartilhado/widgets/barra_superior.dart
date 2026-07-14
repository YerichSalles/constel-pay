import 'package:flutter/material.dart';

class BarraSuperior extends StatelessWidget implements PreferredSizeWidget {
  const BarraSuperior({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.avatar,
    this.aoVoltar,
    this.acoes,
    this.publicidade,
  });

  final String titulo;
  final String? subtitulo;
  final Widget? avatar;
  final VoidCallback? aoVoltar;
  final List<Widget>? acoes;

  /// Slot opcional de publicidade, exibido à direita do título ocupando
  /// TODO o espaço restante depois de voltar/logo/nome. Sem publicidade, o
  /// layout permanece exatamente igual ao de hoje.
  final Widget? publicidade;

  /// Fração da largura do título reservada como teto para a área do nome
  /// quando há publicidade — apenas um limite máximo (nome curto não
  /// empurra o letreiro; o espaço real do nome é o do seu conteúdo).
  static const double _fracaoMaximaNome = 0.45;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  Color _ajustarLuminosidade(Color cor, double delta) {
    final hsl = HSLColor.fromColor(cor);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }

  Widget _colunaNome() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: .2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitulo != null)
            Text(
              subtitulo!,
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: .92)),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      );

  Widget _divisor() => Container(
        width: 1,
        height: 22,
        color: Colors.white.withValues(alpha: .25),
      );

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;
    return AppBar(
      toolbarHeight: kToolbarHeight + 8,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: .25),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _ajustarLuminosidade(primaria, .05),
              _ajustarLuminosidade(primaria, -.04),
            ],
          ),
          border: Border(
            bottom: BorderSide(color: Colors.black.withValues(alpha: .12)),
          ),
        ),
      ),
      leading: aoVoltar != null
          ? Center(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: aoVoltar,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: .15),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                ),
              ),
            )
          : null,
      automaticallyImplyLeading: false,
      title: publicidade == null
          ? Row(
              children: [
                if (avatar != null) ...[avatar!, const SizedBox(width: 16)],
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: _colunaNome(),
                ),
              ],
            )
          : LayoutBuilder(
              builder: (context, restricoes) {
                final tetoNome = restricoes.maxWidth * _fracaoMaximaNome;
                return Row(
                  children: [
                    if (avatar != null) ...[
                      avatar!,
                      const SizedBox(width: 16),
                    ],
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: tetoNome),
                      child: _colunaNome(),
                    ),
                    const SizedBox(width: 12),
                    _divisor(),
                    const SizedBox(width: 12),
                    Expanded(child: publicidade!),
                    const SizedBox(width: 14),
                  ],
                );
              },
            ),
      actions: acoes,
    );
  }
}
