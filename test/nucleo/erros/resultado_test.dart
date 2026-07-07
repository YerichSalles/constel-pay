import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Resultado', () {
    test('quando executa o ramo de sucesso', () {
      const Resultado<int> resultado = Sucesso(42);
      final saida = resultado.quando(
        sucesso: (valor) => 'ok $valor',
        erro: (_) => 'erro',
      );
      expect(saida, 'ok 42');
    });

    test('quando executa o ramo de erro com a mensagem da falha', () {
      const Resultado<int> resultado = Erro(FalhaRede());
      final saida = resultado.quando(
        sucesso: (_) => 'ok',
        erro: (falha) => falha.mensagem,
      );
      expect(saida, 'Sem conexão com a internet.');
    });

    test('falhas possuem mensagens padrão em pt-BR', () {
      expect(const FalhaTimeout().mensagem, contains('demorou'));
      expect(const FalhaServidor().mensagem, contains('servidor'));
      expect(const FalhaDesconhecida().mensagem, contains('inesperado'));
      expect(const FalhaValidacao('Campo obrigatório.').mensagem,
          'Campo obrigatório.');
    });
  });
}
