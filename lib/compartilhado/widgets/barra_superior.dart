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

  /// Slot opcional de publicidade, exibido à direita do título com o
  /// espaço que sobrar depois de voltar/logo/nome. Sem publicidade, o
  /// layout permanece exatamente igual ao de hoje.
  final Widget? publicidade;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  Color _ajustarLuminosidade(Color cor, double delta) {
    final hsl = HSLColor.fromColor(cor);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }

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
      title: Row(
        children: [
          if (avatar != null) ...[avatar!, const SizedBox(width: 16)],
          Flexible(
            fit: publicidade != null ? FlexFit.loose : FlexFit.tight,
            child: Column(
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
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: .92)),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (publicidade != null) ...[
            const SizedBox(width: 12),
            Expanded(child: publicidade!),
          ],
        ],
      ),
      actions: acoes,
    );
  }
}
