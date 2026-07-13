import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/repositorios/repositorio_pagamento_impl.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/dados_pix.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/status_pagamento.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter_test/flutter_test.dart';

Pagamento _pagamento(
  String id, {
  int valorCentavos = 13600,
  int servicoCentavos = 1360,
  int descontoCentavos = 0,
  int totalCentavos = 14960,
}) =>
    Pagamento(
      id: id,
      valorCentavos: valorCentavos,
      servicoCentavos: servicoCentavos,
      descontoCentavos: descontoCentavos,
      totalCentavos: totalCentavos,
      metodo: MetodoPagamento.pix,
      status: StatusPagamento.processando,
      criadoEm: DateTime(2026, 7, 6),
      atualizadoEm: DateTime(2026, 7, 6),
      comandaIds: const ['c1'],
    );

void main() {
  late FontePagamentoMock fonte;
  late RepositorioPagamentoImpl repositorio;

  setUp(() {
    fonte = FontePagamentoMock(atraso: Duration.zero);
    repositorio = RepositorioPagamentoImpl(fonte);
  });

  test('gerarPix devolve dados com o valor e expiracao futura', () async {
    final casoUso = CasoUsoGerarPix(repositorio);
    final resultado = await casoUso.executar(
        chaveIdempotencia: 'chave-1', valorCentavos: 14960);
    final dados = (resultado as Sucesso<DadosPix>).valor;
    expect(dados.valorCentavos, 14960);
    expect(dados.copiaCola, isNotEmpty);
    expect(dados.qrCode, dados.copiaCola);
    expect(dados.expiraEm.isAfter(DateTime.now()), isTrue);
  });

  test('gerarPix com valor zero devolve FalhaValidacao', () async {
    final casoUso = CasoUsoGerarPix(repositorio);
    final resultado =
        await casoUso.executar(chaveIdempotencia: 'chave-1', valorCentavos: 0);
    expect(resultado, isA<Erro<DadosPix>>());
    expect((resultado as Erro<DadosPix>).falha, isA<FalhaValidacao>());
  });

  test('processar aprova o pagamento', () async {
    final casoUso = CasoUsoProcessarPagamento(repositorio);
    final resultado = await casoUso.executar(_pagamento('pag-1'));
    final aprovado = (resultado as Sucesso<Pagamento>).valor;
    expect(aprovado.status, StatusPagamento.aprovado);
    expect(aprovado.totalCentavos, 14960);
  });

  test('processar recusa total acima de subtotal + servico - desconto',
      () async {
    final casoUso = CasoUsoProcessarPagamento(repositorio);
    final resultado = await casoUso.executar(
        _pagamento('pag-inflado', descontoCentavos: 500, totalCentavos: 14960));
    expect((resultado as Erro<Pagamento>).falha, isA<FalhaValidacao>());
    expect(fonte.execucoesProcessar, 0);
  });

  test(
      'processar aceita total menor que o teto (desconto ou pagamento parcial)',
      () async {
    final casoUso = CasoUsoProcessarPagamento(repositorio);
    final resultado = await casoUso.executar(_pagamento('pag-desconto',
        descontoCentavos: 500, totalCentavos: 14460));
    expect((resultado as Sucesso<Pagamento>).valor.status,
        StatusPagamento.aprovado);
  });

  test('processar e idempotente: mesmo id nao reprocessa', () async {
    final casoUso = CasoUsoProcessarPagamento(repositorio);
    final primeiro = await casoUso.executar(_pagamento('pag-1'));
    final segundo = await casoUso.executar(_pagamento('pag-1'));
    expect((primeiro as Sucesso<Pagamento>).valor,
        (segundo as Sucesso<Pagamento>).valor);
    expect(fonte.execucoesProcessar, 1);
  });

  test('consultarStatus devolve aprovado apos processar e aguardando antes',
      () {
    expect(fonte.consultarStatus('nao-existe'), StatusPagamento.aguardando);
  });
}
