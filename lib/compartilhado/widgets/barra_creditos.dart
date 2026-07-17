import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Rodapé de créditos presente em todas as telas. Segue a cor primária
/// configurada no tema, salvo cor própria em [corFundo]. Mostra "Constel Pay"
/// + versão à esquerda e o site da Constel à direita, com contraste de texto
/// automático conforme a cor de fundo.
class BarraCreditos extends StatelessWidget {
  const BarraCreditos({super.key, this.sobreCor, this.corFundo})
      : assert(sobreCor == null || corFundo == null,
            'Sobreposta a barra não pinta fundo: use um ou outro.');

  /// Cor da superfície sobre a qual a barra está sobreposta (ex.: a faixa de
  /// pagamento). Quando informada, a barra não pinta fundo próprio — deixa a
  /// superfície aparecer, sem cobrir o que estiver desenhado nela — e calcula
  /// o contraste do texto a partir dessa cor.
  final Color? sobreCor;

  /// Fundo próprio da barra. Sem ela, a barra usa a cor primária do tema.
  final Color? corFundo;

  static const String _nomeApp = 'Constel Pay';
  static const String _site = 'www.constel.cloud';

  // Versão carregada uma única vez e reaproveitada por todas as telas.
  static Future<String>? _versaoCache;
  static Future<String> _versao() =>
      _versaoCache ??= PackageInfo.fromPlatform().then((info) => info.version);

  @override
  Widget build(BuildContext context) {
    final base = sobreCor ?? corFundo ?? Theme.of(context).colorScheme.primary;
    final fundoEscuro = base.computeLuminance() < .5;
    final corForte = fundoEscuro ? Colors.white : const Color(0xFF1E1E1E);
    final corSuave = corForte.withValues(alpha: fundoEscuro ? .82 : .68);

    return Material(
      color: sobreCor != null ? Colors.transparent : base,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: Row(
            children: [
              Text(
                _nomeApp,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .2,
                  color: corForte,
                ),
              ),
              const SizedBox(width: 6),
              FutureBuilder<String>(
                future: _versao(),
                builder: (contexto, snap) {
                  final versao = snap.data;
                  if (versao == null) return const SizedBox.shrink();
                  return Text(
                    'v$versao',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: corSuave,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _site,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .5,
                    color: corSuave,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
