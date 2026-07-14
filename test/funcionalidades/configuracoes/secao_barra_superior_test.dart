import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/editor_carrossel.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_publicidade.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/editor_letreiro.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/editor_parceiro.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/secao_barra_superior.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/letreiro_publicidade.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A seção usa `ListView`s (padrão AbaAparencia): diferente de uma Column
// dentro de SingleChildScrollView, o sliver só monta os filhos dentro do
// viewport. Uma superfície bem alta evita ter que rolar até cada seção só
// para localizá-la nos testes. `tester.view.physicalSize` (não
// `tester.binding.setSurfaceSize`) é usado porque este último ignora a
// altura pedida nesta versão do Flutter.
Future<ProviderContainer> _montarSecao(WidgetTester tester,
    {Size tamanho = const Size(800, 2400)}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = tamanho;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  final preferencias = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
  );
  addTearDown(container.dispose);
  await container.read(provedorTema.notifier).carregar();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: SecaoBarraSuperior())),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return container;
}

void main() {
  testWidgets(
      'monta com defaults: toggle desligado, carrossel selecionado e sem '
      'conteudo', (tester) async {
    await _montarSecao(tester);

    final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(toggle.value, isFalse);

    expect(find.byType(EditorCarrossel), findsOneWidget);
    expect(find.byType(EditorLetreiro), findsNothing);
    expect(find.byType(EditorParceiro), findsNothing);
    expect(find.text('Nenhum conteúdo configurado.'), findsOneWidget);

    expect(find.text('Publicidade na barra superior'), findsOneWidget);
    expect(find.text('Formato de exibição'), findsOneWidget);
    expect(find.text('Pré-visualização'), findsOneWidget);
    // 'Carrossel de banners' aparece no card do formato E no título do
    // editor selecionado.
    expect(find.text('Carrossel de banners'), findsWidgets);
  });

  testWidgets(
      'selecionar letreiro troca o editor e preserva o estado do carrossel '
      'ao voltar', (tester) async {
    final container = await _montarSecao(tester);
    container.read(provedorPublicidade.notifier).adicionarBanners(['/b/a.png']);
    await tester.pump();
    expect(find.byType(EditorCarrossel), findsOneWidget);

    await tester.tap(find.text('Letreiro de mensagens'));
    await tester.pump();
    expect(find.byType(EditorLetreiro), findsOneWidget);
    expect(find.byType(EditorCarrossel), findsNothing);

    await tester.tap(find.text('Carrossel de banners'));
    await tester.pump();

    expect(find.byType(EditorCarrossel), findsOneWidget);
    expect(container.read(provedorPublicidade).rascunho.banners, hasLength(1));
    expect(find.text('Banner 1'), findsOneWidget);
  });

  testWidgets(
      'adicionar mensagem no letreiro mostra alteracoes pendentes e '
      'atualiza a previa ao vivo', (tester) async {
    await _montarSecao(tester);

    await tester.tap(find.text('Exibir publicidade na barra'));
    await tester.pump();
    await tester.tap(find.text('Letreiro de mensagens'));
    await tester.pump();

    // Ativa e sem conteudo: a previa ainda mostra o aviso.
    expect(find.text('Adicione conteúdo para visualizar.'), findsOneWidget);
    expect(find.byType(LetreiroPublicidade), findsNothing);

    await tester.tap(find.text('+ Adicionar mensagem'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Promoção hoje');
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Alterações não salvas'), findsOneWidget);
    // A previa deixa de mostrar o aviso e passa a renderizar o letreiro.
    expect(find.text('Adicione conteúdo para visualizar.'), findsNothing);
    expect(find.byType(LetreiroPublicidade), findsOneWidget);
  });

  testWidgets(
      'aplicar com publicidade ativa e formato sem conteudo mostra a '
      'validacao e nao persiste nada', (tester) async {
    final container = await _montarSecao(tester);
    final preferencias = container.read(provedorSharedPreferences);

    await tester.tap(find.text('Exibir publicidade na barra'));
    await tester.pump();

    await tester.tap(find.text('Aplicar alterações'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
        find.text(
            'Adicione ao menos um conteúdo antes de ativar este formato.'),
        findsOneWidget);
    expect(preferencias.containsKey('publicidade_barra'), isFalse);
    expect(find.text('Alterações não salvas'), findsOneWidget);
  });

  testWidgets(
      'fluxo feliz: ativa, adiciona mensagem no letreiro e aplica persiste '
      'no SharedPreferences', (tester) async {
    final container = await _montarSecao(tester);
    final preferencias = container.read(provedorSharedPreferences);

    await tester.tap(find.text('Exibir publicidade na barra'));
    await tester.pump();
    await tester.tap(find.text('Letreiro de mensagens'));
    await tester.pump();
    await tester.tap(find.text('+ Adicionar mensagem'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Promoção hoje');
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(preferencias.containsKey('publicidade_barra'), isFalse);

    await tester.tap(find.text('Aplicar alterações'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Configurações de propaganda aplicadas com sucesso.'),
        findsOneWidget);
    expect(preferencias.containsKey('publicidade_barra'), isTrue);
    expect(find.text('Alterações não salvas'), findsNothing);
    expect(container.read(provedorPublicidade).salva.ativa, isTrue);
    expect(container.read(provedorPublicidade).salva.mensagens, hasLength(1));
  });

  testWidgets('descartar restaura a publicidade salva apos confirmar',
      (tester) async {
    final container = await _montarSecao(tester);

    await tester.tap(find.text('Exibir publicidade na barra'));
    await tester.pump();
    expect(find.text('Alterações não salvas'), findsOneWidget);

    await tester.tap(find.text('Descartar alterações'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar alterações?'), findsOneWidget);

    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();

    expect(find.text('Alterações não salvas'), findsNothing);
    expect(container.read(provedorPublicidade).rascunho.ativa, isFalse);
  });

  testWidgets(
      'previa mostra o aviso de conteudo quando a publicidade esta ativa '
      'sem nenhum banner/mensagem/parceiro', (tester) async {
    await _montarSecao(tester);
    expect(find.text('Adicione conteúdo para visualizar.'), findsNothing);

    await tester.tap(find.text('Exibir publicidade na barra'));
    await tester.pump();

    expect(find.text('Adicione conteúdo para visualizar.'), findsOneWidget);
  });

  testWidgets('largura 1200 usa duas colunas com a previa visivel',
      (tester) async {
    await _montarSecao(tester, tamanho: const Size(1200, 900));

    expect(find.text('Pré-visualização'), findsOneWidget);
    expect(find.text('Formato de exibição'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('largura 480 empilha os cards sem estourar o layout',
      (tester) async {
    await _montarSecao(tester, tamanho: const Size(480, 2600));

    expect(find.text('Pré-visualização'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
