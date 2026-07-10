import 'dart:convert';

import 'package:constel_pay/funcionalidades/autenticacao/dados/repositorios/repositorio_sessao_nuvem_impl.dart';
import 'package:constel_pay/funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _StorageMock extends Mock implements FlutterSecureStorage {}

SessaoNuvem _sessao() => SessaoNuvem(
      token: 'jwt',
      validade: DateTime.utc(2026, 7, 11),
      usuario: const UsuarioSessao(nome: 'Ana', credencial: 'a@x.com', imagem: ''),
      empresa: const EmpresaSessao(id: 'e1', nome: 'Empresa'),
      dispositivo: const DispositivoSessao(id: 'd1', nome: 'Terminal'),
      estabelecimento: const EstabelecimentoSessao(id: 's1', nome: 'Loja'),
    );

void main() {
  late _StorageMock storage;
  late RepositorioSessaoNuvemImpl repositorio;

  setUp(() {
    storage = _StorageMock();
    repositorio = RepositorioSessaoNuvemImpl(storage);
  });

  test('salvar grava o JSON da sessão na chave sessao_nuvem', () async {
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    await repositorio.salvar(_sessao());
    final captured = verify(() => storage.write(
        key: 'sessao_nuvem', value: captureAny(named: 'value'))).captured.single;
    final decodificado = jsonDecode(captured as String) as Map<String, dynamic>;
    expect(decodificado['token'], 'jwt');
  });

  test('obter devolve a sessão desserializada', () async {
    when(() => storage.read(key: 'sessao_nuvem'))
        .thenAnswer((_) async => jsonEncode(_sessao().toJson()));
    final sessao = await repositorio.obter();
    expect(sessao, isNotNull);
    expect(sessao!.token, 'jwt');
  });

  test('obter devolve null quando não há nada gravado', () async {
    when(() => storage.read(key: 'sessao_nuvem')).thenAnswer((_) async => null);
    expect(await repositorio.obter(), isNull);
  });

  test('obter devolve null quando o conteúdo está corrompido', () async {
    when(() => storage.read(key: 'sessao_nuvem'))
        .thenAnswer((_) async => 'não é json');
    expect(await repositorio.obter(), isNull);
  });

  test('remover apaga a chave', () async {
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
    await repositorio.remover();
    verify(() => storage.delete(key: 'sessao_nuvem')).called(1);
  });
}
