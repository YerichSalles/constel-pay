import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../leitura_cartao/dominio/entidades/cartao_consumo.dart';
import '../../../pagamento/dominio/entidades/dados_pix.dart';
import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';
import '../../dominio/entidades/mensagem.dart';

part 'estado_fluxo_pagamento.freezed.dart';

enum EtapaFluxo {
  inicial,
  lendo,
  aguardandoMaisCartoes,
  semConsumo,
  erroLeitura,
  escolhaMetodo,
  pixAguardando,
  processando,

  /// Cobrança já aprovada na maquininha (crédito, débito ou PIX), mas o
  /// encerramento financeiro falhou. NUNCA volta para `escolhaMetodo` —
  /// cobrar de novo aqui debitaria o cliente duas vezes. Só oferece repetir
  /// o encerramento com os mesmos dados da transação já aprovada.
  falhaAposCobranca,
  sucessoComRestante,
  sucessoCompleto,
  encerramento,
}

@freezed
class EstadoFluxoPagamento with _$EstadoFluxoPagamento {
  const EstadoFluxoPagamento._();

  const factory EstadoFluxoPagamento({
    @Default(EtapaFluxo.inicial) EtapaFluxo etapa,
    @Default([]) List<Mensagem> mensagens,
    @Default([]) List<CartaoConsumo> cartoes,
    @Default(0) int cartoesRestantes,
    DadosPix? dadosPix,

    /// Método em cobrança. Fica no estado porque as etapas seguintes
    /// (processando, erro, comprovante) precisam saber por onde a cobrança
    /// entrou — o PIX por QR na tela e o cartão na maquininha voltam para
    /// pontos diferentes quando dá errado.
    MetodoPagamento? metodoSelecionado,
    @Default(false) bool digitando,
    @Default(false) bool copiado,
  }) = _EstadoFluxoPagamento;

  List<CartaoConsumo> get selecionados =>
      cartoes.where((c) => c.selecionado && !c.pago).toList();

  // Todos os valores são somas dos campos já calculados pela API. A taxa de
  // serviço e o desconto são regra do retaguarda — o app nunca os recalcula.
  int get subtotalCentavos =>
      selecionados.fold(0, (acumulado, c) => acumulado + c.subtotalCentavos);

  int get servicoCentavos =>
      selecionados.fold(0, (acumulado, c) => acumulado + c.servicoCentavos);

  int get descontoCentavos =>
      selecionados.fold(0, (acumulado, c) => acumulado + c.descontoCentavos);

  /// Valor devido: soma do `saldo` de cada comanda (total menos o já pago).
  int get totalCentavos =>
      selecionados.fold(0, (acumulado, c) => acumulado + c.saldoCentavos);
}
