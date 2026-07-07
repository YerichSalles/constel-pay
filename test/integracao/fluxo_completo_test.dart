import 'package:constel_pay/aplicativo/constel_pay_app.dart';
import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/aplicativo/rotas.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'fluxo completo: splash -> propaganda -> chat -> pagamento -> novo',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    // Terminal ja provisionado (PIN criado)
    await RepositorioConfiguracaoImpl(preferencias)
        .salvar(const ConfiguracaoTerminal(pinHash: 'hash-existente'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provedorSharedPreferences.overrideWithValue(preferencias),
          provedorAtrasoBot.overrideWithValue(Duration.zero),
          provedorFonteLeituraMock
              .overrideWithValue(FonteLeituraMock(atraso: Duration.zero)),
          provedorFontePagamentoMock
              .overrideWithValue(FontePagamentoMock(atraso: Duration.zero)),
        ],
        child: ConstelPayApp(roteador: criarRoteador(localInicial: '/splash')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Splash -> Propaganda (timer de 4s)
    expect(find.text('Terminal de autoatendimento'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Propaganda (sem midias) -> CTA
    expect(find.text('Toque para pagar'), findsOneWidget);
    await tester.tap(find.text('Toque para pagar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Chat: leitura, pagamento, encerramento
    // Pump extra: o conteúdo recém-adicionado ao ListView só reflete a
    // rolagem automática (jumpTo pós-frame) no quadro seguinte.
    await tester.pump();
    await tester.tap(find.textContaining('Simular leitura'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.textContaining('Ir para o pagamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Sem taxa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.tap(find.text('Pix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.tap(find.text('Já fiz o pagamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('aprovado'), findsWidgets);

    // Encerrar -> comprovante -> novo pagamento volta ao splash
    await tester.ensureVisible(find.text('Encerrar'));
    await tester.tap(find.text('Encerrar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(find.text('Comprovante de pagamento'), findsOneWidget);
    await tester.ensureVisible(find.text('Novo pagamento'));
    await tester.tap(find.text('Novo pagamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Terminal de autoatendimento'), findsOneWidget);

    // Descarrega o timer do splash para o teste encerrar sem timers pendentes.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 100));
  });
}
