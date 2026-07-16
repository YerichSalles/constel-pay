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

  // Chaves de SharedPreferences que SOBREVIVEM ao "Limpar dados locais":
  // registros transacionais cuja perda deixaria dado financeiro órfão no
  // retaguarda. Toda feature com dado desse tipo registra a chave aqui.
  static const List<String> chavesProtegidasNaLimpeza = [
    'transacoes_pendentes',
  ];
}
