import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/ajuste_tela.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef EnquadramentoSalvo = ({
  AjusteMidia ajuste,
  FundoMidia fundo,
  AncoraMidia ancora,
  int zoomPercentual,
  int rotacaoGraus,
});

void main() {
  const midiaImagem = MidiaPropaganda(
      id: 'a', tipo: TipoMidia.imagem, caminho: '/m/inexistente.png', ordem: 1);
  const midiaVideo = MidiaPropaganda(
      id: 'v', tipo: TipoMidia.video, caminho: '/m/inexistente.mp4', ordem: 1);

  Future<void> abrir(
    WidgetTester tester,
    MidiaPropaganda midia, {
    OrientacaoTela orientacao = OrientacaoTela.vertical,
    void Function(EnquadramentoSalvo salvo)? aoSalvar,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => DialogoAjusteMidia(
                  midia: midia,
                  corTema: const Color(0xFF5E52D6),
                  orientacao: orientacao,
                  aoSalvar: ({
                    required AjusteMidia ajuste,
                    required FundoMidia fundo,
                    required AncoraMidia ancora,
                    required int zoomPercentual,
                    required int rotacaoGraus,
                  }) =>
                      aoSalvar?.call((
                    ajuste: ajuste,
                    fundo: fundo,
                    ancora: ancora,
                    zoomPercentual: zoomPercentual,
                    rotacaoGraus: rotacaoGraus,
                  )),
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  /// A midia inexistente agenda o temporizador de 1s do player; drena antes
  /// do fim do teste.
  Future<void> drenar(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 2));

  Future<void> escolherModo(WidgetTester tester, String rotulo) async {
    await tester.tap(find.byType(DropdownButton<AjusteMidia>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(rotulo).last);
    await tester.pumpAndSettle();
  }

  testWidgets('preview usa o mesmo player da tela real', (tester) async {
    await abrir(tester, midiaImagem);
    expect(find.byType(PlayerPropaganda), findsOneWidget);
    await drenar(tester);
  });

  testWidgets('preview recebe a midia editada, nao a original', (tester) async {
    await abrir(tester, midiaImagem);
    await escolherModo(tester, 'Preencher (corta)');
    await tester.tap(find.byKey(const ValueKey('ancora-topo')));
    await tester.pump();
    final player =
        tester.widget<PlayerPropaganda>(find.byType(PlayerPropaganda));
    expect(player.midia.ajuste, AjusteMidia.preencher,
        reason: 'o preview precisa refletir o modo recem-escolhido');
    expect(player.midia.ancora, AncoraMidia.topo);
    expect(player.midia.id, midiaImagem.id,
        reason: 'id estavel: o player nao reinicia a cada edicao');
    await drenar(tester);
  });

  testWidgets('cancelar fecha sem salvar', (tester) async {
    EnquadramentoSalvo? salvo;
    await abrir(tester, midiaImagem, aoSalvar: (s) => salvo = s);
    await escolherModo(tester, 'Preencher (corta)');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(salvo, isNull);
    expect(find.byType(DialogoAjusteMidia), findsNothing);
    await drenar(tester);
  });

  testWidgets('salvar devolve o enquadramento editado', (tester) async {
    EnquadramentoSalvo? salvo;
    await abrir(tester, midiaImagem, aoSalvar: (s) => salvo = s);
    await escolherModo(tester, 'Preencher (corta)');
    await tester.tap(find.byKey(const ValueKey('ancora-topo')));
    await tester.pump();
    // O slider fica dentro de um SingleChildScrollView; garante que esta
    // visivel antes de arrastar, senao o gesto erra o alvo.
    await tester.ensureVisible(find.byType(Slider));
    await tester.pumpAndSettle();
    // Arrasta a partir do polegar (valor minimo -> ponta esquerda da trilha)
    // ate a ponta direita: zoom maximo, deterministico.
    final slider = find.byType(Slider);
    final borda = tester.getTopLeft(slider);
    final centroY = tester.getCenter(slider).dy;
    final gesto = await tester.startGesture(Offset(borda.dx + 24, centroY));
    await gesto.moveBy(const Offset(600, 0));
    await gesto.up();
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(salvo, isNotNull);
    expect(salvo!.ajuste, AjusteMidia.preencher);
    expect(salvo!.ancora, AncoraMidia.topo);
    expect(salvo!.zoomPercentual, zoomMaximo);
    expect(salvo!.rotacaoGraus, 0);
    expect(find.byType(DialogoAjusteMidia), findsNothing);
    await drenar(tester);
  });

  testWidgets(
      'controles de corte so aparecem no preencher; fundo so onde '
      'ha sobra', (tester) async {
    await abrir(tester, midiaImagem);
    // automatico: fundo sim, corte nao.
    expect(find.byType(SegmentedButton<FundoMidia>), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
    expect(find.byKey(const ValueKey('ancora-topo')), findsNothing);

    await escolherModo(tester, 'Preencher (corta)');
    expect(find.byType(SegmentedButton<FundoMidia>), findsNothing);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byKey(const ValueKey('ancora-topo')), findsOneWidget);
    await drenar(tester);
  });

  testWidgets('video nao oferece fundo enquanto o gate nao libera',
      (tester) async {
    await abrir(tester, midiaVideo);
    expect(find.byType(SegmentedButton<FundoMidia>), findsNothing);
    await drenar(tester);
  });

  test('toda ancora tem rotulo em pt-BR', () {
    for (final ancora in AncoraMidia.values) {
      expect(DialogoAjusteMidia.rotulosAncora[ancora], isNotNull,
          reason: 'sem rotulo para $ancora');
    }
  });

  testWidgets('girar cicla 90 em 90 e o preview acompanha', (tester) async {
    EnquadramentoSalvo? salvo;
    await abrir(tester, midiaImagem, aoSalvar: (s) => salvo = s);
    await tester.tap(find.text('Girar 90°'));
    await tester.pump();
    var player = tester.widget<PlayerPropaganda>(find.byType(PlayerPropaganda));
    expect(player.midia.rotacaoGraus, 90);

    await tester.tap(find.text('Girar 90°'));
    await tester.tap(find.text('Girar 90°'));
    await tester.tap(find.text('Girar 90°'));
    await tester.pump();
    player = tester.widget<PlayerPropaganda>(find.byType(PlayerPropaganda));
    expect(player.midia.rotacaoGraus, 0, reason: '4 toques dao a volta');

    await tester.tap(find.text('Girar 90°'));
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(salvo!.rotacaoGraus, 90);
    await drenar(tester);
  });

  testWidgets('preview segue a orientacao da tela', (tester) async {
    await abrir(tester, midiaImagem);
    var aspecto = tester.widget<AspectRatio>(find.descendant(
        of: find.byType(DialogoAjusteMidia),
        matching: find.byType(AspectRatio)));
    expect(aspecto.aspectRatio, closeTo(9 / 16, 0.001));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await drenar(tester);

    await abrir(tester, midiaImagem, orientacao: OrientacaoTela.horizontal);
    aspecto = tester.widget<AspectRatio>(find.descendant(
        of: find.byType(DialogoAjusteMidia),
        matching: find.byType(AspectRatio)));
    expect(aspecto.aspectRatio, closeTo(16 / 9, 0.001));
    await drenar(tester);
  });

  testWidgets(
      'no preencher, o controle de fundo aparece quando o zoom '
      'encolhe', (tester) async {
    await abrir(tester, midiaImagem);
    await escolherModo(tester, 'Preencher (corta)');
    expect(find.byType(SegmentedButton<FundoMidia>), findsNothing,
        reason: 'zoom 100 cobre a tela: nao ha sobra para configurar');

    await tester.ensureVisible(find.byType(Slider));
    await tester.pumpAndSettle();
    // Toca perto do inicio do trilho: o valor salta para baixo de 100%.
    final trilho = tester.getTopLeft(find.byType(Slider));
    final centroY = tester.getCenter(find.byType(Slider)).dy;
    await tester.tapAt(Offset(trilho.dx + 30, centroY));
    await tester.pump();
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.value, lessThan(100));
    expect(slider.value, greaterThanOrEqualTo(50));
    expect(find.byType(SegmentedButton<FundoMidia>), findsOneWidget,
        reason: 'com sobra, o operador escolhe o fundo');
    await drenar(tester);
  });

  testWidgets('grade de ancoras usa a cor do tema', (tester) async {
    const corTema = Color(0xFF5E52D6);
    await abrir(tester, midiaImagem);
    await escolherModo(tester, 'Preencher (corta)');

    BoxDecoration decoracaoDe(String chave) {
      final container = tester.widget<Container>(find.descendant(
        of: find.byKey(ValueKey(chave)),
        matching: find.byType(Container),
      ));
      return container.decoration! as BoxDecoration;
    }

    final selecionada = decoracaoDe('ancora-centro');
    expect(selecionada.border!.top.color, corTema,
        reason: 'selecionada marca com a cor primaria da loja');
    expect(selecionada.color, corTema.withValues(alpha: .18));

    final vizinha = decoracaoDe('ancora-topo');
    expect(vizinha.border!.top.color, corTema.withValues(alpha: .45),
        reason: 'as demais celulas ficam visiveis em qualquer tema');
    expect(vizinha.color, isNull);
    await drenar(tester);
  });

  test('resumo do enquadramento por modo', () {
    expect(resumoEnquadramento(midiaImagem), 'Automático · fundo borrado');
    expect(resumoEnquadramento(midiaImagem.copyWith(fundo: FundoMidia.cor)),
        'Automático · fundo na cor do tema');
    expect(resumoEnquadramento(midiaVideo), 'Automático · fundo na cor do tema',
        reason: 'video segue o gate: o resumo nao pode prometer blur');
    expect(
        resumoEnquadramento(midiaImagem.copyWith(
            ajuste: AjusteMidia.preencher,
            ancora: AncoraMidia.topo,
            zoomPercentual: 140)),
        'Preencher (corta) · topo · 140%');
    expect(
        resumoEnquadramento(midiaImagem.copyWith(
            ajuste: AjusteMidia.preencher,
            ancora: AncoraMidia.centro,
            zoomPercentual: 80)),
        'Preencher (corta) · centro · 80% · fundo borrado',
        reason: 'zoom < 100 deixa sobra com fundo borrado por padrao');
    expect(
        resumoEnquadramento(midiaImagem.copyWith(
            ajuste: AjusteMidia.preencher,
            ancora: AncoraMidia.centro,
            zoomPercentual: 80,
            fundo: FundoMidia.cor)),
        'Preencher (corta) · centro · 80% · fundo na cor do tema',
        reason: 'zoom < 100 com fundo cor personalizado');
    expect(
        resumoEnquadramento(midiaImagem.copyWith(ajuste: AjusteMidia.esticar)),
        'Esticar (distorce)');
    expect(resumoEnquadramento(midiaImagem.copyWith(rotacaoGraus: 90)),
        'Automático · fundo borrado · girada 90°');
    expect(
        resumoEnquadramento(midiaImagem.copyWith(
            ajuste: AjusteMidia.esticar, rotacaoGraus: 270)),
        'Esticar (distorce) · girada 270°');
  });
}
