import 'package:constel_pay/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_login_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/repositorios/repositorio_sessao_nuvem.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_configuracoes.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/casos_uso/caso_uso_testar_conexao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/credencial.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_credencial.dart';
import 'package:constel_pay/nucleo/configuracao/ambiente.dart';
import 'package:constel_pay/nucleo/configuracao/cliente_api.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

class _SessaoFake implements RepositorioSessaoNuvem {
  SessaoNuvem? salva;

  @override
  Future<SessaoNuvem?> obter() async => salva;

  @override
  Future<void> salvar(SessaoNuvem sessao) async => salva = sessao;

  @override
  Future<void> remover() async => salva = null;
}

class _LoginNuvemMock extends Mock implements CasoUsoLoginNuvem {}

/// Responde 200 sem tocar a rede — o teste de conexão só precisa saber que o
/// servidor está acessível.
class _AdaptadorOk implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<List<int>>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString('{}', 200, headers: {
        'content-type': ['application/json']
      });

  @override
  void close({bool force = false}) {}
}

SessaoNuvem _sessao() => SessaoNuvem(
      token: 'jwt',
      validade: DateTime.utc(2026, 7, 11),
      usuario: const UsuarioSessao(nome: 'Ana', imagem: ''),
      empresa: const EmpresaSessao(id: 'e1', nome: 'Empresa'),
      dispositivo: const DispositivoSessao(id: 'd1', nome: 'Terminal'),
      estabelecimento: const EstabelecimentoSessao(id: 's1', nome: 'Loja'),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RepositorioConfiguracaoImpl repositorioConfiguracao;
  late _CredencialFake repositorioCredencial;
  late _SessaoFake repositorioSessao;
  late _SessaoFake repositorioSessaoLoja;
  late _LoginNuvemMock casoUsoLoginNuvem;
  late _LoginNuvemMock casoUsoLoginLoja;
  late ControladorConfiguracoes controlador;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    repositorioConfiguracao = RepositorioConfiguracaoImpl(preferencias);
    await repositorioConfiguracao.salvar(const ConfiguracaoTerminal(
      urlBaseHomologacao: 'https://localhost:3001/api',
      urlNuvemHomologacao: 'https://nuvem.constel.dev/api',
    ));
    repositorioCredencial = _CredencialFake();
    repositorioSessao = _SessaoFake();
    repositorioSessaoLoja = _SessaoFake();
    casoUsoLoginNuvem = _LoginNuvemMock();
    casoUsoLoginLoja = _LoginNuvemMock();
    // Por padrão o login da loja passa: os testes abaixo focam na nuvem.
    when(() => casoUsoLoginLoja.executar())
        .thenAnswer((_) async => Sucesso(_sessao()));
    controlador = ControladorConfiguracoes(
      repositorioConfiguracao: repositorioConfiguracao,
      repositorioCredencial: repositorioCredencial,
      repositorioSessaoNuvem: repositorioSessao,
      repositorioSessaoLoja: repositorioSessaoLoja,
      casoUsoTestarConexao: CasoUsoTestarConexao(
        clienteLoja: ClienteApi(
          repositorioConfiguracao: repositorioConfiguracao,
          seletorBase: (c) => c.urlBaseAtiva,
          dio: Dio()..httpClientAdapter = _AdaptadorOk(),
        ),
        clienteNuvem: ClienteApi(
          repositorioConfiguracao: repositorioConfiguracao,
          seletorBase: (c) => c.urlNuvemAtiva,
          dio: Dio()..httpClientAdapter = _AdaptadorOk(),
        ),
        repositorioConfiguracao: repositorioConfiguracao,
        preferencias: preferencias,
      ),
      casoUsoLoginNuvem: casoUsoLoginNuvem,
      casoUsoLoginLoja: casoUsoLoginLoja,
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
    expect(configuracao.urlBaseAtiva, 'https://api.constel.com.br/');
  });

  test('salvarComunicacao grava identificador e UUID do dispositivo', () async {
    await controlador.salvarComunicacao(
      usuario: 'operador',
      senha: 's3nh4',
      ambiente: Ambiente.homologacao,
      urlProducao: '',
      urlHomologacao: '',
      identificadorDispositivo: 'TOTEM-07',
      idDispositivo: 'b47ac10b-58cc-4372-a567-0e02b2c3d479',
    );
    final configuracao = await repositorioConfiguracao.obter();
    expect(configuracao.identificadorDispositivo, 'TOTEM-07');
    expect(configuracao.idDispositivo, 'b47ac10b-58cc-4372-a567-0e02b2c3d479');
  });

  test('salvarComunicacao grava e persiste a leitura por câmera', () async {
    await controlador.salvarComunicacao(
      usuario: 'operador',
      senha: 's3nh4',
      ambiente: Ambiente.homologacao,
      urlProducao: '',
      urlHomologacao: '',
      leituraPorCamera: true,
    );
    expect((await repositorioConfiguracao.obter()).leituraPorCamera, isTrue);

    // Omitir o campo preserva o valor salvo: quem salva outra seção da aba não
    // pode desligar a câmera sem querer.
    await controlador.salvarComunicacao(
      usuario: 'operador',
      senha: 's3nh4',
      ambiente: Ambiente.homologacao,
      urlProducao: '',
      urlHomologacao: '',
    );
    expect((await repositorioConfiguracao.obter()).leituraPorCamera, isTrue);
  });

  test('leitura por câmera vem desligada por padrão', () async {
    expect(const ConfiguracaoTerminal().leituraPorCamera, isFalse);
  });

  test('salvarComunicacao invalida a sessão de nuvem gravada', () async {
    repositorioSessao.salva = _sessao();
    await controlador.salvarComunicacao(
      usuario: 'outro',
      senha: 'nova',
      ambiente: Ambiente.homologacao,
      urlProducao: '',
      urlHomologacao: '',
    );
    expect(repositorioSessao.salva, isNull);
  });

  test('testarApiLocal sem URL valida nem tenta o login', () async {
    await repositorioConfiguracao.salvar(const ConfiguracaoTerminal());
    await controlador.testarApiLocal();
    expect(controlador.state.mensagemErro, isTrue);
    expect(controlador.state.mensagem, contains('URL'));
    verifyNever(() => casoUsoLoginLoja.executar());
  });

  test('testarApiLocal OK mostra usuário e estabelecimento da loja', () async {
    await controlador.testarApiLocal();
    expect(controlador.state.testandoLocal, isFalse);
    expect(controlador.state.mensagemErro, isFalse);
    expect(controlador.state.mensagem, contains('API Local OK'));
    expect(controlador.state.mensagem, contains('Ana'));
    expect(controlador.state.mensagem, contains('Loja'));
    verifyNever(() => casoUsoLoginNuvem.executar());
  });

  test('testarApiNuvem OK mostra usuário e estabelecimento da nuvem', () async {
    when(() => casoUsoLoginNuvem.executar())
        .thenAnswer((_) async => Sucesso(_sessao()));
    await controlador.testarApiNuvem();
    expect(controlador.state.testandoNuvem, isFalse);
    expect(controlador.state.mensagemErro, isFalse);
    expect(controlador.state.mensagem, contains('API Nuvem OK'));
    verifyNever(() => casoUsoLoginLoja.executar());
  });

  test('carregar expõe o estabelecimento da sessão de nuvem salva', () async {
    expect(controlador.state.nomeEstabelecimento, isEmpty);
    repositorioSessao.salva = _sessao();
    await controlador.carregar();
    expect(controlador.state.nomeEstabelecimento, 'Loja');
  });

  test('testarApiNuvem com sucesso atualiza o estabelecimento', () async {
    when(() => casoUsoLoginNuvem.executar())
        .thenAnswer((_) async => Sucesso(_sessao()));
    await controlador.testarApiNuvem();
    expect(controlador.state.nomeEstabelecimento, 'Loja');
  });

  test('salvarComunicacao limpa o estabelecimento junto com a sessão',
      () async {
    repositorioSessao.salva = _sessao();
    await controlador.carregar();
    await controlador.salvarComunicacao(
      usuario: 'outro',
      senha: 'nova',
      ambiente: Ambiente.homologacao,
      urlProducao: '',
      urlHomologacao: '',
    );
    expect(controlador.state.nomeEstabelecimento, isEmpty);
  });

  test('testarApiNuvem com login recusado propaga a mensagem', () async {
    when(() => casoUsoLoginNuvem.executar())
        .thenAnswer((_) async => const Erro(FalhaNaoAutorizado()));
    await controlador.testarApiNuvem();
    expect(controlador.state.testandoNuvem, isFalse);
    expect(controlador.state.mensagemErro, isTrue);
    expect(controlador.state.mensagem, contains('API Nuvem'));
    expect(controlador.state.mensagem, contains('não autorizado'));
  });

  test('testarApiLocal com login recusado propaga a mensagem', () async {
    when(() => casoUsoLoginLoja.executar())
        .thenAnswer((_) async => const Erro(FalhaNaoAutorizado()));
    await controlador.testarApiLocal();
    expect(controlador.state.testandoLocal, isFalse);
    expect(controlador.state.mensagemErro, isTrue);
    expect(controlador.state.mensagem, contains('API Local'));
    expect(controlador.state.mensagem, contains('não autorizado'));
  });

  test('testes com sucesso atualizam status, latência e usuário do painel',
      () async {
    expect(controlador.state.statusLocal, StatusConexao.desconhecido);
    await controlador.testarApiLocal();
    expect(controlador.state.statusLocal, StatusConexao.conectado);
    expect(controlador.state.latenciaLocalMs, isNotNull);
    expect(controlador.state.ultimaVerificacao, isNotNull);

    when(() => casoUsoLoginNuvem.executar())
        .thenAnswer((_) async => Sucesso(_sessao()));
    await controlador.testarApiNuvem();
    expect(controlador.state.statusNuvem, StatusConexao.conectado);
    expect(controlador.state.usuarioNuvem, isNotEmpty);
  });

  test('falha no teste marca status de erro e salvar reseta os status',
      () async {
    when(() => casoUsoLoginNuvem.executar())
        .thenAnswer((_) async => const Erro(FalhaNaoAutorizado()));
    await controlador.testarApiNuvem();
    expect(controlador.state.statusNuvem, StatusConexao.erro);

    await controlador.salvarComunicacao(
      usuario: 'outro',
      senha: 'nova',
      ambiente: Ambiente.homologacao,
      urlProducao: '',
      urlHomologacao: '',
    );
    expect(controlador.state.statusNuvem, StatusConexao.desconhecido);
    expect(controlador.state.statusLocal, StatusConexao.desconhecido);
    expect(controlador.state.usuarioNuvem, isEmpty);
  });

  test(
      'salvar sem mudar credencial, URLs ou ambiente preserva o status '
      'verificado', () async {
    // Normaliza as URLs (barra final) para a comparação do segundo salvar.
    await controlador.salvarComunicacao(
      usuario: 'operador',
      senha: 's3nh4',
      ambiente: Ambiente.homologacao,
      urlProducao: '',
      urlHomologacao: 'https://localhost:3001/api',
      urlNuvemProducao: '',
      urlNuvemHomologacao: 'https://nuvem.constel.dev/api',
    );
    await controlador.testarApiLocal();
    expect(controlador.state.statusLocal, StatusConexao.conectado);

    // Só o identificador do terminal muda: a verificação continua valendo.
    await controlador.salvarComunicacao(
      usuario: 'operador',
      senha: 's3nh4',
      ambiente: Ambiente.homologacao,
      urlProducao: '',
      urlHomologacao: 'https://localhost:3001/api',
      urlNuvemProducao: '',
      urlNuvemHomologacao: 'https://nuvem.constel.dev/api',
      identificadorDispositivo: 'TOTEM-99',
    );
    expect(controlador.state.statusLocal, StatusConexao.conectado);
    expect(controlador.state.nomeEstabelecimento, 'Loja');
    expect(controlador.state.configuracao.identificadorDispositivo, 'TOTEM-99');
  });

  test('testarApiNuvem mede a latência da nuvem', () async {
    when(() => casoUsoLoginNuvem.executar())
        .thenAnswer((_) async => Sucesso(_sessao()));
    await controlador.testarApiNuvem();
    expect(controlador.state.latenciaNuvemMs, isNotNull);
  });
}
