import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../leitura_cartao/dominio/entidades/cartao_consumo.dart';
import '../../../leitura_cartao/dominio/entidades/mesa.dart';
import '../../../pagamento/dominio/entidades/dados_pix.dart';
import '../../dominio/entidades/mensagem.dart';

part 'estado_fluxo_pagamento.freezed.dart';

enum EtapaFluxo {
  inicial,
  lendo,
  aguardandoMaisCartoes,
  gorjeta,
  escolhaMetodo,
  pixAguardando,
  processando,
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
    Mesa? mesa,
    @Default([]) List<CartaoConsumo> cartoes,
    @Default(0) int cartoesRestantes,
    @Default(0) int gorjetaPercentual,
    DadosPix? dadosPix,
    @Default(false) bool digitando,
    @Default(false) bool copiado,
  }) = _EstadoFluxoPagamento;

  List<CartaoConsumo> get selecionados =>
      cartoes.where((c) => c.selecionado && !c.pago).toList();

  int get subtotalCentavos =>
      selecionados.fold(0, (acumulado, c) => acumulado + c.subtotalCentavos);

  int get gorjetaCentavos =>
      ((subtotalCentavos * gorjetaPercentual) / 100).round();

  int get totalCentavos => subtotalCentavos + gorjetaCentavos;
}
