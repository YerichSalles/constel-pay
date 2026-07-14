/// Situação da fatura no retaguarda. Valores do contrato real: a fatura é
/// enviada como `autorizada` e volta `paga` quando a baixa é imediata.
enum FaturaSituacao {
  rascunho(10),
  autorizada(210),
  paga(340),
  estornada(920);

  const FaturaSituacao(this.valor);

  final int valor;
}

/// Tipo do documento financeiro. Encerramento de comanda gera `venda`.
enum FaturaTipo {
  compra(10),
  despesa(20),
  venda(110),
  receita(120);

  const FaturaTipo(this.valor);

  final int valor;
}

/// Natureza do lançamento: venda é `entrada` de recurso.
enum FaturaNatureza {
  saida(-1),
  entrada(1);

  const FaturaNatureza(this.valor);

  final int valor;
}

/// Ações do `POST venda/atendimento/encerra`: `iniciar` abre o fechamento
/// (antes da fatura) e `confirmar` conclui usando a fatura persistida.
enum AcaoEncerramento {
  iniciar(10),
  confirmar(30);

  const AcaoEncerramento(this.valor);

  final int valor;
}
