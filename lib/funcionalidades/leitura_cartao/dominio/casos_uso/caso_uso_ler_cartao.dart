import '../../../../nucleo/erros/resultado.dart';
import '../entidades/cartao_consumo.dart';
import '../repositorios/repositorio_leitura.dart';

class CasoUsoLerCartao {
  CasoUsoLerCartao(this._repositorio);

  final RepositorioLeitura _repositorio;

  Future<Resultado<CartaoConsumo>> executar() => _repositorio.lerCartao();
}
