import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_tema_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:constel_pay/nucleo/configuracao/ambiente.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RepositorioConfiguracaoImpl', () {
    test('devolve padrao quando nada foi salvo', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio =
          RepositorioConfiguracaoImpl(await SharedPreferences.getInstance());
      final config = await repositorio.obter();
      expect(config, const ConfiguracaoTerminal());
    });

    test('salva e recupera a configuracao', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio =
          RepositorioConfiguracaoImpl(await SharedPreferences.getInstance());
      const config = ConfiguracaoTerminal(
        nomeRestaurante: 'Durango Burgers',
        ambiente: Ambiente.producao,
        urlBaseProducao: 'https://api.durango.com.br',
        pinHash: 'abc123',
      );
      await repositorio.salvar(config);
      expect(await repositorio.obter(), config);
    });

    test('devolve padrao quando o JSON esta corrompido', () async {
      SharedPreferences.setMockInitialValues(
          {'configuracao_terminal': '{invalido'});
      final repositorio =
          RepositorioConfiguracaoImpl(await SharedPreferences.getInstance());
      expect(await repositorio.obter(), const ConfiguracaoTerminal());
    });
  });

  group('RepositorioTemaImpl', () {
    test('salva e recupera o tema', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio =
          RepositorioTemaImpl(await SharedPreferences.getInstance());
      const tema =
          TemaPersonalizado(corPrimaria: '#112233', logoPath: '/tmp/logo.png');
      await repositorio.salvar(tema);
      expect(await repositorio.obter(), tema);
    });

    test('devolve padrao quando nada foi salvo', () async {
      SharedPreferences.setMockInitialValues({});
      final repositorio =
          RepositorioTemaImpl(await SharedPreferences.getInstance());
      expect(await repositorio.obter(), const TemaPersonalizado());
    });
  });
}
