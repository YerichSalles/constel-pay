import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/controlador_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/controladores/estado_fluxo_pagamento.dart';
import 'package:constel_pay/funcionalidades/chat/dominio/entidades/tipo_mensagem.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_consumo_atendimento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_recurso_item.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/atendimento.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/repositorios/repositorio_leitura_impl.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/repositorios/repositorio_pagamento_impl.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
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
  String? ultimaReferencia;

  @override
  Future<Resultado<List<Atendimento>>> consultar(
      {required String referencia}) async {
    ultimaReferencia = referencia;
    return resultado;
  }
}

class _FonteRecursoFake implements FonteRecursoItem {
  _FonteRecursoFake(this.porItem);
  final Map<String, String> porItem;
  final List<String> consultados = [];

  @override
  Future<String> obterImagem(String itemId) async {
    consultados.add(itemId);
    return porItem[itemId] ?? '';
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
  itens: [
    ItemAtendimento(
      id: 'i1',
      itemId: 'item-burger',
      sequencial: 1,
      nome: 'x - Burger',
      codigo: '0002',
      quantidade: 1,
      medida: 'UN',
      valorCentavos: 4530,
      subtotalCentavos: 4530,
      totalCentavos: 4530,
      comandaId: 'c1',
      comandaCodigo: '0010033',
    ),
  ],
);

void main() {
  late FontePagamentoMock fontePagamento;
  late RepositorioLeituraImpl repositorioLeitura;
  late ControladorFluxoPagamento controlador;
  late _FonteConsumoFake fonteConsumo;
  late _FonteRecursoFake fonteRecurso;

  setUp(() {
    final fonteLeitura = FonteLeituraMock(atraso: Duration.zero);
    fontePagamento = FontePagamentoMock(atraso: Duration.zero);
    repositorioLeitura = RepositorioLeituraImpl(fonteLeitura);
    final repositorioPagamento = RepositorioPagamentoImpl(fontePagamento);
    fonteConsumo = _FonteConsumoFake(const Sucesso([_atendimento502]));
    fonteRecurso = _FonteRecursoFake(
        {'item-burger': 'https://s3.amazonaws.com/files/burger.png'});
    controlador = ControladorFluxoPagamento(
      casoUsoLerCartao: CasoUsoLerCartao(repositorioLeitura),
      repositorioLeitura: repositorioLeitura,
      casoUsoGerarPix: CasoUsoGerarPix(repositorioPagamento),
      casoUsoProcessarPagamento:
          CasoUsoProcessarPagamento(repositorioPagamento),
      repositorioConfiguracao: _RepositorioConfiguracaoFake(),
      fonteConsumoAtendimento: fonteConsumo,
      fonteRecursoItem: fonteRecurso,
      atrasoBot: Duration.zero,
    );
  });

  Future<void> irAteEscolhaMetodo() async {
    await controlador.iniciar();
    await controlador.lerCartao();
    await controlador.irParaPagamento();
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

  test('irParaPagamento vai direto a escolha de metodo com os valores da API',
      () async {
    await irAteEscolhaMetodo();
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.escolhaMetodo);
    expect(estado.subtotalCentavos, 13600);
    expect(estado.servicoCentavos, 1360);
    expect(estado.totalCentavos, 14960);
    expect(estado.mensagens.any((m) => m.tipo == TipoMensagem.metodos), isTrue);
  });

  test('totais somam os campos da API, sem recalcular a taxa de servico',
      () async {
    // Atendimento com serviço que NÃO é 10% do subtotal: o app deve obedecer.
    fonteConsumo.resultado = const Sucesso([
      Atendimento(
        id: 'at700',
        codigo: '0010040',
        nome: 'Cartão 700',
        referencia: '700',
        situacao: 20,
        subtotalCentavos: 5699,
        servicoCentavos: 489,
        servicoPercentual: 8.58,
        descontoCentavos: 0,
        totalCentavos: 6188,
        pagoCentavos: 0,
        saldoCentavos: 6188,
        sessaoId: 's2',
        sessaoCodigo: '0003450',
      ),
    ]);
    await controlador.iniciar();
    await controlador.lerComandaDigitada('700');
    await controlador.irParaPagamento();
    final estado = controlador.state;
    expect(estado.subtotalCentavos, 5699);
    expect(estado.servicoCentavos, 489);
    expect(estado.totalCentavos, 6188);
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
    expect(controlador.state.totalCentavos, 34980);
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

  test('lerComandaDigitada adiciona o cartão real da API', () async {
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    final estado = controlador.state;
    expect(fonteConsumo.ultimaReferencia, '502');
    expect(estado.etapa, EtapaFluxo.aguardandoMaisCartoes);
    expect(estado.cartoes.single.id, 'at502');
    expect(estado.cartoes.single.nome, 'Cartão 502');
    expect(estado.cartoes.single.selecionado, isTrue);
    expect(estado.subtotalCentavos, 4530);
    expect(estado.mensagens.any((m) => m.tipo == TipoMensagem.leituraCartao),
        isTrue);
  });

  test('lerComandaDigitada traz a foto do item do cadastro da loja', () async {
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    final item = controlador.state.cartoes.single.itens.single;
    expect(fonteRecurso.consultados, ['item-burger']);
    expect(item.imagemUrl, 'https://s3.amazonaws.com/files/burger.png');
  });

  test('item sem foto no cadastro mantem o emoji e nao quebra o fluxo',
      () async {
    fonteRecurso.porItem.clear();
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    final item = controlador.state.cartoes.single.itens.single;
    expect(item.imagemUrl, isEmpty);
    expect(item.emoji, isNotEmpty);
    expect(controlador.state.etapa, EtapaFluxo.aguardandoMaisCartoes);
  });

  test('foto ja carregada nao e buscada de novo na releitura', () async {
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    await controlador.lerOutroCartao();
    await controlador.lerComandaDigitada('502');
    expect(fonteRecurso.consultados, ['item-burger']);
  });

  test('lerComandaDigitada sem consumo mostra aviso e segue lendo', () async {
    fonteConsumo.resultado = const Sucesso([]);
    await controlador.iniciar();
    await controlador.lerComandaDigitada('505');
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.lendo);
    expect(estado.cartoes, isEmpty);
    expect(estado.mensagens.last.texto, contains('505'));
  });

  test('lerComandaDigitada com falha mostra a mensagem de erro', () async {
    fonteConsumo.resultado = const Erro(FalhaNaoAutorizado());
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    final estado = controlador.state;
    expect(estado.etapa, EtapaFluxo.lendo);
    expect(estado.cartoes, isEmpty);
    expect(estado.mensagens.last.texto, contains('não autorizado'));
  });

  test('lerComandaDigitada não duplica cartão já adicionado', () async {
    await controlador.iniciar();
    await controlador.lerComandaDigitada('502');
    await controlador.lerOutroCartao();
    await controlador.lerComandaDigitada('502');
    expect(controlador.state.cartoes, hasLength(1));
  });

  test('cartao lido ja vem com os itens (nao ha etapa de ver detalhe)',
      () async {
    await controlador.iniciar();
    await controlador.lerCartao();
    expect(controlador.state.cartoes.single.itens, isNotEmpty);
  });
}
