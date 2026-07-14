import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/area_acoes.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/cartao_consumo.dart';
import 'package:constel_pay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _cartao = CartaoConsumo(
  id: 'c1',
  codigo: '001',
  nome: 'Comanda 01',
  pessoa: 'Mesa 1',
  emoji: '🧾',
  resumo: '',
  itens: [],
  subtotalCentavos: 1000,
  servicoCentavos: 0,
  descontoCentavos: 0,
  totalCentavos: 1000,
  saldoCentavos: 1000,
  selecionado: true,
);

Widget _montar(EstadoFluxoPagamento estado,
    {VoidCallback? aoTentarNovamente,
    VoidCallback? aoContinuarComCartoes,
    Locale locale = const Locale('pt', 'BR')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: AreaAcoes(
        estado: estado,
        aoLerOutro: () {},
        aoIrPagamento: () {},
        aoPagarRestante: () {},
        aoEncerrar: () {},
        aoNovaOperacao: () {},
        aoTentarNovamente: aoTentarNovamente ?? () {},
        aoContinuarComCartoes: aoContinuarComCartoes ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('primeira leitura nao mostra acao de desistencia',
      (tester) async {
    await tester.pumpWidget(
        _montar(const EstadoFluxoPagamento(etapa: EtapaFluxo.lendo)));
    expect(find.text('Continuar com os cartões já adicionados'), findsNothing);
  });

  testWidgets('leitura adicional mostra acao discreta de desistencia',
      (tester) async {
    var continuou = false;
    await tester.pumpWidget(_montar(
      const EstadoFluxoPagamento(etapa: EtapaFluxo.lendo, cartoes: [_cartao]),
      aoContinuarComCartoes: () => continuou = true,
    ));
    await tester.tap(find.text('Continuar com os cartões já adicionados'));
    expect(continuou, isTrue);
  });

  testWidgets('aguardandoMaisCartoes oferece adicionar outro e continuar',
      (tester) async {
    await tester.pumpWidget(_montar(const EstadoFluxoPagamento(
        etapa: EtapaFluxo.aguardandoMaisCartoes, cartoes: [_cartao])));
    expect(find.text('Adicionar outro cartão'), findsOneWidget);
    expect(find.text('Continuar para pagamento'), findsOneWidget);
  });

  testWidgets('semConsumo com cartao oferece tentar outro e continuar com 1',
      (tester) async {
    var tentou = false;
    await tester.pumpWidget(_montar(
      const EstadoFluxoPagamento(
          etapa: EtapaFluxo.semConsumo, cartoes: [_cartao]),
      aoTentarNovamente: () => tentou = true,
    ));
    expect(find.text('Continuar com 1 cartão adicionado'), findsOneWidget);
    await tester.tap(find.text('Tentar outro cartão'));
    expect(tentou, isTrue);
  });

  testWidgets('semConsumo sem cartoes so oferece tentar outro', (tester) async {
    await tester.pumpWidget(
        _montar(const EstadoFluxoPagamento(etapa: EtapaFluxo.semConsumo)));
    expect(find.text('Tentar outro cartão'), findsOneWidget);
    expect(find.textContaining('Continuar com'), findsNothing);
  });

  testWidgets('erroLeitura com cartoes oferece tentar novamente e continuar',
      (tester) async {
    await tester.pumpWidget(_montar(
        const EstadoFluxoPagamento(etapa: EtapaFluxo.erroLeitura, cartoes: [
      _cartao,
      CartaoConsumo(
        id: 'c2',
        codigo: '002',
        nome: 'Comanda 02',
        pessoa: 'Mesa 2',
        emoji: '🧾',
        resumo: '',
        itens: [],
        subtotalCentavos: 2000,
        servicoCentavos: 0,
        descontoCentavos: 0,
        totalCentavos: 2000,
        saldoCentavos: 2000,
        selecionado: true,
      )
    ])));
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.text('Continuar com 2 cartões adicionados'), findsOneWidget);
  });

  testWidgets('locale en mostra os rotulos em ingles', (tester) async {
    await tester.pumpWidget(_montar(
      const EstadoFluxoPagamento(
          etapa: EtapaFluxo.aguardandoMaisCartoes, cartoes: [_cartao]),
      locale: const Locale('en'),
    ));
    expect(find.text('Continue to payment'), findsOneWidget);
  });
}
