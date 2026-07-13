import 'dart:convert';

import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_recurso_item.dart';
import 'package:constel_pay/nucleo/configuracao/cliente_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepositorioFake implements RepositorioConfiguracao {
  _RepositorioFake(this.configuracao);
  ConfiguracaoTerminal configuracao;
  @override
  Future<ConfiguracaoTerminal> obter() async => configuracao;
  @override
  Future<void> salvar(ConfiguracaoTerminal nova) async => configuracao = nova;
}

class _AdaptadorResposta implements HttpClientAdapter {
  _AdaptadorResposta(this.corpo, this.status);
  final Object corpo;
  final int status;
  int chamadas = 0;
  RequestOptions? ultimaRequisicao;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    chamadas++;
    ultimaRequisicao = options;
    return ResponseBody.fromString(jsonEncode(corpo), status, headers: {
      'content-type': ['application/json']
    });
  }

  @override
  void close({bool force = false}) {}
}

FonteRecursoItem _fonte(HttpClientAdapter adaptador) {
  final repositorio = _RepositorioFake(const ConfiguracaoTerminal(
      urlBaseHomologacao: 'https://localhost:3001/api/'));
  final dio = Dio()..httpClientAdapter = adaptador;
  return FonteRecursoItemApi(
      ClienteApi(repositorioConfiguracao: repositorio, dio: dio));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const itemId = 'd3f605c9-ecd9-46e5-94f9-863441257554';
  const urlFoto =
      'https://s3.amazonaws.com/alpha.constel.cloud/files/05f20e10.png';

  test('devolve a URL do campo imagem e chama recurso/item/{id}', () async {
    final adaptador = _AdaptadorResposta(
        const {'id': itemId, 'nome': 'Café Extra Forte', 'imagem': urlFoto},
        200);
    expect(await _fonte(adaptador).obterImagem(itemId), urlFoto);
    expect(
        adaptador.ultimaRequisicao!.uri.path, endsWith('recurso/item/$itemId'));
  });

  test('item sem foto (imagem null) devolve vazio', () async {
    final fonte = _fonte(_AdaptadorResposta(
        const {'id': itemId, 'nome': 'Café', 'imagem': null}, 200));
    expect(await fonte.obterImagem(itemId), isEmpty);
  });

  test('falha da API devolve vazio em vez de erro', () async {
    final fonte = _fonte(_AdaptadorResposta(const {'message': 'nao'}, 500));
    expect(await fonte.obterImagem(itemId), isEmpty);
  });

  test('id vazio nem chega a chamar a API', () async {
    final adaptador = _AdaptadorResposta(const {}, 200);
    expect(await _fonte(adaptador).obterImagem(''), isEmpty);
    expect(adaptador.chamadas, 0);
  });

  test('URL encontrada fica em cache: o mesmo item nao repete requisicao',
      () async {
    final adaptador = _AdaptadorResposta(const {'imagem': urlFoto}, 200);
    final fonte = _fonte(adaptador);
    expect(await fonte.obterImagem(itemId), urlFoto);
    expect(await fonte.obterImagem(itemId), urlFoto);
    expect(adaptador.chamadas, 1);
  });
}
