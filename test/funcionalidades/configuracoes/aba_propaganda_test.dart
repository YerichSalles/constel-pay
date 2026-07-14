import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/seletor_ajuste_midia.dart';
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
}
