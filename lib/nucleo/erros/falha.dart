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

final class FalhaDesconhecida extends Falha {
  const FalhaDesconhecida([super.mensagem = 'Ocorreu um erro inesperado.']);
}
