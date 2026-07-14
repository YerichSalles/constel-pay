import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('enum possui as etapas de saida do modo de inclusao', () {
    expect(EtapaFluxo.values, contains(EtapaFluxo.semConsumo));
    expect(EtapaFluxo.values, contains(EtapaFluxo.erroLeitura));
  });
}
