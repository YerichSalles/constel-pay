import 'package:constel_pay/funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart';
import 'package:flutter_test/flutter_test.dart';

SessaoNuvem _sessao(DateTime validade) => SessaoNuvem(
      token: 'jwt',
      validade: validade,
      usuario: const UsuarioSessao(nome: 'Ana', imagem: ''),
      empresa: const EmpresaSessao(id: 'e1', nome: 'Empresa'),
      dispositivo: const DispositivoSessao(id: 'd1', nome: 'Terminal'),
      estabelecimento: const EstabelecimentoSessao(
        id: 's1',
        nome: 'Loja',
        ambientes: [AmbienteSessao(id: 'a1', nome: 'Padrão', padrao: true)],
      ),
    );

void main() {
  test('expirada é false quando validade está no futuro', () {
    final sessao = _sessao(DateTime.now().add(const Duration(days: 1)));
    expect(sessao.expirada, isFalse);
  });

  test('expirada é true quando validade está no passado', () {
    final sessao = _sessao(DateTime.now().subtract(const Duration(minutes: 1)));
    expect(sessao.expirada, isTrue);
  });

  test('round-trip toJson/fromJson preserva os dados', () {
    final original = _sessao(DateTime.utc(2026, 7, 11));
    final copia = SessaoNuvem.fromJson(original.toJson());
    expect(copia, original);
    expect(copia.estabelecimento.ambientes.first.padrao, isTrue);
  });
}
