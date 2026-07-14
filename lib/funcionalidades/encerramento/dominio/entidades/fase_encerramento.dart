/// Fases da operação de encerramento, na ordem em que acontecem. A UI usa a
/// fase para mostrar a mensagem de progresso correspondente.
enum FaseEncerramento {
  preparandoEncerramento,
  gerandoFatura,
  confirmandoEncerramento,
  concluida,
  erro,
}
