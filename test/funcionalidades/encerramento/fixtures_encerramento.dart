/// Fixtures do cenário real observado no caixa (ConstelPDV, 2026-07-13):
/// cartão 512, Água com Gás, subtotal 5,90 + serviço 0,59 = total 6,49.
library;

import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/configuracao_faturamento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/modelos/resposta_consumo_atendimento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/atendimento.dart';

const String idAtendimento512 = 'dd222fda-aa10-4ab8-9ee3-9a40ae3cbbdb';
const String idSessao = 'e330e839-0e9c-4490-b947-c330cff1317a';
const String codigoSessao = '0003479';

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
      'modalidade': {
        'situacao': 0,
        'tipo': 10,
        'id': '877a7dbb-c1c3-4c14-b369-bbb48592434b',
        'codigo': '01',
        'nome': 'Balcão',
      },
      'resultado': {
        'nivel': 0,
        'analitico': false,
        'percentual': 0.0,
        'valor': 0.0,
        'id': '0699fb41-2943-417d-a2f7-017ffce3ce01',
        'nome': 'Vendas',
      },
      'dispositivo': {
        'situacao': 0,
        'id': '39dfe2d9-ea47-4a8b-b5ed-76a03d09ca7a',
        'codigo': '0072',
        'nome': 'NOE CAIXA',
      },
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
