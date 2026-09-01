import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/chat/dominio/entidades/tipo_mensagem.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_consumo_atendimento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_recurso_item.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/repositorios/repositorio_leitura_impl.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/atendimento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/gateway_pagamento_mock.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/repositorios/repositorio_pagamento_impl.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_iniciar_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/parametros_adquirente.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/resultado_transacao.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/status_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/tipo_adquirente.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/repositorios/gateway_pagamento.dart';
import 'package:constel_pay/l10n/app_localizations.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

class _RepositorioConfiguracaoFake implements RepositorioConfiguracao {
  @override
  Future<ConfiguracaoTerminal> obter() async => const ConfiguracaoTerminal(
        nomeRestaurante: 'Durango Burgers',
      );

  @override
  Future<void> salvar(ConfiguracaoTerminal configuracao) async {}
}

class _FonteConsumoFake implements FonteConsumoAtendimento {
  _FonteConsumoFake(this.resultado);
  Resultado<List<Atendimento>> resultado;

  @override
  Future<Resultado<List<Atendimento>>> consultar(
          {required String referencia}) async =>
      resultado;
}

class _FonteRecursoFake implements FonteRecursoItem {
  @override
  Future<String> obterImagem(String itemId) async => '';
}

/// Gateway de terminal controlável: cada teste diz o que a maquininha responde.
class _GatewayTerminalFake implements GatewayPagamento {
  _GatewayTerminalFake(this.resposta);

  Resultado<ResultadoTransacao> resposta;
  int chamadas = 0;
  String? ultimaChave;
  ParametrosAdquirente? ultimosParametros;

  @override
  TipoAdquirente get adquirente => TipoAdquirente.stone;

  @override
  Set<MetodoPagamento> get metodosSuportados => const {
        MetodoPagamento.credito,
        MetodoPagamento.debito,
        MetodoPagamento.pix,
      };

  @override
  Future<Resultado<ResultadoTransacao>> iniciarPagamento({
    required String chaveIdempotencia,
    required int valorCentavos,
    required MetodoPagamento metodo,
    int parcelas = 1,
    ParametrosAdquirente parametros = const ParametrosAdquirente.nenhum(),
  }) async {
    chamadas++;
    ultimaChave = chaveIdempotencia;
    ultimosParametros = parametros;
    return resposta;
  }
}

const _atendimento502 = Atendimento(
  id: 'at502',
  codigo: '0010030',
  nome: 'Cartão 502',
  referencia: '502',
  situacao: 20,
  subtotalCentavos: 4530,
  servicoCentavos: 0,
  servicoPercentual: 0,
  descontoCentavos: 0,
  totalCentavos: 4530,
  pagoCentavos: 0,
  saldoCentavos: 4530,
  sessaoId: 's1',
  sessaoCodigo: '0003449',
  itens: [],
);

ResultadoTransacao _transacao(StatusPagamento status,
        {String mensagemOperador = ''}) =>
    ResultadoTransacao(
      status: status,
      metodo: MetodoPagamento.credito,
      valorCentavos: 4530,
      nsu: '778899',
      finalCartao: '4321',
      adquirente: 'Stone',
      mensagemOperador: mensagemOperador,
    );

void main() {
  late GatewayPagamentoMock fontePix;

  ControladorFluxoPagamento criar({_GatewayTerminalFake? terminal}) {
    fontePix = GatewayPagamentoMock(atraso: Duration.zero);
    final repositorioLeitura =
        RepositorioLeituraImpl(FonteLeituraMock(atraso: Duration.zero));
    final repositorioPagamento = RepositorioPagamentoImpl(fontePix);
    return ControladorFluxoPagamento(
      casoUsoLerCartao: CasoUsoLerCartao(repositorioLeitura),
      repositorioLeitura: repositorioLeitura,
      casoUsoGerarPix: CasoUsoGerarPix(repositorioPagamento),
      casoUsoProcessarPagamento:
          CasoUsoProcessarPagamento(repositorioPagamento),
      repositorioConfiguracao: _RepositorioConfiguracaoFake(),
      obterTraducoes: () => lookupAppLocalizations(const Locale('pt', 'BR')),
      fonteConsumoAtendimento:
          _FonteConsumoFake(const Sucesso([_atendimento502])),
      fonteRecursoItem: _FonteRecursoFake(),
      casoUsoIniciarPagamento:
          terminal == null ? null : CasoUsoIniciarPagamento(terminal),
      atrasoBot: Duration.zero,
    );
  }

  Future<void> ateEscolhaMetodo(ControladorFluxoPagamento c) async {
    await c.iniciar();
    await c.lerCartao();
    await c.irParaPagamento();
  }

  group('build genérica (sem adquirente embarcada)', () {
    test('cartão continua indisponível e não gera cobrança', () async {
      final controlador = criar();
      await ateEscolhaMetodo(controlador);
      await controlador.selecionarMetodo(MetodoPagamento.credito);
      expect(controlador.state.etapa, EtapaFluxo.escolhaMetodo);
      expect(controlador.state.mensagens.last.texto,
          contains('ainda não está disponível'));
    });

    test('PIX segue pelo QR Code na tela', () async {
      final controlador = criar();
      await ateEscolhaMetodo(controlador);
      await controlador.selecionarMetodo(MetodoPagamento.pix);
      expect(controlador.state.etapa, EtapaFluxo.pixAguardando);
      expect(controlador.state.dadosPix, isNotNull);
      expect(controlador.state.mensagens.last.tipo, TipoMensagem.pix);
    });
  });

  group('build com adquirente (Stone)', () {
    test('crédito aprovado quita a comanda sem passar por QR Code', () async {
      final terminal =
          _GatewayTerminalFake(Sucesso(_transacao(StatusPagamento.aprovado)));
      final controlador = criar(terminal: terminal);
      await ateEscolhaMetodo(controlador);
      await controlador.selecionarMetodo(MetodoPagamento.credito);

      expect(terminal.chamadas, 1);
      expect(controlador.state.dadosPix, isNull);
      expect(controlador.state.metodoSelecionado, MetodoPagamento.credito);
      expect(controlador.state.etapa,
          anyOf(EtapaFluxo.sucessoComRestante, EtapaFluxo.encerramento));
      expect(controlador.state.cartoes.every((c) => c.pago), isTrue);
      expect(
          controlador.state.mensagens
              .any((m) => m.tipo == TipoMensagem.sucesso),
          isTrue);
    });

    test('PIX também vai pela maquininha, sem card de QR Code', () async {
      final terminal =
          _GatewayTerminalFake(Sucesso(_transacao(StatusPagamento.aprovado)));
      final controlador = criar(terminal: terminal);
      await ateEscolhaMetodo(controlador);
      await controlador.selecionarMetodo(MetodoPagamento.pix);

      expect(terminal.chamadas, 1);
      expect(controlador.state.dadosPix, isNull);
      expect(controlador.state.mensagens.any((m) => m.tipo == TipoMensagem.pix),
          isFalse);
    });

    test('a chave de idempotência da escolha do método chega ao terminal',
        () async {
      final terminal =
          _GatewayTerminalFake(Sucesso(_transacao(StatusPagamento.aprovado)));
      final controlador = criar(terminal: terminal);
      await ateEscolhaMetodo(controlador);
      await controlador.selecionarMetodo(MetodoPagamento.debito);
      expect(terminal.ultimaChave, isNotNull);
      expect(terminal.ultimaChave, isNotEmpty);
    });

    test('recusa volta à escolha do método e não quita a comanda', () async {
      final terminal = _GatewayTerminalFake(Sucesso(
          _transacao(StatusPagamento.recusado, mensagemOperador: 'Sem saldo')));
      final controlador = criar(terminal: terminal);
      await ateEscolhaMetodo(controlador);
      await controlador.selecionarMetodo(MetodoPagamento.credito);

      expect(controlador.state.etapa, EtapaFluxo.escolhaMetodo);
      expect(controlador.state.cartoes.any((c) => c.pago), isFalse);
      expect(controlador.state.mensagens.last.subtexto, 'Sem saldo');
    });

    test('cancelamento na maquininha não é tratado como erro técnico',
        () async {
      final terminal =
          _GatewayTerminalFake(Sucesso(_transacao(StatusPagamento.cancelado)));
      final controlador = criar(terminal: terminal);
      await ateEscolhaMetodo(controlador);
      await controlador.selecionarMetodo(MetodoPagamento.debito);
      expect(controlador.state.etapa, EtapaFluxo.escolhaMetodo);
      expect(controlador.state.mensagens.last.texto, contains('cancelado'));
    });

    test('terminal indisponível avisa e permite tentar de novo', () async {
      final terminal = _GatewayTerminalFake(
          const Erro<ResultadoTransacao>(FalhaTerminalPagamento()));
      final controlador = criar(terminal: terminal);
      await ateEscolhaMetodo(controlador);
      await controlador.selecionarMetodo(MetodoPagamento.credito);
      expect(controlador.state.etapa, EtapaFluxo.escolhaMetodo);
      expect(controlador.state.cartoes.any((c) => c.pago), isFalse);
    });

    test(
        'pagamento indeterminado preserva a chave: nova tentativa reusa a mesma',
        () async {
      final terminal = _GatewayTerminalFake(
          const Erro<ResultadoTransacao>(FalhaPagamentoIndeterminado()));
      final controlador = criar(terminal: terminal);
      await ateEscolhaMetodo(controlador);
      await controlador.selecionarMetodo(MetodoPagamento.credito);
      final primeiraChave = terminal.ultimaChave;
      expect(controlador.state.etapa, EtapaFluxo.escolhaMetodo);

      // Segunda tentativa: a mesma chave precisa chegar à adquirente, senão
      // uma cobrança que passou vira débito em duplicidade.
      await controlador.selecionarMetodo(MetodoPagamento.credito);
      expect(terminal.chamadas, 2);
      expect(terminal.ultimaChave, primeiraChave);
    });

    test('a fonte de PIX por QR não é usada quando há adquirente', () async {
      final terminal =
          _GatewayTerminalFake(Sucesso(_transacao(StatusPagamento.aprovado)));
      final controlador = criar(terminal: terminal);
      await ateEscolhaMetodo(controlador);
      await controlador.selecionarMetodo(MetodoPagamento.pix);
      expect(fontePix.execucoesProcessar, 0);
    });
  });
}
