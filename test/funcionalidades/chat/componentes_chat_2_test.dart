import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/area_acoes.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/barra_total.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_metodos_pagamento.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_pix.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_scanner.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_sucesso.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/chip_acao.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/dados_pix.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget filho) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: filho)));

void main() {
  testWidgets('CardScanner dispara aoEscanear quando habilitado',
      (tester) async {
    var escaneou = false;
    await tester
        .pumpWidget(_app(CardScanner(aoEscanear: () => escaneou = true)));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.textContaining('Simular leitura'));
    expect(escaneou, isTrue);
  });

  testWidgets('CardScanner com aoDigitarComanda envia o número digitado',
      (tester) async {
    String? recebido;
    await tester.pumpWidget(_app(CardScanner(
      aoEscanear: () {},
      aoDigitarComanda: (valor) => recebido = valor,
    )));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), '502');
    await tester.tap(find.text('Buscar'));
    expect(recebido, '502');
  });

  testWidgets('CardScanner sem aoDigitarComanda esconde o campo',
      (tester) async {
    await tester.pumpWidget(_app(CardScanner(aoEscanear: () {})));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('CardScanner desabilitado nao dispara', (tester) async {
    var escaneou = false;
    await tester.pumpWidget(_app(
        CardScanner(aoEscanear: () => escaneou = true, habilitado: false)));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.textContaining('Simular leitura'),
        warnIfMissed: false);
    expect(escaneou, isFalse);
  });

  testWidgets(
      'AreaAcoes oferece ler outro cartao mesmo sem contagem de restantes '
      '(caso da API real, que nao informa quantos faltam)', (tester) async {
    var leuOutro = false;
    await tester.pumpWidget(_app(AreaAcoes(
      estado: const EstadoFluxoPagamento(
        etapa: EtapaFluxo.aguardandoMaisCartoes,
        cartoesRestantes: 0,
      ),
      aoLerOutro: () => leuOutro = true,
      aoIrPagamento: () {},
      aoPagarRestante: () {},
      aoEncerrar: () {},
      aoNovaOperacao: () {},
    )));
    await tester.tap(find.text('Ler outro cartão'));
    expect(leuOutro, isTrue);
    expect(find.text('Ir para o pagamento'), findsOneWidget);
  });

  testWidgets('CardMetodosPagamento lista os metodos e seleciona',
      (tester) async {
    MetodoPagamento? escolhido;
    await tester.pumpWidget(_app(CardMetodosPagamento(
      metodos: const [MetodoPagamento.pix, MetodoPagamento.credito],
      aoSelecionar: (metodo) => escolhido = metodo,
    )));
    expect(find.text('Pix'), findsOneWidget);
    expect(find.text('Crédito'), findsOneWidget);
    await tester.tap(find.text('Pix'));
    expect(escolhido, MetodoPagamento.pix);
  });

  testWidgets('CardPix mostra valor, copia e confirma', (tester) async {
    var copiou = false;
    var confirmou = false;
    final dados = DadosPix(
      qrCode: 'MOCK-PIX-123',
      copiaCola: 'MOCK-PIX-123',
      valorCentavos: 14960,
      expiraEm: DateTime.now().add(const Duration(minutes: 5)),
    );
    await tester.pumpWidget(_app(CardPix(
      dadosPix: dados,
      copiado: false,
      aoCopiar: () => copiou = true,
      aoConfirmar: () => confirmou = true,
    )));
    expect(find.text(r'R$ 149,60'), findsOneWidget);
    await tester.tap(find.textContaining('Copiar código'));
    expect(copiou, isTrue);
    await tester.tap(find.text('Já fiz o pagamento'));
    expect(confirmou, isTrue);
  });

  testWidgets('CardSucesso mostra valor e comandas quitadas', (tester) async {
    await tester.pumpWidget(_app(const CardSucesso(
      valorCentavos: 14960,
      comandas: ['Comanda 01', 'Comanda 02'],
    )));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('aprovado'), findsOneWidget);
    expect(find.text(r'R$ 149,60'), findsOneWidget);
    expect(find.text('✓ Comanda 01'), findsOneWidget);
    expect(find.text('✓ Comanda 02'), findsOneWidget);
  });

  testWidgets('ChipAcao e BarraTotal renderizam', (tester) async {
    var tocado = false;
    await tester.pumpWidget(_app(Column(children: [
      ChipAcao(
          rotulo: 'Encerrar', aoTocar: () => tocado = true, primario: true),
      const BarraTotal(rotulo: '2 cartões', valorCentavos: 23800),
    ])));
    await tester.tap(find.text('Encerrar'));
    expect(tocado, isTrue);
    expect(find.text(r'R$ 238,00'), findsOneWidget);
  });
}
