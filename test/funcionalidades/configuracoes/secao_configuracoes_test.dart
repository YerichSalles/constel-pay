import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/secao_configuracoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget filho) => MaterialApp(home: Scaffold(body: filho));

void main() {
  testWidgets('mostra titulo, descricao e filho', (tester) async {
    await tester.pumpWidget(_app(const SecaoConfiguracoes(
      titulo: 'Título',
      descricao: 'Descrição curta.',
      filho: Text('conteúdo'),
    )));
    expect(find.text('Título'), findsOneWidget);
    expect(find.text('Descrição curta.'), findsOneWidget);
    expect(find.text('conteúdo'), findsOneWidget);
  });

  testWidgets('acao fica no cabecalho, a direita do titulo', (tester) async {
    await tester.pumpWidget(_app(SecaoConfiguracoes(
      titulo: 'Título',
      descricao: 'Descrição.',
      acao: Switch(value: true, onChanged: (_) {}),
    )));
    expect(find.byType(Switch), findsOneWidget);
    final titulo = tester.getCenter(find.text('Título'));
    final acao = tester.getCenter(find.byType(Switch));
    expect(acao.dx, greaterThan(titulo.dx),
        reason: 'a acao fica alinhada a direita do cabecalho');
  });

  testWidgets('card so com cabecalho (sem filho) monta sem erro',
      (tester) async {
    await tester
        .pumpWidget(_app(const SecaoConfiguracoes(titulo: 'Só cabeçalho')));
    expect(find.text('Só cabeçalho'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cabecalho com acao nao estoura em largura estreita',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(SecaoConfiguracoes(
      titulo: 'Publicidade na barra superior',
      descricao: 'Descrição longa o bastante para quebrar em mais de uma '
          'linha em uma janela bem estreita.',
      acao: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(
            child: Text('Exibir publicidade na barra',
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Switch(value: false, onChanged: (_) {}),
        ],
      ),
    )));
    expect(tester.takeException(), isNull,
        reason: 'o cabecalho precisa ceder espaco em vez de estourar');
  });
}
