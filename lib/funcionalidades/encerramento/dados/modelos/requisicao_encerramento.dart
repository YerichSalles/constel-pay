import '../../dominio/entidades/fatura_enums.dart';

/// Payload do `POST venda/atendimento/encerra`. Os atendimentos são ecoados
/// INTEIROS, exatamente como vieram de `venda/atendimento/colecao` — o caixa
/// faz o mesmo (situação, pago e saldo permanecem com os valores originais,
/// inclusive na ação 30).
class RequisicaoEncerramento {
  /// Ação 10: sem sessão e sem fatura (`null` no payload).
  const RequisicaoEncerramento.iniciar(this.atendimentosBrutos)
      : acao = AcaoEncerramento.iniciar,
        sessaoId = '',
        sessaoCodigo = '',
        faturaId = '',
        faturaCodigo = '';

  /// Ação 30: com a sessão do caixa e a fatura persistida.
  const RequisicaoEncerramento.confirmar({
    required this.atendimentosBrutos,
    required this.sessaoId,
    required this.sessaoCodigo,
    required this.faturaId,
    required this.faturaCodigo,
  }) : acao = AcaoEncerramento.confirmar;

  final List<Map<String, dynamic>> atendimentosBrutos;
  final AcaoEncerramento acao;
  final String sessaoId;
  final String sessaoCodigo;
  final String faturaId;
  final String faturaCodigo;

  Map<String, dynamic> paraJson() => {
        'atendimentos': atendimentosBrutos,
        'sessao': acao == AcaoEncerramento.confirmar
            ? {'id': sessaoId, 'codigo': sessaoCodigo}
            : null,
        'fatura': acao == AcaoEncerramento.confirmar
            ? {'id': faturaId, 'codigo': faturaCodigo}
            : null,
        'acao': acao.valor,
      };
}
