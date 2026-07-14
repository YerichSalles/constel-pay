import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../comprovante/dominio/entidades/comprovante.dart';
import '../../../configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import '../../../encerramento/dominio/casos_uso/caso_uso_encerrar_atendimentos.dart';
import '../../../encerramento/dominio/entidades/fase_encerramento.dart';
import '../../../encerramento/dominio/entidades/resultado_encerramento.dart';
import '../../../leitura_cartao/dados/adaptadores/adaptador_atendimento.dart';
import '../../../leitura_cartao/dados/fontes_dados/fonte_consumo_atendimento.dart';
import '../../../leitura_cartao/dados/fontes_dados/fonte_recurso_item.dart';
import '../../../leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart';
import '../../../leitura_cartao/dominio/repositorios/repositorio_leitura.dart';
import '../../../pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart';
import '../../../pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart';
import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';
import '../../../pagamento/dominio/entidades/pagamento.dart';
import '../../../pagamento/dominio/entidades/status_pagamento.dart';
import '../../dominio/entidades/mensagem.dart';
import '../../dominio/entidades/tipo_mensagem.dart';
import 'apoio_encerramento_chat.dart';
import 'estado_fluxo_pagamento.dart';

class ControladorFluxoPagamento extends StateNotifier<EstadoFluxoPagamento> {
  ControladorFluxoPagamento({
    required CasoUsoLerCartao casoUsoLerCartao,
    required RepositorioLeitura repositorioLeitura,
    required CasoUsoGerarPix casoUsoGerarPix,
    required CasoUsoProcessarPagamento casoUsoProcessarPagamento,
    required RepositorioConfiguracao repositorioConfiguracao,
    required AppLocalizations Function() obterTraducoes,
    FonteConsumoAtendimento? fonteConsumoAtendimento,
    FonteRecursoItem? fonteRecursoItem,
    CasoUsoEncerrarAtendimentos? casoUsoEncerrar,
    this.atrasoBot = const Duration(milliseconds: 650),
  })  : _casoUsoLerCartao = casoUsoLerCartao,
        _repositorioLeitura = repositorioLeitura,
        _casoUsoGerarPix = casoUsoGerarPix,
        _casoUsoProcessarPagamento = casoUsoProcessarPagamento,
        _repositorioConfiguracao = repositorioConfiguracao,
        _obterTraducoes = obterTraducoes,
        _fonteConsumoAtendimento = fonteConsumoAtendimento,
        _fonteRecursoItem = fonteRecursoItem,
        _encerramento = ApoioEncerramentoChat(casoUso: casoUsoEncerrar),
        super(const EstadoFluxoPagamento());

  final CasoUsoLerCartao _casoUsoLerCartao;
  final RepositorioLeitura _repositorioLeitura;
  final FonteConsumoAtendimento? _fonteConsumoAtendimento;
  final FonteRecursoItem? _fonteRecursoItem;
  final CasoUsoGerarPix _casoUsoGerarPix;
  final CasoUsoProcessarPagamento _casoUsoProcessarPagamento;
  final RepositorioConfiguracao _repositorioConfiguracao;
  final AppLocalizations Function() _obterTraducoes;
  final ApoioEncerramentoChat _encerramento;
  final Duration atrasoBot;

  static const Uuid _uuid = Uuid();

  int _proximoIdMensagem = 1;
  String? _chaveIdempotencia;
  Comprovante? _ultimoComprovante;

  // ---- auxiliares ----

  Mensagem _mensagem(
    TipoMensagem tipo, {
    LadoMensagem lado = LadoMensagem.assistente,
    String? texto,
    String? subtexto,
    String? emoji,
    Map<String, dynamic>? dados,
  }) =>
      Mensagem(
        id: _proximoIdMensagem++,
        tipo: tipo,
        lado: lado,
        texto: texto,
        subtexto: subtexto,
        emoji: emoji,
        dados: dados,
      );

  void _adicionar(Mensagem mensagem) =>
      state = state.copyWith(mensagens: [...state.mensagens, mensagem]);

  /// Traduz a mensagem de uma falha: os tipos com texto padrão usam a chave
  /// correspondente no idioma atual; `FalhaValidacao` carrega texto próprio
  /// (vindo da API/regra de negócio) e é exibida como veio.
  String _mensagemFalha(Falha falha) {
    final t = _obterTraducoes();
    return switch (falha) {
      FalhaRede() => t.errorNetwork,
      FalhaTimeout() => t.errorTimeout,
      FalhaServidor() => t.errorServer,
      FalhaNaoAutorizado() => t.errorUnauthorized,
      FalhaValidacao() => falha.mensagem,
      FalhaDesconhecida() => t.errorUnknown,
    };
  }

  String _rotuloMetodo(MetodoPagamento metodo) {
    final t = _obterTraducoes();
    return switch (metodo) {
      MetodoPagamento.pix => t.paymentMethodPix,
      MetodoPagamento.credito => t.paymentMethodCredit,
      MetodoPagamento.debito => t.paymentMethodDebit,
      MetodoPagamento.tef => t.paymentMethodTef,
      MetodoPagamento.pos => t.paymentMethodPos,
      MetodoPagamento.voucher => t.paymentMethodVoucher,
      MetodoPagamento.dinheiro => t.paymentMethodCash,
    };
  }

  String _rotuloStatus(StatusPagamento status) {
    final t = _obterTraducoes();
    return switch (status) {
      StatusPagamento.aguardando => t.paymentStatusWaiting,
      StatusPagamento.processando => t.paymentStatusProcessing,
      StatusPagamento.aprovado => t.paymentStatusApproved,
      StatusPagamento.recusado => t.paymentStatusDeclined,
      StatusPagamento.cancelado => t.paymentStatusCancelled,
      StatusPagamento.expirado => t.paymentStatusExpired,
      StatusPagamento.erro => t.paymentStatusError,
    };
  }

  /// Busca a foto de cada item novo no cadastro da loja e atualiza os cartões.
  /// Enfeite: roda depois da comanda já estar na tela, em paralelo, e engole
  /// falhas — item sem foto (ou API fora) simplesmente mantém o emoji.
  Future<void> _carregarFotosItens() async {
    final fonte = _fonteRecursoItem;
    if (fonte == null) return;
    final pendentes = {
      for (final cartao in state.cartoes)
        for (final item in cartao.itens)
          if (item.itemId.isNotEmpty && item.imagemUrl.isEmpty) item.itemId,
    };
    if (pendentes.isEmpty) return;

    final urls = <String, String>{};
    await Future.wait(pendentes.map((itemId) async {
      final url = await fonte.obterImagem(itemId);
      if (url.isNotEmpty) urls[itemId] = url;
    }));
    if (!mounted || urls.isEmpty) return;

    state = state.copyWith(
      cartoes: [
        for (final cartao in state.cartoes)
          cartao.copyWith(
            itens: [
              for (final item in cartao.itens)
                urls.containsKey(item.itemId) && item.imagemUrl.isEmpty
                    ? item.copyWith(imagemUrl: urls[item.itemId]!)
                    : item,
            ],
          ),
      ],
    );
  }

  Future<void> _bot(void Function() acao) async {
    state = state.copyWith(digitando: true);
    await Future<void>.delayed(atrasoBot);
    if (!mounted) return;
    state = state.copyWith(digitando: false);
    acao();
  }

  // ---- fluxo ----

  Future<void> iniciar() async {
    if (state.etapa != EtapaFluxo.inicial) return;
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      final t = _obterTraducoes();
      _adicionar(_mensagem(TipoMensagem.texto, texto: t.welcomeMessage));
      _adicionar(_mensagem(TipoMensagem.texto, texto: t.scanInstruction));
      _adicionar(_mensagem(TipoMensagem.scanner));
    });
  }

  Future<void> lerCartao() async {
    if (state.etapa != EtapaFluxo.lendo || state.digitando) return;
    state = state.copyWith(digitando: true);
    final resultado = await _casoUsoLerCartao.executar();
    if (!mounted) return;
    state = state.copyWith(digitando: false);
    resultado.quando(
      sucesso: (cartao) {
        final t = _obterTraducoes();
        state = state.copyWith(
          cartoes: [...state.cartoes, cartao.copyWith(selecionado: true)],
          cartoesRestantes: _repositorioLeitura.cartoesRestantes,
        );
        _adicionar(_mensagem(TipoMensagem.leituraCartao,
            dados: {'comandaId': cartao.id}));
        _adicionar(_mensagem(TipoMensagem.texto,
            texto: state.cartoesRestantes > 0
                ? t.addAnotherCardQuestion
                : t.lastCardOpenMessage));
        state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
      },
      erro: (falha) {
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: '⚠️',
            texto: _obterTraducoes().cardReadErrorTitle,
            subtexto: _mensagemFalha(falha)));
        state = state.copyWith(etapa: EtapaFluxo.erroLeitura);
      },
    );
  }

  // TEMPORÁRIO (teste da API de consumo): leitura digitando o número da
  // comanda em vez do código de barras. Remover quando o scanner real
  // substituir o mock.
  Future<void> lerComandaDigitada(String referencia) async {
    final fonte = _fonteConsumoAtendimento;
    final ref = referencia.trim();
    if (fonte == null || ref.isEmpty) return;
    if (state.etapa != EtapaFluxo.lendo || state.digitando) return;
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente,
        texto: _obterTraducoes().clientCardEcho(ref)));
    state = state.copyWith(digitando: true);
    final resultado = await fonte.consultar(referencia: ref);
    if (!mounted) return;
    state = state.copyWith(digitando: false);
    resultado.quando(
      sucesso: (atendimentos) {
        _encerramento.registrar(atendimentos);
        final t = _obterTraducoes();
        if (atendimentos.isEmpty) {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '🔎',
              texto: t.noOpenItemsTitle,
              subtexto: t.noOpenItemsMessage(ref)));
          state = state.copyWith(etapa: EtapaFluxo.semConsumo);
          return;
        }
        var adicionouNovo = false;
        for (final atendimento in atendimentos) {
          if (state.cartoes.any((c) => c.id == atendimento.id)) continue;
          final cartao = AdaptadorAtendimento.paraCartao(atendimento)
              .copyWith(selecionado: true);
          state = state.copyWith(cartoes: [...state.cartoes, cartao]);
          _adicionar(_mensagem(TipoMensagem.leituraCartao,
              dados: {'comandaId': cartao.id}));
          adicionouNovo = true;
        }
        if (!adicionouNovo) {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '🔁',
              texto: t.cardAlreadyAddedTitle,
              subtexto: t.cardAlreadyAddedMessage(ref)));
          state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
          return;
        }
        _adicionar(
            _mensagem(TipoMensagem.texto, texto: t.addAnotherCardQuestion));
        state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
      },
      erro: (falha) {
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: '⚠️',
            texto: _obterTraducoes().cardReadErrorTitle,
            subtexto: _mensagemFalha(falha)));
        state = state.copyWith(etapa: EtapaFluxo.erroLeitura);
      },
    );
    await _carregarFotosItens();
  }

  Future<void> lerOutroCartao() async {
    if (state.etapa != EtapaFluxo.aguardandoMaisCartoes) return;
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente, texto: _obterTraducoes().addAnotherCard));
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          texto: _obterTraducoes().nextCardInstruction));
      _adicionar(_mensagem(TipoMensagem.scanner));
    });
  }

  /// Sai de um aviso (sem consumo / erro de leitura) de volta ao leitor,
  /// preservando todas as comandas já adicionadas.
  Future<void> tentarNovamente() async {
    if (state.etapa != EtapaFluxo.semConsumo &&
        state.etapa != EtapaFluxo.erroLeitura) {
      return;
    }
    final t = _obterTraducoes();
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente,
        texto: state.etapa == EtapaFluxo.semConsumo
            ? t.tryAnotherCard
            : t.tryAgain));
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          texto: _obterTraducoes().nextCardInstruction));
      _adicionar(_mensagem(TipoMensagem.scanner));
    });
  }

  Future<void> irParaPagamento() async {
    if (state.etapa != EtapaFluxo.aguardandoMaisCartoes ||
        state.selecionados.isEmpty) {
      return;
    }
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente,
        texto: _obterTraducoes().continueToPaymentWithAmount(
            FormatadorMoeda.formatar(state.subtotalCentavos))));
    await _avancarParaEscolhaMetodo();
  }

  /// Desiste da inclusão em andamento e avança usando só as comandas
  /// já adicionadas. Não remove nada e não altera totais.
  Future<void> continuarComCartoes() async {
    const etapasInclusao = [
      EtapaFluxo.lendo,
      EtapaFluxo.semConsumo,
      EtapaFluxo.erroLeitura,
    ];
    if (!etapasInclusao.contains(state.etapa) ||
        state.digitando ||
        state.selecionados.isEmpty) {
      return;
    }
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente,
        texto: _obterTraducoes()
            .continueWithAddedCardsCount(state.selecionados.length)));
    await _avancarParaEscolhaMetodo();
  }

  Future<void> _avancarParaEscolhaMetodo() async {
    _chaveIdempotencia = _uuid.v4();
    state = state.copyWith(etapa: EtapaFluxo.escolhaMetodo);
    await _bot(() {
      final t = _obterTraducoes();
      _adicionar(_mensagem(TipoMensagem.texto,
          emoji: '💳',
          texto: t.howWouldYouLikePay(
              FormatadorMoeda.formatar(state.totalCentavos)),
          subtexto: state.servicoCentavos > 0
              ? t.includesServiceFee(
                  FormatadorMoeda.formatar(state.servicoCentavos))
              : null));
      _adicionar(_mensagem(TipoMensagem.metodos));
    });
  }

  Future<void> selecionarMetodo(MetodoPagamento metodo) async {
    if (state.etapa != EtapaFluxo.escolhaMetodo || state.digitando) return;
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente, texto: _rotuloMetodo(metodo)));
    if (metodo != MetodoPagamento.pix) {
      await _bot(() {
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: 'ℹ️', texto: _obterTraducoes().methodNotAvailable));
      });
      return;
    }
    state = state.copyWith(digitando: true, copiado: false);
    final resultado = await _casoUsoGerarPix.executar(
      chaveIdempotencia: _chaveIdempotencia!,
      valorCentavos: state.totalCentavos,
    );
    if (!mounted) return;
    state = state.copyWith(digitando: false);
    resultado.quando(
      sucesso: (dados) {
        state =
            state.copyWith(dadosPix: dados, etapa: EtapaFluxo.pixAguardando);
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: '📲', texto: _obterTraducoes().pixReadyMessage));
        _adicionar(_mensagem(TipoMensagem.pix));
      },
      erro: (falha) {
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: '⚠️', texto: _mensagemFalha(falha)));
      },
    );
  }

  void marcarCopiado() => state = state.copyWith(copiado: true);

  Future<void> confirmarPagamentoPix() async {
    if (state.etapa != EtapaFluxo.pixAguardando || state.digitando) return;
    state = state.copyWith(digitando: true);
    final selecionados = state.selecionados;

    // Impedimento conhecido do encerramento (config incompleta, pendência
    // conflitante, mistura com demonstração) precisa barrar ANTES da
    // cobrança — não depois do dinheiro debitado.
    final impedimento = await _encerramento.validarAntesDoPagamento(
        selecionados: selecionados, metodo: MetodoPagamento.pix);
    if (!mounted) return;
    if (impedimento != null) {
      state = state.copyWith(digitando: false);
      _adicionar(_mensagem(TipoMensagem.texto,
          emoji: '⚠️',
          texto: _obterTraducoes().closingErrorTitle,
          subtexto: _mensagemFalha(impedimento)));
      return;
    }

    state = state.copyWith(etapa: EtapaFluxo.processando);
    final agora = DateTime.now();
    final pagamento = Pagamento(
      id: _chaveIdempotencia!,
      valorCentavos: state.subtotalCentavos,
      servicoCentavos: state.servicoCentavos,
      descontoCentavos: state.descontoCentavos,
      totalCentavos: state.totalCentavos,
      metodo: MetodoPagamento.pix,
      status: StatusPagamento.processando,
      criadoEm: agora,
      atualizadoEm: agora,
      comandaIds: selecionados.map((c) => c.id).toList(),
    );
    final resultado = await _casoUsoProcessarPagamento.executar(pagamento);
    if (!mounted) return;
    final configuracao = await _repositorioConfiguracao.obter();
    if (!mounted) return;
    switch (resultado) {
      case Erro(:final falha):
        state = state.copyWith(digitando: false);
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: '⚠️', texto: _mensagemFalha(falha)));
        state = state.copyWith(etapa: EtapaFluxo.pixAguardando);
      case Sucesso(valor: final aprovado):
        final t = _obterTraducoes();
        if (aprovado.status != StatusPagamento.aprovado) {
          state = state.copyWith(digitando: false);
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '❌',
              texto: t.paymentNotApproved(
                  _rotuloStatus(aprovado.status).toLowerCase())));
          state = state.copyWith(etapa: EtapaFluxo.pixAguardando);
          return;
        }

        // Encerramento financeiro real (ação 10 → fatura → ação 30) quando
        // as comandas vieram da API. Só depois da ação 30 confirmada os
        // cartões são dados como pagos; erro mantém a comanda aberta e
        // permite tentar de novo — a pendência preserva o identificador.
        final encerramento = await _encerramento.encerrar(
          selecionados: selecionados,
          metodo: MetodoPagamento.pix,
          aoMudarFase: _mensagemDeFase,
        );
        if (!mounted) return;
        state = state.copyWith(digitando: false);
        if (encerramento is Erro<ResultadoEncerramento>) {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '⚠️',
              texto: t.closingErrorTitle,
              subtexto: _mensagemFalha(encerramento.falha)));
          state = state.copyWith(etapa: EtapaFluxo.pixAguardando);
          return;
        }

        final nomes = selecionados.map((c) => c.nome).toList();
        final cartoesAtualizados = state.cartoes
            .map((c) => c.selecionado && !c.pago
                ? c.copyWith(pago: true, selecionado: false)
                : c)
            .toList();
        state = state.copyWith(cartoes: cartoesAtualizados);
        _adicionar(_mensagem(TipoMensagem.sucesso, dados: {
          'valorCentavos': aprovado.totalCentavos,
          'comandas': nomes
        }));
        _ultimoComprovante = Comprovante(
          id: _uuid.v4(),
          pagamentoId: aprovado.id,
          valorCentavos: aprovado.totalCentavos,
          metodo: aprovado.metodo,
          comandas: nomes,
          dataHora: DateTime.now(),
          nomeRestaurante: configuracao.nomeRestaurante,
        );
        _chaveIdempotencia = null;
        final restantes = state.cartoesRestantes;
        if (restantes > 0) {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '🧾', texto: t.remainingCardsQuestion(restantes)));
          state = state.copyWith(etapa: EtapaFluxo.sucessoComRestante);
        } else {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '🥳', texto: t.allCardsSettled));
          state = state.copyWith(etapa: EtapaFluxo.sucessoCompleto);
        }
    }
  }

  /// Mensagem de progresso de cada fase do encerramento financeiro.
  void _mensagemDeFase(FaseEncerramento fase) {
    if (!mounted) return;
    final t = _obterTraducoes();
    final texto = switch (fase) {
      FaseEncerramento.preparandoEncerramento => t.closingPreparing,
      FaseEncerramento.gerandoFatura => t.closingGeneratingInvoice,
      FaseEncerramento.confirmandoEncerramento => t.closingConfirming,
      _ => null,
    };
    if (texto != null) {
      _adicionar(_mensagem(TipoMensagem.texto, emoji: '🧾', texto: texto));
    }
  }

  Future<void> pagarRestante() async {
    if (state.etapa != EtapaFluxo.sucessoComRestante) return;
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente, texto: _obterTraducoes().payRemaining));
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          texto: _obterTraducoes().nextCardInstruction));
      _adicionar(_mensagem(TipoMensagem.scanner));
    });
  }

  Future<void> encerrar() async {
    if (state.etapa != EtapaFluxo.sucessoComRestante &&
        state.etapa != EtapaFluxo.sucessoCompleto) {
      return;
    }
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente, texto: _obterTraducoes().endService));
    state = state.copyWith(etapa: EtapaFluxo.encerramento);
    await _bot(() {
      final t = _obterTraducoes();
      _adicionar(_mensagem(TipoMensagem.texto,
          emoji: '🙏', texto: t.thankYouMessage, subtexto: t.receiptMessage));
      final comprovante = _ultimoComprovante;
      if (comprovante != null) {
        _adicionar(_mensagem(TipoMensagem.comprovante, dados: {
          'id': comprovante.id,
          'valorCentavos': comprovante.valorCentavos,
          'metodo': comprovante.metodo.name,
          'comandas': comprovante.comandas,
          'dataHora': comprovante.dataHora.toIso8601String(),
          'nomeRestaurante': comprovante.nomeRestaurante,
        }));
      }
    });
  }

  void novaOperacao() {
    _repositorioLeitura.reiniciar();
    _proximoIdMensagem = 1;
    _chaveIdempotencia = null;
    _ultimoComprovante = null;
    _encerramento.limpar();
    state = const EstadoFluxoPagamento();
  }
}

final provedorFluxoPagamento =
    StateNotifierProvider<ControladorFluxoPagamento, EstadoFluxoPagamento>(
        (ref) {
  return ControladorFluxoPagamento(
    casoUsoLerCartao: ref.watch(provedorCasoUsoLerCartao),
    repositorioLeitura: ref.watch(provedorRepositorioLeitura),
    casoUsoGerarPix: ref.watch(provedorCasoUsoGerarPix),
    casoUsoProcessarPagamento: ref.watch(provedorCasoUsoProcessarPagamento),
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    obterTraducoes: () => lookupAppLocalizations(ref.read(provedorIdioma)),
    fonteConsumoAtendimento: ref.watch(provedorFonteConsumoAtendimento),
    fonteRecursoItem: ref.watch(provedorFonteRecursoItem),
    casoUsoEncerrar: ref.watch(provedorCasoUsoEncerrarAtendimentos),
    atrasoBot: ref.watch(provedorAtrasoBot),
  );
});
