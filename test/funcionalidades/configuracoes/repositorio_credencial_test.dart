import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_credencial_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/credencial.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockArmazenamento extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockArmazenamento armazenamento;
  late RepositorioCredencialImpl repositorio;

  setUp(() {
    armazenamento = _MockArmazenamento();
    repositorio = RepositorioCredencialImpl(armazenamento);
  });

  test('salvar grava usuario e senha em chaves separadas', () async {
    when(() => armazenamento.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});
    await repositorio
        .salvar(const Credencial(usuario: 'operador', senha: 's3nh4'));
    verify(() =>
            armazenamento.write(key: 'credencial_usuario', value: 'operador'))
        .called(1);
    verify(() => armazenamento.write(key: 'credencial_senha', value: 's3nh4'))
        .called(1);
  });

  test('obter devolve null quando nao ha credencial', () async {
    when(() => armazenamento.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    expect(await repositorio.obter(), isNull);
  });

  test('obter devolve a credencial salva', () async {
    when(() => armazenamento.read(key: 'credencial_usuario'))
        .thenAnswer((_) async => 'operador');
    when(() => armazenamento.read(key: 'credencial_senha'))
        .thenAnswer((_) async => 's3nh4');
    expect(await repositorio.obter(),
        const Credencial(usuario: 'operador', senha: 's3nh4'));
  });

  test('remover apaga as duas chaves', () async {
    when(() => armazenamento.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});
    await repositorio.remover();
    verify(() => armazenamento.delete(key: 'credencial_usuario')).called(1);
    verify(() => armazenamento.delete(key: 'credencial_senha')).called(1);
  });
}
