import 'package:freezed_annotation/freezed_annotation.dart';

import 'metodo_pagamento.dart';
import 'status_pagamento.dart';

part 'pagamento.freezed.dart';

@freezed
class Pagamento with _$Pagamento {
  const factory Pagamento({
    required String id,

    /// Subtotal do consumo, sem serviço e sem desconto (vem da API).
    required int valorCentavos,

    /// Taxa de serviço calculada pela API, não pelo app.
    required int servicoCentavos,
    @Default(0) int descontoCentavos,

    /// Valor efetivamente cobrado: o saldo devido informado pela API.
    required int totalCentavos,
    required MetodoPagamento metodo,
    required StatusPagamento status,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    required List<String> comandaIds,
  }) = _Pagamento;
}
