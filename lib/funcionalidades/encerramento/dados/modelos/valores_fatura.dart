import '../../../../nucleo/utils/json_leniente.dart';

/// Conversões monetárias do payload da fatura. O app trabalha em centavos
/// (`int`); o contrato transporta reais como número decimal. Divisão por 100
/// é exata para 2 casas — o caminho inverso é o mesmo do resto do app
/// ([JsonLeniente.centavos]), para leitura e faturamento nunca divergirem.
abstract final class ValoresFatura {
  static double reais(int centavos) => centavos / 100;

  static int centavos(dynamic v) => JsonLeniente.centavos(v);
}
