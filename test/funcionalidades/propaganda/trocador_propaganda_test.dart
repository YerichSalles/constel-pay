import 'dart:convert';
import 'dart:io';

import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/trocador_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _png1x1 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8'
    'BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

void main() {
  late Directory temporaria;
  late String caminhoA;
  late String caminhoB;
  late String ausenteA;
  late String ausenteB;

  setUp(() async {
    temporaria = await Directory.systemTemp.createTemp('trocador');
    caminhoA = '${temporaria.path}${Platform.pathSeparator}a.png';
    caminhoB = '${temporaria.path}${Platform.pathSeparator}b.png';
    await File(caminhoA).writeAsBytes(base64Decode(_png1x1));
    await File(caminhoB).writeAsBytes(base64Decode(_png1x1));
    ausenteA = '${temporaria.path}${Platform.pathSeparator}sumiu-a.png';
    ausenteB = '${temporaria.path}${Platform.pathSeparator}sumiu-b.png';
  });

  tearDown(() async {
    imageCache.clear();
    await temporaria.delete(recursive: true);
  });

  MidiaPropaganda imagem(String id, String caminho) => MidiaPropaganda(
      id: id,
      tipo: TipoMidia.imagem,
      caminho: caminho,
      duracaoSegundos: 1,
      ordem: 1);

  Future<void> montar(
    WidgetTester tester, {
    required int indice,
    required MidiaPropaganda atual,
    required MidiaPropaganda seguinte,
    required VoidCallback aoAvancar,
  }) {
    return tester.pumpWidget(MaterialApp(
      home: TrocadorPropaganda(
        indice: indice,
        midiaAtual: atual,
        midiaSeguinte: seguinte,
        corFundo: const Color(0xFF123456),
        aoAvancar: aoAvancar,
      ),
    ));
  }

  PlayerPropaganda playerAtivo(WidgetTester tester) => tester
      .widgetList<PlayerPropaganda>(
          find.byType(PlayerPropaganda, skipOffstage: false))
      .singleWhere((p) => p.ativo);

  testWidgets('mantem o atual visivel e o seguinte preparando offstage',
      (tester) async {
    final a = imagem('a', caminhoA);
    final b = imagem('b', caminhoB);
    await montar(tester, indice: 0, atual: a, seguinte: b, aoAvancar: () {});
    await tester.pump();

    final players = tester.widgetList<PlayerPropaganda>(
        find.byType(PlayerPropaganda, skipOffstage: false));
    expect(players, hasLength(2));
    expect(find.byType(PlayerPropaganda), findsOneWidget,
        reason: 'so o ativo esta em cena; o seguinte prepara offstage');
    expect(playerAtivo(tester).midia.id, 'a');
    final seguinte = players.singleWhere((p) => !p.ativo);
    expect(seguinte.midia.id, 'b');
    expect(seguinte.aoPreparado, isNotNull,
        reason: 'o seguinte precisa avisar quando estiver pronto');

    // O timer de 1s do atual fica pendente: desmonta para cancelar.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('fim do atual com seguinte pronto avanca uma vez',
      (tester) async {
    var avancos = 0;
    final a = imagem('a', ausenteA);
    final b = imagem('b', ausenteB);
    await montar(tester,
        indice: 0, atual: a, seguinte: b, aoAvancar: () => avancos++);
    await tester.pump();
    // Arquivo ausente: o seguinte sinaliza pronto ja na montagem e o atual
    // agenda o avanco de erro de 1s — tudo no relogio do teste.
    await tester.pump(const Duration(seconds: 1));
    expect(avancos, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('no swap, o player que era seguinte sobrevive (mesmo State)',
      (tester) async {
    final a = imagem('a', ausenteA);
    final b = imagem('b', ausenteB);
    await montar(tester, indice: 0, atual: a, seguinte: b, aoAvancar: () {});
    await tester.pump();
    final estadoSeguinteAntes = tester.state(find.byWidgetPredicate(
        (w) => w is PlayerPropaganda && !w.ativo && w.midia.id == 'b',
        skipOffstage: false));

    // Simula o controlador avancando: mesmo trocador, indice novo.
    await montar(tester, indice: 1, atual: b, seguinte: a, aoAvancar: () {});
    await tester.pump();
    final estadoAtivoDepois = tester.state(find.byWidgetPredicate(
        (w) => w is PlayerPropaganda && w.ativo && w.midia.id == 'b',
        skipOffstage: false));

    expect(identical(estadoSeguinteAntes, estadoAtivoDepois), isTrue,
        reason: 'recriar o player na troca e exatamente a piscada que o '
            'trocador existe para eliminar');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('midia unica: atual e seguinte sao exibicoes distintas dela',
      (tester) async {
    var avancos = 0;
    final a = imagem('a', ausenteA);
    await montar(tester,
        indice: 0, atual: a, seguinte: a, aoAvancar: () => avancos++);
    await tester.pump();
    final players = tester.widgetList<PlayerPropaganda>(
        find.byType(PlayerPropaganda, skipOffstage: false));
    expect(players, hasLength(2),
        reason: 'duas exibicoes do mesmo arquivo, cada uma com seu player');
    await tester.pump(const Duration(seconds: 1));
    expect(avancos, 1);
    await tester.pumpWidget(const SizedBox());
  });
}
