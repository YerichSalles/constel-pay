import 'package:freezed_annotation/freezed_annotation.dart';

part 'atendimento.freezed.dart';

/// Atendimento de consumo em aberto na API da loja (mesa/cartão).
/// Modelo fiel ao endpoint `venda/atendimento/colecao`; valores monetários
/// já convertidos para centavos pelo mapper.
@freezed
class Atendimento with _$Atendimento {
  const factory Atendimento({
    required String id,
    required String codigo,
    required String nome,
    required String referencia,
    required int situacao,
    DateTime? inicio,
    DateTime? conclusao,
    required int subtotalCentavos,
    required int servicoCentavos,
    required num servicoPercentual,
    required int descontoCentavos,
    required int totalCentavos,
    required int pagoCentavos,
    required int saldoCentavos,
    required String sessaoId,
    required String sessaoCodigo,
    @Default(<ComandaAtendimento>[]) List<ComandaAtendimento> comandas,
    @Default(<ItemAtendimento>[]) List<ItemAtendimento> itens,

    /// JSON original do atendimento como veio da API. O encerramento ecoa o
    /// atendimento INTEIRO de volta (ações 10 e 30) e a fatura reaproveita
    /// sub-objetos (parceiro, preço, modalidade, resumos) — guardar o bruto
    /// evita modelar dezenas de campos que o app não usa.
    @Default(<String, dynamic>{}) Map<String, dynamic> bruto,
  }) = _Atendimento;
}

@freezed
class ComandaAtendimento with _$ComandaAtendimento {
  const factory ComandaAtendimento({
    required String id,
    required String codigo,
    required int numero,
    required int situacao,
  }) = _ComandaAtendimento;
}

@freezed
class ItemAtendimento with _$ItemAtendimento {
  const factory ItemAtendimento({
    required String id,

    /// Id do item no cadastro (`item.id`) — chave de `recurso/item/{id}`,
    /// de onde vem a foto. Diferente do `id` da linha do atendimento.
    @Default('') String itemId,
    required int sequencial,
    required String nome,
    required String codigo,
    required num quantidade,
    required String medida,
    required int valorCentavos,
    required int subtotalCentavos,
    required int totalCentavos,
    required String comandaId,
    required String comandaCodigo,
  }) = _ItemAtendimento;
}
