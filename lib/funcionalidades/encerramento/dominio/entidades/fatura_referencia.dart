import 'package:freezed_annotation/freezed_annotation.dart';

part 'fatura_referencia.freezed.dart';

/// Referência da fatura persistida pelo retaguarda — o essencial que a
/// resposta do `POST movimento/fatura` devolve e que a ação 30 exige.
@freezed
class FaturaReferencia with _$FaturaReferencia {
  const factory FaturaReferencia({
    required String id,
    required String codigo,
    required String identificador,
    required int situacao,
    required int pagoCentavos,
    required int saldoCentavos,

    /// Ids dos atendimentos encerrados por esta fatura
    /// (`faturaModalidades[].referenciaId`). A consulta de reconciliação do
    /// retaguarda NEM SEMPRE devolve o `identificador` — este é o casamento
    /// alternativo com a transação pendente.
    @Default(<String>[]) List<String> atendimentoIds,
  }) = _FaturaReferencia;
}
