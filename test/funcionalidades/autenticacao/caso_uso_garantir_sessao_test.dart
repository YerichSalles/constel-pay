// test/funcionalidades/autenticacao/caso_uso_garantir_sessao_test.dart
import 'package:constel_pay/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_garantir_sessao.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/casos_uso/caso_uso_login_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/repositorios/repositorio_sessao_nuvem.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _LoginMock extends Mock implements CasoUsoLoginNuvem {}

class _SessaoFake implements RepositorioSessaoNuvem {
  _SessaoFake(this.salva);
  SessaoNuvem? salva;
  @override
  Future<SessaoNuvem?> obter() async => salva;
  @override
  Future<void> salvar(SessaoNuvem sessao) async => salva = sessao;
  @override
  Future<void> remover() async => salva = null;
}

SessaoNuvem _sessao(DateTime validade) => SessaoNuvem(
      token: 'jwt',
      validade: validade,
      usuario: const UsuarioSessao(nome: 'Ana', imagem: ''),
      empresa: const EmpresaSessao(id: 'e1', nome: 'Empresa'),
      dispositivo: const DispositivoSessao(id: 'd1', nome: 'Terminal'),
      estabelecimento: const EstabelecimentoSessao(id: 's1', nome: 'Loja'),
    );

void main() {
  test('sessão válida é reusada sem chamar o login', () async {
    final login = _LoginMock();
    final repo =
        _SessaoFake(_sessao(DateTime.now().add(const Duration(days: 1))));
    final caso =
        CasoUsoGarantirSessao(repositorioSessao: repo, casoUsoLogin: login);
    final resultado = await caso.executar();
    expect(resultado, isA<Sucesso<SessaoNuvem>>());
    verifyNever(() => login.executar());
  });

  test('sessão expirada dispara novo login', () async {
    final login = _LoginMock();
    final novaSessao = _sessao(DateTime.now().add(const Duration(days: 2)));
    when(() => login.executar()).thenAnswer((_) async => Sucesso(novaSessao));
    final repo = _SessaoFake(
        _sessao(DateTime.now().subtract(const Duration(minutes: 1))));
    final caso =
        CasoUsoGarantirSessao(repositorioSessao: repo, casoUsoLogin: login);
    final resultado = await caso.executar();
    expect(resultado, isA<Sucesso<SessaoNuvem>>());
    verify(() => login.executar()).called(1);
  });

  test('sessão ausente dispara login e propaga falha', () async {
    final login = _LoginMock();
    when(() => login.executar())
        .thenAnswer((_) async => const Erro(FalhaValidacao('sem credencial')));
    final repo = _SessaoFake(null);
    final caso =
        CasoUsoGarantirSessao(repositorioSessao: repo, casoUsoLogin: login);
    final resultado = await caso.executar();
    expect(resultado, isA<Erro<SessaoNuvem>>());
    verify(() => login.executar()).called(1);
  });
}
