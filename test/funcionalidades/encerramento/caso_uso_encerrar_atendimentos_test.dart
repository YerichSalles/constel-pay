import 'dart:async';

import 'package:constel_pay/funcionalidades/encerramento/dados/fontes_dados/fonte_encerramento_atendimento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/fontes_dados/fonte_fatura.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/modelos/requisicao_encerramento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dados/modelos/resposta_fatura.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/casos_uso/caso_uso_encerrar_atendimentos.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/configuracao_faturamento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/fase_encerramento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/fatura_referencia.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/resultado_encerramento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/transacao_pendente.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/repositorios/repositorio_configuracao_faturamento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/repositorios/repositorio_transacoes_pendentes.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/modelos/resposta_consumo_atendimento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/atendimento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:constel_pay/nucleo/utils/gerador_identificador.dart';
import 'package:constel_pay/nucleo/utils/relogio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures_encerramento.dart';

class _FonteEncerramentoFake implements FonteEncerramentoAtendimento {
  final List<RequisicaoEncerramento> enviadas = [];
  final List<Resultado<void>> respostas = [];
  Completer<Resultado<void>>? segurarProxima;

  @override
  Future<Resultado<void>> enviar(RequisicaoEncerramento requisicao,
      {String? chaveIdempotencia}) async {
    enviadas.add(requisicao);
    final segurada = segurarProxima;
    if (segurada != null) {
      segurarProxima = null;
      return segurada.future;
    }
    return respostas.isEmpty ? const Sucesso(null) : respostas.removeAt(0);
  }

  List<int> get acoes => [for (final r in enviadas) r.acao.valor];
}

class _FonteFaturaFake implements FonteFatura {
  final List<Map<String, dynamic>> criadas = [];
  final List<String> identificadores = [];
  final List<Resultado<FaturaReferencia>> respostas = [];
  Resultado<List<FaturaReferencia>> consulta = const Sucesso([]);
  int consultas = 0;

  @override
  Future<Resultado<FaturaReferencia>> criar(Map<String, dynamic> faturaJson,
      {required String identificador}) async {
    criadas.add(faturaJson);
    identificadores.add(identificador);
    if (respostas.isNotEmpty) return respostas.removeAt(0);
    return Sucesso(
        RespostaFatura.paraReferencia(respostaFaturaPaga(identificador)));
  }

  @override
  Future<Resultado<List<FaturaReferencia>>> consultarPorSessao(
      String sessaoId) async {
    consultas++;
    return consulta;
  }
}

class _PendentesMemoria implements RepositorioTransacoesPendentes {
  final Map<String, TransacaoPendente> registros = {};

  @override
  Future<List<TransacaoPendente>> obterTodas() async =>
      registros.values.toList();

  @override
  Future<void> salvar(TransacaoPendente transacao) async =>
      registros[transacao.identificador] = transacao;

  @override
  Future<void> remover(String identificador) async =>
      registros.remove(identificador);
}

class _ConfiguracaoFake implements RepositorioConfiguracaoFaturamento {
  _ConfiguracaoFake([this.configuracao]);
  ConfiguracaoFaturamento? configuracao;

  @override
  Future<ConfiguracaoFaturamento?> obter() async => configuracao;

  @override
  Future<void> salvar(String jsonBruto) async {}

  @override
  Future<void> remover() async {}
}

class _Cenario {
  _Cenario({ConfiguracaoFaturamento? configuracao})
      : fonteEncerramento = _FonteEncerramentoFake(),
        fonteFatura = _FonteFaturaFake(),
        pendentes = _PendentesMemoria(),
        repositorioConfiguracao =
            _ConfiguracaoFake(configuracao ?? configuracaoFaturamento()) {
    casoUso = CasoUsoEncerrarAtendimentos(
      fonteEncerramento: fonteEncerramento,
      fonteFatura: fonteFatura,
      repositorioPendentes: pendentes,
      repositorioConfiguracao: repositorioConfiguracao,
      relogio: RelogioFixo(DateTime(2026, 7, 13, 21, 44, 25)),
      geradorIdentificador: _GeradorSequencial(),
    );
  }

  final _FonteEncerramentoFake fonteEncerramento;
  final _FonteFaturaFake fonteFatura;
  final _PendentesMemoria pendentes;
  final _ConfiguracaoFake repositorioConfiguracao;
  late final CasoUsoEncerrarAtendimentos casoUso;

  Future<Resultado<ResultadoEncerramento>> executar(
          {List<FaseEncerramento>? fases}) =>
      casoUso.executar(
        atendimentos: [atendimentoCartao512()],
        metodo: MetodoPagamento.dinheiro,
        aoMudarFase: fases?.add,
      );
}

void main() {
  test('fluxo feliz: ação 10 → fatura → ação 30, sem pendência ao final',
      () async {
    final cenario = _Cenario();
    final fases = <FaseEncerramento>[];
    final resultado = await cenario.executar(fases: fases);

    expect(resultado, isA<Sucesso<ResultadoEncerramento>>());
    final encerramento = (resultado as Sucesso<ResultadoEncerramento>).valor;
    expect(encerramento.fatura.id, 'e0c2eafc-493f-40a6-a3b9-eddfff7b1522');
    expect(encerramento.fatura.codigo, 'VN0051625');
    expect(cenario.fonteEncerramento.acoes, [10, 30]);
    expect(cenario.pendentes.registros, isEmpty);
    expect(fases, [
      FaseEncerramento.preparandoEncerramento,
      FaseEncerramento.gerandoFatura,
      FaseEncerramento.confirmandoEncerramento,
      FaseEncerramento.concluida,
    ]);
  });

  test('ação 30 envia a sessão e a fatura retornada pela API', () async {
    final cenario = _Cenario();
    await cenario.executar();
    final confirmacao = cenario.fonteEncerramento.enviadas.last.paraJson();
    expect(confirmacao['acao'], 30);
    expect(confirmacao['sessao'], {'id': idSessao, 'codigo': codigoSessao});
    expect(confirmacao['fatura'], {
      'id': 'e0c2eafc-493f-40a6-a3b9-eddfff7b1522',
      'codigo': 'VN0051625',
    });
    // Ação 10 vai sem sessão e sem fatura.
    final inicio = cenario.fonteEncerramento.enviadas.first.paraJson();
    expect(inicio['acao'], 10);
    expect(inicio['sessao'], isNull);
    expect(inicio['fatura'], isNull);
  });

  test('não executa a ação 30 quando a criação da fatura falha', () async {
    final cenario = _Cenario();
    cenario.fonteFatura.respostas.add(const Erro(FalhaServidor('recusada')));
    final resultado = await cenario.executar();
    expect(resultado, isA<Erro<ResultadoEncerramento>>());
    expect(cenario.fonteEncerramento.acoes, [10]);
    // Rejeição explícita do servidor: pendência removida (nada foi criado).
    expect(cenario.pendentes.registros, isEmpty);
  });

  test('erro de rede na fatura mantém a pendência com o mesmo identificador',
      () async {
    final cenario = _Cenario();
    cenario.fonteFatura.respostas.add(const Erro(FalhaRede()));
    await cenario.executar();
    final pendente = cenario.pendentes.registros.values.single;
    expect(pendente.etapa, EtapaTransacao.faturaEnviada);
    expect(pendente.identificador, cenario.fonteFatura.identificadores.single);
  });

  test('retry após erro de rede reutiliza o identificador e o payload',
      () async {
    final cenario = _Cenario();
    cenario.fonteFatura.respostas.add(const Erro(FalhaRede()));
    await cenario.executar();
    // Segunda tentativa: reconciliação não encontra nada e reenvia.
    final resultado = await cenario.executar();
    expect(resultado, isA<Sucesso<ResultadoEncerramento>>());
    expect(cenario.fonteFatura.consultas, 1);
    expect(cenario.fonteFatura.identificadores.toSet().length, 1,
        reason: 'o identificador precisa ser o MESMO nas duas tentativas');
    expect(cenario.fonteFatura.criadas.first, cenario.fonteFatura.criadas.last,
        reason: 'o retry reenvia o payload congelado');
    expect(cenario.pendentes.registros, isEmpty);
  });

  test(
      'reconciliação casa pelo id do atendimento quando a consulta '
      'não devolve o identificador', () async {
    final cenario = _Cenario();
    cenario.fonteFatura.respostas.add(const Erro(FalhaTimeout()));
    await cenario.executar();
    // Consulta devolve a fatura no formato real do retaguarda: sem
    // `identificador`, com o atendimento em faturaModalidades[].referenciaId.
    cenario.fonteFatura.consulta = Sucesso([
      RespostaFatura.paraReferencia(
          faturaDaConsultaSemIdentificador(idAtendimento512)),
    ]);
    final resultado = await cenario.executar();
    expect(resultado, isA<Sucesso<ResultadoEncerramento>>());
    expect(cenario.fonteFatura.criadas.length, 1,
        reason: 'fatura existente reconhecida — nenhum segundo POST');
    final confirmacao = cenario.fonteEncerramento.enviadas.last.paraJson();
    expect((confirmacao['fatura'] as Map)['codigo'], 'VN0051634');
    expect(cenario.pendentes.registros, isEmpty);
  });

  test('timeout na fatura: reconciliação encontra e NÃO cria de novo',
      () async {
    final cenario = _Cenario();
    cenario.fonteFatura.respostas.add(const Erro(FalhaTimeout()));
    await cenario.executar();
    final identificador = cenario.fonteFatura.identificadores.single;
    cenario.fonteFatura.consulta = Sucesso([
      RespostaFatura.paraReferencia(respostaFaturaPaga(identificador)),
    ]);
    final resultado = await cenario.executar();
    expect(resultado, isA<Sucesso<ResultadoEncerramento>>());
    expect(cenario.fonteFatura.criadas.length, 1,
        reason: 'nenhum segundo POST de fatura');
    expect(cenario.fonteEncerramento.acoes, [10, 30]);
    expect(cenario.pendentes.registros, isEmpty);
  });

  test('fatura criada + erro na ação 30: retry repete SÓ a confirmação',
      () async {
    final cenario = _Cenario();
    cenario.fonteEncerramento.respostas.addAll([
      const Sucesso(null), // ação 10
      const Erro(FalhaTimeout()), // ação 30 falha
    ]);
    final primeira = await cenario.executar();
    expect(primeira, isA<Erro<ResultadoEncerramento>>());
    final pendente = cenario.pendentes.registros.values.single;
    expect(pendente.etapa, EtapaTransacao.confirmacaoEnviada);
    expect(pendente.faturaCodigo, 'VN0051625');

    final segunda = await cenario.executar();
    expect(segunda, isA<Sucesso<ResultadoEncerramento>>());
    expect(cenario.fonteFatura.criadas.length, 1,
        reason: 'não gera segunda fatura');
    expect(cenario.fonteEncerramento.acoes, [10, 30, 30],
        reason: 'repete somente a ação 30');
    expect(cenario.pendentes.registros, isEmpty);
  });

  test('impede dois encerramentos simultâneos', () async {
    final cenario = _Cenario();
    final segurada = Completer<Resultado<void>>();
    cenario.fonteEncerramento.segurarProxima = segurada;
    final primeira = cenario.executar();
    final segunda = await cenario.executar();
    expect(segunda, isA<Erro<ResultadoEncerramento>>());
    expect(
        (segunda as Erro<ResultadoEncerramento>).falha, isA<FalhaValidacao>());
    segurada.complete(const Sucesso(null));
    expect(await primeira, isA<Sucesso<ResultadoEncerramento>>());
  });

  test('erro definitivo na ação 10 remove a pendência e não gera fatura',
      () async {
    final cenario = _Cenario();
    cenario.fonteEncerramento.respostas
        .add(const Erro(FalhaServidor('recusado')));
    final resultado = await cenario.executar();
    expect(resultado, isA<Erro<ResultadoEncerramento>>());
    expect(cenario.fonteFatura.criadas, isEmpty);
    expect(cenario.pendentes.registros, isEmpty);
  });

  test('timeout na ação 10 mantém a pendência para retomada', () async {
    final cenario = _Cenario();
    cenario.fonteEncerramento.respostas.add(const Erro(FalhaTimeout()));
    await cenario.executar();
    expect(cenario.pendentes.registros.values.single.etapa,
        EtapaTransacao.preparacaoEnviada);
  });

  test('pagamento insuficiente é recusado antes de qualquer chamada', () async {
    final cenario = _Cenario();
    final resultado = await cenario.casoUso.executar(
      atendimentos: [atendimentoCartao512()],
      metodo: MetodoPagamento.dinheiro,
      valorRecebidoCentavos: 600,
    );
    expect(resultado, isA<Erro<ResultadoEncerramento>>());
    expect((resultado as Erro<ResultadoEncerramento>).falha,
        isA<FalhaValidacao>());
    expect(cenario.fonteEncerramento.enviadas, isEmpty);
    expect(cenario.fonteFatura.criadas, isEmpty);
  });

  test('pagamento com troco preserva o total e registra o troco', () async {
    final cenario = _Cenario();
    final resultado = await cenario.casoUso.executar(
      atendimentos: [atendimentoCartao512()],
      metodo: MetodoPagamento.dinheiro,
      valorRecebidoCentavos: 1000,
    );
    expect(resultado, isA<Sucesso<ResultadoEncerramento>>());
    final pagamento = (cenario.fonteFatura.criadas.single['faturaPagamentos']
        as List)[0] as Map;
    expect(pagamento['troco'], 3.51);
    expect(pagamento['total'], 6.49);
    expect(cenario.fonteFatura.criadas.single['total'], 6.49);
  });

  test('fatura sem quitação confirmada bloqueia a ação 30', () async {
    final cenario = _Cenario();
    cenario.fonteFatura.respostas.add(Sucesso(RespostaFatura.paraReferencia({
      ...respostaFaturaPaga('X'),
      'situacao': 210,
      'pago': 0,
      'saldo': 6.49,
    })));
    final resultado = await cenario.executar();
    expect(resultado, isA<Erro<ResultadoEncerramento>>());
    expect(cenario.fonteEncerramento.acoes, [10],
        reason: 'ação 30 não pode rodar com fatura não quitada');
  });

  test('sem configuração de faturamento recusa com mensagem clara', () async {
    final cenario = _Cenario(
        configuracao:
            ConfiguracaoFaturamento.deJson(const {}) // inválida → null
        );
    cenario.repositorioConfiguracao.configuracao = null;
    final resultado = await cenario.executar();
    expect(resultado, isA<Erro<ResultadoEncerramento>>());
    final falha = (resultado as Erro<ResultadoEncerramento>).falha;
    expect(falha, isA<FalhaValidacao>());
    expect(falha.mensagem, contains('Faturamento não configurado'));
    expect(cenario.fonteEncerramento.enviadas, isEmpty);
  });

  test('total da requisição corresponde ao total do atendimento', () async {
    final cenario = _Cenario();
    await cenario.executar();
    final json = cenario.fonteFatura.criadas.single;
    expect(json['total'], 6.49);
    expect(json['subtotal'], 5.9);
    expect(json['servico'], 0.59);
    final itens = json['faturaItens'] as List;
    expect((itens.single as Map)['total'], 6.49);
  });

  group('pendência com combinação diferente de comandas', () {
    Atendimento outroAtendimento() {
      final bruto = atendimentoBrutoCartao512();
      bruto['id'] = 'outro-atendimento';
      return RespostaConsumoAtendimento.paraLista([bruto]).single;
    }

    test('pendência com fatura + seleção parcial é bloqueada', () async {
      final cenario = _Cenario();
      // Pendência A+B com fatura criada e ação 30 falhando.
      cenario.fonteEncerramento.respostas.addAll([
        const Sucesso(null),
        const Erro(FalhaTimeout()),
      ]);
      await cenario.casoUso.executar(
        atendimentos: [atendimentoCartao512(), outroAtendimento()],
        metodo: MetodoPagamento.dinheiro,
      );
      expect(cenario.pendentes.registros, isNotEmpty);

      // Nova operação só com o cartão 512: NÃO pode retomar nem criar nova.
      final resultado = await cenario.executar();
      expect(resultado, isA<Erro<ResultadoEncerramento>>());
      expect((resultado as Erro<ResultadoEncerramento>).falha,
          isA<FalhaValidacao>());
      expect(cenario.fonteFatura.criadas.length, 1,
          reason: 'nenhuma fatura nova para o subconjunto');
    });

    test('pendência só de preparação é descartada e a nova seleção segue',
        () async {
      final cenario = _Cenario();
      // Preparação A+B interrompida por timeout na ação 10.
      cenario.fonteEncerramento.respostas.add(const Erro(FalhaTimeout()));
      await cenario.casoUso.executar(
        atendimentos: [atendimentoCartao512(), outroAtendimento()],
        metodo: MetodoPagamento.dinheiro,
      );
      final antiga = cenario.pendentes.registros.values.single;
      expect(antiga.etapa, EtapaTransacao.preparacaoEnviada);

      // Nova seleção só com o 512: pendência antiga sai, operação nova roda.
      final resultado = await cenario.executar();
      expect(resultado, isA<Sucesso<ResultadoEncerramento>>());
      expect(cenario.pendentes.registros, isEmpty);
      expect(cenario.fonteFatura.identificadores.single,
          isNot(antiga.identificador),
          reason: 'operação nova, identificador novo — sem fatura antiga');
    });
  });

  group('validarAntesDoPagamento', () {
    test('sem configuração devolve null (fluxo local, pode cobrar)', () async {
      final cenario = _Cenario();
      cenario.repositorioConfiguracao.configuracao = null;
      final falha = await cenario.casoUso.validarAntesDoPagamento(
        atendimentos: [atendimentoCartao512()],
        metodo: MetodoPagamento.pix,
      );
      expect(falha, isNull);
    });

    test('configuração sem a forma do método é barrada antes da cobrança',
        () async {
      final cenario = _Cenario();
      final falha = await cenario.casoUso.validarAntesDoPagamento(
        atendimentos: [atendimentoCartao512()],
        metodo: MetodoPagamento.credito,
      );
      expect(falha, isA<FalhaValidacao>());
    });

    test('retomada exata passa mesmo com atendimento já faturado', () async {
      final cenario = _Cenario();
      cenario.fonteEncerramento.respostas.addAll([
        const Sucesso(null),
        const Erro(FalhaTimeout()),
      ]);
      await cenario.executar();
      // O atendimento relido agora teria fatura vinculada — mas a pendência
      // com o MESMO conjunto permite (e resolve com) a retomada.
      final falha = await cenario.casoUso.validarAntesDoPagamento(
        atendimentos: [atendimentoCartao512()],
        metodo: MetodoPagamento.dinheiro,
      );
      expect(falha, isNull);
    });
  });

  group('confirmarTransacoesPendentes', () {
    test('conclui pendência com fatura criada executando a ação 30', () async {
      final cenario = _Cenario();
      cenario.fonteEncerramento.respostas.addAll([
        const Sucesso(null),
        const Erro(FalhaRede()),
      ]);
      await cenario.executar();
      expect(cenario.pendentes.registros, isNotEmpty);

      final resolvidas = await cenario.casoUso.confirmarTransacoesPendentes();
      expect(resolvidas, 1);
      expect(cenario.pendentes.registros, isEmpty);
      expect(cenario.fonteFatura.criadas.length, 1,
          reason: 'recuperação nunca cria fatura nova');
    });

    test('descarta pendência de fatura enviada que não existe no retaguarda',
        () async {
      final cenario = _Cenario();
      cenario.fonteFatura.respostas.add(const Erro(FalhaTimeout()));
      await cenario.executar();

      cenario.fonteFatura.consulta = const Sucesso([]);
      final resolvidas = await cenario.casoUso.confirmarTransacoesPendentes();
      expect(resolvidas, 0);
      expect(cenario.pendentes.registros, isEmpty,
          reason: 'fatura não criada → pendência descartada');
      expect(cenario.fonteFatura.criadas.length, 1,
          reason: 'em segundo plano NÃO reenvia fatura');
    });

    test('mantém pendência quando a reconciliação falha', () async {
      final cenario = _Cenario();
      cenario.fonteFatura.respostas.add(const Erro(FalhaTimeout()));
      await cenario.executar();

      cenario.fonteFatura.consulta = const Erro(FalhaRede());
      await cenario.casoUso.confirmarTransacoesPendentes();
      expect(cenario.pendentes.registros, isNotEmpty);
    });
  });
}

class _GeradorSequencial extends GeradorIdentificador {
  int _contador = 0;

  @override
  String gerar() => 'IDENTIFICADORT${(_contador++).toString().padLeft(3, '0')}';
}
