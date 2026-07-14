import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/compartilhado/widgets/seletor_idioma.dart';
import 'package:constel_pay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  // O locale do MaterialApp acompanha o provedorIdioma, exatamente como no
  // ConstelPayApp real — sem isso, o AppLocalizations.of(context) resolveria
  // pelo locale do dispositivo/ambiente de teste, ignorando o provider.
  Future<void> montar(WidgetTester tester) => tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) => MaterialApp(
              locale: ref.watch(provedorIdioma),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(body: Center(child: SeletorIdioma())),
            ),
          ),
        ),
      );

  testWidgets('mostra a sigla do idioma atual (PT por padrao)', (tester) async {
    await montar(tester);
    expect(find.text('PT'), findsOneWidget);
  });

  testWidgets('pill mostra a bandeira do idioma atual (br.svg por padrao)',
      (tester) async {
    await montar(tester);

    // O pill mostra a bandeira do idioma selecionado (br.svg por padrao),
    // nao mais o emoji de globo — mas a sigla continua junto, nunca so a
    // bandeira como identificador.
    final bandeira = tester.widget<SvgPicture>(find.byType(SvgPicture));
    final bytesLoader = bandeira.bytesLoader;
    expect(bytesLoader, isA<SvgAssetLoader>());
    expect(
        (bytesLoader as SvgAssetLoader).assetName, 'assets/bandeiras/br.svg');
    expect(find.text('🌐'), findsNothing);
    expect(find.text('PT'), findsOneWidget);
  });

  testWidgets('tem semantics/tooltip com a frase traduzida do idioma atual',
      (tester) async {
    await montar(tester);
    expect(
      find.byTooltip('Alterar idioma. Idioma atual: Português.'),
      findsOneWidget,
    );
  });

  testWidgets('toque abre o dialogo com titulo e as tres opcoes de idioma',
      (tester) async {
    await montar(tester);

    await tester.tap(find.byType(SeletorIdioma));
    await tester.pumpAndSettle();

    expect(find.text('Escolha o idioma'), findsOneWidget);
    expect(find.text('Português'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    // Bandeira é SVG (assets/bandeiras/*.svg), não emoji: Windows não tem
    // fonte de emoji de bandeira e renderizava como sigla de duas letras.
    // Escopo em AlertDialog: o pill (atrás do diálogo) também tem sua
    // própria bandeira, então find.byType(SvgPicture) sem escopo pegaria 4.
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(SvgPicture),
      ),
      findsNWidgets(3),
    );
  });

  testWidgets(
      'selecionar English muda o provider para Locale(en) e fecha o dialogo',
      (tester) async {
    await montar(tester);

    await tester.tap(find.byType(SeletorIdioma));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(container.read(provedorIdioma), const Locale('en'));
    expect(find.text('Escolha o idioma'), findsNothing);

    // Pill volta a mostrar 1 SvgPicture (o dialogo fechou) e a bandeira
    // agora é a dos EUA, acompanhando a sigla EN.
    expect(find.byType(SvgPicture), findsOneWidget);
    final bandeira = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect((bandeira.bytesLoader as SvgAssetLoader).assetName,
        'assets/bandeiras/us.svg');
    expect(find.text('EN'), findsOneWidget);
  });

  testWidgets('apos selecionar espanhol, a sigla do botao vira ES',
      (tester) async {
    await montar(tester);

    await tester.tap(find.byType(SeletorIdioma));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('ES'), findsOneWidget);
    expect(container.read(provedorIdioma), const Locale('es'));
  });
}
