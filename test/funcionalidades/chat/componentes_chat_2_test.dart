import 'package:constel_pay/compartilhado/widgets/botao_primario.dart';
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
import 'package:constel_pay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget filho, {Locale locale = const Locale('pt', 'BR')}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: filho)),
    );

void main() {
  testWidgets('CardScanner mostra o visor sem busca manual nem simulacao',
      (tester) async {
    await tester.pumpWidget(_app(const CardScanner()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Posicione o código do cartão dentro da área'),
        findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(BotaoPrimario), findsNothing);
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
      aoTentarNovamente: () {},
      aoContinuarComCartoes: () {},
    )));
    await tester.tap(find.text('Adicionar outro cartão'));
    expect(leuOutro, isTrue);
    expect(find.text('Continuar para pagamento'), findsOneWidget);
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
    expect(find.text('Comanda 01'), findsOneWidget);
    expect(find.text('Comanda 02'), findsOneWidget);
    // Círculo de aprovado + um check por comanda quitada.
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
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

  testWidgets('ChipAcao discreto renderiza sem borda e dispara o toque',
      (tester) async {
    var tocado = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChipAcao(
          rotulo: 'Continuar com os cartões já adicionados',
          aoTocar: () => tocado = true,
          discreto: true,
        ),
      ),
    ));
    await tester.tap(find.text('Continuar com os cartões já adicionados'));
    expect(tocado, isTrue);
    final material = tester.widget<Material>(find
        .ancestor(of: find.byType(InkWell), matching: find.byType(Material))
        .first);
    expect(material.color, Colors.transparent);
  });
}
