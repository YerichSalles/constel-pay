/// Rateio de resultado da fatura. O caixa envia o resultado da configuração
/// SEM o campo `nome` nesta posição (diferente de `faturaItens[].resultado`,
/// que vai completo) — reproduzimos o mesmo recorte.
class RequisicaoFaturaResultado {
  const RequisicaoFaturaResultado({
    this.sequencial = 1,
    required this.resultado,
    this.percentual = 100.0,
  });

  final int sequencial;
  final Map<String, dynamic> resultado;
  final num percentual;

  Map<String, dynamic> paraJson() => {
        'sequencial': sequencial,
        'resultado': {
          for (final entrada in resultado.entries)
            if (entrada.key != 'nome') entrada.key: entrada.value,
        },
        'percentual': percentual,
      };
}
