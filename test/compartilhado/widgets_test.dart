import 'package:constel_pay/compartilhado/feedback/estado_erro.dart';
import 'package:constel_pay/compartilhado/layout/layout_responsivo.dart';
import 'package:constel_pay/compartilhado/widgets/botao_primario.dart';
import 'package:constel_pay/compartilhado/widgets/campo_senha.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget filho) => MaterialApp(home: Scaffold(body: filho));

void main() {
  testWidgets('BotaoPrimario mostra rotulo e dispara callback', (tester) async {
    var tocado = false;
    await tester.pumpWidget(
        _app(BotaoPrimario(rotulo: 'Pagar', aoTocar: () => tocado = true)));
    expect(find.text('Pagar'), findsOneWidget);
    await tester.tap(find.byType(BotaoPrimario));
    expect(tocado, isTrue);
  });

  testWidgets('BotaoPrimario carregando desabilita o toque', (tester) async {
    var tocado = false;
    await tester.pumpWidget(_app(BotaoPrimario(
        rotulo: 'Pagar', carregando: true, aoTocar: () => tocado = true)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(BotaoPrimario), warnIfMissed: false);
    expect(tocado, isFalse);
  });

  testWidgets('CampoSenha alterna a visibilidade', (tester) async {
    await tester.pumpWidget(_app(const CampoSenha(rotulo: 'Senha')));
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('EstadoErro mostra mensagem e botao de tentar novamente',
      (tester) async {
    var tentou = false;
    await tester.pumpWidget(_app(EstadoErro(
        mensagem: 'Falhou', aoTentarNovamente: () => tentou = true)));
    expect(find.text('Falhou'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    expect(tentou, isTrue);
  });

  test('modoPorLargura aplica os breakpoints', () {
    expect(modoPorLargura(412), ModoDispositivo.celular);
    expect(modoPorLargura(660), ModoDispositivo.tablet);
    expect(modoPorLargura(1200), ModoDispositivo.totem);
  });
}
