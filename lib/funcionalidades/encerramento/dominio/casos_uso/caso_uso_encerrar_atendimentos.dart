import 'dart:convert';

import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../../nucleo/utils/gerador_identificador.dart';
import '../../../../nucleo/utils/json_leniente.dart';
import '../../../../nucleo/utils/registrador.dart';
import '../../../../nucleo/utils/relogio.dart';
import '../../../leitura_cartao/dados/fontes_dados/fonte_consumo_atendimento.dart';
import '../../../leitura_cartao/dados/modelos/resposta_consumo_atendimento.dart';
import '../../../leitura_cartao/dominio/entidades/atendimento.dart';
import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';
import '../../dados/adaptadores/derivador_configuracao_faturamento.dart';
import '../../dados/adaptadores/mapeador_fatura.dart';
import '../../dados/fontes_dados/fonte_atendimentos_sessao.dart';
import '../../dados/fontes_dados/fonte_encerramento_atendimento.dart';
import '../../dados/fontes_dados/fonte_fatura.dart';
import '../../dados/modelos/requisicao_encerramento.dart';
import '../../dados/modelos/resposta_fatura.dart';
import '../entidades/atendimento_encerrado.dart';
import '../entidades/configuracao_faturamento.dart';
import '../entidades/fatura_enums.dart';
import '../entidades/fase_encerramento.dart';
import '../entidades/fatura_referencia.dart';
import '../entidades/resultado_encerramento.dart';
import '../entidades/transacao_pendente.dart';
import '../repositorios/repositorio_configuracao_faturamento.dart';
import '../repositorios/repositorio_transacoes_pendentes.dart';
import 'validacoes_encerramento.dart';

/// Orquestra o encerramento financeiro da comanda: ação 10 → fatura → ação 30.
///
/// Garantias contra duplicidade:
/// - identificador único gerado UMA vez e congelado na transação pendente;
/// - o payload da fatura é persistido antes do POST e um retry reenvia
///   exatamente o que foi salvo;
/// - a pendência só é removida depois da ação 30 confirmada;
/// - timeout NUNCA assume que a fatura não foi criada — reconcilia primeiro
///   consultando no retaguarda as faturas vinculadas a cada atendimento;
/// - uma instância única (provider) trava operações simultâneas; a retomada
///   exige o MESMO conjunto de atendimentos da pendência.
class CasoUsoEncerrarAtendimentos {
  CasoUsoEncerrarAtendimentos({
    required FonteEncerramentoAtendimento fonteEncerramento,
    required FonteFatura fonteFatura,
    required FonteAtendimentosSessao fonteAtendimentosSessao,
    required RepositorioTransacoesPendentes repositorioPendentes,
    required RepositorioConfiguracaoFaturamento repositorioConfiguracao,
    FonteConsumoAtendimento? fonteConsumo,
    Relogio relogio = const Relogio(),
    GeradorIdentificador? geradorIdentificador,
  })  : _fonteEncerramento = fonteEncerramento,
        _fonteFatura = fonteFatura,
        _fonteAtendimentosSessao = fonteAtendimentosSessao,
        _pendentes = repositorioPendentes,
        _configuracoes = repositorioConfiguracao,
        _fonteConsumo = fonteConsumo,
        _relogio = relogio,
        _gerador = geradorIdentificador ?? GeradorIdentificador();

  final FonteEncerramentoAtendimento _fonteEncerramento;
  final FonteFatura _fonteFatura;
  final FonteAtendimentosSessao _fonteAtendimentosSessao;
  final RepositorioTransacoesPendentes _pendentes;
  final RepositorioConfiguracaoFaturamento _configuracoes;
  final FonteConsumoAtendimento? _fonteConsumo;
  final Relogio _relogio;
  final GeradorIdentificador _gerador;

  bool _emAndamento = false;

  /// FaturaSituacao.paga — quitação validada quando a fatura foi criada.
  static const int _situacaoPaga = 340;

  /// Validação ANTES da cobrança: nada pode ser cobrado do cliente se o
  /// encerramento estiver fadado a falhar por estado conhecido (configuração
  /// não derivável, operação em andamento, pendência de outra combinação,
  /// atendimento inválido). `null` = pode cobrar.
  Future<Falha?> validarAntesDoPagamento({
    required List<Atendimento> atendimentos,
    required MetodoPagamento metodo,
  }) async {
    if (atendimentos.isEmpty) {
      return const FalhaValidacao('Nenhum atendimento selecionado.');
    }
    if (_emAndamento) {
      return const FalhaValidacao(
          'Há um encerramento em andamento. Aguarde alguns instantes e '
          'tente novamente.');
    }
    final ids = [for (final a in atendimentos) a.id];
    final pendente = await _pendenteEnvolvendo(ids);
    if (pendente != null) {
      if (_mesmoConjunto(pendente.atendimentoIds, ids)) {
        // Retomada legítima: as validações de frescor não se aplicam — a
        // operação continua do ponto onde parou com os dados congelados.
        return null;
      }
      if (pendente.etapa != EtapaTransacao.preparacaoEnviada) {
        return const FalhaValidacao(
            'Há um encerramento pendente com outra combinação de comandas. '
            'Conclua-o (mesmas comandas) antes de iniciar outro.');
      }
    }
    final configuracao =
        await _resolverConfiguracao(atendimentos.first.sessaoId, metodo);
    return ValidacoesEncerramento.validarAtendimentos(
        atendimentos, metodo, configuracao);
  }

  /// Encerra os atendimentos com a forma de pagamento do [metodo]. Pendência
  /// com o MESMO conjunto de atendimentos é retomada do ponto onde parou.
  Future<Resultado<ResultadoEncerramento>> executar({
    required List<Atendimento> atendimentos,
    required MetodoPagamento metodo,
    int? valorRecebidoCentavos,
    void Function(FaseEncerramento fase)? aoMudarFase,
  }) async {
    if (_emAndamento) {
      return const Erro(
          FalhaValidacao('Já existe um encerramento em andamento. Aguarde.'));
    }
    _emAndamento = true;
    try {
      final resultado = await _executar(
        atendimentos: atendimentos,
        metodo: metodo,
        valorRecebidoCentavos: valorRecebidoCentavos,
        aoMudarFase: aoMudarFase ?? (_) {},
      );
      if (resultado is Erro<ResultadoEncerramento>) {
        aoMudarFase?.call(FaseEncerramento.erro);
      }
      return resultado;
    } catch (erro) {
      // Exceção inesperada (ex.: falha de disco ao persistir a pendência).
      // Tratada como incerteza: nada é descartado e a UI recebe erro em vez
      // de congelar aguardando um Future que lançou.
      registrador.e('Encerramento: erro inesperado: $erro');
      aoMudarFase?.call(FaseEncerramento.erro);
      return const Erro(FalhaDesconhecida());
    } finally {
      _emAndamento = false;
    }
  }

  Future<Resultado<ResultadoEncerramento>> _executar({
    required List<Atendimento> atendimentos,
    required MetodoPagamento metodo,
    required int? valorRecebidoCentavos,
    required void Function(FaseEncerramento fase) aoMudarFase,
  }) async {
    final configuracao = await _resolverConfiguracao(
        atendimentos.isEmpty ? '' : atendimentos.first.sessaoId, metodo);

    // Pendência primeiro: retomada não passa pelas validações de frescor
    // (o atendimento relido pode já vir com a fatura vinculada — é
    // exatamente o caso que a retomada resolve com a ação 30).
    final ids = [for (final a in atendimentos) a.id];
    final existente = await _pendenteEnvolvendo(ids);
    if (existente != null) {
      if (_mesmoConjunto(existente.atendimentoIds, ids)) {
        return _retomar(existente, configuracao, aoMudarFase);
      }
      if (existente.etapa == EtapaTransacao.preparacaoEnviada) {
        // Nenhum dado financeiro criado: a tentativa antiga é descartada e
        // a nova seleção segue com identificador novo, sem risco de fatura.
        await _pendentes.remover(existente.identificador);
        registrador.i('Pendência ${existente.identificador} descartada '
            '(preparação antiga, seleção mudou).');
      } else {
        return const Erro(FalhaValidacao(
            'Há um encerramento pendente com outra combinação de comandas. '
            'Conclua-o (mesmas comandas) antes de iniciar outro.'));
      }
    }

    final falhaValidacao = ValidacoesEncerramento.validarAtendimentos(
        atendimentos, metodo, configuracao);
    if (falhaValidacao != null) return Erro(falhaValidacao);

    final totalCentavos = _totalCentavos(atendimentos);
    final recebido = valorRecebidoCentavos ?? totalCentavos;
    if (recebido < totalCentavos) {
      return const Erro(
          FalhaValidacao('O valor recebido não cobre o total da conta.'));
    }

    final pendente = TransacaoPendente(
      identificador: _gerador.gerar(),
      atendimentoIds: ids,
      sessaoId: atendimentos.first.sessaoId,
      sessaoCodigo: atendimentos.first.sessaoCodigo,
      etapa: EtapaTransacao.preparacaoEnviada,
      dataTentativa: _relogio.agoraUtc(),
      atendimentosBrutos: [for (final a in atendimentos) a.bruto],
      metodo: metodo.name,
      trocoCentavos: recebido - totalCentavos,
    );
    await _pendentes.salvar(pendente);

    return _prosseguirDaPreparacao(
        pendente, atendimentos, configuracao!, metodo,
        aoMudarFase: aoMudarFase);
  }

  /// Ação 10 em diante, para operações novas ou retomadas na preparação.
  Future<Resultado<ResultadoEncerramento>> _prosseguirDaPreparacao(
    TransacaoPendente pendente,
    List<Atendimento> atendimentos,
    ConfiguracaoFaturamento configuracao,
    MetodoPagamento metodo, {
    required void Function(FaseEncerramento fase) aoMudarFase,
  }) async {
    aoMudarFase(FaseEncerramento.preparandoEncerramento);
    final inicio = await _fonteEncerramento
        .enviar(RequisicaoEncerramento.iniciar(pendente.atendimentosBrutos));
    if (inicio is Erro<void>) {
      // Sem incerteza (o servidor respondeu ou nada foi enviado): nada foi
      // criado, a pendência sai e a comanda continua aberta para retry.
      if (!_incerta(inicio.falha)) {
        await _pendentes.remover(pendente.identificador);
      }
      return Erro(inicio.falha);
    }

    final requisicao = MapeadorFatura.montar(
      atendimentos: atendimentos,
      configuracao: configuracao,
      formaPagamento: configuracao.formasPagamento[metodo.name]!,
      identificador: pendente.identificador,
      momentoUtc: _relogio.agoraUtc(),
      dataOperacional: _relogio.dataOperacional(),
      trocoCentavos: pendente.trocoCentavos,
    );
    final faturaJson = requisicao.paraJson();

    final inconsistencia = ValidacoesEncerramento.conferirConsistencia(
        requisicao.totalCentavos,
        requisicao.itens.fold(0, (s, i) => s + i.totalCentavos),
        requisicao.modalidades.fold(0, (s, m) => s + m.totalCentavos));
    if (inconsistencia != null) {
      await _pendentes.remover(pendente.identificador);
      return Erro(inconsistencia);
    }

    final comFatura = pendente.copiarCom(
        etapa: EtapaTransacao.faturaEnviada, faturaJson: faturaJson);
    await _pendentes.salvar(comFatura);
    return _gerarFatura(comFatura, aoMudarFase, primeiroEnvio: true);
  }

  /// POST da fatura com o payload congelado + validação da resposta.
  Future<Resultado<ResultadoEncerramento>> _gerarFatura(
    TransacaoPendente pendente,
    void Function(FaseEncerramento fase) aoMudarFase, {
    required bool primeiroEnvio,
  }) async {
    aoMudarFase(FaseEncerramento.gerandoFatura);
    final resultado = await _fonteFatura.criar(pendente.faturaJson,
        identificador: pendente.identificador);
    switch (resultado) {
      case Erro(:final falha):
        // No PRIMEIRO envio, rejeição explícita do servidor = fatura não
        // criada: a pendência sai para permitir nova tentativa limpa (novo
        // identificador). Num REENVIO pós-timeout a rejeição pode ser efeito
        // do primeiro POST ainda em processamento — a pendência fica para
        // reconciliar. Incerteza (timeout/rede/corpo ilegível) sempre
        // mantém a pendência.
        if (primeiroEnvio && !_incerta(falha)) {
          await _pendentes.remover(pendente.identificador);
        }
        return Erro(falha);
      case Sucesso(:final valor):
        return _aposFaturaPersistida(pendente, valor, aoMudarFase);
    }
  }

  Future<Resultado<ResultadoEncerramento>> _aposFaturaPersistida(
    TransacaoPendente pendente,
    FaturaReferencia fatura,
    void Function(FaseEncerramento fase) aoMudarFase,
  ) async {
    final falha = ValidacoesEncerramento.validarFatura(pendente, fatura);
    if (falha != null) return Erro(falha);

    final criada = pendente.copiarCom(
      etapa: EtapaTransacao.faturaCriada,
      faturaId: fatura.id,
      faturaCodigo: fatura.codigo,
    );
    await _pendentes.salvar(criada);
    return _confirmar(criada, fatura, aoMudarFase);
  }

  /// Ação 30 com a fatura persistida. Só aqui o atendimento é dado por
  /// encerrado; qualquer falha mantém a pendência para repetir SÓ este passo.
  Future<Resultado<ResultadoEncerramento>> _confirmar(
    TransacaoPendente pendente,
    FaturaReferencia fatura,
    void Function(FaseEncerramento fase) aoMudarFase,
  ) async {
    aoMudarFase(FaseEncerramento.confirmandoEncerramento);
    final enviada =
        pendente.copiarCom(etapa: EtapaTransacao.confirmacaoEnviada);
    await _pendentes.salvar(enviada);

    final resultado = await _fonteEncerramento.enviar(
      RequisicaoEncerramento.confirmar(
        atendimentosBrutos: enviada.atendimentosBrutos,
        sessaoId: enviada.sessaoId,
        sessaoCodigo: enviada.sessaoCodigo,
        faturaId: enviada.faturaId,
        faturaCodigo: enviada.faturaCodigo,
      ),
    );
    if (resultado is Erro<void>) return Erro(resultado.falha);

    await _pendentes.remover(enviada.identificador);
    aoMudarFase(FaseEncerramento.concluida);
    return Sucesso(ResultadoEncerramento(
        fatura: fatura, atendimentoIds: enviada.atendimentoIds));
  }

  /// Retoma uma pendência do ponto onde parou.
  Future<Resultado<ResultadoEncerramento>> _retomar(
    TransacaoPendente pendente,
    ConfiguracaoFaturamento? configuracao,
    void Function(FaseEncerramento fase) aoMudarFase,
  ) async {
    switch (pendente.etapa) {
      case EtapaTransacao.preparacaoEnviada:
        // Fatura ainda não montada: refaz da ação 10 com o MESMO
        // identificador (nenhum dado financeiro foi criado).
        final metodo = MetodoPagamento.values.asNameMap()[pendente.metodo];
        if (metodo == null) {
          return const Erro(FalhaValidacao(
              'A pendência tem uma forma de pagamento desconhecida e não '
              'pode ser retomada automaticamente.'));
        }
        if (configuracao == null || !configuracao.completaPara(metodo)) {
          return Erro(FalhaValidacao(
              'A forma de pagamento "${metodo.name}" desta pendência não '
              'está mais configurada para faturamento.'));
        }
        // Reusa o parser oficial: os brutos são o eco integral da coleção.
        final atendimentos =
            RespostaConsumoAtendimento.paraLista(pendente.atendimentosBrutos);
        return _prosseguirDaPreparacao(
            pendente, atendimentos, configuracao, metodo,
            aoMudarFase: aoMudarFase);
      case EtapaTransacao.faturaEnviada:
        return _reconciliarFatura(pendente, aoMudarFase);
      case EtapaTransacao.faturaCriada:
      case EtapaTransacao.confirmacaoEnviada:
        return _confirmarComVerificacao(pendente, aoMudarFase);
    }
  }

  /// A fatura foi enviada mas a resposta se perdeu: consulta as faturas da
  /// sessão procurando o identificador. Achou → segue para a ação 30; a
  /// consulta funcionou e NÃO achou → reenvia o payload congelado (mesmo
  /// identificador); consulta falhou/ambígua → mantém a pendência e erra.
  Future<Resultado<ResultadoEncerramento>> _reconciliarFatura(
    TransacaoPendente pendente,
    void Function(FaseEncerramento fase) aoMudarFase,
  ) async {
    aoMudarFase(FaseEncerramento.gerandoFatura);
    switch (await _procurarFaturaDaPendencia(pendente)) {
      case Erro(:final falha):
        return Erro(falha);
      case Sucesso(valor: null):
        return _gerarFatura(pendente, aoMudarFase, primeiroEnvio: false);
      case Sucesso(:final valor):
        return _aposFaturaPersistida(pendente, valor!, aoMudarFase);
    }
  }

  /// Repete a ação 30. Se o servidor recusar, verifica se os atendimentos
  /// ainda estão abertos na loja — todos ausentes = já foi encerrado.
  Future<Resultado<ResultadoEncerramento>> _confirmarComVerificacao(
    TransacaoPendente pendente,
    void Function(FaseEncerramento fase) aoMudarFase,
  ) async {
    // Referência local: a resposta original se perdeu, mas a quitação foi
    // validada quando a fatura virou `faturaCriada` (pago = total, saldo 0).
    final fatura = FaturaReferencia(
      id: pendente.faturaId,
      codigo: pendente.faturaCodigo,
      identificador: pendente.identificador,
      situacao: _situacaoPaga,
      pagoCentavos: ValidacoesEncerramento.somaBrutos(
          pendente.atendimentosBrutos, 'total'),
      saldoCentavos: 0,
    );
    final resultado = await _confirmar(pendente, fatura, aoMudarFase);
    if (resultado is Sucesso<ResultadoEncerramento>) return resultado;

    final falha = (resultado as Erro<ResultadoEncerramento>).falha;
    if (falha is FalhaServidor && await _jaEncerrado(pendente)) {
      await _pendentes.remover(pendente.identificador);
      aoMudarFase(FaseEncerramento.concluida);
      return Sucesso(ResultadoEncerramento(
          fatura: fatura, atendimentoIds: pendente.atendimentoIds));
    }
    return resultado;
  }

  /// Recupera pendências ao iniciar o app / restaurar a sessão. Resolve o
  /// que der sem interação e reporta quantas foram concluídas.
  Future<int> confirmarTransacoesPendentes() async {
    if (_emAndamento) return 0;
    _emAndamento = true;
    try {
      var resolvidas = 0;
      for (final pendente in await _pendentes.obterTodas()) {
        resolvidas += await _recuperar(pendente) ? 1 : 0;
      }
      return resolvidas;
    } finally {
      _emAndamento = false;
    }
  }

  Future<bool> _recuperar(TransacaoPendente pendente) async {
    switch (pendente.etapa) {
      case EtapaTransacao.preparacaoEnviada:
        // A ação 10 PODE ter chegado ao servidor; a pendência fica guardada
        // para retomada exata (ou descarte quando uma seleção nova e
        // diferente envolver os mesmos atendimentos).
        registrador.i('Pendência ${pendente.identificador} aguardando '
            'retomada (preparação sem fatura).');
        return false;
      case EtapaTransacao.faturaEnviada:
        return _reconciliarNaRecuperacao(pendente);
      case EtapaTransacao.faturaCriada:
      case EtapaTransacao.confirmacaoEnviada:
        final resultado = await _confirmarComVerificacao(pendente, (_) {});
        return resultado is Sucesso<ResultadoEncerramento>;
    }
  }

  /// Na recuperação em segundo plano NÃO recria fatura: só resolve o que já
  /// existe no servidor. Fatura inexistente = tentativa abandonada.
  Future<bool> _reconciliarNaRecuperacao(TransacaoPendente pendente) async {
    switch (await _procurarFaturaDaPendencia(pendente)) {
      case Erro(:final falha):
        registrador.w('Pendência ${pendente.identificador}: reconciliação '
            'indisponível (${falha.mensagem}).');
        return false;
      case Sucesso(valor: null):
        await _pendentes.remover(pendente.identificador);
        registrador.i('Pendência ${pendente.identificador} descartada '
            '(fatura não foi criada no retaguarda).');
        return false;
      case Sucesso(:final valor):
        final resultado = await _aposFaturaPersistida(pendente, valor!, (_) {});
        return resultado is Sucesso<ResultadoEncerramento>;
    }
  }

  /// Procura a fatura da pendência consultando o retaguarda POR ATENDIMENTO
  /// (`texto=<id>` casa a fatura pela ocupação da modalidade — não existe
  /// consulta por sessão nem por identificador). `Sucesso(null)` = consulta
  /// ok e não existe; `Erro` = consulta falhou/ilegível/ambígua — nunca
  /// confundir com "não existe". Fatura estornada é tentativa antiga já
  /// desfeita e não conta.
  Future<Resultado<FaturaReferencia?>> _procurarFaturaDaPendencia(
      TransacaoPendente pendente) async {
    final idsFatura = <String>{};
    for (final atendimentoId in pendente.atendimentoIds) {
      final consulta =
          await _fonteFatura.consultarPorAtendimento(atendimentoId);
      switch (consulta) {
        case Erro(:final falha):
          return Erro(falha);
        case Sucesso(:final valor):
          for (final fatura in valor) {
            if (JsonLeniente.inteiro(fatura['situacao']) ==
                FaturaSituacao.estornada.valor) {
              continue;
            }
            final id = JsonLeniente.texto(fatura['id']);
            if (id.isNotEmpty) idsFatura.add(id);
          }
      }
    }
    if (idsFatura.length > 1) {
      return const Erro(
          FalhaServidor('Mais de uma fatura corresponde a esta operação. '
              'Verifique no retaguarda antes de continuar.'));
    }
    if (idsFatura.isEmpty) return const Sucesso(null);

    // A coleção vem enxuta (sem identificador nem quitação): o detalhe traz
    // o que as validações da ação 30 exigem.
    final detalhe = await _fonteFatura.obterBruta(idsFatura.single);
    return switch (detalhe) {
      Erro(:final falha) => Erro(falha),
      Sucesso(:final valor) => Sucesso(RespostaFatura.paraReferencia(valor)),
    };
  }

  // ---- auxiliares ----

  /// Configuração de faturamento SEM intervenção do técnico: cache da mesma
  /// sessão → derivação das faturas que o caixa já gerou → cache antigo como
  /// reserva (nuvem fora do ar ou sessão ainda sem vendas). Cache da própria
  /// sessão só encerra a busca se cobrir a forma pedida — a primeira venda
  /// do dia numa forma nova (ex.: PIX no caixa) precisa ser re-aprendida.
  Future<ConfiguracaoFaturamento?> _resolverConfiguracao(
      String sessaoId, MetodoPagamento metodo) async {
    final cache = await _configuracoes.obter();
    if (sessaoId.isEmpty) return cache;
    if (cache != null &&
        cache.sessaoOrigem == sessaoId &&
        cache.completaPara(metodo)) {
      return cache;
    }

    final derivada = await _derivarConfiguracao(sessaoId);
    if (derivada == null) {
      if (cache != null) {
        registrador.i('Faturamento: sessão $sessaoId sem faturas deriváveis; '
            'usando configuração aprendida anteriormente.');
      }
      return cache;
    }
    final mesclada = derivada.mesclandoFormasDe(cache);
    try {
      await _configuracoes.salvar(jsonEncode(mesclada.paraJson()));
    } catch (erro) {
      registrador.w('Faturamento: falha ao gravar cache derivado: $erro');
    }
    return mesclada;
  }

  /// As faturas da sessão vêm do mapa de atendimentos ENCERRADOS da própria
  /// loja (cada um ecoa a fatura que o encerrou); o detalhe de cada fatura é
  /// buscado na nuvem — limitado às mais recentes para não atrasar o fluxo
  /// de pagamento.
  Future<ConfiguracaoFaturamento?> _derivarConfiguracao(String sessaoId) async {
    final consulta =
        await _fonteAtendimentosSessao.consultarEncerrados(sessaoId);
    if (consulta is! Sucesso<List<AtendimentoEncerrado>>) return null;

    final encerrados = [...consulta.valor]
      ..sort((a, b) => b.conclusao.compareTo(a.conclusao));
    final idsFatura = <String>{};
    for (final encerrado in encerrados) {
      if (encerrado.faturaId.isEmpty) continue;
      idsFatura.add(encerrado.faturaId);
      if (idsFatura.length == 3) break;
    }
    final detalhadas = <Map<String, dynamic>>[];
    for (final id in idsFatura) {
      final detalhe = await _fonteFatura.obterBruta(id);
      if (detalhe is Sucesso<Map<String, dynamic>>) {
        detalhadas.add(detalhe.valor);
      }
    }
    return DerivadorConfiguracaoFaturamento.derivar(detalhadas,
        sessaoId: sessaoId);
  }

  Future<TransacaoPendente?> _pendenteEnvolvendo(List<String> ids) async {
    for (final pendente in await _pendentes.obterTodas()) {
      if (pendente.atendimentoIds.any(ids.contains)) return pendente;
    }
    return null;
  }

  static bool _mesmoConjunto(List<String> a, List<String> b) =>
      a.toSet().containsAll(b) && b.toSet().containsAll(a);

  /// Algum atendimento da pendência ainda aparece como aberto na loja?
  /// Consulta TODAS as referências envolvidas; qualquer consulta falhando
  /// devolve `false` (não dá para afirmar que já encerrou).
  Future<bool> _jaEncerrado(TransacaoPendente pendente) async {
    final fonte = _fonteConsumo;
    if (fonte == null) return false;
    final referencias = {
      for (final bruto in pendente.atendimentosBrutos)
        JsonLeniente.texto(bruto['referencia']),
    }..remove('');
    if (referencias.isEmpty) return false;
    final abertos = <String>{};
    for (final referencia in referencias) {
      final consulta = await fonte.consultar(referencia: referencia);
      if (consulta is! Sucesso<List<Atendimento>>) return false;
      abertos.addAll([for (final a in consulta.valor) a.id]);
    }
    return !pendente.atendimentoIds.any(abertos.contains);
  }

  /// Incerteza de entrega: o pedido pode ter chegado ao servidor mesmo sem
  /// resposta. Exige reconciliação em vez de nova tentativa cega.
  bool _incerta(Falha falha) =>
      falha is FalhaTimeout || falha is FalhaRede || falha is FalhaDesconhecida;

  int _totalCentavos(List<Atendimento> atendimentos) =>
      atendimentos.fold(0, (soma, a) => soma + a.totalCentavos);
}
