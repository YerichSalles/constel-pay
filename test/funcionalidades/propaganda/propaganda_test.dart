import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/aplicativo/tema/tema_constel.dart';
import 'package:constel_pay/compartilhado/widgets/faixa_pagamento.dart';
import 'package:constel_pay/compartilhado/widgets/seletor_idioma.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/trocador_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/controladores/controlador_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dados/repositorios/repositorio_propaganda_impl.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:constel_pay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // O locale do MaterialApp acompanha o provedorIdioma, exatamente como no
  // ConstelPayApp real — sem isso, o AppLocalizations.of(context) usado pela
  // pagina resolveria pelo locale do ambiente de teste, ignorando o provider.
  Widget appPropaganda(GoRouter roteador) => Consumer(
        builder: (context, ref, _) => MaterialApp.router(
          routerConfig: roteador,
          locale: ref.watch(provedorIdioma),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );

  GoRouter roteadorPropagandaEChat() => GoRouter(
        initialLocation: '/propaganda',
        routes: [
          GoRoute(
              path: '/propaganda',
              builder: (_, __) => const PaginaPropaganda()),
          GoRoute(
              path: '/chat',
              builder: (_, __) => const Scaffold(body: Text('CHAT'))),
        ],
      );

  test('midiaSeguinte aponta a proxima exibicao, circular', () {
    const a = MidiaPropaganda(
        id: 'a', tipo: TipoMidia.imagem, caminho: '/m/a.png', ordem: 1);
    const b = MidiaPropaganda(
        id: 'b', tipo: TipoMidia.imagem, caminho: '/m/b.png', ordem: 2);
    expect(const EstadoPropaganda().midiaSeguinte, isNull);
    expect(const EstadoPropaganda(midias: [a]).midiaSeguinte, a,
        reason: 'midia unica: a proxima exibicao e ela mesma');
    expect(const EstadoPropaganda(midias: [a, b], indice: 0).midiaSeguinte, b);
    expect(const EstadoPropaganda(midias: [a, b], indice: 1).midiaSeguinte, a);
  });

  test('controlador carrega midias ativas e avanca circularmente', () async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioPropagandaImpl(preferencias);
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a', tipo: TipoMidia.imagem, caminho: '/x/a.png', ordem: 1),
      MidiaPropaganda(
          id: 'b', tipo: TipoMidia.imagem, caminho: '/x/b.png', ordem: 2),
    ]);
    final controlador = ControladorPropaganda(repositorio);
    await controlador.carregar();
    expect(controlador.state.midias, hasLength(2));
    expect(controlador.state.midiaAtual?.id, 'a');
    controlador.avancar();
    expect(controlador.state.midiaAtual?.id, 'b');
    controlador.avancar();
    expect(controlador.state.midiaAtual?.id, 'a');
  });

  testWidgets('sem midias mostra CTA e navega para o chat ao tocar',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final roteador = GoRouter(
      initialLocation: '/propaganda',
      routes: [
        GoRoute(
            path: '/propaganda', builder: (_, __) => const PaginaPropaganda()),
        GoRoute(
            path: '/chat',
            builder: (_, __) => const Scaffold(body: Text('CHAT'))),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: appPropaganda(roteador),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(FaixaPagamento), findsOneWidget);
    expect(find.text('Toque para pagar'), findsOneWidget);
    // O card branco e os tres passos sairam da tela junto com o botao fixo.
    expect(find.text('Escaneie'), findsNothing);
    await tester.tap(find.text('Toque para pagar'));
    await tester.pump();
    await tester.pump();
    expect(find.text('CHAT'), findsOneWidget);
  });

  testWidgets(
      'com midia, o player e a faixa coexistem, o player recebe a cor '
      'primaria do tema e o toque ainda navega para o chat', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioPropagandaImpl(preferencias);
    // Imagem apontando para um arquivo inexistente: o player pinta so a cor
    // de fundo e agenda o temporizador de 1s da midia sem arquivo, sem
    // depender do video_player.
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: '/midias/inexistente.png',
          ordem: 1),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: appPropaganda(roteadorPropagandaEChat()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(TrocadorPropaganda), findsOneWidget);
    expect(find.byType(PlayerPropaganda, skipOffstage: false), findsNWidgets(2),
        reason: 'atual tocando + seguinte preparando');
    expect(find.byType(FaixaPagamento), findsOneWidget);

    final player = tester
        .widgetList<PlayerPropaganda>(
            find.byType(PlayerPropaganda, skipOffstage: false))
        .singleWhere((p) => p.ativo);
    expect(player.corFundo, TemaConstel.corDeHex('#5E52D6', Colors.black),
        reason: 'o player precisa herdar a cor primaria do tema da loja');

    // Drena o temporizador de 1s da midia sem arquivo antes de seguir, para
    // nao deixar timer pendente no fim do teste.
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byType(FaixaPagamento));
    await tester.pump();
    await tester.pump();
    // O trocador saiu de cena na navegacao; nada mais pendente.
    expect(find.text('CHAT'), findsOneWidget);
  });

  testWidgets(
      'enquanto carrega, a faixa nao aparece (evita piscar a chamada antes '
      'da tela existir)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: appPropaganda(roteadorPropagandaEChat()),
      ),
    );

    // Logo apos o primeiro frame, antes do postFrameCallback terminar de
    // carregar as midias: estado.carregando ainda e true.
    expect(find.byType(FaixaPagamento), findsNothing);

    // Deixa o carregamento terminar para nao vazar estado pendente no teste.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('o seletor de idioma aparece a esquerda da engrenagem',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: appPropaganda(roteadorPropagandaEChat()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SeletorIdioma), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);

    final xSeletor = tester.getCenter(find.byType(SeletorIdioma)).dx;
    final xEngrenagem = tester.getCenter(find.byIcon(Icons.settings)).dx;
    expect(xSeletor, lessThan(xEngrenagem));
  });

  testWidgets('no preview, o seletor de idioma e a engrenagem nao aparecem',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(provedorIdioma),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PaginaPropaganda(preview: true),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SeletorIdioma), findsNothing);
    expect(find.byIcon(Icons.settings), findsNothing);
  });

  testWidgets('com o idioma em ingles, a faixa padrao mostra "Tap to pay"',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
    );
    addTearDown(container.dispose);
    container.read(provedorIdioma.notifier).selecionar(const Locale('en'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: appPropaganda(roteadorPropagandaEChat()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Tap to pay'), findsOneWidget);
    expect(find.text('Toque para pagar'), findsNothing);
  });

  testWidgets(
      'faixa personalizada pelo operador aparece mesmo com o idioma em ingles',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
    );
    addTearDown(container.dispose);
    await container
        .read(provedorTema.notifier)
        .atualizar(const TemaPersonalizado(textoFaixa: 'Peça já pelo totem'));
    container.read(provedorIdioma.notifier).selecionar(const Locale('en'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: appPropaganda(roteadorPropagandaEChat()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Peça já pelo totem'), findsOneWidget);
    expect(find.text('Tap to pay'), findsNothing);
  });
}
