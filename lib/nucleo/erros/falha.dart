sealed class Falha {
  const Falha(this.mensagem);

  final String mensagem;
}

final class FalhaRede extends Falha {
  const FalhaRede(
      [super.mensagem = 'Falha de comunicação com a API. '
          'Verifique a URL configurada, a rede e se o serviço está no ar.']);
}

final class FalhaTimeout extends Falha {
  const FalhaTimeout(
      [super.mensagem = 'O servidor demorou para responder. Tente novamente.']);
}

final class FalhaServidor extends Falha {
  const FalhaServidor([super.mensagem = 'Erro ao comunicar com o servidor.']);
}

final class FalhaNaoAutorizado extends Falha {
  const FalhaNaoAutorizado(
      [super.mensagem = 'Acesso não autorizado. Verifique usuário e senha.']);
}

final class FalhaValidacao extends Falha {
  const FalhaValidacao(super.mensagem);
}

/// Terminal de pagamento indisponível: maquininha desconectada, SDK da
/// adquirente não ativado, ou build sem a adquirente embarcada. A cobrança
/// NÃO chegou a acontecer — repetir é seguro.
final class FalhaTerminalPagamento extends Falha {
  const FalhaTerminalPagamento(
      [super.mensagem = 'O terminal de pagamento não respondeu. '
          'Verifique o equipamento e tente novamente.']);
}

/// A cobrança PODE ter sido efetivada e o app não conseguiu confirmar
/// (tempo esgotado, app encerrado durante a operação). Nunca tratar como
/// recusa nem repetir automaticamente: exige conferência antes de cobrar
/// de novo, sob pena de debitar duas vezes.
final class FalhaPagamentoIndeterminado extends Falha {
  const FalhaPagamentoIndeterminado(
      [super.mensagem = 'Não foi possível confirmar o resultado do pagamento. '
          'Confira o comprovante na maquininha antes de cobrar novamente.']);
}

final class FalhaDesconhecida extends Falha {
  const FalhaDesconhecida([super.mensagem = 'Ocorreu um erro inesperado.']);
}
