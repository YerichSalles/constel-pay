import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/entidades/cartao_consumo.dart';
import '../../dominio/entidades/mesa.dart';
import '../../dominio/repositorios/repositorio_leitura.dart';
import '../fontes_dados/fonte_leitura_mock.dart';

class RepositorioLeituraImpl implements RepositorioLeitura {
  RepositorioLeituraImpl(this._fonte);

  final FonteLeituraMock _fonte;

  @override
  Future<Resultado<Mesa>> obterMesa() async => Sucesso(_fonte.obterMesa());

  @override
  Future<Resultado<CartaoConsumo>> lerCartao() async {
    final cartao = await _fonte.lerProximo();
    if (cartao == null) {
      return const Erro(
          FalhaValidacao('Não há mais cartões em aberto nesta mesa.'));
    }
    return Sucesso(cartao);
  }

  @override
  int get cartoesRestantes => _fonte.restantes;

  @override
  void reiniciar() => _fonte.reiniciar();
}
