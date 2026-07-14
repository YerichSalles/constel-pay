import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/repositorios/repositorio_leitura_impl.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dominio/entidades/cartao_consumo.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FonteLeituraMock fonte;
  late RepositorioLeituraImpl repositorio;
  late CasoUsoLerCartao casoUso;

  setUp(() {
    fonte = FonteLeituraMock(atraso: Duration.zero);
    repositorio = RepositorioLeituraImpl(fonte);
    casoUso = CasoUsoLerCartao(repositorio);
  });

  test('subtotal de cada comanda coincide com a soma dos itens', () async {
    for (var i = 0; i < 3; i++) {
      final resultado = await casoUso.executar();
      final cartao = (resultado as Sucesso<CartaoConsumo>).valor;
      final soma = cartao.itens
          .fold<int>(0, (acumulado, item) => acumulado + item.totalCentavos);
      expect(cartao.subtotalCentavos, soma, reason: 'comanda ${cartao.nome}');
    }
  });

  test('le as tres comandas em ordem e depois devolve falha', () async {
    final primeira = await casoUso.executar();
    expect((primeira as Sucesso<CartaoConsumo>).valor.pessoa, 'João');
    expect((primeira).valor.subtotalCentavos, 13600);
    expect(repositorio.cartoesRestantes, 2);

    final segunda = await casoUso.executar();
    expect((segunda as Sucesso<CartaoConsumo>).valor.pessoa, 'Maria');

    final terceira = await casoUso.executar();
    expect((terceira as Sucesso<CartaoConsumo>).valor.pessoa, 'Ana');
    expect(repositorio.cartoesRestantes, 0);

    final quarta = await casoUso.executar();
    expect(quarta, isA<Erro<CartaoConsumo>>());
    expect((quarta as Erro<CartaoConsumo>).falha, isA<FalhaValidacao>());
  });

  test('reiniciar permite ler tudo de novo', () async {
    await casoUso.executar();
    await casoUso.executar();
    repositorio.reiniciar();
    expect(repositorio.cartoesRestantes, 3);
    final resultado = await casoUso.executar();
    expect((resultado as Sucesso<CartaoConsumo>).valor.pessoa, 'João');
  });
}
