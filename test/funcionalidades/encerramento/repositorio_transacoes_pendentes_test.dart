import 'package:constel_pay/funcionalidades/encerramento/dados/repositorios/repositorio_transacoes_pendentes_impl.dart';
import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/transacao_pendente.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

TransacaoPendente _pendente(String identificador) => TransacaoPendente(
      identificador: identificador,
      atendimentoIds: const ['a1'],
      sessaoId: 's1',
      sessaoCodigo: 'c1',
      etapa: EtapaTransacao.faturaCriada,
      dataTentativa: DateTime.utc(2026, 7, 14),
      atendimentosBrutos: const [
        {'id': 'a1'}
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<RepositorioTransacoesPendentesImpl> repositorio() async {
    SharedPreferences.setMockInitialValues(const {});
    return RepositorioTransacoesPendentesImpl(
        await SharedPreferences.getInstance());
  }

  test('salva, lê e remove pelo identificador', () async {
    final repo = await repositorio();
    await repo.salvar(_pendente('A'));
    await repo.salvar(_pendente('B'));
    expect((await repo.obterTodas()).length, 2);

    await repo.remover('A');
    final restantes = await repo.obterTodas();
    expect(restantes.single.identificador, 'B');
  });

  test('salvar de novo substitui o registro do mesmo identificador', () async {
    final repo = await repositorio();
    await repo.salvar(_pendente('A'));
    await repo
        .salvar(_pendente('A').copiarCom(etapa: EtapaTransacao.faturaEnviada));
    final todas = await repo.obterTodas();
    expect(todas.length, 1);
    expect(todas.single.etapa, EtapaTransacao.faturaEnviada);
  });

  test('conteúdo corrompido não derruba a leitura', () async {
    SharedPreferences.setMockInitialValues(const {
      RepositorioTransacoesPendentesImpl.chave: '{não é json válido',
    });
    final repo = RepositorioTransacoesPendentesImpl(
        await SharedPreferences.getInstance());
    expect(await repo.obterTodas(), isEmpty);
  });
}
