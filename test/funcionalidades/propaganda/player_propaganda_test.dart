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

  MidiaPropaganda midiaCom(AjusteMidia ajuste, String caminho) =>
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: caminho,
          ordem: 1,
          ajuste: ajuste);

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
      tester.widget<Image>(find.byType(Image)).fit;

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

  testWidgets('automatico encaixa imagem quadrada em tela retrato',
      (tester) async {
    await tester.runAsync(() async {
      await montar(tester, midiaCom(AjusteMidia.automatico, caminhoImagem),
          const Size(90, 160));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    });
    expect(fitAplicado(tester), BoxFit.contain);
  });

  testWidgets('automatico preenche imagem quadrada em tela quadrada',
      (tester) async {
    await tester.runAsync(() async {
      await montar(tester, midiaCom(AjusteMidia.automatico, caminhoImagem),
          const Size(120, 120));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump();
    });
    expect(fitAplicado(tester), BoxFit.cover);
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
}
