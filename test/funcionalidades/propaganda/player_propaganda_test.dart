import 'dart:convert';
import 'dart:io';

import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// PNG 1x1 valido: razao de aspecto 1,0.
const _png1x1 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8'
    'BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
const _corFundo = Color(0xFF123456);

void main() {
  late Directory temporaria;
  late String caminhoImagem;

  setUp(() async {
    temporaria = await Directory.systemTemp.createTemp('player_propaganda');
    caminhoImagem = '${temporaria.path}${Platform.pathSeparator}a.png';
    await File(caminhoImagem).writeAsBytes(base64Decode(_png1x1));
  });

  tearDown(() async {
    imageCache.clear();
    await temporaria.delete(recursive: true);
  });

  MidiaPropaganda midiaCom(
    AjusteMidia ajuste,
    String caminho, {
    FundoMidia fundo = FundoMidia.borrado,
    AncoraMidia ancora = AncoraMidia.centro,
    int zoomPercentual = 100,
    int rotacaoGraus = 0,
  }) =>
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: caminho,
          ordem: 1,
          ajuste: ajuste,
          fundo: fundo,
          ancora: ancora,
          zoomPercentual: zoomPercentual,
          rotacaoGraus: rotacaoGraus);

  Future<void> montar(WidgetTester tester, MidiaPropaganda midia, Size tela) {
    return tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox(
          width: tela.width,
          height: tela.height,
          child: PlayerPropaganda(
              midia: midia, corFundo: _corFundo, aoTerminar: () {}),
        ),
      ),
    ));
  }

  BoxFit? fitAplicado(WidgetTester tester) =>
      tester.widget<FittedBox>(find.byKey(const ValueKey('midia-nitida'))).fit;

  testWidgets('modos explicitos aplicam o BoxFit sem precisar medir a imagem',
      (tester) async {
    const tela = Size(90, 160);
    final esperados = {
      AjusteMidia.preencher: BoxFit.cover,
      AjusteMidia.encaixar: BoxFit.contain,
      AjusteMidia.esticar: BoxFit.fill,
    };
    for (final entrada in esperados.entries) {
      await montar(tester, midiaCom(entrada.key, caminhoImagem), tela);
      await tester.pump();
      expect(fitAplicado(tester), entrada.value, reason: '${entrada.key}');
    }
  });

  testWidgets('automatico nunca corta, qualquer que seja a tela',
      (tester) async {
    // Tela quadrada com imagem quadrada dava cover; agora tudo e contain.
    await montar(tester, midiaCom(AjusteMidia.automatico, caminhoImagem),
        const Size(120, 120));
    await tester.pump();
    expect(fitAplicado(tester), BoxFit.contain);

    await montar(tester, midiaCom(AjusteMidia.automatico, caminhoImagem),
        const Size(90, 160));
    await tester.pump();
    expect(fitAplicado(tester), BoxFit.contain);
  });

  testWidgets('arquivo ausente mostra a cor de fundo, nao preto',
      (tester) async {
    await montar(
        tester,
        midiaCom(AjusteMidia.preencher,
            '${temporaria.path}${Platform.pathSeparator}sumiu.png'),
        const Size(90, 160));
    await tester.pump();
    expect(find.byType(Image), findsNothing);
    final fundo = tester
        .widgetList<ColoredBox>(find.descendant(
          of: find.byType(PlayerPropaganda),
          matching: find.byType(ColoredBox),
        ))
        .first;
    expect(fundo.color, _corFundo);
    // Deixa o temporizador de 1s do arquivo ausente disparar antes do teardown.
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('sobra com fundo borrado ganha a camada desfocada da midia',
      (tester) async {
    await montar(tester, midiaCom(AjusteMidia.automatico, caminhoImagem),
        const Size(90, 160));
    await tester.pump();
    expect(find.byKey(const ValueKey('fundo-borrado')), findsOneWidget);
    expect(
        find.descendant(
            of: find.byKey(const ValueKey('fundo-borrado')),
            matching: find.byType(ImageFiltered)),
        findsOneWidget,
        reason: 'a camada de fundo precisa estar de fato desfocada');
  });

  testWidgets('fundo=cor mantem a tarja chapada, sem camada borrada',
      (tester) async {
    await montar(
        tester,
        midiaCom(AjusteMidia.automatico, caminhoImagem, fundo: FundoMidia.cor),
        const Size(90, 160));
    await tester.pump();
    expect(find.byKey(const ValueKey('fundo-borrado')), findsNothing);
  });

  testWidgets(
      'preencher nao tem sobra: sem camada borrada mesmo com '
      'fundo=borrado', (tester) async {
    await montar(tester, midiaCom(AjusteMidia.preencher, caminhoImagem),
        const Size(90, 160));
    await tester.pump();
    expect(find.byKey(const ValueKey('fundo-borrado')), findsNothing);
  });

  testWidgets('preencher com zoom reduzido ganha sobra com fundo borrado',
      (tester) async {
    await montar(
        tester,
        midiaCom(AjusteMidia.preencher, caminhoImagem, zoomPercentual: 80),
        const Size(90, 160));
    await tester.pump();
    expect(find.byKey(const ValueKey('fundo-borrado')), findsOneWidget,
        reason: 'zoom < 100 encolhe a midia: a moldura precisa de fundo');
    final transformes = tester.widgetList<Transform>(find.descendant(
        of: find.byType(PlayerPropaganda), matching: find.byType(Transform)));
    expect(transformes, hasLength(1));
    expect(
        transformes.single.transform.getMaxScaleOnAxis(), closeTo(0.8, 0.001));
  });

  testWidgets('preencher aplica ancora e zoom; demais modos nao escalam',
      (tester) async {
    await montar(
        tester,
        midiaCom(AjusteMidia.preencher, caminhoImagem,
            ancora: AncoraMidia.topo, zoomPercentual: 140),
        const Size(90, 160));
    await tester.pump();
    final nitida =
        tester.widget<FittedBox>(find.byKey(const ValueKey('midia-nitida')));
    expect(nitida.alignment, Alignment.topCenter,
        reason: 'a ancora diz qual parte da midia sobrevive ao corte');
    final transformes = tester.widgetList<Transform>(find.descendant(
        of: find.byType(PlayerPropaganda), matching: find.byType(Transform)));
    expect(transformes, hasLength(1));
    expect(
        transformes.single.transform.getMaxScaleOnAxis(), closeTo(1.4, 0.001));
    expect(transformes.single.alignment, Alignment.topCenter,
        reason: 'o zoom amplia a partir da ancora, nao do centro');

    await montar(tester, midiaCom(AjusteMidia.automatico, caminhoImagem),
        const Size(90, 160));
    await tester.pump();
    expect(
        find.descendant(
            of: find.byType(PlayerPropaganda),
            matching: find.byType(Transform)),
        findsNothing,
        reason: 'zoom so existe no preencher');
  });

  testWidgets('rotacao gira a midia e o fundo borrado juntos', (tester) async {
    await montar(
        tester,
        midiaCom(AjusteMidia.automatico, caminhoImagem, rotacaoGraus: 90),
        const Size(90, 160));
    await tester.pump();
    final rotacoes = tester.widgetList<RotatedBox>(find.descendant(
        of: find.byType(PlayerPropaganda), matching: find.byType(RotatedBox)));
    expect(rotacoes, hasLength(2),
        reason: 'camada nitida e fundo borrado giram juntos');
    for (final rotacao in rotacoes) {
      expect(rotacao.quarterTurns, 1);
    }
  });

  testWidgets('sem rotacao, quarterTurns fica em zero', (tester) async {
    await montar(
        tester,
        midiaCom(AjusteMidia.automatico, caminhoImagem, fundo: FundoMidia.cor),
        const Size(90, 160));
    await tester.pump();
    final rotacao = tester.widget<RotatedBox>(find.descendant(
        of: find.byType(PlayerPropaganda), matching: find.byType(RotatedBox)));
    expect(rotacao.quarterTurns, 0);
  });
}
