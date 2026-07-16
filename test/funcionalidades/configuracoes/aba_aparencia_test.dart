import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/aba_aparencia.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/campo_cor.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_tema_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:constel_pay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _montarAba(WidgetTester tester,
    {TemaPersonalizado? temaSalvo}) async {
  SharedPreferences.setMockInitialValues({});
  final preferencias = await SharedPreferences.getInstance();
  if (temaSalvo != null) {
    await RepositorioTemaImpl(preferencias).salvar(temaSalvo);
  }
  final container = ProviderContainer(
    overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
  );
  addTearDown(container.dispose);
  await container.read(provedorTema.notifier).carregar();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: AbaAparencia()),
      ),
    ),
  );
  await tester.pump();
  return container;
}

Finder _campoHex(Key chave) => find.descendant(
    of: find.byKey(chave), matching: find.byType(TextFormField));

ElevatedButton _botaoAplicar(WidgetTester tester) =>
    tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Aplicar alterações'));

Future<void> _rolarAte(WidgetTester tester, Finder alvo) async {
  await tester.dragUntilVisible(
      alvo, find.byType(ListView), const Offset(0, -300));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('CampoCor propaga hex válido normalizado (sem # e minúsculo)',
      (tester) async {
    var recebido = '';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CampoCor(
            rotulo: 'Cor principal',
            valorHex: '#5E52D6',
            aoMudar: (hex) => recebido = hex),
      ),
    ));
    await tester.enterText(find.byType(TextFormField), 'a1b2c3');
    expect(recebido, '#A1B2C3');
  });

  testWidgets('CampoCor não propaga valor inválido e mostra erro discreto',
      (tester) async {
    var recebido = '';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CampoCor(
            rotulo: 'Cor principal',
            valorHex: '#5E52D6',
            aoMudar: (hex) => recebido = hex),
      ),
    ));
    await tester.enterText(find.byType(TextFormField), '#12XZ99');
    await tester.pump();
    expect(recebido, '');
    expect(find.text('Informe uma cor hexadecimal válida.'), findsOneWidget);
  });

  testWidgets('CampoCor acompanha o valorHex quando ele muda de fora',
      (tester) async {
    Widget montar(String hex) => MaterialApp(
          home: Scaffold(
            body: CampoCor(
                rotulo: 'Cor da faixa', valorHex: hex, aoMudar: (_) {}),
          ),
        );
    await tester.pumpWidget(montar('#5E52D6'));
    expect(find.text('#5E52D6'), findsOneWidget);

    await tester.pumpWidget(montar('#112233'));
    await tester.pump();
    expect(find.text('#112233'), findsOneWidget);
  });

  testWidgets(
      'Aplicar alterações começa desabilitado, habilita ao editar e '
      'persiste no provedorTema', (tester) async {
    final container = await _montarAba(tester);

    expect(_botaoAplicar(tester).onPressed, isNull);

    await tester.enterText(_campoHex(const Key('cor_principal')), '#112233');
    await tester.pumpAndSettle();

    expect(_botaoAplicar(tester).onPressed, isNotNull);
    expect(find.text('Alterações não salvas'), findsOneWidget);
    // Nada persiste antes de aplicar.
    expect(container.read(provedorTema).corPrimaria, '#5E52D6');

    await tester.tap(find.text('Aplicar alterações'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(container.read(provedorTema).corPrimaria, '#112233');
    expect(_botaoAplicar(tester).onPressed, isNull);
    expect(find.text('Alterações não salvas'), findsNothing);
  });

  testWidgets('indicador de contraste muda de estado com as cores da faixa',
      (tester) async {
    await _montarAba(tester);

    // Padrão: texto branco sobre a primária roxa — contraste adequado.
    await _rolarAte(tester, find.byKey(const Key('indicador_contraste')));
    expect(find.text('Boa legibilidade'), findsOneWidget);
    expect(find.textContaining('Contraste:'), findsOneWidget);

    // Faixa branca com texto branco: insuficiente.
    await tester.enterText(_campoHex(const Key('cor_faixa')), '#FFFFFF');
    await tester.pumpAndSettle();
    expect(find.text('Contraste baixo'), findsOneWidget);
  });

  testWidgets(
      'o indicador avisa mesmo quando a faixa herdada veio de um corFaixa '
      'em branco (string vazia, nao null)', (tester) async {
    // Loja com primaria amarela e corFaixa gravado como string vazia: com o
    // texto padrao branco, a faixa fica quase ilegivel (~1,7:1).
    await _montarAba(tester,
        temaSalvo:
            const TemaPersonalizado(corPrimaria: '#FFD166', corFaixa: ''));

    await _rolarAte(tester, find.byKey(const Key('indicador_contraste')));
    expect(find.text('Contraste baixo'), findsOneWidget,
        reason: 'faixa amarela com texto branco e ilegivel e devia disparar '
            'o aviso de contraste, mesmo com corFaixa em string vazia');
  });

  testWidgets(
      'a cor da faixa acompanha a cor principal quando ela e a cor herdada',
      (tester) async {
    await _montarAba(tester);

    await tester.enterText(_campoHex(const Key('cor_principal')), '#112233');
    await tester.pumpAndSettle();

    await _rolarAte(tester, find.byKey(const Key('cor_faixa')));
    final campoFaixa =
        tester.widget<TextFormField>(_campoHex(const Key('cor_faixa')));
    expect(campoFaixa.controller!.text, '#112233');
  });

  testWidgets(
      'Restaurar padrão pede confirmação, volta os valores no rascunho e só '
      'persiste ao aplicar', (tester) async {
    final container = await _montarAba(tester,
        temaSalvo: const TemaPersonalizado(corPrimaria: '#112233'));

    await tester.tap(find.text('Restaurar padrão'));
    await tester.pumpAndSettle();
    expect(find.text('Restaurar aparência padrão?'), findsOneWidget);

    // Cancelar não muda nada.
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(container.read(provedorTema).corPrimaria, '#112233');
    expect(_botaoAplicar(tester).onPressed, isNull);

    // Confirmar carrega os padrões só no rascunho.
    await tester.tap(find.text('Restaurar padrão'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restaurar'));
    await tester.pumpAndSettle();

    final campoPrincipal =
        tester.widget<TextFormField>(_campoHex(const Key('cor_principal')));
    expect(campoPrincipal.controller!.text, '#5E52D6');
    expect(container.read(provedorTema).corPrimaria, '#112233');
    expect(find.text('Alterações não salvas'), findsOneWidget);

    await tester.tap(find.text('Aplicar alterações'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(container.read(provedorTema).corPrimaria, '#5E52D6');
  });

  testWidgets(
      'seletor de cores abre pela amostra, aplica cor rápida ao confirmar',
      (tester) async {
    await _montarAba(tester);

    final amostra = find.descendant(
        of: find.byKey(const Key('cor_principal')),
        matching: find.byTooltip('Abrir seletor de cores'));
    await tester.tap(amostra);
    await tester.pumpAndSettle();
    expect(find.text('Escolher cor'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cor_rapida_#FFD166')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    final campoPrincipal =
        tester.widget<TextFormField>(_campoHex(const Key('cor_principal')));
    expect(campoPrincipal.controller!.text, '#FFD166');
    expect(find.text('Alterações não salvas'), findsOneWidget);
  });

  testWidgets('cor secundária reflete na prévia em tempo real', (tester) async {
    // Tela larga: a prévia fica na coluna direita, já construída.
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _montarAba(tester);

    await tester.enterText(_campoHex(const Key('cor_secundaria')), '#123456');
    await tester.pumpAndSettle();

    final detalhe = tester
        .widget<Container>(find.byKey(const Key('previa_detalhe_secundaria')));
    expect(detalhe.color, const Color(0xFF123456));
    final avatar = tester
        .widget<Container>(find.byKey(const Key('previa_avatar_secundaria')));
    expect((avatar.decoration as BoxDecoration).color, const Color(0xFF123456));
  });

  testWidgets('ícone de paleta abre o seletor de cores', (tester) async {
    await _montarAba(tester);

    await tester.tap(find.descendant(
        of: find.byKey(const Key('cor_principal')),
        matching: find.byIcon(Icons.palette_outlined)));
    await tester.pumpAndSettle();

    expect(find.text('Escolher cor'), findsOneWidget);
  });

  testWidgets('editar o hexadecimal não abre o seletor', (tester) async {
    await _montarAba(tester);

    await tester.enterText(_campoHex(const Key('cor_principal')), '#112233');
    await tester.pumpAndSettle();

    expect(find.text('Escolher cor'), findsNothing);
  });

  testWidgets('em telas largas usa duas colunas com a prévia visível',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _montarAba(tester);

    // A prévia fica no painel próprio à direita, visível sem rolar.
    expect(find.text('Pré-visualização'), findsOneWidget);
    expect(find.text('Identidade visual'), findsOneWidget);
  });

  testWidgets('em tela estreita não estoura layout', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _montarAba(tester);

    await tester.enterText(_campoHex(const Key('cor_principal')), '#112233');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Alterações não salvas'), findsOneWidget);
  });

  testWidgets('cancelar o seletor de cores restaura o valor anterior',
      (tester) async {
    await _montarAba(tester);

    final amostra = find.descendant(
        of: find.byKey(const Key('cor_principal')),
        matching: find.byTooltip('Abrir seletor de cores'));
    await tester.tap(amostra);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cor_rapida_#FFD166')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    final campoPrincipal =
        tester.widget<TextFormField>(_campoHex(const Key('cor_principal')));
    expect(campoPrincipal.controller!.text, '#5E52D6');
    expect(_botaoAplicar(tester).onPressed, isNull);
  });
}
