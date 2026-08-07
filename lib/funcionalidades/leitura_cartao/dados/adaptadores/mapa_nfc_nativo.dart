import 'dart:async';

import 'package:flutter/services.dart';

import '../../../../nucleo/erros/falha.dart';

/// Tradução entre o contrato do canal nativo de NFC e o domínio. Espelha
/// `MapaTransacaoNativa`: erros nunca viram exceção solta, sempre `Falha`
/// com mensagem específica para o card mostrar.
abstract final class MapaNfcNativo {
  static Falha falhaDeExcecao(Object erro) {
    if (erro is MissingPluginException) {
      // Build sem adquirente embarcada: o canal não existe do lado nativo.
      return const FalhaTerminalPagamento(
          'Este terminal não tem leitor NFC disponível.');
    }
    if (erro is TimeoutException) {
      return const FalhaTimeout('Tempo esgotado aguardando o cartão.');
    }
    if (erro is! PlatformException) {
      return const FalhaTerminalPagamento(
          'Não foi possível ler o cartão. Aproxime novamente.');
    }
    return switch (erro.code) {
      'SEM_LEITOR' => FalhaTerminalPagamento(_mensagemOuPadrao(
          erro, 'Este terminal não tem leitor NFC disponível.')),
      'TEMPO_ESGOTADO' => FalhaTimeout(
          _mensagemOuPadrao(erro, 'Tempo esgotado aguardando o cartão.')),
      'CANCELADO' || 'EM_ANDAMENTO' || 'ERRO_LEITURA' => FalhaTerminalPagamento(
          _mensagemOuPadrao(
              erro, 'Não foi possível ler o cartão. Aproxime novamente.')),
      _ => const FalhaTerminalPagamento(
          'Não foi possível ler o cartão. Aproxime novamente.'),
    };
  }

  static String _mensagemOuPadrao(PlatformException erro, String padrao) {
    final mensagem = (erro.message ?? '').trim();
    return mensagem.isEmpty ? padrao : mensagem;
  }
}
