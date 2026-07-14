import 'package:constel_pay/funcionalidades/encerramento/dados/adaptadores/derivador_configuracao_faturamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures_encerramento.dart';

void main() {
  test('deriva a configuração completa de uma fatura real do retaguarda', () {
    final configuracao = DerivadorConfiguracaoFaturamento.derivar(
      [faturaCompletaParaDerivacao()],
      sessaoId: idSessao,
    );
    expect(configuracao, isNotNull);
    expect(configuracao!.sessaoOrigem, idSessao);
    expect(configuracao.historico['codigo'], '3.01');
    expect(configuracao.operacao['codigo'], '510');
    expect(configuracao.moeda['codigo'], 'BRL');
    expect(configuracao.modalidade['nome'], 'Balcão');
    expect(configuracao.resultado['nome'], 'Vendas');
    expect(configuracao.dispositivo['codigo'], '0072');
    expect(configuracao.estabelecimentoDepartamento['nome'], 'Almoxarifado');
  });

  test('reconhece as formas pela espécie: 1=dinheiro, 230=pix', () {
    final configuracao = DerivadorConfiguracaoFaturamento.derivar(
      [faturaCompletaParaDerivacao()],
      sessaoId: idSessao,
    )!;
    expect(configuracao.completaPara(MetodoPagamento.dinheiro), isTrue);
    expect(configuracao.completaPara(MetodoPagamento.pix), isTrue);
    expect(configuracao.completaPara(MetodoPagamento.credito), isFalse);
    final pix = configuracao.formasPagamento['pix']!;
    expect(pix.forma['nome'], 'Recebimento em PIX');
    expect(pix.conta['nome'], 'Banco do Brasil Aldeota');
    final dinheiro = configuracao.formasPagamento['dinheiro']!;
    expect(dinheiro.conta['nome'], 'Caixa Miron');
  });

  test('ignora fatura que não é venda e espécie desconhecida', () {
    final compra = faturaCompletaParaDerivacao()..['tipo'] = 10;
    expect(
        DerivadorConfiguracaoFaturamento.derivar([compra], sessaoId: idSessao),
        isNull);

    final especieEstranha = faturaCompletaParaDerivacao();
    for (final pagamento
        in (especieEstranha['faturaPagamentos'] as List).cast<Map>()) {
      pagamento['especie'] = 999;
      (pagamento['forma'] as Map)['especie'] = 999;
    }
    expect(
        DerivadorConfiguracaoFaturamento.derivar([especieEstranha],
            sessaoId: idSessao),
        isNull,
        reason: 'nenhuma forma reconhecida → sem configuração');
  });

  test('usa a venda mais recente como base e junta formas de várias', () {
    final antiga = faturaCompletaParaDerivacao()
      ..['inclusao'] = '2026-07-10T10:00:00Z';
    // Mais recente só com dinheiro e outro dispositivo.
    final recente = faturaCompletaParaDerivacao()
      ..['inclusao'] = '2026-07-14T18:00:00Z'
      ..['dispositivo'] = {'id': 'disp-novo', 'codigo': '0099', 'nome': 'CX2'}
      ..['faturaPagamentos'] =
          (faturaCompletaParaDerivacao()['faturaPagamentos'] as List)
              .sublist(0, 1);
    final configuracao = DerivadorConfiguracaoFaturamento.derivar(
      [antiga, recente],
      sessaoId: idSessao,
    )!;
    expect(configuracao.dispositivo['codigo'], '0099',
        reason: 'base = venda mais recente');
    expect(configuracao.completaPara(MetodoPagamento.pix), isTrue,
        reason: 'forma PIX vem da fatura antiga');
  });
}
