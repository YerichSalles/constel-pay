import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../encerramento/dominio/casos_uso/caso_uso_encerrar_atendimentos.dart';
import '../../../encerramento/dominio/entidades/fase_encerramento.dart';
import '../../../encerramento/dominio/entidades/resultado_encerramento.dart';
import '../../../leitura_cartao/dominio/entidades/atendimento.dart';
import '../../../leitura_cartao/dominio/entidades/cartao_consumo.dart';
import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';

/// Ponte entre o fluxo do chat e o encerramento financeiro: guarda os
/// `Atendimento` completos das comandas lidas na API (o `CartaoConsumo` da UI
/// não carrega sessão nem o JSON bruto) e decide quando o encerramento real
/// se aplica.
class ApoioEncerramentoChat {
  ApoioEncerramentoChat({CasoUsoEncerrarAtendimentos? casoUso})
      : _casoUso = casoUso;

  final CasoUsoEncerrarAtendimentos? _casoUso;
  final Map<String, Atendimento> _porId = {};

  /// Registra os atendimentos reais lidos da API da loja.
  void registrar(List<Atendimento> atendimentos) {
    for (final atendimento in atendimentos) {
      _porId[atendimento.id] = atendimento;
    }
  }

  void limpar() => _porId.clear();

  /// Validação ANTES de cobrar o cliente: se o encerramento real vai rodar
  /// depois do pagamento, qualquer impedimento conhecido (mistura com
  /// demonstração, configuração incompleta, pendência conflitante) precisa
  /// aparecer AGORA — nunca depois do dinheiro debitado.
  /// `null` = pode cobrar.
  Future<Falha?> validarAntesDoPagamento({
    required List<CartaoConsumo> selecionados,
    required MetodoPagamento metodo,
  }) async {
    final casoUso = _casoUso;
    if (casoUso == null) return null;
    final reais = _reais(selecionados);
    if (reais.isEmpty) return null;
    if (reais.length != selecionados.length) {
      return const FalhaValidacao(
          'Comandas de demonstração não podem ser encerradas junto com '
          'comandas reais. Remova uma das duas.');
    }
    return casoUso.validarAntesDoPagamento(atendimentos: reais, metodo: metodo);
  }

  /// Executa o encerramento real das comandas selecionadas.
  ///
  /// Retorna `null` quando o encerramento não se aplica — sem caso de uso
  /// injetado ou nenhuma comanda veio da API (fluxo de demonstração segue
  /// só com o comprovante local).
  Future<Resultado<ResultadoEncerramento>?> encerrar({
    required List<CartaoConsumo> selecionados,
    required MetodoPagamento metodo,
    void Function(FaseEncerramento fase)? aoMudarFase,
  }) async {
    final casoUso = _casoUso;
    if (casoUso == null) return null;
    final reais = _reais(selecionados);
    if (reais.isEmpty) return null;
    if (reais.length != selecionados.length) {
      return const Erro(FalhaValidacao(
          'Comandas de demonstração não podem ser encerradas junto com '
          'comandas reais.'));
    }
    return casoUso.executar(
      atendimentos: reais,
      metodo: metodo,
      aoMudarFase: aoMudarFase,
    );
  }

  List<Atendimento> _reais(List<CartaoConsumo> selecionados) => [
        for (final cartao in selecionados)
          if (_porId[cartao.id] != null) _porId[cartao.id]!,
      ];
}
