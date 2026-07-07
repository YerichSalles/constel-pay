import 'package:flutter/material.dart';

class BarraSuperior extends StatelessWidget implements PreferredSizeWidget {
  const BarraSuperior({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.avatar,
    this.aoVoltar,
    this.acoes,
  });

  final String titulo;
  final String? subtitulo;
  final Widget? avatar;
  final VoidCallback? aoVoltar;
  final List<Widget>? acoes;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: kToolbarHeight + 8,
      leading: aoVoltar != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new), onPressed: aoVoltar)
          : null,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (avatar != null) ...[avatar!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
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
        ],
      ),
      actions: acoes,
    );
  }
}
