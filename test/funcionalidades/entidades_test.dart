import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/item_consumo.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:constel_pay/nucleo/configuracao/ambiente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('urlBaseAtiva respeita o ambiente (com barra final para o Dio)', () {
    const config = ConfiguracaoTerminal(
      urlBaseProducao: 'https://producao',
      urlBaseHomologacao: 'https://homologacao',
    );
    expect(config.urlBaseAtiva, 'https://homologacao/');
    expect(config.copyWith(ambiente: Ambiente.producao).urlBaseAtiva,
        'https://producao/');
  });

  test('ItemConsumo calcula o total da linha', () {
    const item = ItemConsumo(
        emoji: '🍺', nome: 'Chopp 300ml', quantidade: 2, valorCentavos: 900);
    expect(item.totalCentavos, 1800);
  });

  test('TemaPersonalizado tem as cores padrão da identidade', () {
    const tema = TemaPersonalizado();
    expect(tema.corPrimaria, '#5E52D6');
    expect(tema.corSecundaria, '#FFD166');
    expect(tema.corFundo, '#F7F7FB');
    expect(tema.corBotoes, '#5E52D6');
  });

  test('MetodoPagamento tem os 7 metodos com rotulos', () {
    expect(MetodoPagamento.values, hasLength(7));
    expect(MetodoPagamento.pix.rotulo, 'Pix');
    expect(MetodoPagamento.credito.rotulo, 'Crédito');
  });
}
