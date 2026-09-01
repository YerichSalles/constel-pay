/// Parâmetros que só uma adquirente específica exige.
///
/// É uma hierarquia selada, e não campos opcionais na assinatura do gateway,
/// para que uma adquirente futura acrescente o que precisa sem obrigar as
/// outras a carregar campos que não usam. O `switch` exaustivo do Dart 3
/// cobra o tratamento de cada caso na hora de serializar para o canal.
///
/// Hoje existe só [SemParametrosAdquirente]: a Stone não pede nada além do
/// valor e do método — a cobrança vai pelo aplicativo de pagamento da Stone,
/// que é credenciado no próprio aparelho, fora do app.
sealed class ParametrosAdquirente {
  const ParametrosAdquirente();

  /// Adquirente que não exige nada além do valor e do método.
  const factory ParametrosAdquirente.nenhum() = SemParametrosAdquirente;
}

final class SemParametrosAdquirente extends ParametrosAdquirente {
  const SemParametrosAdquirente();
}
