import '../../../../nucleo/erros/resultado.dart';
import '../entidades/cartao_consumo.dart';

abstract interface class RepositorioLeitura {
  Future<Resultado<CartaoConsumo>> lerCartao();

  int get cartoesRestantes;

  void reiniciar();
}
