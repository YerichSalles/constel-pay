import 'package:constel_pay/funcionalidades/autenticacao/dados/fontes_dados/fonte_autenticacao_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dados/modelos/requisicao_login_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_login_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/repositorios/repositorio_sessao_nuvem.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/credencial.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/repositorios/repositorio_credencial.dart';
import 'package:constel_pay/nucleo/dispositivo/info_aplicativo.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FonteMock extends Mock implements FonteAutenticacaoNuvem {}

class _ConfiguracaoFake implements RepositorioConfiguracao {
  _ConfiguracaoFake(this.configuracao);
  ConfiguracaoTerminal configuracao;
  @override
  Future<ConfiguracaoTerminal> obter() async => configuracao;
  @override
  Future<void> salvar(ConfiguracaoTerminal nova) async => configuracao = nova;
}

class _CredencialFake implements RepositorioCredencial {
  _CredencialFake(this.credencial);
  Credencial? credencial;
  @override
  Future<Credencial?> obter() async => credencial;
  @override
  Future<void> salvar(Credencial nova) async => credencial = nova;
  @override
  Future<void> remover() async => credencial = null;
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

class _InfoFake implements InfoAplicativo {
  @override
  Future<String> versao() async => '1.0.0';
}

SessaoNuvem _sessao() => SessaoNuvem(
      token: 'jwt',
      validade: DateTime.utc(2026, 7, 11),
      usuario: const UsuarioSessao(nome: 'Ana', credencial: 'a@x.com', imagem: ''),
      empresa: const EmpresaSessao(id: 'e1', nome: 'Empresa'),
      dispositivo: const DispositivoSessao(id: 'd1', nome: 'Terminal'),
      estabelecimento: const EstabelecimentoSessao(id: 's1', nome: 'Loja'),
    );

const _configValida = ConfiguracaoTerminal(
  identificadorDispositivo: 'TERMINAL-01',
  idDispositivo: 'dev-uuid',
  urlNuvemHomologacao: 'http://localhost:3000/api/',
  urlBaseHomologacao: 'http://localhost:3000/api/',
);

void main() {
  setUpAll(() {
    registerFallbackValue(const RequisicaoLoginNuvem(
      username: '', password: '', timezone: '', nomeAplicativo: '',
      versaoAplicativo: '', dataAplicativo: '', caminhoApi: '',
      idDispositivo: '', nomeDispositivo: '',
    ));
  });

  CasoUsoLoginNuvem construir({
    required _FonteMock fonte,
    Credencial? credencial =
        const Credencial(usuario: 'admin@audax.com', senha: 'segredo'),
    ConfiguracaoTerminal configuracao = _configValida,
    required _SessaoFake sessao,
  }) =>
      CasoUsoLoginNuvem(
        fonte: fonte,
        repositorioConfiguracao: _ConfiguracaoFake(configuracao),
        repositorioCredencial: _CredencialFake(credencial),
        repositorioSessao: sessao,
        infoAplicativo: _InfoFake(),
      );

  test('sem credencial devolve FalhaValidacao sem chamar a fonte', () async {
    final fonte = _FonteMock();
    final caso = construir(fonte: fonte, credencial: null, sessao: _SessaoFake());
    final resultado = await caso.executar();
    expect(resultado, isA<Erro<SessaoNuvem>>());
    expect((resultado as Erro<SessaoNuvem>).falha, isA<FalhaValidacao>());
    verifyNever(() => fonte.login(any()));
  });

  test('sem URL de nuvem devolve FalhaValidacao sem chamar a fonte', () async {
    final fonte = _FonteMock();
    final caso = construir(
        fonte: fonte,
        configuracao: const ConfiguracaoTerminal(),
        sessao: _SessaoFake());
    final resultado = await caso.executar();
    expect(resultado, isA<Erro<SessaoNuvem>>());
    verifyNever(() => fonte.login(any()));
  });

  test('login com sucesso persiste a sessão e monta o payload correto', () async {
    final fonte = _FonteMock();
    final sessao = _SessaoFake();
    when(() => fonte.login(any())).thenAnswer((_) async => Sucesso(_sessao()));
    final caso = construir(fonte: fonte, sessao: sessao);

    final resultado = await caso.executar();

    expect(resultado, isA<Sucesso<SessaoNuvem>>());
    expect(sessao.salva?.token, 'jwt');
    final capturada =
        verify(() => fonte.login(captureAny())).captured.single as RequisicaoLoginNuvem;
    expect(capturada.username, 'admin@audax.com');
    expect(capturada.nomeAplicativo, 'Constel Pay');
    expect(capturada.versaoAplicativo, '1.0.0');
    expect(capturada.caminhoApi, 'http://localhost:3000/api/');
    expect(capturada.idDispositivo, 'dev-uuid');
    expect(capturada.nomeDispositivo, 'TERMINAL-01');
  });

  test('falha da fonte não persiste sessão', () async {
    final fonte = _FonteMock();
    final sessao = _SessaoFake();
    when(() => fonte.login(any()))
        .thenAnswer((_) async => const Erro(FalhaServidor()));
    final caso = construir(fonte: fonte, sessao: sessao);
    final resultado = await caso.executar();
    expect(resultado, isA<Erro<SessaoNuvem>>());
    expect(sessao.salva, isNull);
  });
}
