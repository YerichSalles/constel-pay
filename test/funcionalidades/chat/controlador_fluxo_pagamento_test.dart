import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/chat/dominio/entidades/tipo_mensagem.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/repositorios/repositorio_leitura_impl.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/repositorios/repositorio_pagamento_impl.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepositorioConfiguracaoFake implements RepositorioConfiguracao {
  @override
  Future<ConfiguracaoTerminal> obter() async =>
      const ConfiguracaoTerminal(nomeRestaurante: 'Durango Burgers');

  @override
  Future<void> salvar(ConfiguracaoTerminal configuracao) async {}
}

void main() {
  late FontePagamentoMock fontePagamento;
  late RepositorioLeituraImpl repositorioLeitura;
  late ControladorFluxoPagamento controlador;

  setUp(() {
    final fonteLeitura = FonteLeituraMock(atraso: Duration.zero);
    fontePagamento = FontePagamentoMock(atraso: Duration.zero);
    repositorioLeitura = RepositorioLeituraImpl(fonteLeitura);
    final repositorioPagamento = RepositorioPagamentoImpl(fontePagamento);
    controlador = ControladorFluxoPagamento(
      casoUsoLerCartao: CasoUsoLerCartao(repositorioLeitura),
      repositorioLeitura: repositorioLeitura,
      casoUsoGerarPix: CasoUsoGerarPix(repositorioPagamento),
      casoUsoProcessarPagamento:
          CasoUsoProcessarPagamento(repositorioPagamento),
      repositorioConfiguracao: _RepositorioConfiguracaoFake(),
      atrasoBot: Duration.zero,
    );
  });

  Future<void> irAteEscolhaMetodo({int gorjeta = 10}) async {
    await controlador.iniciar();
    await controlador.lerCartao();
    await controlador.irParaPagamento();
    await controlador.definirGorjeta(gorjeta);
  }

  test('iniciar apresenta boas-vindas e scanner', () async {
    await controlador.iniciar();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.lendo);
    expect(
        estado.mensagens.map((m) => m.tipo),
        containsAllInOrder(
            [TipoMensagem.texto, TipoMensagem.texto, TipoMensagem.scanner]));
  });

  test('iniciar duas vezes nao duplica mensagens', () async {
    await controlador.iniciar();
    final quantidade = controlador.state.mensagens.length;
    await controlador.iniciar();
    expect(controlador.state.mensagens.length, quantidade);
  });

  test('primeira leitura identifica a mesa e seleciona a comanda', () async {
    await controlador.iniciar();
    await controlador.lerCartao();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.aguardandoMaisCartoes);
    expect(estado.mesa?.numero, 12);
    expect(estado.cartoes, hasLength(1));
    expect(estado.selecionados, hasLength(1));
    expect(estado.subtotalCentavos, 13600);
    expect(estado.cartoesRestantes, 2);
    expect(estado.mensagens.any((m) => m.tipo == TipoMensagem.mesa), isTrue);
    expect(estado.mensagens.any((m) => m.tipo == TipoMensagem.leituraCartao),
        isTrue);
  });

  test('lerCartao fora da etapa lendo e ignorado', () async {
    await controlador.iniciar();
    await controlador.lerCartao();
    final quantidade = controlador.state.mensagens.length;
    await controlador.lerCartao();
    expect(controlador.state.mensagens.length, quantidade);
  });

  test('gorjeta de 10% calcula os totais corretamente', () async {
    await irAteEscolhaMetodo();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.escolhaMetodo);
    expect(estado.subtotalCentavos, 13600);
    expect(estado.gorjetaCentavos, 1360);
    expect(estado.totalCentavos, 14960);
    expect(estado.mensagens.any((m) => m.tipo == TipoMensagem.metodos), isTrue);
  });

  test('selecionar Pix gera dados e vai para pixAguardando', () async {
    await irAteEscolhaMetodo();
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.pixAguardando);
    expect(estado.dadosPix?.valorCentavos, 14960);
    expect(estado.mensagens.any((m) => m.tipo == TipoMensagem.pix), isTrue);
  });

  test('selecionar metodo indisponivel mantem a etapa de escolha', () async {
    await irAteEscolhaMetodo();
    await controlador.selecionarMetodo(MetodoPagamento.credito);
    expect(controlador.state.etapa, EtapaFluxo.escolhaMetodo);
    expect(controlador.state.dadosPix, isNull);
  });

  test('confirmar pagamento quita a comanda e informa restantes', () async {
    await irAteEscolhaMetodo();
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    await controlador.confirmarPagamentoPix();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.sucessoComRestante);
    expect(estado.cartoes.single.pago, isTrue);
    expect(estado.selecionados, isEmpty);
    final sucesso =
        estado.mensagens.lastWhere((m) => m.tipo == TipoMensagem.sucesso);
    expect(sucesso.dados?['valorCentavos'], 14960);
    expect(sucesso.dados?['comandas'], ['Comanda 01']);
  });

  test('fluxo completo das 3 comandas termina em sucessoCompleto', () async {
    await controlador.iniciar();
    await controlador.lerCartao();
    await controlador.lerOutroCartao();
    await controlador.lerCartao();
    await controlador.lerOutroCartao();
    await controlador.lerCartao();
    expect(controlador.state.cartoesRestantes, 0);
    expect(controlador.state.subtotalCentavos, 31800);
    await controlador.irParaPagamento();
    await controlador.definirGorjeta(0);
    expect(controlador.state.totalCentavos, 31800);
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    await controlador.confirmarPagamentoPix();
    expect(controlador.state.etapa, EtapaFluxo.sucessoCompleto);
  });

  test('encerrar exibe o comprovante com o nome do restaurante', () async {
    await irAteEscolhaMetodo();
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    await controlador.confirmarPagamentoPix();
    await controlador.encerrar();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.encerramento);
    final comprovante =
        estado.mensagens.lastWhere((m) => m.tipo == TipoMensagem.comprovante);
    expect(comprovante.dados?['nomeRestaurante'], 'Durango Burgers');
    expect(comprovante.dados?['valorCentavos'], 14960);
  });

  test('pagarRestante volta ao scanner', () async {
    await irAteEscolhaMetodo();
    await controlador.selecionarMetodo(MetodoPagamento.pix);
    await controlador.confirmarPagamentoPix();
    await controlador.pagarRestante();
    expect(controlador.state.etapa, EtapaFluxo.lendo);
  });

  test('novaOperacao reseta tudo e permite reler os cartoes', () async {
    await irAteEscolhaMetodo();
    controlador.novaOperacao();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.inicial);
    expect(estado.mensagens, isEmpty);
    expect(estado.cartoes, isEmpty);
    expect(repositorioLeitura.cartoesRestantes, 3);
  });

  test('verItens adiciona mensagem de detalhe da comanda', () async {
    await controlador.iniciar();
    await controlador.lerCartao();
    controlador.verItens('c1');
    final detalhe = controlador.state.mensagens.last;
    expect(detalhe.tipo, TipoMensagem.detalhe);
    expect(detalhe.dados?['comandaId'], 'c1');
  });
}
