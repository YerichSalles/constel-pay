import '../entidades/configuracao_terminal.dart';

abstract interface class RepositorioConfiguracao {
  Future<ConfiguracaoTerminal> obter();

  Future<void> salvar(ConfiguracaoTerminal configuracao);
}
