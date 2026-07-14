import 'package:constel_pay/funcionalidades/encerramento/dados/adaptadores/mapeador_fatura.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/modelos/requisicao_fatura.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures_encerramento.dart';

RequisicaoFatura _montar({int trocoCentavos = 0}) {
  final configuracao = configuracaoFaturamento();
  return MapeadorFatura.montar(
    atendimentos: [atendimentoCartao512()],
    configuracao: configuracao,
    formaPagamento: configuracao.formasPagamento['dinheiro']!,
    identificador: 'Z1FTGFRQXFDGLVHTS',
    momentoUtc: DateTime.utc(2026, 7, 14, 0, 44, 25, 422),
    dataOperacional: DateTime.utc(2026, 7, 13),
    trocoCentavos: trocoCentavos,
  );
}

void main() {
  test('mapeia subtotal, serviço e total consolidados (sem recalcular)', () {
    final fatura = _montar();
    expect(fatura.subtotalCentavos, 590);
    expect(fatura.servicoCentavos, 59);
    expect(fatura.totalCentavos, 649);
    final json = fatura.paraJson();
    expect(json['subtotal'], 5.9);
    expect(json['servico'], 0.59);
    expect(json['total'], 6.49);
  });

  test('cabeçalho segue o contrato: enums, nova, rateada e sessão só com id',
      () {
    final json = _montar().paraJson();
    expect(json['nova'], false);
    expect(json['identificador'], 'Z1FTGFRQXFDGLVHTS');
    expect(json['situacao'], 210);
    expect(json['tipo'], 110);
    expect(json['natureza'], 1);
    expect(json['rateada'], true);
    expect(json['cache'], false);
    expect(json['sessao'], {'id': idSessao});
    expect(json['pago'], 0.0);
    expect(json['saldo'], 0.0);
    expect(json['pessoas'], 1);
  });

  test('referências do atendimento e da configuração vão para o cabeçalho', () {
    final json = _montar().paraJson();
    expect((json['estabelecimento'] as Map)['id'],
        'fe5b422e-bfb2-4328-83d4-7876020acef9');
    expect((json['parceiro'] as Map)['id'],
        '7e80c8f1-8c1c-407f-8f30-71a8669ab147');
    expect((json['preco'] as Map)['nome'], 'Atacado');
    expect((json['historico'] as Map)['codigo'], '3.01');
    expect((json['operacao'] as Map)['codigo'], '510');
    expect((json['moeda'] as Map)['codigo'], 'BRL');
    // Modalidade do cabeçalho é a do TERMINAL (Balcão), não a do atendimento.
    expect((json['modalidade'] as Map)['nome'], 'Balcão');
    expect((json['dispositivo'] as Map)['codigo'], '0072');
    expect(
        (json['estabelecimentoDepartamento'] as Map)['nome'], 'Almoxarifado');
  });

  test('mapeia o item a partir do resumo consolidado', () {
    final fatura = _montar();
    expect(fatura.itens.length, 1);
    final item = fatura.itens.single.paraJson();
    expect(item['sequencial'], 1);
    expect((item['item'] as Map)['nome'], 'Água com Gás');
    expect((item['resultado'] as Map)['nome'], 'Vendas');
    expect(item['valor'], 5.9);
    expect(item['quantidade'], 1.0);
    expect(item['fator'], 1.0);
    expect(item['subtotal'], 5.9);
    expect(item['servico'], 0.59);
    expect(item['total'], 6.49);
    expect(item['comissiona'], true);
    expect(item['montagem'], false);
    expect((item['ocupacao'] as Map)['id'], idAtendimento512);
  });

  test('mapeia a modalidade com referencia, numero e referenciaId separados',
      () {
    final fatura = _montar();
    expect(fatura.modalidades.length, 1);
    final modalidade = fatura.modalidades.single.paraJson();
    expect(modalidade['sequencial'], 1);
    expect((modalidade['modalidade'] as Map)['nome'], 'Cartão');
    expect(modalidade['referencia'], '512');
    expect(modalidade['numero'], 512);
    expect(modalidade['referenciaId'], idAtendimento512);
    expect(modalidade['inicio'], '2026-07-14T00:44:09.225Z');
    expect(modalidade['conclusao'], '2026-07-14T00:44:25.422Z');
    expect(modalidade['subtotal'], 5.9);
    expect(modalidade['servico'], 0.59);
    expect(modalidade['total'], 6.49);
    expect(modalidade['pessoas'], 1);
    expect((modalidade['localizador'] as Map)['codigo'], '512');
  });

  test('mapeia o pagamento à vista com forma, plano e conta da configuração',
      () {
    final fatura = _montar();
    final pagamento = fatura.pagamentos.single.paraJson();
    expect((pagamento['forma'] as Map)['nome'], 'Dinheiro');
    expect((pagamento['plano'] as Map)['nome'], 'A vista');
    expect((pagamento['conta'] as Map)['nome'], 'Caixa Miron');
    expect(pagamento['parcelas'], 1);
    expect(pagamento['edita'], false);
    expect(pagamento['subtotal'], 6.49);
    expect(pagamento['troco'], 0.0);
    expect(pagamento['total'], 6.49);
    expect(pagamento['pago'], 0.0);
    expect(pagamento['saldo'], 0.0);
    expect(pagamento['referenciaClasse'], 0);
    expect(pagamento['online'], false);
    expect(pagamento['faturaPagamentoEletronico'], isNull);
  });

  test('troco vai no pagamento sem reduzir o total da venda', () {
    final json = _montar(trocoCentavos: 351).paraJson();
    final pagamento = (json['faturaPagamentos'] as List).single as Map;
    expect(pagamento['troco'], 3.51);
    expect(pagamento['total'], 6.49);
    expect(json['total'], 6.49);
  });

  test('gera as datas do contrato: momento UTC e datas operacionais', () {
    final json = _montar().paraJson();
    expect(json['momento'], '2026-07-14T00:44:25.422Z');
    expect(json['emissao'], '2026-07-13T00:00:00.000Z');
    expect(json['competencia'], '2026-07-13T00:00:00.000Z');
    expect(json['baixa'], '2026-07-13T00:00:00.000Z');
  });

  test('faturaResultados usa o resultado da configuração SEM o nome', () {
    final json = _montar().paraJson();
    final resultado = (json['faturaResultados'] as List).single as Map;
    expect(resultado['sequencial'], 1);
    expect(resultado['percentual'], 100.0);
    final referencia = resultado['resultado'] as Map;
    expect(referencia['id'], '0699fb41-2943-417d-a2f7-017ffce3ce01');
    expect(referencia.containsKey('nome'), isFalse);
  });

  test('total da fatura corresponde à soma dos atendimentos', () {
    final fatura = _montar();
    final somaItens = fatura.itens.fold<int>(0, (s, i) => s + i.totalCentavos);
    final somaModalidades =
        fatura.modalidades.fold<int>(0, (s, m) => s + m.totalCentavos);
    expect(fatura.totalCentavos, 649);
    expect(somaItens, fatura.totalCentavos);
    expect(somaModalidades, fatura.totalCentavos);
    expect(fatura.pagamentos.single.totalCentavos, fatura.totalCentavos);
  });
}
