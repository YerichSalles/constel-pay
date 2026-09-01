import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/gateway_pagamento_channel.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/resultado_transacao.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/status_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/tipo_adquirente.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const canal = MethodChannel('teste.pagamento');
  late List<MethodCall> chamadas;

  GatewayPagamentoChannel criar() => GatewayPagamentoChannel(
        adquirente: TipoAdquirente.stone,
        metodosSuportados: const {
          MetodoPagamento.credito,
          MetodoPagamento.debito,
          MetodoPagamento.pix,
        },
        canal: canal,
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

  test('envia o contrato do canal com o tipo de transacao correto', () async {
    responderCom((_) async => {'status': 'aprovado'});
    await criar().iniciarPagamento(
      chaveIdempotencia: 'chave-1',
      valorCentavos: 14960,
      metodo: MetodoPagamento.debito,
      parcelas: 1,
    );
    final argumentos = chamadas.single.arguments as Map;
    expect(chamadas.single.method, 'iniciarPagamento');
    expect(argumentos['tipoTransacao'], 120);
    expect(argumentos['chaveIdempotencia'], 'chave-1');
    expect(argumentos['valorCentavos'], 14960);
  });

  test('nenhuma adquirente exige argumento extra hoje', () async {
    responderCom((_) async => {'status': 'aprovado'});
    await criar().iniciarPagamento(
      chaveIdempotencia: 'chave-1',
      valorCentavos: 100,
      metodo: MetodoPagamento.pix,
    );
    final argumentos = chamadas.single.arguments as Map;
    expect(argumentos.keys.toSet(), {
      'chaveIdempotencia',
      'valorCentavos',
      'tipoTransacao',
      'parcelas',
    });
  });

  test('resposta aprovada vira transacao de dominio', () async {
    responderCom((_) async => {'status': 'aprovado', 'nsu': '4242'});
    final resultado = await criar().iniciarPagamento(
      chaveIdempotencia: 'chave-1',
      valorCentavos: 14960,
      metodo: MetodoPagamento.credito,
    );
    final transacao = (resultado as Sucesso<ResultadoTransacao>).valor;
    expect(transacao.status, StatusPagamento.aprovado);
    expect(transacao.nsu, '4242');
  });

  test('erro da plataforma vira Falha, nunca excecao vazando', () async {
    responderCom(
        (_) async => throw PlatformException(code: 'TERMINAL_INDISPONIVEL'));
    final resultado = await criar().iniciarPagamento(
      chaveIdempotencia: 'chave-1',
      valorCentavos: 100,
      metodo: MetodoPagamento.credito,
    );
    expect((resultado as Erro<ResultadoTransacao>).falha,
        isA<FalhaTerminalPagamento>());
  });

  test('metodo sem codigo de transacao nem chega a chamar o canal', () async {
    responderCom((_) async => {'status': 'aprovado'});
    final resultado = await criar().iniciarPagamento(
      chaveIdempotencia: 'chave-1',
      valorCentavos: 100,
      metodo: MetodoPagamento.dinheiro,
    );
    expect(
        (resultado as Erro<ResultadoTransacao>).falha, isA<FalhaValidacao>());
    expect(chamadas, isEmpty);
  });

  test('canal ausente na build generica vira FalhaTerminalPagamento', () async {
    // Sem manipulador registrado: é exatamente o que a build sem adquirente
    // embarcada produz.
    final resultado = await criar().iniciarPagamento(
      chaveIdempotencia: 'chave-1',
      valorCentavos: 100,
      metodo: MetodoPagamento.credito,
    );
    expect((resultado as Erro<ResultadoTransacao>).falha,
        isA<FalhaTerminalPagamento>());
  });
}
