import 'dart:convert';

import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/conteudo_publicidade.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/letreiro_publicidade.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/publicidade_barra_superior.dart';
import 'package:constel_pay/funcionalidades/propaganda/dados/modelos/modelo_publicidade.dart';
import 'package:constel_pay/funcionalidades/propaganda/dados/repositorios/repositorio_publicidade_impl.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/publicidade_barra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _publicidadeLetreiro = PublicidadeBarra(
  ativa: true,
  formato: FormatoPublicidade.letreiro,
  mensagens: [
    MensagemLetreiro(id: 'm1', texto: 'Promoção especial hoje', ordem: 1),
  ],
);

Future<ProviderContainer> _montar(
  WidgetTester tester, {
  PublicidadeBarra? publicidadeSalva,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferencias = await SharedPreferences.getInstance();
  if (publicidadeSalva != null) {
    await RepositorioPublicidadeImpl(preferencias).salvar(publicidadeSalva);
  }
  final container = ProviderContainer(
    overrides: [provedorSharedPreferences.overrideWithValue(preferencias)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(body: PublicidadeBarraSuperior()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return container;
}

void main() {
  testWidgets('SharedPreferences vazio: continua SizedBox.shrink',
      (tester) async {
    await _montar(tester);

    expect(find.byType(ConteudoPublicidade), findsOneWidget);
    expect(find.byType(LetreiroPublicidade), findsNothing);
    final vazio = tester.widget<SizedBox>(find.descendant(
      of: find.byType(ConteudoPublicidade),
      matching: find.byType(SizedBox),
    ));
    expect(vazio.width, 0);
    expect(vazio.height, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'publicidade ativa em formato letreiro com mensagem: '
      'LetreiroPublicidade aparece', (tester) async {
    await _montar(tester, publicidadeSalva: _publicidadeLetreiro);

    expect(find.byType(LetreiroPublicidade), findsOneWidget);
    final letreiro =
        tester.widget<LetreiroPublicidade>(find.byType(LetreiroPublicidade));
    expect(letreiro.mensagens, ['Promoção especial hoje']);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'publicidade com conteúdo mas ativa=false: continua SizedBox.shrink '
      '(conteúdo salvo é preservado, só não é exibido)', (tester) async {
    final publicidadeInativa = _publicidadeLetreiro.copyWith(ativa: false);
    await _montar(tester, publicidadeSalva: publicidadeInativa);

    expect(find.byType(LetreiroPublicidade), findsNothing);
    final vazio = tester.widget<SizedBox>(find.descendant(
      of: find.byType(ConteudoPublicidade),
      matching: find.byType(SizedBox),
    ));
    expect(vazio.width, 0);
    expect(vazio.height, 0);

    // O conteúdo salvo continua intacto no SharedPreferences (não foi
    // apagado por estar inativo).
    final preferencias = await SharedPreferences.getInstance();
    final texto = preferencias.getString('publicidade_barra');
    expect(texto, isNotNull);
    final salvo =
        ModeloPublicidade.fromJson(jsonDecode(texto!) as Map<String, dynamic>)
            .paraEntidade();
    expect(salvo.mensagens, publicidadeInativa.mensagens);
    expect(tester.takeException(), isNull);
  });
}
