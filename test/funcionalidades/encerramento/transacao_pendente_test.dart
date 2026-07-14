import 'package:constel_pay/funcionalidades/encerramento/dominio/entidades/transacao_pendente.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TransacaoPendente exemplo() => TransacaoPendente(
        identificador: 'ABC123',
        atendimentoIds: const ['a1', 'a2'],
        sessaoId: 's1',
        sessaoCodigo: '0003479',
        etapa: EtapaTransacao.faturaCriada,
        dataTentativa: DateTime.utc(2026, 7, 14, 0, 44),
        atendimentosBrutos: const [
          {'id': 'a1', 'total': 6.49},
          {'id': 'a2', 'total': 1.0},
        ],
        metodo: 'dinheiro',
        trocoCentavos: 351,
        faturaJson: const {'identificador': 'ABC123', 'total': 7.49},
        faturaId: 'f1',
        faturaCodigo: 'VN1',
      );

  test('roda ida e volta pelo JSON sem perder nada', () {
    final original = exemplo();
    final recuperada = TransacaoPendente.deJson(original.paraJson());
    expect(recuperada.identificador, original.identificador);
    expect(recuperada.atendimentoIds, original.atendimentoIds);
    expect(recuperada.sessaoId, original.sessaoId);
    expect(recuperada.sessaoCodigo, original.sessaoCodigo);
    expect(recuperada.etapa, original.etapa);
    expect(recuperada.dataTentativa, original.dataTentativa);
    expect(recuperada.atendimentosBrutos, original.atendimentosBrutos);
    expect(recuperada.metodo, original.metodo);
    expect(recuperada.trocoCentavos, original.trocoCentavos);
    expect(recuperada.faturaJson, original.faturaJson);
    expect(recuperada.faturaId, original.faturaId);
    expect(recuperada.faturaCodigo, original.faturaCodigo);
  });

  test('copiarCom preserva identificador e brutos', () {
    final alterada = exemplo()
        .copiarCom(etapa: EtapaTransacao.confirmacaoEnviada, faturaId: 'novo');
    expect(alterada.identificador, 'ABC123');
    expect(alterada.etapa, EtapaTransacao.confirmacaoEnviada);
    expect(alterada.faturaId, 'novo');
    expect(alterada.faturaCodigo, 'VN1');
    expect(alterada.atendimentosBrutos.length, 2);
    expect(alterada.trocoCentavos, 351);
  });

  test('JSON malformado degrada para valores neutros', () {
    final recuperada = TransacaoPendente.deJson(const {
      'identificador': 'X',
      'etapa': 'inexistente',
      'atendimentoIds': 'não é lista',
    });
    expect(recuperada.identificador, 'X');
    expect(recuperada.etapa, EtapaTransacao.preparacaoEnviada);
    expect(recuperada.atendimentoIds, isEmpty);
    expect(recuperada.atendimentosBrutos, isEmpty);
  });
}
