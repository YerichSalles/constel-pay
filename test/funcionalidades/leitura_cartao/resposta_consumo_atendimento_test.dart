import 'dart:convert';

import 'package:constel_pay/funcionalidades/leitura_cartao/dados/modelos/resposta_consumo_atendimento.dart';
import 'package:flutter_test/flutter_test.dart';

// Payload real capturado do endpoint venda/atendimento/colecao da APL
// (2026-07-12), enxugado dos ramos ignorados pelo mapper (resumos,
// agrupamentos, parceiro, preço etc. permanecem para provar tolerância).
const _payloadReal = r'''
[
  {
    "classe": 1600,
    "id": "5c76dab9-3cc6-49e2-ab69-ee8270498049",
    "codigo": "0010030",
    "nome": "Mesa 01",
    "situacao": 20,
    "tipo": 110,
    "referencia": "01",
    "estabelecimento": {
      "id": "fe5b422e-bfb2-4328-83d4-7876020acef9",
      "nome": "Dionísio Torres"
    },
    "parceiro": {"id": "7e80c8f1", "codigo": "000001", "nome": "(Padrão)"},
    "preco": {"id": "ed90534c", "codigo": "01", "nome": "Atacado"},
    "modalidade": {"id": "7acbf6ed", "nome": "Mesa", "tipo": 110},
    "localizador": {"id": "0cf76e1a", "codigo": "01", "nome": "01"},
    "localizacao": null,
    "inicio": "2026-07-10T00:44:04.695Z",
    "atualizacao": "2026-07-10T00:44:04.695Z",
    "conclusao": null,
    "subtotal": 10,
    "acrescimo": 0,
    "servico": 1,
    "frete": 0,
    "servicoPercentual": 10,
    "desconto": 0,
    "abatimento": 0,
    "deducao": 0,
    "total": 11,
    "pago": 0,
    "saldo": 11,
    "consumo": 10,
    "pessoas": 1,
    "ocupado": true,
    "atendimentoEventos": [],
    "atendimentoComandas": [
      {
        "_id": "6a5040541eab43ee210b45aa",
        "id": "f247e25d-160a-4289-979d-34e886732443",
        "inclusao": "2026-07-10T00:44:04.767Z",
        "codigo": "0010033",
        "numero": 10033,
        "situacao": 20,
        "procedimento": 10,
        "usuario": {"id": "8125413e", "nome": "Ivan Noé"}
      }
    ],
    "atendimentoItens": [
      {
        "id": "00bcc30d-375c-44d1-a824-966ccee432b9",
        "inclusao": "2026-07-10T00:44:04.799Z",
        "sequencial": 1,
        "situacao": 20,
        "item": {
          "id": "1ce403e1",
          "codigo": "0002",
          "nome": "Bacon Burger",
          "tipo": 0,
          "fracionamento": false
        },
        "preco": {"id": "ed90534c", "nome": "Preço"},
        "estabelecimentoDepartamento": {"id": "4e0fa4ec", "nome": "Cozinha"},
        "valor": 10,
        "quantidade": 1,
        "medida": "UN",
        "subtotal": 10,
        "acrescimo": 0,
        "servico": 1,
        "desconto": 0,
        "total": 11,
        "promocao": null,
        "remanescente": 1,
        "producaoSituacao": 10,
        "comanda_Id": "6a5040541eab43ee210b45aa",
        "comandaId": "f247e25d-160a-4289-979d-34e886732443",
        "comandaCodigo": "0010033",
        "selecionado": false
      }
    ],
    "atendimentoResumos": [{"valor": 10, "quantidade": 1}],
    "atendimentoAgrupamentos": [{"valor": 10, "quantidade": 1}],
    "sessao": {
      "id": "54f15f14-70c1-4b9d-b3d3-898b25e3b034",
      "codigo": "0003449"
    }
  }
]
''';

void main() {
  test('payload real mapeia atendimento completo', () {
    final lista = RespostaConsumoAtendimento.paraLista(
        jsonDecode(_payloadReal) as List<dynamic>);
    expect(lista.length, 1);

    final atendimento = lista.first;
    expect(atendimento.id, '5c76dab9-3cc6-49e2-ab69-ee8270498049');
    expect(atendimento.codigo, '0010030');
    expect(atendimento.nome, 'Mesa 01');
    expect(atendimento.referencia, '01');
    expect(atendimento.situacao, 20);
    expect(atendimento.inicio, DateTime.parse('2026-07-10T00:44:04.695Z'));
    expect(atendimento.conclusao, isNull);
    expect(atendimento.subtotalCentavos, 1000);
    expect(atendimento.servicoCentavos, 100);
    expect(atendimento.servicoPercentual, 10);
    expect(atendimento.descontoCentavos, 0);
    expect(atendimento.totalCentavos, 1100);
    expect(atendimento.pagoCentavos, 0);
    expect(atendimento.saldoCentavos, 1100);
    expect(atendimento.sessaoId, '54f15f14-70c1-4b9d-b3d3-898b25e3b034');
    expect(atendimento.sessaoCodigo, '0003449');

    expect(atendimento.comandas.length, 1);
    final comanda = atendimento.comandas.first;
    expect(comanda.id, 'f247e25d-160a-4289-979d-34e886732443');
    expect(comanda.codigo, '0010033');
    expect(comanda.numero, 10033);
    expect(comanda.situacao, 20);

    expect(atendimento.itens.length, 1);
    final item = atendimento.itens.first;
    expect(item.id, '00bcc30d-375c-44d1-a824-966ccee432b9');
    expect(item.sequencial, 1);
    expect(item.nome, 'Bacon Burger');
    expect(item.codigo, '0002');
    expect(item.quantidade, 1);
    expect(item.medida, 'UN');
    expect(item.valorCentavos, 1000);
    expect(item.subtotalCentavos, 1000);
    expect(item.totalCentavos, 1100);
    expect(item.comandaId, comanda.id, reason: 'item liga à comanda pelo id');
    expect(item.comandaCodigo, comanda.codigo);
  });

  test('conversão de dinheiro arredonda artefatos de ponto flutuante', () {
    final lista = RespostaConsumoAtendimento.paraLista([
      {'subtotal': 4.9, 'total': 5.390000000000001, 'saldo': 5.39},
    ]);
    expect(lista.first.subtotalCentavos, 490);
    expect(lista.first.totalCentavos, 539);
    expect(lista.first.saldoCentavos, 539);
  });

  test('array vazio devolve lista vazia', () {
    expect(RespostaConsumoAtendimento.paraLista(const []), isEmpty);
  });

  test('atendimento sem sub-objetos não lança e usa padrões', () {
    final lista = RespostaConsumoAtendimento.paraLista([
      <String, dynamic>{},
    ]);
    final atendimento = lista.first;
    expect(atendimento.id, '');
    expect(atendimento.nome, '');
    expect(atendimento.situacao, 0);
    expect(atendimento.inicio, isNull);
    expect(atendimento.saldoCentavos, 0);
    expect(atendimento.sessaoId, '');
    expect(atendimento.comandas, isEmpty);
    expect(atendimento.itens, isEmpty);
  });

  test('elementos não-mapa e item sem sub-objeto item são tolerados', () {
    final lista = RespostaConsumoAtendimento.paraLista([
      'lixo',
      {
        'id': 'a1',
        'atendimentoItens': [
          {'id': 'i1', 'valor': 2.5}
        ],
      },
    ]);
    expect(lista.length, 1);
    expect(lista.first.itens.first.nome, '');
    expect(lista.first.itens.first.valorCentavos, 250);
  });
}
