import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_configuracoes.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/casos_uso/caso_uso_testar_conexao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/credencial.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_credencial.dart';
import 'package:constel_pay/nucleo/configuracao/ambiente.dart';
import 'package:constel_pay/nucleo/configuracao/cliente_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CredencialFake implements RepositorioCredencial {
  Credencial? salva;

  @override
  Future<Credencial?> obter() async => salva;

  @override
  Future<void> salvar(Credencial credencial) async => salva = credencial;

  @override
  Future<void> remover() async => salva = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RepositorioConfiguracaoImpl repositorioConfiguracao;
  late _CredencialFake repositorioCredencial;
  late ControladorConfiguracoes controlador;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    repositorioConfiguracao = RepositorioConfiguracaoImpl(preferencias);
    repositorioCredencial = _CredencialFake();
    controlador = ControladorConfiguracoes(
      repositorioConfiguracao: repositorioConfiguracao,
      repositorioCredencial: repositorioCredencial,
      casoUsoTestarConexao: CasoUsoTestarConexao(
        clienteApi: ClienteApi(
            repositorioConfiguracao: repositorioConfiguracao, dio: Dio()),
        repositorioConfiguracao: repositorioConfiguracao,
        preferencias: preferencias,
      ),
    );
    await controlador.carregar();
  });

  test('carregar preenche configuracao e credencial', () async {
    expect(controlador.state.carregando, isFalse);
    expect(controlador.state.configuracao.nomeRestaurante, 'Constel Pay');
  });

  test('salvarConfiguracao persiste os novos dados', () async {
    final nova = controlador.state.configuracao.copyWith(
        nomeRestaurante: 'Durango Burgers',
        identificadorDispositivo: 'TOTEM-07');
    await controlador.salvarConfiguracao(nova);
    expect((await repositorioConfiguracao.obter()).nomeRestaurante,
        'Durango Burgers');
    expect(controlador.state.mensagem, isNotNull);
    expect(controlador.state.mensagemErro, isFalse);
  });

  test('salvarComunicacao grava credencial e urls', () async {
    await controlador.salvarComunicacao(
      usuario: 'operador',
      senha: 's3nh4',
      ambiente: Ambiente.producao,
      urlProducao: 'https://api.constel.com.br',
      urlHomologacao: 'https://homolog.constel.com.br',
    );
    expect(repositorioCredencial.salva,
        const Credencial(usuario: 'operador', senha: 's3nh4'));
    final configuracao = await repositorioConfiguracao.obter();
    expect(configuracao.ambiente, Ambiente.producao);
    expect(configuracao.urlBaseAtiva, 'https://api.constel.com.br');
  });

  test('testarConexao sem URL valida gera mensagem de erro', () async {
    await controlador.testarConexao();
    expect(controlador.state.mensagemErro, isTrue);
    expect(controlador.state.mensagem, contains('URL'));
  });
}
