import '../entidades/transacao_pendente.dart';

/// Fila local de encerramentos interrompidos. A pendência entra antes do
/// primeiro passo crítico e só sai depois da ação 30 confirmada.
abstract interface class RepositorioTransacoesPendentes {
  Future<List<TransacaoPendente>> obterTodas();

  /// Insere ou substitui (pelo `identificador`).
  Future<void> salvar(TransacaoPendente transacao);

  Future<void> remover(String identificador);
}
