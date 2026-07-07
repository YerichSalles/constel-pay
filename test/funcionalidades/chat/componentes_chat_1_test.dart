import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/bolha_mensagem.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_comanda.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_detalhe_comanda.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_mesa.dart';
import 'package:constel_pay/funcionalidades/chat/dominio/entidades/mensagem.dart';
import 'package:constel_pay/funcionalidades/chat/dominio/entidades/tipo_mensagem.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/cartao_consumo.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/item_consumo.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/mesa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget filho) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: filho)));

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

  testWidgets('CardMesa mostra numero e total consumido', (tester) async {
    final mesa = Mesa(
        numero: 12,
        abertoEm: DateTime(2026, 7, 6, 19, 42),
        totalComandas: 3,
        totalCentavos: 31800);
    await tester.pumpWidget(_app(CardMesa(mesa: mesa)));
    expect(find.text('Mesa 12'), findsOneWidget);
    expect(find.textContaining('19:42'), findsOneWidget);
    expect(find.text(r'R$ 318,00'), findsOneWidget);
    expect(find.text('ABERTA'), findsOneWidget);
  });

  testWidgets('CardComanda mostra dados e dispara ver itens', (tester) async {
    final cartao = CartaoConsumo(
      id: 'c1',
      codigo: '789100000001',
      nome: 'Comanda 01',
      pessoa: 'João',
      emoji: '🍲',
      resumo: '2 pratos · 3 bebidas',
      subtotalCentavos: 13600,
      itens: const [
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
            emoji: '🍺',
            nome: 'Chopp 300ml',
            quantidade: 2,
            valorCentavos: 900),
      ],
    );
    var visto = '';
    await tester.pumpWidget(
        _app(CardComanda(cartao: cartao, aoVerItens: (id) => visto = id)));
    expect(find.textContaining('Comanda 01'), findsOneWidget);
    expect(find.text(r'R$ 136,00'), findsOneWidget);
    await tester.tap(find.byType(GestureDetector));
    expect(visto, 'c1');
  });

  testWidgets('CardDetalheComanda lista os itens com totais', (tester) async {
    final cartao = CartaoConsumo(
      id: 'c1',
      codigo: '789100000001',
      nome: 'Comanda 01',
      pessoa: 'João',
      emoji: '🍲',
      resumo: '2 pratos · 3 bebidas',
      subtotalCentavos: 13600,
      itens: const [
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
            emoji: '🍺',
            nome: 'Chopp 300ml',
            quantidade: 2,
            valorCentavos: 900),
        ItemConsumo(
            emoji: '🥤',
            nome: 'Guaraná lata',
            quantidade: 1,
            valorCentavos: 800),
      ],
    );
    await tester.pumpWidget(_app(CardDetalheComanda(cartao: cartao)));
    expect(find.text('Feijoada individual'), findsOneWidget);
    expect(find.textContaining('2 un'), findsOneWidget);
    expect(find.text('Total da comanda'), findsOneWidget);
    expect(find.text(r'R$ 136,00'), findsOneWidget);
  });
}
