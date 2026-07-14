import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/aba_propaganda.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_publicidade.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('repro: adicionar banners no carrossel nao trava nem lanca',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    late WidgetRef refCapturada;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provedorSharedPreferences.overrideWithValue(preferencias),
        ],
        child: MaterialApp(
          home: DefaultTabController(
            length: 4,
            child: Scaffold(
              body: Consumer(builder: (context, ref, _) {
                refCapturada = ref;
                return const AbaPropaganda();
              }),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Vai para a seção Barra superior.
    await tester.tap(find.text('Barra superior'));
    await tester.pumpAndSettle();

    // Carrossel já é o formato default. Adiciona 2 banners direto no
    // controlador (mesmo caminho pós-FilePicker do _adicionarBanners).
    final controlador = refCapturada.read(provedorPublicidade.notifier);
    controlador.adicionarBanners(
        ['C:/tmp/inexistente-a.png', 'C:/tmp/inexistente-b.png']);
    await tester.pump();
    expect(tester.takeException(), isNull, reason: 'excecao no 1o frame');

    // Vários frames — timers/animações/loops de layout aparecem aqui.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      final excecao = tester.takeException();
      expect(excecao, isNull, reason: 'excecao no frame ${i + 2}: $excecao');
    }

    expect(
        refCapturada.read(provedorPublicidade).rascunho.banners, hasLength(2));
  });
}
