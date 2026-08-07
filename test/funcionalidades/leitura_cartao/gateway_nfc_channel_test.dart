import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/gateway_nfc_channel.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const canal = MethodChannel('teste.nfc');
  late List<MethodCall> chamadas;

  GatewayNfcChannel criar({Duration? tempoLimite}) => GatewayNfcChannel(
        canal: canal,
        tempoLimite: tempoLimite ?? const Duration(seconds: 1),
      );

  void responderCom(Future<Object?> Function(MethodCall) manipulador) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canal, (chamada) {
      chamadas.add(chamada);
      return manipulador(chamada);
    });
  }

  setUp(() => chamadas = []);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canal, null);
  });

  test('leitura com sucesso devolve o identificador', () async {
    responderCom((_) async => {'identificador': 'A1B2C3D4'});
    final resultado = await criar().ler();
    expect(chamadas.single.method, 'lerNfc');
    expect((resultado as Sucesso<String>).valor, 'A1B2C3D4');
  });

  test('SEM_LEITOR vira FalhaTerminalPagamento', () async {
    responderCom((_) async => throw PlatformException(
        code: 'SEM_LEITOR', message: 'Sem leitor NFC.'));
    final resultado = await criar().ler();
    final falha = (resultado as Erro<String>).falha;
    expect(falha, isA<FalhaTerminalPagamento>());
    expect(falha.mensagem, 'Sem leitor NFC.');
  });

  test('TEMPO_ESGOTADO vira FalhaTimeout', () async {
    responderCom((_) async => throw PlatformException(
        code: 'TEMPO_ESGOTADO', message: 'Tempo esgotado.'));
    final resultado = await criar().ler();
    expect((resultado as Erro<String>).falha, isA<FalhaTimeout>());
  });

  test('CANCELADO vira FalhaTerminalPagamento', () async {
    responderCom((_) async => throw PlatformException(code: 'CANCELADO'));
    final resultado = await criar().ler();
    expect((resultado as Erro<String>).falha, isA<FalhaTerminalPagamento>());
  });

  test('ERRO_LEITURA vira FalhaTerminalPagamento', () async {
    responderCom((_) async => throw PlatformException(code: 'ERRO_LEITURA'));
    final resultado = await criar().ler();
    expect((resultado as Erro<String>).falha, isA<FalhaTerminalPagamento>());
  });

  test('timeout do lado Dart vira FalhaTimeout, nunca excecao vazando',
      () async {
    responderCom((_) async {
      await Future<void>.delayed(const Duration(seconds: 2));
      return {'identificador': 'TARDE'};
    });
    final resultado =
        await criar(tempoLimite: const Duration(milliseconds: 50)).ler();
    expect((resultado as Erro<String>).falha, isA<FalhaTimeout>());
  });

  test('canal ausente na build generica vira FalhaTerminalPagamento', () async {
    // Sem manipulador registrado: é exatamente o que a build sem adquirente
    // embarcada produz (MissingPluginException).
    final resultado = await criar().ler();
    expect((resultado as Erro<String>).falha, isA<FalhaTerminalPagamento>());
  });

  test('cancelar nunca lança mesmo sem canal', () async {
    await expectLater(criar().cancelar(), completes);
  });
}
