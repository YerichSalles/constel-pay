import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_iniciar_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/parametros_adquirente.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/resultado_transacao.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/status_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/tipo_adquirente.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/repositorios/gateway_pagamento.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gateway falso que registra o que recebeu: o caso de uso precisa provar que
/// só chega ao terminal o que passou pelas validações.
class _GatewayFake implements GatewayPagamento {
  _GatewayFake({this.metodosSuportados = const {MetodoPagamento.credito}});

  @override
  final Set<MetodoPagamento> metodosSuportados;

  @override
  TipoAdquirente get adquirente => TipoAdquirente.stone;

  int chamadas = 0;
  String? ultimaChave;
  int? ultimasParcelas;

  @override
  Future<Resultado<ResultadoTransacao>> iniciarPagamento({
    required String chaveIdempotencia,
    required int valorCentavos,
    required MetodoPagamento metodo,
    int parcelas = 1,
    ParametrosAdquirente parametros = const ParametrosAdquirente.nenhum(),
  }) async {
    chamadas++;
    ultimaChave = chaveIdempotencia;
    ultimasParcelas = parcelas;
    return Sucesso(ResultadoTransacao(
      status: StatusPagamento.aprovado,
      metodo: metodo,
      valorCentavos: valorCentavos,
      parcelas: parcelas,
    ));
  }
}

void main() {
  late _GatewayFake gateway;
  late CasoUsoIniciarPagamento casoUso;

  setUp(() {
    gateway = _GatewayFake();
    casoUso = CasoUsoIniciarPagamento(gateway);
  });

  test('encaminha ao gateway e devolve a transacao aprovada', () async {
    final resultado = await casoUso.executar(
      chaveIdempotencia: 'chave-1',
      valorCentavos: 14960,
      metodo: MetodoPagamento.credito,
    );
    final transacao = (resultado as Sucesso<ResultadoTransacao>).valor;
    expect(transacao.status, StatusPagamento.aprovado);
    expect(transacao.valorCentavos, 14960);
    expect(gateway.ultimaChave, 'chave-1');
    expect(gateway.ultimasParcelas, 1);
  });

  test('chave de idempotencia vazia nao chega ao terminal', () async {
    final resultado = await casoUso.executar(
      chaveIdempotencia: '  ',
      valorCentavos: 14960,
      metodo: MetodoPagamento.credito,
    );
    expect(
        (resultado as Erro<ResultadoTransacao>).falha, isA<FalhaValidacao>());
    expect(gateway.chamadas, 0);
  });

  test('valor zero ou negativo nao chega ao terminal', () async {
    for (final valor in [0, -1]) {
      final resultado = await casoUso.executar(
        chaveIdempotencia: 'chave-1',
        valorCentavos: valor,
        metodo: MetodoPagamento.credito,
      );
      expect(
          (resultado as Erro<ResultadoTransacao>).falha, isA<FalhaValidacao>());
    }
    expect(gateway.chamadas, 0);
  });

  test('metodo fora dos suportados pela adquirente devolve FalhaValidacao',
      () async {
    final resultado = await casoUso.executar(
      chaveIdempotencia: 'chave-1',
      valorCentavos: 14960,
      metodo: MetodoPagamento.voucher,
    );
    expect(
        (resultado as Erro<ResultadoTransacao>).falha, isA<FalhaValidacao>());
    expect(gateway.chamadas, 0);
  });

  test('parcelas fora da faixa nao chegam ao terminal', () async {
    for (final parcelas in [0, -1, 13]) {
      final resultado = await casoUso.executar(
        chaveIdempotencia: 'chave-1',
        valorCentavos: 14960,
        metodo: MetodoPagamento.credito,
        parcelas: parcelas,
      );
      expect(
          (resultado as Erro<ResultadoTransacao>).falha, isA<FalhaValidacao>());
    }
    expect(gateway.chamadas, 0);
  });

  test('gateway sem metodos suportados recusa tudo (build generica)', () async {
    final casoUsoGenerico =
        CasoUsoIniciarPagamento(_GatewayFake(metodosSuportados: const {}));
    for (final metodo in MetodoPagamento.values) {
      final resultado = await casoUsoGenerico.executar(
        chaveIdempotencia: 'chave-1',
        valorCentavos: 14960,
        metodo: metodo,
      );
      expect(
          (resultado as Erro<ResultadoTransacao>).falha, isA<FalhaValidacao>());
    }
  });
}
