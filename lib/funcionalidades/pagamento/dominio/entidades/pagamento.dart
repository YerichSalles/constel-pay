import 'package:freezed_annotation/freezed_annotation.dart';

import 'metodo_pagamento.dart';
import 'status_pagamento.dart';

part 'pagamento.freezed.dart';

@freezed
class Pagamento with _$Pagamento {
  const factory Pagamento({
    required String id,
    required int valorCentavos,
    required int gorjetaCentavos,
    required int totalCentavos,
    required MetodoPagamento metodo,
    required StatusPagamento status,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    required List<String> comandaIds,
  }) = _Pagamento;
}
