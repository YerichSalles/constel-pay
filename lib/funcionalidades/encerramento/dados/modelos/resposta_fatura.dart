import '../../../../nucleo/utils/json_leniente.dart';
import '../../dominio/entidades/fatura_referencia.dart';
import 'valores_fatura.dart';

/// Converte a resposta do `POST movimento/fatura` (ou um elemento da coleção
/// de reconciliação) na referência mínima que a ação 30 e as validações
/// exigem. Tolerante a campos ausentes — a validação fica no caso de uso.
abstract final class RespostaFatura {
  static FaturaReferencia paraReferencia(Map<String, dynamic> json) =>
      FaturaReferencia(
        id: JsonLeniente.texto(json['id']),
        codigo: JsonLeniente.texto(json['codigo']),
        identificador: JsonLeniente.texto(json['identificador']),
        situacao: JsonLeniente.inteiro(json['situacao']),
        pagoCentavos: ValoresFatura.centavos(json['pago']),
        saldoCentavos: ValoresFatura.centavos(json['saldo']),
        atendimentoIds: [
          for (final modalidade
              in JsonLeniente.lista(json['faturaModalidades']))
            if (JsonLeniente.texto(modalidade['referenciaId']).isNotEmpty)
              JsonLeniente.texto(modalidade['referenciaId']),
        ],
      );

  /// Lista de faturas devolvida pela consulta por sessão (reconciliação).
  /// Aceita lista crua ou envelope conhecido ({itens}/{dados}). Formato
  /// DESCONHECIDO devolve `null` — jamais lista vazia: "não sei ler" não
  /// pode virar "a fatura não existe", senão a reconciliação reenviaria
  /// uma fatura que pode já existir.
  static List<FaturaReferencia>? paraLista(dynamic corpo) {
    final itens = switch (corpo) {
      final List lista => lista,
      final Map<String, dynamic> mapa when mapa['itens'] is List =>
        mapa['itens'] as List,
      final Map<String, dynamic> mapa when mapa['dados'] is List =>
        mapa['dados'] as List,
      _ => null,
    };
    return itens
        ?.whereType<Map<String, dynamic>>()
        .map(paraReferencia)
        .toList();
  }
}
