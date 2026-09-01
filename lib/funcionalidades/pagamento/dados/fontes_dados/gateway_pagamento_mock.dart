import '../../../../nucleo/erros/resultado.dart';
import '../../dominio/entidades/dados_pix.dart';
import '../../dominio/entidades/metodo_pagamento.dart';
import '../../dominio/entidades/pagamento.dart';
import '../../dominio/entidades/parametros_adquirente.dart';
import '../../dominio/entidades/resultado_transacao.dart';
import '../../dominio/entidades/status_pagamento.dart';
import '../../dominio/entidades/tipo_adquirente.dart';
import '../../dominio/repositorios/gateway_pagamento.dart';
import 'fonte_pagamento.dart';

/// Pagamento MOCK: sempre aprova após um atraso simulado. O payload Pix é
/// claramente rotulado como MOCK — não é um Pix real.
///
/// Cobre os dois papéis da build genérica: a fonte do PIX por QR Code na tela
/// e o gateway de terminal, que por padrão não cobra nada (nenhum método
/// suportado). Os testes ligam os métodos que precisam exercitar.
class GatewayPagamentoMock implements FontePagamento, GatewayPagamento {
  GatewayPagamentoMock({
    this.atraso = const Duration(milliseconds: 900),
    this.metodosSuportados = const {},
  });

  final Duration atraso;

  @override
  final Set<MetodoPagamento> metodosSuportados;

  @override
  TipoAdquirente get adquirente => TipoAdquirente.generico;

  final Map<String, Pagamento> _processados = {};
  final Map<String, ResultadoTransacao> _transacoes = {};

  int execucoesProcessar = 0;
  int execucoesIniciarPagamento = 0;

  @override
  Future<DadosPix> gerarPix({
    required String chaveIdempotencia,
    required int valorCentavos,
  }) async {
    await Future<void>.delayed(atraso);
    final payload =
        '00020126-CONSTEL-PAY-MOCK-$chaveIdempotencia-$valorCentavos';
    return DadosPix(
      qrCode: payload,
      copiaCola: payload,
      valorCentavos: valorCentavos,
      expiraEm: DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  @override
  Future<Pagamento> processar(Pagamento pagamento) async {
    final existente = _processados[pagamento.id];
    if (existente != null) return existente;
    execucoesProcessar++;
    await Future<void>.delayed(atraso);
    final aprovado = pagamento.copyWith(
      status: StatusPagamento.aprovado,
      atualizadoEm: DateTime.now(),
    );
    _processados[pagamento.id] = aprovado;
    return aprovado;
  }

  @override
  StatusPagamento consultarStatus(String pagamentoId) =>
      _processados[pagamentoId]?.status ?? StatusPagamento.aguardando;

  @override
  Future<Resultado<ResultadoTransacao>> iniciarPagamento({
    required String chaveIdempotencia,
    required int valorCentavos,
    required MetodoPagamento metodo,
    int parcelas = 1,
    ParametrosAdquirente parametros = const ParametrosAdquirente.nenhum(),
  }) async {
    // Mesma chave não cobra de novo: espelha a idempotência que a adquirente
    // real precisa garantir.
    final existente = _transacoes[chaveIdempotencia];
    if (existente != null) return Sucesso(existente);
    execucoesIniciarPagamento++;
    await Future<void>.delayed(atraso);
    final transacao = ResultadoTransacao(
      status: StatusPagamento.aprovado,
      metodo: metodo,
      valorCentavos: valorCentavos,
      parcelas: parcelas,
      adquirente: 'MOCK',
      mensagemOperador: 'Transação simulada (homologação).',
    );
    _transacoes[chaveIdempotencia] = transacao;
    return Sucesso(transacao);
  }
}
