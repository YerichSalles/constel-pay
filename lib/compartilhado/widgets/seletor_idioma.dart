import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../aplicativo/injecao.dart';
import '../../aplicativo/tema/cores_app.dart';
import '../../l10n/app_localizations.dart';

/// Um idioma suportado pelo seletor: locale usado pelo `provedorIdioma` e
/// bandeira exibida como apoio visual (o nome do idioma vem sempre traduzido
/// no próprio idioma, via ARB — nunca hardcoded aqui). A bandeira é um SVG
/// próprio (não emoji): Windows não tem fonte de emoji de bandeira e
/// renderiza como sigla de duas letras.
class _Idioma {
  const _Idioma(this.locale, this.bandeira);

  final Locale locale;
  final String bandeira;
}

const List<_Idioma> _idiomasSuportados = [
  _Idioma(Locale('pt', 'BR'), 'assets/bandeiras/br.svg'),
  _Idioma(Locale('en'), 'assets/bandeiras/us.svg'),
  _Idioma(Locale('es'), 'assets/bandeiras/es.svg'),
];

/// Pill de troca de idioma do atendimento, exibido ao lado da engrenagem de
/// configurações na tela inicial. Trocar o idioma aqui só atualiza
/// `provedorIdioma` (o MaterialApp reage sozinho) — não navega, não reinicia
/// o atendimento e não mexe na engrenagem.
class SeletorIdioma extends ConsumerWidget {
  const SeletorIdioma({super.key});

  static String _sigla(String languageCode) => switch (languageCode) {
        'en' => 'EN',
        'es' => 'ES',
        _ => 'PT',
      };

  static String _nome(AppLocalizations textos, String languageCode) =>
      switch (languageCode) {
        'en' => textos.languageEnglish,
        'es' => textos.languageSpanish,
        _ => textos.languagePortuguese,
      };

  Future<void> _abrirSeletor(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations textos,
  ) async {
    final atual = ref.read(provedorIdioma).languageCode;
    await showDialog<void>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          textos.chooseLanguageTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final idioma in _idiomasSuportados)
              _OpcaoIdioma(
                bandeira: idioma.bandeira,
                nome: _nome(textos, idioma.locale.languageCode),
                selecionado: idioma.locale.languageCode == atual,
                onTap: () {
                  ref.read(provedorIdioma.notifier).selecionar(idioma.locale);
                  Navigator.of(contextoDialogo).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(provedorIdioma).languageCode;
    final textos = AppLocalizations.of(context);
    final mensagem =
        textos.changeLanguageSemantics(_nome(textos, languageCode));

    return Tooltip(
      message: mensagem,
      child: Material(
        color: Colors.black.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _abrirSeletor(context, ref, textos),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  _sigla(languageCode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const Icon(Icons.arrow_drop_down,
                    color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Uma opção de idioma dentro do diálogo do [SeletorIdioma]: bandeira como
/// apoio visual + nome do idioma no próprio idioma + indicador do idioma
/// atual (ícone de check, nunca só cor, para não depender de percepção de
/// cor). A bandeira é sempre acompanhada do nome — nunca é o único
/// identificador do idioma.
class _OpcaoIdioma extends StatelessWidget {
  const _OpcaoIdioma({
    required this.bandeira,
    required this.nome,
    required this.selecionado,
    required this.onTap,
  });

  final String bandeira;
  final String nome;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x22000000)),
                ),
                child: SvgPicture.asset(
                  bandeira,
                  width: 28,
                  height: 19,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                nome,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selecionado ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
            if (selecionado)
              const Icon(Icons.check, color: CoresApp.sucesso, size: 22),
          ],
        ),
      ),
    );
  }
}
