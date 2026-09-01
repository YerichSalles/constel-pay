import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/componentes/card_nfc.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/repositorios/gateway_nfc.dart';
import 'package:constel_pay/l10n/app_localizations.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _GatewayNfcFake implements GatewayNfc {
  _GatewayNfcFake(this.respostas);

  final List<Resultado<String>> respostas;
  int chamadas = 0;
  int cancelamentos = 0;

  @override
  Future<Resultado<String>> ler() async {
    final indice =
        chamadas < respostas.length ? chamadas : respostas.length - 1;
    chamadas++;
    return respostas[indice];
  }

  @override
  Future<void> cancelar() async => cancelamentos++;
}

Widget _app(_GatewayNfcFake gateway, Widget filho) {
  return ProviderScope(
    overrides: [provedorGatewayNfc.overrideWithValue(gateway)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: filho),
    ),
  );
}

void main() {
  testWidgets('arma ao entrar ativo e chama aoLer com o identificador lido',
      (tester) async {
    final gateway = _GatewayNfcFake([const Sucesso('A1B2C3')]);
    String? lido;
    await tester.pumpWidget(_app(
        gateway,
        CardNfc(
          ativo: true,
          aoLer: (identificador) => lido = identificador,
        )));
    await tester.pump();
    expect(lido, 'A1B2C3');
    expect(gateway.chamadas, 1);
  });

  testWidgets('nao arma quando inativo', (tester) async {
    final gateway = _GatewayNfcFake([const Sucesso('A1B2C3')]);
    await tester.pumpWidget(_app(
        gateway,
        CardNfc(
          ativo: false,
          aoLer: (_) {},
        )));
    await tester.pump();
    expect(gateway.chamadas, 0);
  });

  testWidgets('rearma automaticamente apos erro de leitura', (tester) async {
    final gateway = _GatewayNfcFake([
      const Erro(FalhaTerminalPagamento('Não foi possível ler o cartão.')),
      const Sucesso('XYZ999'),
    ]);
    String? lido;
    await tester.pumpWidget(_app(
        gateway,
        CardNfc(
          ativo: true,
          aoLer: (identificador) => lido = identificador,
        )));
    await tester.pump();
    expect(gateway.chamadas, 1);
    expect(lido, isNull);
    expect(find.text('Não foi possível ler o cartão.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(gateway.chamadas, 2);
    expect(lido, 'XYZ999');
  });

  testWidgets('cancela a leitura ao ficar inativo', (tester) async {
    final gateway = _GatewayNfcFake([const Sucesso('NUNCA-CHEGA')]);
    final chave = GlobalKey();
    await tester.pumpWidget(
        _app(gateway, CardNfc(key: chave, ativo: true, aoLer: (_) {})));
    await tester.pump();

    await tester.pumpWidget(
        _app(gateway, CardNfc(key: chave, ativo: false, aoLer: (_) {})));
    await tester.pump();

    expect(gateway.cancelamentos, greaterThanOrEqualTo(1));
  });
}
