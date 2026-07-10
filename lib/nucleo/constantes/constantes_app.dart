abstract final class ConstantesApp {
  static const Duration tempoInatividade = Duration(minutes: 2);
  static const Duration duracaoSplash = Duration(seconds: 4);
  static const Duration atrasoBotPadrao = Duration(milliseconds: 650);
  static const Duration duracaoPadraoImagem = Duration(seconds: 8);
  static const String chaveUltimaSincronizacao = 'ultima_sincronizacao';

  // Identificação do app enviada no login da API na nuvem.
  // Ajuste 'nomeAplicativoLogin' se o backend exigir outro nome registrado
  // (ex.: 'Atendimento') e 'dataVersaoAplicativo' a cada release.
  static const String nomeAplicativoLogin = 'Constel Pay';
  static const String dataVersaoAplicativo = '2026-07-08';

  // Caminho do login na API de nuvem (relativo à urlNuvemAtiva, que deve
  // terminar com '/'). Ex.: base 'http://host/api/' + 'auth/login'.
  static const String caminhoLoginNuvem = 'auth/login';
}
