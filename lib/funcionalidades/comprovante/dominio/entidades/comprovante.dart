import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';

part 'comprovante.freezed.dart';

@freezed
class Comprovante with _$Comprovante {
  const factory Comprovante({
    required String id,
    required String pagamentoId,
    required int valorCentavos,
    required MetodoPagamento metodo,
    required List<String> comandas,
    required DateTime dataHora,
    required String nomeRestaurante,
  }) = _Comprovante;
}
