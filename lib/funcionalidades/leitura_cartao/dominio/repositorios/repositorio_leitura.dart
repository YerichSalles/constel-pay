import '../../../../nucleo/erros/resultado.dart';
import '../entidades/cartao_consumo.dart';
import '../entidades/mesa.dart';

abstract interface class RepositorioLeitura {
  Future<Resultado<Mesa>> obterMesa();

  Future<Resultado<CartaoConsumo>> lerCartao();

  int get cartoesRestantes;

  void reiniciar();
}
