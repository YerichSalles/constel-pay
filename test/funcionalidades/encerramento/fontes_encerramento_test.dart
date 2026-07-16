import 'dart:convert';

import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/fontes_dados/fonte_dispositivo.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/fontes_dados/fonte_encerramento_atendimento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/fontes_dados/fonte_fatura.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/fontes_dados/fonte_forma_pagamento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/modelos/requisicao_encerramento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/fatura_referencia.dart';
import 'package:constel_pay/nucleo/configuracao/cliente_api.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures_encerramento.dart';

class _RepositorioFake implements RepositorioConfiguracao {
  @override
  Future<ConfiguracaoTerminal> obter() async => const ConfiguracaoTerminal(
        urlBaseHomologacao: 'https://localhost:3001/api/',
        urlNuvemHomologacao: 'https://nuvem.exemplo/api/',
      );

  @override
  Future<void> salvar(ConfiguracaoTerminal nova) async {}
}

class _AdaptadorResposta implements HttpClientAdapter {
  _AdaptadorResposta(this.corpo, this.status);
  final Object corpo;
  final int status;
  RequestOptions? ultimaRequisicao;
  String? ultimoCorpoEnviado;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    ultimaRequisicao = options;
    if (options.data != null) {
      ultimoCorpoEnviado = jsonEncode(options.data);
    }
    return ResponseBody.fromString(jsonEncode(corpo), status, headers: {
      'content-type': ['application/json']
    });
  }

  @override
  void close({bool force = false}) {}
}

ClienteApi _cliente(HttpClientAdapter adaptador) => ClienteApi(
      repositorioConfiguracao: _RepositorioFake(),
      dio: Dio()..httpClientAdapter = adaptador,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FonteEncerramentoAtendimento', () {
    test('envia o payload no caminho do encerra SEM Idempotency-Key', () async {
      final adaptador = _AdaptadorResposta(const {}, 200);
      final fonte = FonteEncerramentoAtendimento(_cliente(adaptador));
      final resultado = await fonte.enviar(
        RequisicaoEncerramento.iniciar([atendimentoBrutoCartao512()]),
      );
      expect(resultado, isA<Sucesso<void>>());
      final requisicao = adaptador.ultimaRequisicao!;
      expect(requisicao.method, 'POST');
      expect(requisicao.uri.path, endsWith('venda/atendimento/encerra'));
      // Mesmo endpoint para as ações 10 e 30: uma chave repetida faria um
      // servidor com dedupe responder a 30 com replay da 10.
      expect(requisicao.headers.containsKey('Idempotency-Key'), isFalse);
      final corpo =
          jsonDecode(adaptador.ultimoCorpoEnviado!) as Map<String, dynamic>;
      expect(corpo['acao'], 10);
      expect(corpo['sessao'], isNull);
      expect(corpo['fatura'], isNull);
      expect((corpo['atendimentos'] as List).single['id'], idAtendimento512);
    });

    test('erro HTTP vira Falha mapeada', () async {
      final fonte = FonteEncerramentoAtendimento(
          _cliente(_AdaptadorResposta(const {'message': 'x'}, 500)));
      final resultado = await fonte.enviar(
          RequisicaoEncerramento.iniciar([atendimentoBrutoCartao512()]));
      expect(resultado, isA<Erro<void>>());
      expect((resultado as Erro<void>).falha, isA<FalhaServidor>());
    });
  });

  group('FonteFatura', () {
    test('cria a fatura e devolve a referência da resposta', () async {
      final adaptador = _AdaptadorResposta(respostaFaturaPaga('IDX'), 200);
      final fonte = FonteFatura(_cliente(adaptador));
      final resultado = await fonte
          .criar(const {'identificador': 'IDX'}, identificador: 'IDX');
      expect(resultado, isA<Sucesso<FaturaReferencia>>());
      final fatura = (resultado as Sucesso<FaturaReferencia>).valor;
      expect(fatura.id, 'e0c2eafc-493f-40a6-a3b9-eddfff7b1522');
      expect(fatura.codigo, 'VN0051625');
      expect(fatura.identificador, 'IDX');
      expect(fatura.situacao, 340);
      expect(fatura.pagoCentavos, 649);
      expect(fatura.saldoCentavos, 0);
      final requisicao = adaptador.ultimaRequisicao!;
      expect(requisicao.uri.path, endsWith('movimento/fatura'));
      expect(requisicao.headers['Idempotency-Key'], 'IDX');
    });

    test('consulta por atendimento manda texto e abre o envelope paginado',
        () async {
      // Formato real do retaguarda: envelope com `lista` (paginação).
      final adaptador = _AdaptadorResposta({
        'registros': 1,
        'linhas': 10,
        'pagina': 1,
        'paginas': 1,
        'lista': [respostaFaturaPaga('IDY')],
      }, 200);
      final fonte = FonteFatura(_cliente(adaptador));
      final resultado = await fonte.consultarPorAtendimento('a1');
      expect(resultado, isA<Sucesso<List<Map<String, dynamic>>>>());
      final lista = (resultado as Sucesso<List<Map<String, dynamic>>>).valor;
      expect(lista.single['codigo'], 'VN0051625');
      expect(adaptador.ultimaRequisicao!.queryParameters, {'texto': 'a1'});
    });

    test(
        'corpo ilegível num 2xx vira FalhaDesconhecida (incerteza, '
        'nunca rejeição)', () async {
      final fonte = FonteFatura(_cliente(_AdaptadorResposta(const [], 200)));
      final resultado = await fonte.criar(const {}, identificador: 'ID');
      expect(resultado, isA<Erro<FaturaReferencia>>());
      expect(
          (resultado as Erro<FaturaReferencia>).falha, isA<FalhaDesconhecida>(),
          reason: 'a fatura pode ter sido criada — a pendência precisa '
              'sobreviver para reconciliar');
    });

    test('consulta em formato desconhecido vira erro, não lista vazia',
        () async {
      final fonte = FonteFatura(_cliente(_AdaptadorResposta(const {
        'conteudo': [
          {'id': 'x'}
        ]
      }, 200)));
      final resultado = await fonte.consultarPorAtendimento('a1');
      expect(resultado, isA<Erro<List<Map<String, dynamic>>>>());
      expect((resultado as Erro<List<Map<String, dynamic>>>).falha,
          isA<FalhaDesconhecida>(),
          reason: '"não sei ler" não pode virar "a fatura não existe"');
    });
  });

  group('FonteDispositivo', () {
    test('busca o documento do dispositivo por id', () async {
      final adaptador = _AdaptadorResposta(dispositivoDocJson(), 200);
      final fonte = FonteDispositivo(_cliente(adaptador));
      final resultado = await fonte.obter(idDispositivoTerminal);
      expect(resultado, isA<Sucesso<Map<String, dynamic>>>());
      final doc = (resultado as Sucesso<Map<String, dynamic>>).valor;
      expect((doc['operacao'] as Map)['codigo'], '519');
      expect(adaptador.ultimaRequisicao!.uri.path,
          endsWith('estrutura/dispositivo/$idDispositivoTerminal'));
    });

    test('erro HTTP vira Falha mapeada', () async {
      final fonte = FonteDispositivo(
          _cliente(_AdaptadorResposta(const {'message': 'x'}, 500)));
      final resultado = await fonte.obter('x');
      expect(resultado, isA<Erro<Map<String, dynamic>>>());
    });
  });

  group('FonteFormaPagamento', () {
    test('lista as formas com texto vazio', () async {
      final adaptador = _AdaptadorResposta(formasListaJson(), 200);
      final fonte = FonteFormaPagamento(_cliente(adaptador));
      final resultado = await fonte.listar();
      expect(resultado, isA<Sucesso<List<Map<String, dynamic>>>>());
      final lista = (resultado as Sucesso<List<Map<String, dynamic>>>).valor;
      expect(lista.length, 3);
      expect(
          adaptador.ultimaRequisicao!.uri.path, endsWith('financeiro/forma'));
      expect(adaptador.ultimaRequisicao!.queryParameters, {'texto': ''});
    });

    test('detalhe da forma traz a conta de recebimento', () async {
      final adaptador = _AdaptadorResposta(formaPixDetalheJson(), 200);
      final fonte = FonteFormaPagamento(_cliente(adaptador));
      final resultado = await fonte.obter(idFormaPix);
      expect(resultado, isA<Sucesso<Map<String, dynamic>>>());
      final detalhe = (resultado as Sucesso<Map<String, dynamic>>).valor;
      expect((detalhe['conta'] as Map)['nome'], 'Banco do Brasil Aldeota');
      expect(adaptador.ultimaRequisicao!.uri.path,
          endsWith('financeiro/forma/$idFormaPix'));
    });

    test('listagem em formato desconhecido vira erro', () async {
      final fonte = FonteFormaPagamento(
          _cliente(_AdaptadorResposta(const {'x': 1}, 200)));
      final resultado = await fonte.listar();
      expect(resultado, isA<Erro<List<Map<String, dynamic>>>>());
    });
  });
}
