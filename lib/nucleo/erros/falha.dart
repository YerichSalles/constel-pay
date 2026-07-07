sealed class Falha {
  const Falha(this.mensagem);

  final String mensagem;
}

final class FalhaRede extends Falha {
  const FalhaRede([super.mensagem = 'Sem conexão com a internet.']);
}

final class FalhaTimeout extends Falha {
  const FalhaTimeout(
      [super.mensagem = 'O servidor demorou para responder. Tente novamente.']);
}

final class FalhaServidor extends Falha {
  const FalhaServidor([super.mensagem = 'Erro ao comunicar com o servidor.']);
}

final class FalhaValidacao extends Falha {
  const FalhaValidacao(super.mensagem);
}

final class FalhaDesconhecida extends Falha {
  const FalhaDesconhecida([super.mensagem = 'Ocorreu um erro inesperado.']);
}
