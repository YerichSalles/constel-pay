import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../comprovante/dominio/entidades/comprovante.dart';
import '../../../configuracoes/dominio/repositorios/repositorio_configuracao.dart';
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
import 'estado_fluxo_pagamento.dart';

class ControladorFluxoPagamento extends StateNotifier<EstadoFluxoPagamento> {
  ControladorFluxoPagamento({
    required CasoUsoLerCartao casoUsoLerCartao,
    required RepositorioLeitura repositorioLeitura,
    required CasoUsoGerarPix casoUsoGerarPix,
    required CasoUsoProcessarPagamento casoUsoProcessarPagamento,
    required RepositorioConfiguracao repositorioConfiguracao,
    FonteConsumoAtendimento? fonteConsumoAtendimento,
    FonteRecursoItem? fonteRecursoItem,
    this.atrasoBot = const Duration(milliseconds: 650),
  })  : _casoUsoLerCartao = casoUsoLerCartao,
        _repositorioLeitura = repositorioLeitura,
        _casoUsoGerarPix = casoUsoGerarPix,
        _casoUsoProcessarPagamento = casoUsoProcessarPagamento,
        _repositorioConfiguracao = repositorioConfiguracao,
        _fonteConsumoAtendimento = fonteConsumoAtendimento,
        _fonteRecursoItem = fonteRecursoItem,
        super(const EstadoFluxoPagamento());

  final CasoUsoLerCartao _casoUsoLerCartao;
  final RepositorioLeitura _repositorioLeitura;
  final FonteConsumoAtendimento? _fonteConsumoAtendimento;
  final FonteRecursoItem? _fonteRecursoItem;
  final CasoUsoGerarPix _casoUsoGerarPix;
  final CasoUsoProcessarPagamento _casoUsoProcessarPagamento;
  final RepositorioConfiguracao _repositorioConfiguracao;
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
      _adicionar(_mensagem(TipoMensagem.texto,
          texto: 'Olá! Bem-vindo(a). Vou fechar sua conta em segundos. 😊'));
      _adicionar(_mensagem(TipoMensagem.texto,
          texto:
              'Para começar, aponte a câmera para o código do seu cartão de consumo 👇'));
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
        state = state.copyWith(
          cartoes: [...state.cartoes, cartao.copyWith(selecionado: true)],
          cartoesRestantes: _repositorioLeitura.cartoesRestantes,
        );
        _adicionar(_mensagem(TipoMensagem.leituraCartao,
            dados: {'comandaId': cartao.id}));
        _adicionar(_mensagem(TipoMensagem.texto,
            texto: state.cartoesRestantes > 0
                ? 'Deseja incluir outro cartão nesta conta?'
                : 'Esse foi o último cartão em aberto.'));
        state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
      },
      erro: (falha) {
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: '⚠️',
            texto: 'Não foi possível ler o cartão',
            subtexto: falha.mensagem));
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
        lado: LadoMensagem.cliente, texto: 'Comanda $ref'));
    state = state.copyWith(digitando: true);
    final resultado = await fonte.consultar(referencia: ref);
    if (!mounted) return;
    state = state.copyWith(digitando: false);
    resultado.quando(
      sucesso: (atendimentos) {
        if (atendimentos.isEmpty) {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '🔎',
              texto: 'Nenhum consumo em aberto',
              subtexto:
                  'Não encontramos itens pendentes para o cartão $ref.'));
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
              texto: 'Cartão já adicionado',
              subtexto: 'A comanda $ref já está incluída nesta conta.'));
          state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
          return;
        }
        _adicionar(_mensagem(TipoMensagem.texto,
            texto: 'Deseja incluir outro cartão nesta conta?'));
        state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
      },
      erro: (falha) {
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: '⚠️',
            texto: 'Não foi possível ler o cartão',
            subtexto: falha.mensagem));
        state = state.copyWith(etapa: EtapaFluxo.erroLeitura);
      },
    );
    await _carregarFotosItens();
  }

  Future<void> lerOutroCartao() async {
    if (state.etapa != EtapaFluxo.aguardandoMaisCartoes) return;
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente, texto: 'Adicionar outro cartão'));
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          texto: 'Beleza! Aponte a câmera para o próximo código 👇'));
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
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente,
        texto: state.etapa == EtapaFluxo.semConsumo
            ? 'Tentar outro cartão'
            : 'Tentar novamente'));
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          texto: 'Beleza! Aponte a câmera para o próximo código 👇'));
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
        texto:
            'Continuar para pagamento · ${FormatadorMoeda.formatar(state.subtotalCentavos)}'));
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
        texto: 'Continuar com ${state.rotuloCartoesAdicionados}'));
    await _avancarParaEscolhaMetodo();
  }

  Future<void> _avancarParaEscolhaMetodo() async {
    _chaveIdempotencia = _uuid.v4();
    state = state.copyWith(etapa: EtapaFluxo.escolhaMetodo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          emoji: '💳',
          texto:
              'Como você quer pagar ${FormatadorMoeda.formatar(state.totalCentavos)}?',
          subtexto: state.servicoCentavos > 0
              ? 'Inclui ${FormatadorMoeda.formatar(state.servicoCentavos)} de serviço.'
              : null));
      _adicionar(_mensagem(TipoMensagem.metodos));
    });
  }

  Future<void> selecionarMetodo(MetodoPagamento metodo) async {
    if (state.etapa != EtapaFluxo.escolhaMetodo || state.digitando) return;
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente, texto: metodo.rotulo));
    if (metodo != MetodoPagamento.pix) {
      await _bot(() {
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: 'ℹ️',
            texto:
                'Este método ainda não está disponível neste terminal. Use o Pix por enquanto. 😉'));
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
            emoji: '📲',
            texto: 'Pronto! Escaneie o QR Code ou copie o código Pix 👇'));
        _adicionar(_mensagem(TipoMensagem.pix));
      },
      erro: (falha) {
        _adicionar(
            _mensagem(TipoMensagem.texto, emoji: '⚠️', texto: falha.mensagem));
      },
    );
  }

  void marcarCopiado() => state = state.copyWith(copiado: true);

  Future<void> confirmarPagamentoPix() async {
    if (state.etapa != EtapaFluxo.pixAguardando || state.digitando) return;
    state = state.copyWith(etapa: EtapaFluxo.processando, digitando: true);
    final selecionados = state.selecionados;
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
    state = state.copyWith(digitando: false);
    final configuracao = await _repositorioConfiguracao.obter();
    if (!mounted) return;
    resultado.quando(
      sucesso: (aprovado) {
        if (aprovado.status != StatusPagamento.aprovado) {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '❌',
              texto:
                  'Pagamento ${aprovado.status.rotulo.toLowerCase()}. Tente novamente.'));
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
              emoji: '🧾',
              texto:
                  'Ainda há $restantes ${restantes > 1 ? 'cartões' : 'cartão'} em aberto. Quer pagar agora?'));
          state = state.copyWith(etapa: EtapaFluxo.sucessoComRestante);
        } else {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '🥳',
              texto: 'Tudo certo! Todos os cartões foram quitados.'));
          state = state.copyWith(etapa: EtapaFluxo.sucessoCompleto);
        }
      },
      erro: (falha) {
        _adicionar(
            _mensagem(TipoMensagem.texto, emoji: '⚠️', texto: falha.mensagem));
        state = state.copyWith(etapa: EtapaFluxo.pixAguardando);
      },
    );
  }

  Future<void> pagarRestante() async {
    if (state.etapa != EtapaFluxo.sucessoComRestante) return;
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente, texto: 'Pagar restante'));
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          texto: 'Beleza! Aponte a câmera para o próximo código 👇'));
      _adicionar(_mensagem(TipoMensagem.scanner));
    });
  }

  Future<void> encerrar() async {
    if (state.etapa != EtapaFluxo.sucessoComRestante &&
        state.etapa != EtapaFluxo.sucessoCompleto) {
      return;
    }
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente, texto: 'Encerrar'));
    state = state.copyWith(etapa: EtapaFluxo.encerramento);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          emoji: '🙏',
          texto: 'Obrigado pela visita! Volte sempre 💜',
          subtexto: 'Aqui está o seu comprovante.'));
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
    fonteConsumoAtendimento: ref.watch(provedorFonteConsumoAtendimento),
    fonteRecursoItem: ref.watch(provedorFonteRecursoItem),
    atrasoBot: ref.watch(provedorAtrasoBot),
  );
});
