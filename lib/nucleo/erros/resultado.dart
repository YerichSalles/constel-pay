import 'falha.dart';

sealed class Resultado<T> {
  const Resultado();

  R quando<R>({
    required R Function(T valor) sucesso,
    required R Function(Falha falha) erro,
  }) =>
      switch (this) {
        Sucesso<T>(:final valor) => sucesso(valor),
        Erro<T>(:final falha) => erro(falha),
      };
}

final class Sucesso<T> extends Resultado<T> {
  const Sucesso(this.valor);

  final T valor;
}

final class Erro<T> extends Resultado<T> {
  const Erro(this.falha);

  final Falha falha;
}
