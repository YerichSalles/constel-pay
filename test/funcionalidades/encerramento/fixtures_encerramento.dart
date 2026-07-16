/// Fixtures do cenário real observado no caixa (ConstelPDV, 2026-07-13):
/// cartão 512, Água com Gás, subtotal 5,90 + serviço 0,59 = total 6,49.
library;

import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/configuracao_faturamento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/modelos/resposta_consumo_atendimento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/atendimento.dart';

const String idAtendimento512 = 'dd222fda-aa10-4ab8-9ee3-9a40ae3cbbdb';
const String idSessao = 'e330e839-0e9c-4490-b947-c330cff1317a';
const String codigoSessao = '0003479';

/// Dispositivo do terminal (DPNOE) e formas do cadastro — fontes reais da
/// configuração de faturamento, sem depender de venda anterior.
const String idDispositivoTerminal = '179d91fe-984e-4323-96bc-c95b64cfce44';
const String idEstabelecimento = 'fe5b422e-bfb2-4328-83d4-7876020acef9';
const String idFormaPix = '530feff8-3d7f-4168-b713-35ffc36e33f3';
const String idFormaDinheiro = 'ff01756f-df45-40de-bf8e-75b595abcf88';

/// JSON do atendimento como `venda/atendimento/colecao` devolve.
Map<String, dynamic> atendimentoBrutoCartao512() => {
      'classe': 1600,
      'id': idAtendimento512,
      'codigo': '0010006',
      'nome': 'Cartão 512',
      'situacao': 20,
      'estabelecimento': {
        'situacao': 0,
        'id': 'fe5b422e-bfb2-4328-83d4-7876020acef9',
        'nome': 'Dionísio Torres',
      },
      'parceiro': {
        'situacao': 0,
        'padrao': true,
        'id': '7e80c8f1-8c1c-407f-8f30-71a8669ab147',
        'codigo': '000001',
        'nome': '(Padrão)',
      },
      'preco': {
        'id': 'ed90534c-830a-47fc-9c7b-fc42c322626e',
        'codigo': '01',
        'nome': 'Atacado',
      },
      'modalidade': {
        'situacao': 0,
        'tipo': 120,
        'id': '7ff01196-f7b5-49c0-8333-ae4749dfeb9d',
        'nome': 'Cartão',
      },
      'corretor': {
        'situacao': 0,
        'id': '7e80c8f1-8c1c-407f-8f30-71a8669ab147',
        'nome': '(Padrão)',
      },
      'vendedor': {
        'situacao': 0,
        'id': '7717bd15-a96b-4930-8c2f-3454a60ddf5f',
        'nome': 'Ivan Noe',
      },
      'localizador': {
        'numero': 0,
        'situacao': 0,
        'referencia': '05637FDE6503E9',
        'id': 'bccd11a9-604b-47a8-a71c-a0922fb2b385',
        'codigo': '512',
      },
      'tipo': 120,
      'referencia': '512',
      'numero': 0,
      'inicio': '2026-07-14T00:44:09.225Z',
      'quantidade': 1,
      'subtotal': 5.9,
      'acrescimo': 0.0,
      'frete': 0.0,
      'servico': 0.59,
      'servicoPercentual': 10.0,
      'desconto': 0.0,
      'abatimento': 0.0,
      'deducao': 0.0,
      'total': 6.49,
      'pago': 0.0,
      'saldo': 6.49,
      'pessoas': 1,
      'fatura': null,
      'sessao': {'id': idSessao, 'codigo': codigoSessao},
      'atendimentoResumos': [
        {
          'modalidade': {
            'situacao': 0,
            'tipo': 120,
            'id': '7ff01196-f7b5-49c0-8333-ae4749dfeb9d',
            'nome': 'Cartão',
          },
          'item': {
            'situacao': 0,
            'id': '83d2de05-f0b6-4a6b-ab4d-999486bd568d',
            'codigo': '105308',
            'nome': 'Água com Gás',
          },
          'corretor': {
            'id': '7e80c8f1-8c1c-407f-8f30-71a8669ab147',
            'nome': '(Padrão)',
          },
          'vendedor': {
            'id': '7717bd15-a96b-4930-8c2f-3454a60ddf5f',
            'nome': 'Ivan Noe',
          },
          'preco': {
            'id': 'ed90534c-830a-47fc-9c7b-fc42c322626e',
            'nome': 'Preço',
          },
          'estabelecimentoDepartamento': {
            'situacao': 0,
            'id': 'ef58a474-f5ea-4657-a3bd-d48833ee2c01',
            'nome': 'Almoxarifado',
          },
          'comissiona': true,
          'valor': 5.9,
          'quantidade': 1.0,
          'medida': 'UN',
          'subtotal': 5.9,
          'acrescimo': 0.0,
          'frete': 0.0,
          'servico': 0.59,
          'desconto': 0.0,
          'abatimento': 0.0,
          'total': 6.49,
          'ocupacao': {'situacao': 0, 'tipo': 0, 'id': idAtendimento512},
        }
      ],
      'atendimentoComandas': [
        {
          'codigo': '0010006',
          'numero': 10006,
          'situacao': 20,
          'id': 'a6c48099-cd55-4039-b3f5-cd93fd7bd994',
        }
      ],
      'atendimentoItens': [
        {
          'sequencial': 1,
          'situacao': 20,
          'item': {
            'id': '83d2de05-f0b6-4a6b-ab4d-999486bd568d',
            'codigo': '105308',
            'nome': 'Água com Gás',
          },
          'valor': 5.9,
          'quantidade': 1.0,
          'medida': 'UN',
          'subtotal': 5.9,
          'servico': 0.59,
          'total': 6.49,
          'comandaId': 'a6c48099-cd55-4039-b3f5-cd93fd7bd994',
          'comandaCodigo': '0010006',
          'id': '572f64f1-68ac-4c5e-bc6d-5caa69ca3d4a',
        }
      ],
    };

Atendimento atendimentoCartao512() =>
    RespostaConsumoAtendimento.paraLista([atendimentoBrutoCartao512()]).single;

/// Configuração de faturamento equivalente à do caixa do log.
Map<String, dynamic> configuracaoFaturamentoJson() => {
      'historico': {
        'id': 'ca40f80c-f6f9-4b76-9149-1ad8e2a9203d',
        'codigo': '3.01',
        'nome': 'Venda',
      },
      'operacao': {
        'id': '4fd3c889-1fb9-4ede-abcc-92cf4c8f1d23',
        'codigo': '510',
        'nome': 'Venda CST 102 - Simples Nacional',
      },
      'moeda': {
        'id': 'bd8acb0a-6206-462c-81ce-9cc76b18f528',
        'codigo': 'BRL',
        'nome': 'Real Brasileiro',
      },
      'dispositivo': {
        'situacao': 0,
        'id': '39dfe2d9-ea47-4a8b-b5ed-76a03d09ca7a',
        'codigo': '0072',
        'nome': 'NOE CAIXA',
      },
      'dispositivoOrigem': idDispositivoTerminal,
      'formasPagamento': {
        'dinheiro': {
          'forma': {
            'situacao': 0,
            'especie': 1,
            'id': 'ff01756f-df45-40de-bf8e-75b595abcf88',
            'codigo': '1',
            'nome': 'Dinheiro',
          },
          'plano': {
            'parcelas': 0,
            'id': '71a8ab3f-dd2e-496a-9137-f63c37d0eb8f',
            'nome': 'A vista',
          },
          'conta': {
            'analitica': true,
            'id': '20e4d490-4152-4453-b302-0f5f5fa487b8',
            'codigo': '1.1.01.01.03',
            'nome': 'Caixa Miron',
          },
        },
        'pix': {
          'forma': {'id': 'forma-pix', 'nome': 'PIX'},
          'plano': {'id': '71a8ab3f-dd2e-496a-9137-f63c37d0eb8f'},
          'conta': {'id': '20e4d490-4152-4453-b302-0f5f5fa487b8'},
        },
      },
    };

ConfiguracaoFaturamento configuracaoFaturamento() =>
    ConfiguracaoFaturamento.deJson(configuracaoFaturamentoJson())!;

/// Resposta real (resumida) do `POST movimento/fatura`: fatura paga.
Map<String, dynamic> respostaFaturaPaga(String identificador) => {
      'nova': false,
      'identificador': identificador,
      'situacao': 340,
      'tipo': 110,
      'natureza': 1,
      'total': 6.49,
      'pago': 6.49,
      'saldo': 0,
      'codigo': 'VN0051625',
      'id': 'e0c2eafc-493f-40a6-a3b9-eddfff7b1522',
    };

/// Documento do dispositivo como `estrutura/dispositivo/<id>` devolve: o
/// cabeçalho fiscal já configurado no terminal (histórico, operação, moeda,
/// dispositivo, departamento) — não depende de venda anterior.
Map<String, dynamic> dispositivoDocJson() => {
      'id': idDispositivoTerminal,
      'codigo': '0048',
      'nome': 'DPNOE',
      'caixa': true,
      'conta': {
        'id': 'b715b23a-e4ff-4fe0-94a7-75dfa425c5c7',
        'codigo': '1.1.01.01.05',
        'nome': 'Caixa Guilherme',
      },
      'estabelecimento': {
        'id': idEstabelecimento,
        'codigo': '01',
        'nome': 'Dionísio Torres',
      },
      'estabelecimentoDepartamento': {
        'id': 'ef58a474-f5ea-4657-a3bd-d48833ee2c01',
        'nome': 'Almoxarifado',
      },
      'historico': {
        'id': 'ca40f80c-f6f9-4b76-9149-1ad8e2a9203d',
        'codigo': '3.01',
        'nome': 'Venda',
      },
      'moeda': {
        'id': 'bd8acb0a-6206-462c-81ce-9cc76b18f528',
        'codigo': 'BRL',
        'nome': 'Real Brasileiro',
      },
      'operacao': {
        'id': '339644e7-38d7-4e9b-b4c2-c67d7a4024c3',
        'codigo': '519',
        'nome': 'CST 00 - ICMS - IPI - PIS - COFINS - Regime Normal',
      },
      'preco': {
        'id': 'ed90534c-830a-47fc-9c7b-fc42c322626e',
        'codigo': '01',
        'nome': 'Atacado',
      },
    };

/// Lista de formas como `financeiro/forma?texto=` devolve (enxuta): id,
/// código, nome, situação e espécie. Inclui uma PIX inativa para provar que
/// só a ativa é escolhida.
List<Map<String, dynamic>> formasListaJson() => [
      {
        'id': idFormaDinheiro,
        'codigo': '1',
        'nome': 'Dinheiro',
        'situacao': 1,
        'especie': 1,
      },
      {
        'id': idFormaPix,
        'codigo': '12',
        'nome': 'Recebimento em PIX',
        'situacao': 1,
        'especie': 230,
      },
      {
        'id': 'forma-pix-inativa',
        'codigo': '9',
        'nome': 'PIX desativado',
        'situacao': 90,
        'especie': 230,
      },
    ];

/// Detalhe de uma forma como `financeiro/forma/<id>` devolve: a forma se
/// autodescreve com a `conta` de recebimento (override por estabelecimento em
/// `formaContas`) e o plano padrão (`formaPlanos`).
Map<String, dynamic> formaDetalheJson({
  required String id,
  required String nome,
  required int especie,
  required Map<String, dynamic> conta,
  List<Map<String, dynamic>> formaContas = const [],
}) =>
    {
      'id': id,
      'codigo': especie == 230 ? '12' : '1',
      'nome': nome,
      'especie': especie,
      'baixa': true,
      'situacao': 1,
      'conta': conta,
      'formaPlanos': [
        {
          'padrao': true,
          'plano': {
            'id': '71a8ab3f-dd2e-496a-9137-f63c37d0eb8f',
            'codigo': '01',
            'nome': 'A vista',
            'parcelas': 1,
          },
        },
      ],
      'formaContas': formaContas,
    };

Map<String, dynamic> formaPixDetalheJson() => formaDetalheJson(
      id: idFormaPix,
      nome: 'Recebimento em PIX',
      especie: 230,
      conta: {
        'id': 'baca1738-acbf-4010-94ca-179048d2a636',
        'codigo': '1.1.01.02.01',
        'nome': 'Banco do Brasil Aldeota',
        'analitica': true,
        'tipo': 10,
      },
      // Override para OUTRO estabelecimento: não deve ser usado por esta loja.
      formaContas: [
        {
          'estabelecimentoIds': ['outro-estabelecimento'],
          'conta': {
            'id': 'conta-de-outra-loja',
            'codigo': '1.1.99.99.99',
            'nome': 'Caixa de Outra Loja',
            'analitica': true,
            'tipo': 10,
          },
        },
      ],
    );

Map<String, dynamic> formaDinheiroDetalheJson() => formaDetalheJson(
      id: idFormaDinheiro,
      nome: 'Dinheiro',
      especie: 1,
      conta: {
        'id': '20e4d490-4152-4453-b302-0f5f5fa487b8',
        'codigo': '1.1.01.01.03',
        'nome': 'Caixa Miron',
        'analitica': true,
        'tipo': 10,
      },
    );

/// Fatura como a CONSULTA do retaguarda devolve (fatura real VN0051634,
/// resumida): SEM o campo `identificador`, mas com o id do atendimento em
/// `faturaModalidades[].referenciaId`.
Map<String, dynamic> faturaDaConsultaSemIdentificador(String atendimentoId) => {
      'id': 'b11acb66-f4d0-4b21-9afa-577e88c1740e',
      'codigo': 'VN0051634',
      'situacao': 340,
      'tipo': 110,
      'natureza': 1,
      'total': 6.49,
      'pago': 6.49,
      'saldo': 0,
      'faturaModalidades': [
        {
          'sequencial': 1,
          'referencia': '512',
          'numero': 512,
          'referenciaId': atendimentoId,
        }
      ],
    };
