import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/nucleo/configuracao/ambiente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bases ativas terminam com barra (Dio concatena base + caminho)', () {
    const configuracao = ConfiguracaoTerminal(
      urlBaseHomologacao: 'https://localhost:3001/api',
      urlNuvemHomologacao: 'https://sirius.constel.builders/api',
    );
    expect(configuracao.urlBaseAtiva, 'https://localhost:3001/api/');
    expect(configuracao.urlNuvemAtiva, 'https://sirius.constel.builders/api/');
  });

  test('barra existente não é duplicada', () {
    const configuracao = ConfiguracaoTerminal(
      ambiente: Ambiente.producao,
      urlBaseProducao: 'https://loja.constel.builders/api/',
      urlNuvemProducao: 'https://sirius.constel.builders/api/',
    );
    expect(configuracao.urlBaseAtiva, 'https://loja.constel.builders/api/');
    expect(configuracao.urlNuvemAtiva, 'https://sirius.constel.builders/api/');
  });

  test('base vazia continua vazia (dispara falha de configuração)', () {
    const configuracao = ConfiguracaoTerminal();
    expect(configuracao.urlBaseAtiva, isEmpty);
    expect(configuracao.urlNuvemAtiva, isEmpty);
  });
}
