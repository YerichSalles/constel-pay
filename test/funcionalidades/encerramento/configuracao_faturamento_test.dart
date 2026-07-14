import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/configuracao_faturamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures_encerramento.dart';

void main() {
  test('JSON completo carrega e fica pronto para dinheiro e pix', () {
    final configuracao =
        ConfiguracaoFaturamento.deJson(configuracaoFaturamentoJson());
    expect(configuracao, isNotNull);
    expect(configuracao!.completaPara(MetodoPagamento.dinheiro), isTrue);
    expect(configuracao.completaPara(MetodoPagamento.pix), isTrue);
    expect(configuracao.completaPara(MetodoPagamento.credito), isFalse);
    expect(configuracao.historico['codigo'], '3.01');
  });

  test('sem os objetos básicos com id o JSON é rejeitado', () {
    expect(ConfiguracaoFaturamento.deJson(const {}), isNull);
    final semDispositivo = configuracaoFaturamentoJson()..remove('dispositivo');
    expect(ConfiguracaoFaturamento.deJson(semDispositivo), isNull);
  });

  test('forma sem conta não habilita o método', () {
    final json = configuracaoFaturamentoJson();
    ((json['formasPagamento'] as Map)['dinheiro'] as Map).remove('conta');
    final configuracao = ConfiguracaoFaturamento.deJson(json)!;
    expect(configuracao.completaPara(MetodoPagamento.dinheiro), isFalse);
    expect(configuracao.completaPara(MetodoPagamento.pix), isTrue);
  });

  test('roda ida e volta pelo JSON', () {
    final configuracao =
        ConfiguracaoFaturamento.deJson(configuracaoFaturamentoJson())!;
    final recuperada = ConfiguracaoFaturamento.deJson(configuracao.paraJson())!;
    expect(recuperada.moeda, configuracao.moeda);
    expect(recuperada.formasPagamento.keys, configuracao.formasPagamento.keys);
    expect(recuperada.formasPagamento['dinheiro']!.conta,
        configuracao.formasPagamento['dinheiro']!.conta);
  });
}
