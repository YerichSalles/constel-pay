abstract final class FormatadorMoeda {
  static String formatar(int centavos) {
    final negativo = centavos < 0;
    final absoluto = centavos.abs();
    final inteiro = (absoluto ~/ 100).toString();
    final resto = (absoluto % 100).toString().padLeft(2, '0');
    final agrupado = StringBuffer();
    for (var i = 0; i < inteiro.length; i++) {
      agrupado.write(inteiro[i]);
      final restantes = inteiro.length - i - 1;
      if (restantes > 0 && restantes % 3 == 0) agrupado.write('.');
    }
    return '${negativo ? '-' : ''}R\$ $agrupado,$resto';
  }
}
