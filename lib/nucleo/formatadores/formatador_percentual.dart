abstract final class FormatadorPercentual {
  /// Percentual como a API envia (10, 12.5, 8.58) → "10%", "12,5%", "8,58%".
  /// Sem casas decimais quando o valor é inteiro; nunca arredonda para um
  /// percentual fixo — o número exibido é o que o retaguarda mandou.
  static String formatar(num percentual) {
    final inteiro = percentual == percentual.roundToDouble();
    final texto = inteiro
        ? percentual.round().toString()
        : percentual
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
    return '${texto.replaceAll('.', ',')}%';
  }
}
