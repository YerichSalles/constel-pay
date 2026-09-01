import 'package:freezed_annotation/freezed_annotation.dart';

import 'metodo_pagamento.dart';
import 'status_pagamento.dart';

part 'resultado_transacao.freezed.dart';

/// Desfecho de uma cobrança no terminal físico, já traduzido para o domínio:
/// nada aqui é específico de adquirente nem de plataforma.
///
/// Recusa e cancelamento chegam como [StatusPagamento] — são desfechos de
/// negócio, não falhas. `Falha` fica reservada para o que impediu a operação
/// de ter desfecho conhecido.
@freezed
class ResultadoTransacao with _$ResultadoTransacao {
  const factory ResultadoTransacao({
    required StatusPagamento status,
    required MetodoPagamento metodo,

    /// Sempre em centavos (`int`): valor financeiro não passa por `double`.
    required int valorCentavos,
    @Default(1) int parcelas,
    @Default('') String codigoAutorizacao,
    @Default('') String nsu,
    @Default('') String bandeira,

    /// Apenas os 4 últimos dígitos, já mascarados pelo lado nativo. O número
    /// completo, a trilha e qualquer dado do portador NUNCA atravessam o canal
    /// nem são gravados.
    @Default('') String finalCartao,

    /// Rótulo da adquirente para exibição no comprovante.
    @Default('') String adquirente,

    /// Texto vindo da adquirente para o operador. É conteúdo de terceiro:
    /// exibir como veio, sem interpretar.
    @Default('') String mensagemOperador,

    /// Identificador `atk` devolvido pela Stone no deep link de retorno.
    /// Capturado só para diagnóstico — sem uso definido no payload da
    /// fatura ainda.
    @Default('') String tokenTransacao,
  }) = _ResultadoTransacao;
}
