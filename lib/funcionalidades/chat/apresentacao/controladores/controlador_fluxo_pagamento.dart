import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../nucleo/formatadores/formatador_moeda.dart';
import '../../../comprovante/dominio/entidades/comprovante.dart';
import '../../../configuracoes/dominio/repositorios/repositorio_configuracao.dart';
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
    this.atrasoBot = const Duration(milliseconds: 650),
  })  : _casoUsoLerCartao = casoUsoLerCartao,
        _repositorioLeitura = repositorioLeitura,
        _casoUsoGerarPix = casoUsoGerarPix,
        _casoUsoProcessarPagamento = casoUsoProcessarPagamento,
        _repositorioConfiguracao = repositorioConfiguracao,
        super(const EstadoFluxoPagamento());

  final CasoUsoLerCartao _casoUsoLerCartao;
  final RepositorioLeitura _repositorioLeitura;
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
          emoji: '🍽️',
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
    final primeiraLeitura = state.cartoes.isEmpty;
    if (primeiraLeitura) {
      final resultadoMesa = await _repositorioLeitura.obterMesa();
      resultadoMesa.quando(
        sucesso: (mesa) => state = state.copyWith(mesa: mesa),
        erro: (_) {},
      );
    }
    final resultado = await _casoUsoLerCartao.executar();
    if (!mounted) return;
    state = state.copyWith(digitando: false);
    resultado.quando(
      sucesso: (cartao) {
        state = state.copyWith(
          cartoes: [...state.cartoes, cartao.copyWith(selecionado: true)],
          cartoesRestantes: _repositorioLeitura.cartoesRestantes,
        );
        if (primeiraLeitura && state.mesa != null) {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '📍',
              texto:
                  'Cartão lido! Identificamos sua mesa: Mesa ${state.mesa!.numero} 🪑'));
          _adicionar(_mensagem(TipoMensagem.mesa));
        }
        _adicionar(_mensagem(TipoMensagem.leituraCartao,
            dados: {'comandaId': cartao.id}));
        _adicionar(_mensagem(TipoMensagem.texto,
            emoji: '✅',
            texto: state.cartoesRestantes > 0
                ? 'Deseja adicionar mais cartões da mesa?'
                : 'Esse foi o último cartão em aberto da mesa.'));
        state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
      },
      erro: (falha) {
        _adicionar(
            _mensagem(TipoMensagem.texto, emoji: '⚠️', texto: falha.mensagem));
        state = state.copyWith(etapa: EtapaFluxo.aguardandoMaisCartoes);
      },
    );
  }

  Future<void> lerOutroCartao() async {
    if (state.etapa != EtapaFluxo.aguardandoMaisCartoes) return;
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente, texto: 'Ler outro cartão'));
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          texto: 'Beleza! Aponte para o próximo código 👇'));
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
            'Ir para o pagamento · ${FormatadorMoeda.formatar(state.subtotalCentavos)}'));
    state = state.copyWith(etapa: EtapaFluxo.gorjeta);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          emoji: '💜',
          texto: 'Deseja incluir os 10% de serviço (gorjeta)?',
          subtexto: 'É opcional e vai direto para a equipe que te atendeu.'));
    });
  }

  Future<void> definirGorjeta(int percentual) async {
    if (state.etapa != EtapaFluxo.gorjeta) return;
    state = state.copyWith(gorjetaPercentual: percentual);
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente,
        texto: percentual > 0
            ? 'Sim, incluir os $percentual%'
            : 'Sem taxa de serviço'));
    _chaveIdempotencia = _uuid.v4();
    state = state.copyWith(etapa: EtapaFluxo.escolhaMetodo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          emoji: '💳',
          texto:
              'Como você quer pagar ${FormatadorMoeda.formatar(state.totalCentavos)}?',
          subtexto: percentual > 0
              ? 'Inclui ${FormatadorMoeda.formatar(state.gorjetaCentavos)} de serviço.'
              : 'Sem taxa de serviço.'));
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
      gorjetaCentavos: state.gorjetaCentavos,
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
        state =
            state.copyWith(cartoes: cartoesAtualizados, gorjetaPercentual: 0);
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
                  'Ainda há $restantes ${restantes > 1 ? 'comandas' : 'comanda'} em aberto na mesa. Quer pagar agora?'));
          state = state.copyWith(etapa: EtapaFluxo.sucessoComRestante);
        } else {
          _adicionar(_mensagem(TipoMensagem.texto,
              emoji: '🥳',
              texto: 'Tudo certo! Sua mesa está totalmente quitada.'));
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

  void verItens(String comandaId) => _adicionar(
      _mensagem(TipoMensagem.detalhe, dados: {'comandaId': comandaId}));

  Future<void> pagarRestante() async {
    if (state.etapa != EtapaFluxo.sucessoComRestante) return;
    _adicionar(_mensagem(TipoMensagem.texto,
        lado: LadoMensagem.cliente, texto: 'Pagar restante'));
    state = state.copyWith(etapa: EtapaFluxo.lendo);
    await _bot(() {
      _adicionar(_mensagem(TipoMensagem.texto,
          texto: 'Beleza! Aponte para o próximo código 👇'));
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
    atrasoBot: ref.watch(provedorAtrasoBot),
  );
});
