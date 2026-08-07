import 'dart:async';

import 'package:flutter/services.dart';

import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/entidades/metodo_pagamento.dart';
import '../../dominio/entidades/resultado_transacao.dart';
import '../../dominio/entidades/status_pagamento.dart';

/// Tradução entre o contrato do canal nativo e o domínio.
///
/// Fica isolada do `GatewayPagamentoChannel` para ser testável sem plataforma:
/// é aqui que se decide, diante de uma resposta estranha, entre "recusado" e
/// "não sei" — e a resposta certa em pagamento é sempre "não sei".
abstract final class MapaTransacaoNativa {
  /// Códigos de transação da adquirente. São os MESMOS usados como espécie da
  /// forma de pagamento no retaguarda (ver `EspecieForma`).
  static const Map<MetodoPagamento, int> tipoPorMetodo = {
    MetodoPagamento.credito: 110,
    MetodoPagamento.debito: 120,
    MetodoPagamento.pix: 230,
  };

  /// `null` para método que a camada nativa não cobra — o caso de uso já
  /// barra antes, isto é a segunda barreira.
  static int? tipoDe(MetodoPagamento metodo) => tipoPorMetodo[metodo];

  static const Map<String, StatusPagamento> _statusPorNome = {
    'aprovado': StatusPagamento.aprovado,
    'recusado': StatusPagamento.recusado,
    'cancelado': StatusPagamento.cancelado,
  };

  /// Converte a resposta do canal em transação de domínio.
  ///
  /// [valorCentavos] é o valor que o app pediu, usado quando o nativo não
  /// devolve valor: o dado do app é a referência, não o eco.
  static Resultado<ResultadoTransacao> deResposta(
    Object? resposta, {
    required MetodoPagamento metodo,
    required int valorCentavos,
  }) {
    if (resposta is! Map) return const Erro(FalhaPagamentoIndeterminado());
    final mapa = <String, Object?>{
      for (final entrada in resposta.entries)
        if (entrada.key is String) entrada.key as String: entrada.value,
    };
    final status = _statusPorNome[_texto(mapa['status']).toLowerCase()];
    // Status ausente ou desconhecido: a cobrança pode ter passado. Tratar
    // como recusa aqui abriria caminho para cobrar duas vezes.
    if (status == null) return const Erro(FalhaPagamentoIndeterminado());
    return Sucesso(ResultadoTransacao(
      status: status,
      metodo: metodo,
      valorCentavos: _inteiro(mapa['valorCentavos'], padrao: valorCentavos),
      parcelas: _inteiro(mapa['parcelas'], padrao: 1),
      codigoAutorizacao: _texto(mapa['codigoAutorizacao']),
      nsu: _texto(mapa['nsu']),
      bandeira: _texto(mapa['bandeira']),
      finalCartao: _texto(mapa['finalCartao']),
      adquirente: _texto(mapa['adquirente']),
      mensagemOperador: _truncar(_texto(mapa['mensagemOperador'])),
      tokenTransacao: _texto(mapa['tokenTransacao']),
    ));
  }

  /// Traduz o que veio de errado do canal.
  ///
  /// Regra de ouro: só vira falha "segura para repetir" quando é certo que
  /// nada foi cobrado. Na dúvida, indeterminado.
  static Falha falhaDeExcecao(Object erro) {
    if (erro is MissingPluginException) {
      // Build sem adquirente embarcada: o canal não existe do lado nativo.
      return const FalhaTerminalPagamento(
          'Este terminal não está preparado para cobrar no cartão.');
    }
    if (erro is TimeoutException) return const FalhaPagamentoIndeterminado();
    if (erro is! PlatformException) return const FalhaPagamentoIndeterminado();
    return switch (erro.code) {
      'TERMINAL_INDISPONIVEL' ||
      'NAO_ATIVADO' ||
      'EM_ANDAMENTO' =>
        FalhaTerminalPagamento(
            _mensagemOuPadrao(erro, const FalhaTerminalPagamento().mensagem)),
      'SEM_REDE' => const FalhaRede(),
      'TEMPO_ESGOTADO' => const FalhaTimeout(),
      _ => const FalhaPagamentoIndeterminado(),
    };
  }

  static String _mensagemOuPadrao(PlatformException erro, String padrao) {
    final mensagem = _truncar((erro.message ?? '').trim());
    return mensagem.isEmpty ? padrao : mensagem;
  }

  static String _texto(Object? valor) => valor is String ? valor : '';

  static int _inteiro(Object? valor, {required int padrao}) =>
      valor is num ? valor.toInt() : padrao;

  /// Texto de terceiro tem comprimento imprevisível e a bolha do chat não é
  /// elástica. Mesmo limite usado no eco de mensagem de servidor.
  static String _truncar(String texto) =>
      texto.length <= 160 ? texto : '${texto.substring(0, 159)}…';
}
