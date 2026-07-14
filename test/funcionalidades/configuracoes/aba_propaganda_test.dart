import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/secao_barra_superior.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/secao_conteudo_tela.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/seletor_ajuste_midia.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_tema_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:constel_pay/funcionalidades/propaganda/dados/repositorios/repositorio_propaganda_impl.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('seletor mostra o modo atual e devolve o modo escolhido',
      (tester) async {
    AjusteMidia? escolhido;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SeletorAjusteMidia(
          valor: AjusteMidia.automatico,
          aoMudar: (ajuste) => escolhido = ajuste,
        ),
      ),
    ));
    expect(find.text('Automático'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<AjusteMidia>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Encaixar (mostra tudo)').last);
    await tester.pumpAndSettle();

    expect(escolhido, AjusteMidia.encaixar);
  });

  test('todo modo de ajuste tem rotulo em pt-BR', () {
    for (final ajuste in AjusteMidia.values) {
      expect(SeletorAjusteMidia.rotulos[ajuste], isNotNull,
          reason: 'sem rotulo para $ajuste');
    }
  });

  testWidgets(
      'card de midia com Duracao e Ajuste nao estoura em janela estreita',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioPropagandaImpl(preferencias);
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
        id: 'a',
        tipo: TipoMidia.imagem,
        caminho: '/midias/oferta-do-dia.png',
        ordem: 1,
      ),
    ]);

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.devicePixelRatio = 1.0;
    // 480px de janela ja aperta a regiao Expanded do card (espremida pelo
    // avatar, pelas setas de reordenar, pelo Switch e pelo botao de excluir)
    // abaixo da largura que o Row do SeletorAjusteMidia precisa para caber
    // sem encolher: reproduz o estouro descrito no finding sem depender do
    // caso, ja coberto, de duas mídias nao caberem lado a lado no Wrap.
    tester.view.physicalSize = const Size(480, 800);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: AbaPropaganda())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Ajustar…'), findsOneWidget,
        reason: 'o card precisa renderizar de fato para o teste provar algo '
            'sobre overflow');
    expect(tester.takeException(), isNull,
        reason: 'o card de midia estourou (RenderFlex overflowed) em '
            'janela estreita: o Row de Duracao/Ajuste dentro do Wrap '
            'precisa encolher em vez de forcar a largura intrinseca.');
  });

  testWidgets('card mostra o resumo do enquadramento e abre o dialogo',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioPropagandaImpl(preferencias);
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
        id: 'a',
        tipo: TipoMidia.imagem,
        caminho: '/midias/oferta.png',
        ordem: 1,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: AbaPropaganda())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Nome amigável (posição 1-based) e nome do arquivo como linha
    // secundária, no lugar do nome do arquivo isolado.
    expect(find.text('Imagem 1'), findsOneWidget);
    expect(find.text('oferta.png'), findsOneWidget);

    expect(find.text('Automático · fundo borrado'), findsOneWidget);
    expect(find.byType(DropdownButton<AjusteMidia>), findsNothing,
        reason: 'o dropdown saiu do card e mora no dialogo');

    await tester.tap(find.text('Ajustar…'));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoAjusteMidia), findsOneWidget);

    // Fecha e drena o temporizador de 1s do preview (midia inexistente).
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('seletor de orientacao persiste no tema e muda a ajuda',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: AbaPropaganda())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
        find.text('Formato indicado para terminais verticais.'), findsOneWidget,
        reason: 'em pe por padrao');
    expect(find.textContaining('1080 x 1920'), findsOneWidget,
        reason: 'em pe por padrao');

    await tester.tap(find.text('Deitada'));
    await tester.pump();

    expect(find.text('Formato indicado para terminais horizontais.'),
        findsOneWidget,
        reason: 'a descricao dinamica acompanha a orientacao');
    expect(
        find.text('Formato indicado para terminais verticais.'), findsNothing);
    expect(find.textContaining('1920 x 1080'), findsOneWidget,
        reason: 'a ajuda acompanha a orientacao');
    final salvo = await RepositorioTemaImpl(preferencias).obter();
    expect(salvo.orientacaoTela, OrientacaoTela.horizontal,
        reason: 'a escolha persiste no tema');
  });

  testWidgets('botoes de acao usam os rotulos novos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: SecaoConteudoTela())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('+ Adicionar mídia'), findsOneWidget);
    expect(find.text('Visualizar sequência'), findsOneWidget);
  });

  testWidgets('nomes amigaveis dos cards seguem o tipo e a posicao na lista',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioPropagandaImpl(preferencias);
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: '/midias/oferta.png',
          ordem: 1),
      MidiaPropaganda(
          id: 'b',
          tipo: TipoMidia.video,
          caminho: '/midias/promocao.mp4',
          ordem: 2),
      MidiaPropaganda(
          id: 'c',
          tipo: TipoMidia.imagem,
          caminho: '/midias/banner-animado.gif',
          ordem: 3),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: SecaoConteudoTela())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Imagem 1'), findsOneWidget);
    expect(find.text('oferta.png'), findsOneWidget);
    expect(find.text('Vídeo 2'), findsOneWidget);
    expect(find.text('promocao.mp4'), findsOneWidget);
    expect(find.text('GIF 3'), findsOneWidget,
        reason: 'gif e detectado pela extensao do arquivo, nao pelo tipo');
    expect(find.text('banner-animado.gif'), findsOneWidget);
  });

  testWidgets('acoes do card tem tooltip', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioPropagandaImpl(preferencias);
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: '/midias/oferta.png',
          ordem: 1),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: SecaoConteudoTela())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byTooltip('Mover para cima'), findsOneWidget);
    expect(find.byTooltip('Mover para baixo'), findsOneWidget);
    expect(find.byTooltip('Ativar ou desativar'), findsOneWidget);
    expect(find.byTooltip('Remover'), findsOneWidget);
  });

  testWidgets('confirmacao de remocao usa os textos definidos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioPropagandaImpl(preferencias);
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: '/midias/oferta.png',
          ordem: 1),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: SecaoConteudoTela())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byTooltip('Remover'));
    await tester.pumpAndSettle();

    expect(find.text('Remover mídia?'), findsOneWidget);
    expect(find.text('Esta mídia deixará de ser exibida no terminal.'),
        findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
  });

  testWidgets(
      'navegacao interna mostra os 2 segmentos e inicia em Conteudo da tela',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: AbaPropaganda())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // "Conteúdo da tela" aparece duas vezes: no rótulo da navegação interna
    // e no título do cabeçalho (SecaoConfiguracoes) da seção ativa.
    expect(find.text('Conteúdo da tela'), findsNWidgets(2));
    expect(find.text('Barra superior'), findsOneWidget);
    expect(find.byType(SecaoConteudoTela), findsOneWidget);
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0,
        reason: 'Conteudo da tela e a secao inicial');
  });

  testWidgets(
      'alternar para Barra superior e voltar preserva o estado da secao '
      '(IndexedStack)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final repositorio = RepositorioPropagandaImpl(preferencias);
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: '/midias/oferta.png',
          ordem: 1),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
        child: const MaterialApp(home: Scaffold(body: AbaPropaganda())),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Edita o campo de duracao sem confirmar: o valor so muda de fato no
    // estado local do TextFormField (a persistencia so ocorre em
    // onFieldSubmitted). Se a navegacao interna desmontar a secao ao
    // trocar de segmento, esse valor nao confirmado se perde.
    await tester.enterText(find.byType(TextFormField), '15');
    await tester.pump();

    await tester.tap(find.text('Barra superior'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);
    expect(find.byType(SecaoBarraSuperior), findsOneWidget);

    await tester.tap(find.text('Conteúdo da tela'));
    await tester.pump();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0);

    expect(find.text('15'), findsOneWidget,
        reason: 'o IndexedStack mantem a secao montada; o campo nao pode '
            'voltar ao valor persistido ao trocar de secao interna');
  });
}
