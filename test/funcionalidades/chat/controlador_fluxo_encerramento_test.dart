import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/casos_uso/caso_uso_encerrar_atendimentos.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/fase_encerramento.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/fatura_referencia.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/resultado_encerramento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_consumo_atendimento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/repositorios/repositorio_leitura_impl.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/atendimento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/repositorios/repositorio_pagamento_impl.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:constel_pay/l10n/app_localizations.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

class _RepositorioConfiguracaoFake implements RepositorioConfiguracao {
  @override
  Future<ConfiguracaoTerminal> obter() async =>
      const ConfiguracaoTerminal(nomeRestaurante: 'Durango Burgers');

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

class _CasoUsoEncerrarFake implements CasoUsoEncerrarAtendimentos {
  Falha? impedimento;
  int validacoes = 0;

  @override
  Future<Falha?> validarAntesDoPagamento({
    required List<Atendimento> atendimentos,
    required MetodoPagamento metodo,
  }) async {
    validacoes++;
    return impedimento;
  }

  Resultado<ResultadoEncerramento> resultado = const Sucesso(
    ResultadoEncerramento(
      fatura: FaturaReferencia(
        id: 'f1',
        codigo: 'VN0051625',
        identificador: 'ID1',
        situacao: 340,
        pagoCentavos: 649,
        saldoCentavos: 0,
      ),
      atendimentoIds: ['at502'],
    ),
  );
  final List<List<String>> chamadas = [];

  @override
  Future<Resultado<ResultadoEncerramento>> executar({
    required List<Atendimento> atendimentos,
    required MetodoPagamento metodo,
    int? valorRecebidoCentavos,
    void Function(FaseEncerramento fase)? aoMudarFase,
  }) async {
    chamadas.add([for (final a in atendimentos) a.id]);
    if (resultado is Sucesso<ResultadoEncerramento>) {
      aoMudarFase?.call(FaseEncerramento.preparandoEncerramento);
      aoMudarFase?.call(FaseEncerramento.gerandoFatura);
      aoMudarFase?.call(FaseEncerramento.confirmandoEncerramento);
      aoMudarFase?.call(FaseEncerramento.concluida);
    } else {
      aoMudarFase?.call(FaseEncerramento.erro);
    }
    return resultado;
  }

  @override
  Future<int> confirmarTransacoesPendentes() async => 0;
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
);

void main() {
  late _CasoUsoEncerrarFake casoUsoEncerrar;
  late ControladorFluxoPagamento controlador;

  setUp(() {
    final fonteLeitura = FonteLeituraMock(atraso: Duration.zero);
    final repositorioLeitura = RepositorioLeituraImpl(fonteLeitura);
    final repositorioPagamento =
        RepositorioPagamentoImpl(FontePagamentoMock(atraso: Duration.zero));
    casoUsoEncerrar = _CasoUsoEncerrarFake();
    controlador = ControladorFluxoPagamento(
      casoUsoLerCartao: CasoUsoLerCartao(repositorioLeitura),
      repositorioLeitura: repositorioLeitura,
      casoUsoGerarPix: CasoUsoGerarPix(repositorioPagamento),
      casoUsoProcessarPagamento:
          CasoUsoProcessarPagamento(repositorioPagamento),
      repositorioConfiguracao: _RepositorioConfiguracaoFake(),
      obterTraducoes: () => lookupAppLocalizations(const Locale('pt', 'BR')),
      fonteConsumoAtendimento:
          _FonteConsumoFake(const Sucesso([_atendimento502])),
      casoUsoEncerrar: casoUsoEncerrar,
      atrasoBot: Duration.zero,
    );
  });

  Future<void> pagarComandaReal() async {
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    await controlador.irParaPagamento();
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    await controlador.confirmarPagamentoPix();
  }

  test('comanda real: paga, encerra com as fases e quita o cartão', () async {
    await pagarComandaReal();
    final estado = controlador.state;
    expect(casoUsoEncerrar.chamadas, [
      ['at502']
    ]);
    expect(estado.etapa, EtapaFluxo.sucessoCompleto);
    expect(estado.cartoes.single.pago, isTrue);
    final textos = [for (final m in estado.mensagens) m.texto];
    expect(textos, contains('Preparando encerramento…'));
    expect(textos, contains('Gerando fatura…'));
    expect(textos, contains('Confirmando encerramento…'));
  });

  test('erro no encerramento mantém a comanda aberta e permite repetir',
      () async {
    casoUsoEncerrar.resultado = const Erro(FalhaTimeout());
    await pagarComandaReal();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.pixAguardando,
        reason: 'não pode avançar para sucesso sem a ação 30');
    expect(estado.cartoes.single.pago, isFalse,
        reason: 'cartão só é quitado após o encerramento confirmado');
    final erro = estado.mensagens.last;
    expect(erro.texto, 'Não foi possível encerrar a conta');
    expect(erro.subtexto, isNotEmpty);

    // Retry: nova confirmação chama o encerramento de novo.
    casoUsoEncerrar.resultado = const Sucesso(
      ResultadoEncerramento(
        fatura: FaturaReferencia(
          id: 'f1',
          codigo: 'VN0051625',
          identificador: 'ID1',
          situacao: 340,
          pagoCentavos: 649,
          saldoCentavos: 0,
        ),
        atendimentoIds: ['at502'],
      ),
    );
    await controlador.confirmarPagamentoPix();
    expect(casoUsoEncerrar.chamadas, hasLength(2));
    expect(controlador.state.etapa, EtapaFluxo.sucessoCompleto);
    expect(controlador.state.cartoes.single.pago, isTrue);
  });

  test('comanda de demonstração (mock) não dispara encerramento real',
      () async {
    await controlador.iniciar();
    await controlador.lerCartao();
    await controlador.irParaPagamento();
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    await controlador.confirmarPagamentoPix();
    expect(casoUsoEncerrar.chamadas, isEmpty);
    expect(controlador.state.etapa, EtapaFluxo.sucessoComRestante);
    expect(controlador.state.cartoes.single.pago, isTrue);
  });

  test('impedimento conhecido barra ANTES da cobrança', () async {
    casoUsoEncerrar.impedimento =
        const FalhaValidacao('Faturamento não configurado.');
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    await controlador.irParaPagamento();
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    await controlador.confirmarPagamentoPix();
    final estado = controlador.state;
    expect(casoUsoEncerrar.validacoes, 1);
    expect(casoUsoEncerrar.chamadas, isEmpty,
        reason: 'não pode cobrar nem encerrar com impedimento conhecido');
    expect(estado.etapa, EtapaFluxo.pixAguardando);
    expect(estado.cartoes.single.pago, isFalse);
    expect(estado.mensagens.last.texto, 'Não foi possível encerrar a conta');
    expect(estado.mensagens.last.subtexto,
        contains('Faturamento não configurado'));
  });

  test('nova operação limpa os atendimentos registrados', () async {
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    controlador.novaOperacao();
    await controlador.iniciar();
    await controlador.lerCartao();
    await controlador.irParaPagamento();
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    await controlador.confirmarPagamentoPix();
    expect(casoUsoEncerrar.chamadas, isEmpty,
        reason: 'atendimento antigo não pode vazar para a nova operação');
  });
}
