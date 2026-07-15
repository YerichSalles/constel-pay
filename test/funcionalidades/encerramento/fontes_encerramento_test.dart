import 'dart:convert';

import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/fontes_dados/fonte_atendimentos_sessao.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/fontes_dados/fonte_encerramento_atendimento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/fontes_dados/fonte_fatura.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/modelos/requisicao_encerramento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/atendimento_encerrado.dart';
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

  group('FonteAtendimentosSessao', () {
    test('consulta o mapa da sessão e devolve só encerrados com fatura',
        () async {
      final adaptador = _AdaptadorResposta([
        {
          'id': 'a-encerrado',
          'situacao': 30,
          'conclusao': '2026-07-14T17:34:32.666Z',
          'fatura': {'id': 'f1', 'codigo': 'VN0051636'},
        },
        {
          'id': 'a-estornado',
          'situacao': 90,
          'conclusao': '2026-07-14T18:00:00.000Z',
          'fatura': {'id': 'f2', 'codigo': 'VN0051637'},
        },
      ], 200);
      final fonte = FonteAtendimentosSessao(_cliente(adaptador));
      final resultado = await fonte.consultarEncerrados('s1');
      expect(resultado, isA<Sucesso<List<AtendimentoEncerrado>>>());
      final lista = (resultado as Sucesso<List<AtendimentoEncerrado>>).valor;
      expect(lista.single.atendimentoId, 'a-encerrado');
      expect(lista.single.faturaId, 'f1');
      expect(lista.single.faturaCodigo, 'VN0051636');
      final requisicao = adaptador.ultimaRequisicao!;
      expect(requisicao.uri.path, endsWith('venda/atendimento/mapa'));
      expect(requisicao.queryParameters, {'situacao': 30, 'sessaoid': 's1'});
    });

    test('corpo que não é lista vira erro', () async {
      final fonte = FonteAtendimentosSessao(
          _cliente(_AdaptadorResposta(const {'x': 1}, 200)));
      final resultado = await fonte.consultarEncerrados('s1');
      expect(resultado, isA<Erro<List<AtendimentoEncerrado>>>());
    });
  });
}
