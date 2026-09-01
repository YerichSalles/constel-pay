abstract final class ConstantesApp {
  // PIN fixo de acesso às configurações do terminal. Não é configurável.
  static const String pinAcesso = '159753';

  static const Duration tempoInatividade = Duration(minutes: 2);
  static const Duration tempoAvisoInatividade = Duration(seconds: 15);
  static const Duration duracaoSplash = Duration(seconds: 4);
  static const Duration atrasoBotPadrao = Duration(milliseconds: 650);

  // Tempo que o comprovante fica na tela antes de o terminal voltar sozinho
  // ao início; o cliente pode antecipar tocando em "Novo pagamento".
  static const Duration duracaoExibicaoComprovante = Duration(seconds: 15);
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

  // Consumo do cartão/mesa na API da loja (relativo à base, que deve
  // terminar com '/'). classe e situacao são fixos do atendimento de
  // consumo em aberto; a referência (mesa/cartão) é dinâmica.
  static const String caminhoColecaoAtendimento = 'venda/atendimento/colecao';

  // Cadastro do item na API da loja (relativo à base). Devolve o item completo,
  // de onde o app usa apenas o campo `imagem` (URL pública da foto).
  static const String caminhoRecursoItem = 'recurso/item/';
  static const int classeAtendimentoConsumo = 1600;
  static const int situacaoAtendimentoAberto = 20;

  // Encerramento do atendimento na API da loja (ações 10 = iniciar e
  // 30 = confirmar) e fatura na API da nuvem. Contrato observado no caixa
  // (ConstelPDV): encerra vai ao APL local, a fatura vai à nuvem.
  static const String caminhoEncerraAtendimento = 'venda/atendimento/encerra';
  static const String caminhoFatura = 'movimento/fatura';

  // Documento do dispositivo na API da loja (`estrutura/dispositivo/<id>`):
  // traz o cabeçalho fiscal já configurado para o terminal (histórico,
  // operação, moeda, dispositivo, departamento). É a fonte da configuração
  // de faturamento que NÃO depende de venda anterior.
  static const String caminhoDispositivo = 'estrutura/dispositivo';

  // Cadastro de formas de pagamento na API da nuvem (`financeiro/forma`):
  // `?texto=` lista as formas; `/<id>` traz o detalhe com a conta de
  // recebimento (`conta`/`formaContas` por estabelecimento) e o plano
  // padrão (`formaPlanos`). É como o terminal descobre forma/plano/conta
  // por espécie, sem depender de fatura anterior.
  static const String caminhoForma = 'financeiro/forma';

  // Canal de comunicação com a camada nativa de pagamento. O nome é o MESMO
  // em qualquer build: a pasta nativa muda por adquirente, o canal não. Saber
  // qual adquirente está embarcada é papel do TipoAdquirente, nunca do nome
  // do canal.
  static const String canalPagamentoNativo = 'com.constelpay.pagamento';

  // Canal de comunicação com a leitura por NFC da maquininha (antena da
  // Stone, não o NfcAdapter do Android). Mesmo princípio do canal de
  // pagamento: nome fixo, a pasta nativa é que muda por adquirente.
  static const String canalNfcNativo = 'com.constelpay.nfc';

  // Tempo máximo que o app espera a leitura por NFC. O nativo responde antes
  // (90s) com o motivo real; esta é só a rede de segurança do lado Dart.
  static const Duration tempoLimiteLeituraNfc = Duration(seconds: 95);

  // Teto de parcelas no crédito. O fluxo atual cobra sempre à vista; a
  // constante existe para o caso de uso validar o argumento recebido em vez
  // de carregar um número solto.
  static const int parcelasMaximasCredito = 12;

  // Tempo máximo que o app espera a maquininha responder. Estourado o limite,
  // o resultado é INDETERMINADO (pode ter cobrado), nunca recusa.
  static const Duration tempoLimitePagamentoNativo = Duration(minutes: 3);

  // Chaves de SharedPreferences que SOBREVIVEM ao "Limpar dados locais":
  // registros transacionais cuja perda deixaria dado financeiro órfão no
  // retaguarda. Toda feature com dado desse tipo registra a chave aqui.
  static const List<String> chavesProtegidasNaLimpeza = [
    'transacoes_pendentes',
  ];
}
