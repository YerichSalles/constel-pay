import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/bolha_mensagem.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_comanda.dart';
import 'package:constel_pay/funcionalidades/chat/dominio/entidades/mensagem.dart';
import 'package:constel_pay/funcionalidades/chat/dominio/entidades/tipo_mensagem.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/cartao_consumo.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/item_consumo.dart';
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

const _itens = [
  ItemConsumo(
      emoji: '🍲',
      nome: 'Feijoada individual',
      quantidade: 1,
      valorCentavos: 4600),
  ItemConsumo(
      emoji: '🥩',
      nome: 'Picanha na chapa',
      quantidade: 1,
      valorCentavos: 6400),
  ItemConsumo(
      emoji: '🍺', nome: 'Chopp 300ml', quantidade: 2, valorCentavos: 900),
  ItemConsumo(
      emoji: '🥤', nome: 'Guaraná lata', quantidade: 1, valorCentavos: 800),
];

CartaoConsumo _cartao({
  String nome = 'Comanda 01',
  String pessoa = 'João',
  int servicoCentavos = 1360,
  num servicoPercentual = 10,
  int descontoCentavos = 0,
  int totalCentavos = 14960,
}) =>
    CartaoConsumo(
      id: 'c1',
      codigo: '789100000001',
      nome: nome,
      pessoa: pessoa,
      emoji: '🍲',
      resumo: '2 pratos · 3 bebidas',
      subtotalCentavos: 13600,
      servicoCentavos: servicoCentavos,
      servicoPercentual: servicoPercentual,
      descontoCentavos: descontoCentavos,
      totalCentavos: totalCentavos,
      saldoCentavos: totalCentavos,
      itens: _itens,
    );

void main() {
  testWidgets('BolhaMensagem do assistente mostra texto e subtexto',
      (tester) async {
    const mensagem = Mensagem(
        id: 1,
        tipo: TipoMensagem.texto,
        texto: 'Olá!',
        subtexto: 'Bem-vindo',
        emoji: '🍽️');
    await tester.pumpWidget(_app(const BolhaMensagem(mensagem: mensagem)));
    expect(find.text('Olá!'), findsOneWidget);
    expect(find.text('Bem-vindo'), findsOneWidget);
    expect(find.text('🍽️'), findsOneWidget);
  });

  testWidgets('CardComanda lista os itens sem precisar tocar em nada',
      (tester) async {
    await tester.pumpWidget(_app(CardComanda(cartao: _cartao())));
    expect(find.textContaining('Comanda 01'), findsOneWidget);
    expect(find.text('Feijoada individual'), findsOneWidget);
    expect(find.text('Picanha na chapa'), findsOneWidget);
    expect(find.textContaining('2 un'), findsOneWidget);
    expect(find.textContaining('ver itens'), findsNothing);
  });

  testWidgets('CardComanda mostra subtotal, servico da API e total',
      (tester) async {
    await tester.pumpWidget(_app(CardComanda(cartao: _cartao())));
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text(r'R$ 136,00'), findsOneWidget);
    expect(find.text('Taxa de serviço (10%)'), findsOneWidget);
    expect(find.text(r'R$ 13,60'), findsOneWidget);
    expect(find.text('Total da comanda'), findsOneWidget);
    expect(find.text(r'R$ 149,60'), findsOneWidget);
  });

  testWidgets('CardComanda usa o percentual que a API mandar', (tester) async {
    await tester.pumpWidget(_app(CardComanda(
        cartao: _cartao(
            servicoCentavos: 1167,
            servicoPercentual: 8.58,
            totalCentavos: 14767))));
    expect(find.text('Taxa de serviço (8,58%)'), findsOneWidget);
    expect(find.text(r'R$ 11,67'), findsOneWidget);
    expect(find.text(r'R$ 147,67'), findsOneWidget);
  });

  testWidgets('CardComanda omite a taxa quando a API nao cobra servico',
      (tester) async {
    await tester.pumpWidget(_app(CardComanda(
        cartao: _cartao(
            servicoCentavos: 0, servicoPercentual: 0, totalCentavos: 13600))));
    expect(find.textContaining('Taxa de serviço'), findsNothing);
    expect(find.text('Total da comanda'), findsOneWidget);
  });

  testWidgets('CardComanda nao repete a referencia ja contida no nome',
      (tester) async {
    await tester.pumpWidget(
        _app(CardComanda(cartao: _cartao(nome: 'Cartão 510', pessoa: '510'))));
    expect(find.text('Cartão 510'), findsOneWidget);
    expect(find.textContaining('510 · 510'), findsNothing);
  });

  testWidgets('CardComanda mostra a pessoa quando ela acrescenta informacao',
      (tester) async {
    await tester.pumpWidget(_app(CardComanda(cartao: _cartao())));
    expect(find.textContaining('Comanda 01 · João'), findsOneWidget);
  });

  testWidgets('item sem foto mostra o emoji', (tester) async {
    await tester.pumpWidget(_app(CardComanda(cartao: _cartao())));
    expect(find.byType(Image), findsNothing);
    expect(find.text('🍲'), findsWidgets);
  });

  testWidgets('item com foto renderiza a imagem da URL', (tester) async {
    final comFoto = _cartao().copyWith(itens: [
      _itens.first.copyWith(imagemUrl: 'https://s3.amazonaws.com/f/burger.png'),
    ]);
    await tester.pumpWidget(_app(CardComanda(cartao: comFoto)));
    final imagem = tester.widget<Image>(find.byType(Image));
    expect((imagem.image as NetworkImage).url,
        'https://s3.amazonaws.com/f/burger.png');
  });

  testWidgets('locale es mostra os rotulos de subtotal e servico em espanhol',
      (tester) async {
    await tester.pumpWidget(
        _app(CardComanda(cartao: _cartao()), locale: const Locale('es')));
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('Tarifa de servicio (10%)'), findsOneWidget);
    expect(find.text('Total de la tarjeta'), findsOneWidget);
  });
}
