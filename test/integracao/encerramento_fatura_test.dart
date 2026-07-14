import 'dart:convert';

import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/fontes_dados/fonte_encerramento_atendimento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/fontes_dados/fonte_fatura.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/repositorios/repositorio_configuracao_faturamento_impl.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/repositorios/repositorio_transacoes_pendentes_impl.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/casos_uso/caso_uso_encerrar_atendimentos.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/resultado_encerramento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/modelos/resposta_consumo_atendimento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:constel_pay/nucleo/configuracao/cliente_api.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:constel_pay/nucleo/utils/relogio.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../funcionalidades/encerramento/fixtures_encerramento.dart';

/// Cenário real simplificado do log do caixa: cartão 512, Água com Gás,
/// 5,90 + 0,59 de serviço = 6,49, pago em dinheiro à vista.
/// O adaptador roteia por caminho e captura cada corpo enviado.
class _AdaptadorRotas implements HttpClientAdapter {
  final List<Map<String, dynamic>> encerramentos = [];
  final List<Map<String, dynamic>> faturas = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    final caminho = options.uri.path;
    Object corpoResposta = const {};
    if (caminho.endsWith('venda/atendimento/encerra')) {
      encerramentos.add(_corpo(options));
    } else if (caminho.endsWith('movimento/fatura')) {
      final corpo = _corpo(options);
      faturas.add(corpo);
      corpoResposta = respostaFaturaPaga(corpo['identificador'] as String);
    } else {
      fail('Chamada inesperada: ${options.method} $caminho');
    }
    return ResponseBody.fromString(jsonEncode(corpoResposta), 200, headers: {
      'content-type': ['application/json']
    });
  }

  Map<String, dynamic> _corpo(RequestOptions options) =>
      jsonDecode(jsonEncode(options.data)) as Map<String, dynamic>;

  @override
  void close({bool force = false}) {}
}

class _RepositorioFake implements RepositorioConfiguracao {
  @override
  Future<ConfiguracaoTerminal> obter() async => const ConfiguracaoTerminal(
        urlBaseHomologacao: 'https://localhost:3001/api/',
        urlNuvemHomologacao: 'https://sirius.exemplo/api/',
      );

  @override
  Future<void> salvar(ConfiguracaoTerminal nova) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('encerramento completo do cartão 512 gera UMA fatura paga e confirma',
      () async {
    SharedPreferences.setMockInitialValues(const {});
    final preferencias = await SharedPreferences.getInstance();
    final repositorioFaturamento =
        RepositorioConfiguracaoFaturamentoImpl(preferencias);
    await repositorioFaturamento
        .salvar(jsonEncode(configuracaoFaturamentoJson()));

    final adaptador = _AdaptadorRotas();
    final cliente = ClienteApi(
      repositorioConfiguracao: _RepositorioFake(),
      dio: Dio()..httpClientAdapter = adaptador,
    );
    final pendentes = RepositorioTransacoesPendentesImpl(preferencias);
    final casoUso = CasoUsoEncerrarAtendimentos(
      fonteEncerramento: FonteEncerramentoAtendimento(cliente),
      fonteFatura: FonteFatura(cliente),
      repositorioPendentes: pendentes,
      repositorioConfiguracao: repositorioFaturamento,
      relogio: RelogioFixo(DateTime(2026, 7, 13, 21, 44, 25)),
    );

    // Atendimento parseado exatamente como o app faz na leitura do cartão.
    final atendimentos =
        RespostaConsumoAtendimento.paraLista([atendimentoBrutoCartao512()]);
    expect(atendimentos.single.saldoCentavos, 649);
    expect(atendimentos.single.itens.single.nome, 'Água com Gás');

    final resultado = await casoUso.executar(
      atendimentos: atendimentos,
      metodo: MetodoPagamento.dinheiro,
    );

    // Resultado: fatura persistida com id e código, atendimento confirmado.
    expect(resultado, isA<Sucesso<ResultadoEncerramento>>());
    final encerramento = (resultado as Sucesso<ResultadoEncerramento>).valor;
    expect(encerramento.fatura.id, isNotEmpty);
    expect(encerramento.fatura.codigo, 'VN0051625');
    expect(encerramento.fatura.situacao, 340, reason: 'API devolve paga');
    expect(encerramento.fatura.saldoCentavos, 0);
    expect(encerramento.atendimentoIds, [idAtendimento512]);

    // Exatamente UMA fatura criada, enviada como autorizada (210).
    expect(adaptador.faturas.length, 1);
    final fatura = adaptador.faturas.single;
    expect(fatura['situacao'], 210);
    expect(fatura['tipo'], 110);
    expect(fatura['natureza'], 1);
    expect(fatura['rateada'], true);
    expect(fatura['subtotal'], 5.9);
    expect(fatura['servico'], 0.59);
    expect(fatura['total'], 6.49);
    expect(fatura['pessoas'], 1);
    expect(fatura['sessao'], {'id': idSessao});
    expect((fatura['identificador'] as String).length, 17);
    final item = ((fatura['faturaItens'] as List).single) as Map;
    expect((item['item'] as Map)['nome'], 'Água com Gás');
    expect(item['quantidade'], 1);
    expect(item['total'], 6.49);
    final modalidade = ((fatura['faturaModalidades'] as List).single) as Map;
    expect(modalidade['referencia'], '512');
    expect(modalidade['numero'], 512);
    expect(modalidade['referenciaId'], idAtendimento512);
    final pagamento = ((fatura['faturaPagamentos'] as List).single) as Map;
    expect((pagamento['forma'] as Map)['nome'], 'Dinheiro');
    expect((pagamento['plano'] as Map)['nome'], 'A vista');
    expect(pagamento['parcelas'], 1);
    expect(pagamento['troco'], 0.0);
    expect(pagamento['total'], 6.49);

    // Duas ações de encerramento: 10 (iniciar) e 30 (confirmar com a fatura).
    expect(adaptador.encerramentos.length, 2);
    expect(adaptador.encerramentos.first['acao'], 10);
    final confirmacao = adaptador.encerramentos.last;
    expect(confirmacao['acao'], 30);
    expect(confirmacao['sessao'], {'id': idSessao, 'codigo': codigoSessao});
    expect(confirmacao['fatura'], {
      'id': 'e0c2eafc-493f-40a6-a3b9-eddfff7b1522',
      'codigo': 'VN0051625',
    });
    expect(
        (confirmacao['atendimentos'] as List).single['id'], idAtendimento512);

    // Nada pendente: a comanda deixa de aparecer como aberta no app.
    expect(await pendentes.obterTodas(), isEmpty);
  });
}
