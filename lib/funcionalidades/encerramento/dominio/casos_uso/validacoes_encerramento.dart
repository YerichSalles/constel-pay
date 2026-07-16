import '../../../../nucleo/constantes/constantes_app.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/utils/json_leniente.dart';
import '../../../leitura_cartao/dominio/entidades/atendimento.dart';
import '../../../pagamento/dominio/entidades/metodo_pagamento.dart';
import '../../dados/modelos/valores_fatura.dart';
import '../entidades/configuracao_faturamento.dart';
import '../entidades/fatura_enums.dart';
import '../entidades/fatura_referencia.dart';
import '../entidades/transacao_pendente.dart';

/// Validações do encerramento financeiro, separadas do orquestrador.
/// Todas retornam `null` quando o estado é válido.
abstract final class ValidacoesEncerramento {
  /// Estado dos atendimentos e da configuração ANTES de iniciar a operação.
  static Falha? validarAtendimentos(
    List<Atendimento> atendimentos,
    MetodoPagamento metodo,
    ConfiguracaoFaturamento? configuracao,
  ) {
    if (atendimentos.isEmpty) {
      return const FalhaValidacao('Nenhum atendimento selecionado.');
    }
    if (configuracao == null) {
      return const FalhaValidacao(
          'Não foi possível obter a configuração de faturamento do terminal. '
          'Verifique a conexão com o servidor da loja e com a nuvem e tente '
          'novamente.');
    }
    if (!configuracao.completaPara(metodo)) {
      return FalhaValidacao(
          'A forma de pagamento "${metodo.name}" não está configurada no '
          'retaguarda para este terminal. Verifique o cadastro de formas e '
          'tente novamente.');
    }
    for (final a in atendimentos) {
      if (a.situacao != ConstantesApp.situacaoAtendimentoAberto) {
        return FalhaValidacao('O atendimento ${a.nome} não está mais aberto.');
      }
      if (a.bruto['fatura'] != null) {
        return FalhaValidacao(
            'O atendimento ${a.nome} já possui fatura vinculada.');
      }
      if (JsonLeniente.lista(a.bruto['atendimentoResumos']).isEmpty) {
        return FalhaValidacao('O atendimento ${a.nome} não possui itens.');
      }
      if (a.pagoCentavos > 0) {
        // Contrato de pagamento parcial não observado no caixa: a fatura
        // declararia o total cheio como recebido agora. Bloqueia.
        return FalhaValidacao('O atendimento ${a.nome} tem pagamento '
            'parcial registrado e precisa ser encerrado pelo caixa.');
      }
      if (a.sessaoId.isEmpty) {
        return FalhaValidacao(
            'O atendimento ${a.nome} está sem sessão de caixa.');
      }
      if (_id(a.bruto['estabelecimento']).isEmpty ||
          _id(a.bruto['modalidade']).isEmpty ||
          _id(a.bruto['parceiro']).isEmpty) {
        return FalhaValidacao('O atendimento ${a.nome} está incompleto '
            '(estabelecimento, modalidade ou parceiro ausente).');
      }
    }
    final primeira = atendimentos.first;
    final mesmoContexto = atendimentos.every((a) =>
        a.sessaoId == primeira.sessaoId &&
        _id(a.bruto['estabelecimento']) ==
            _id(primeira.bruto['estabelecimento']));
    if (!mesmoContexto) {
      return const FalhaValidacao(
          'Os atendimentos selecionados são de sessões ou estabelecimentos '
          'diferentes e não podem ser encerrados juntos.');
    }
    final total = atendimentos.fold(0, (soma, a) => soma + a.totalCentavos);
    if (total <= 0) {
      return const FalhaValidacao('O total da conta precisa ser maior que '
          'zero para gerar a fatura.');
    }
    return null;
  }

  /// Somas internas da requisição precisam bater com o total da fatura.
  static Falha? conferirConsistencia(
      int totalFatura, int totalItens, int totalModalidades) {
    if (totalItens != totalFatura || totalModalidades != totalFatura) {
      return const FalhaValidacao(
          'Os valores da fatura não conferem com o atendimento. '
          'Atualize a comanda e tente novamente.');
    }
    return null;
  }

  /// A ação 30 só roda com fatura identificada, desta operação e quitada.
  static Falha? validarFatura(
      TransacaoPendente pendente, FaturaReferencia fatura) {
    if (fatura.id.isEmpty || fatura.codigo.isEmpty) {
      return const FalhaServidor(
          'A fatura retornou sem identificação. Tente novamente.');
    }
    if (fatura.identificador.isNotEmpty &&
        fatura.identificador != pendente.identificador) {
      return const FalhaServidor(
          'A fatura retornada não corresponde a esta operação.');
    }
    if (fatura.situacao == 0) {
      // Payload enxuto (consulta de coleção sem os campos de quitação):
      // não dá para confirmar nem descartar — pendência fica para análise.
      return const FalhaServidor(
          'A consulta não devolveu a situação da fatura. '
          'Verifique no retaguarda antes de tentar de novo.');
    }
    final totalEsperado = somaBrutos(pendente.atendimentosBrutos, 'total');
    final quitada = fatura.situacao == FaturaSituacao.paga.valor &&
        fatura.saldoCentavos == 0 &&
        fatura.pagoCentavos == totalEsperado;
    if (!quitada) {
      return const FalhaServidor(
          'A fatura foi criada mas não consta como quitada. '
          'Verifique no retaguarda antes de tentar de novo.');
    }
    return null;
  }

  static int somaBrutos(List<Map<String, dynamic>> brutos, String campo) =>
      brutos.fold(0, (soma, b) => soma + ValoresFatura.centavos(b[campo]));

  static String _id(dynamic mapa) =>
      JsonLeniente.texto(JsonLeniente.mapa(mapa)['id']);
}
