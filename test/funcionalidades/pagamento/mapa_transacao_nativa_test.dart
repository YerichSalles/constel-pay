import 'dart:async';

import 'package:constel_pay/funcionalidades/pagamento/dados/adaptadores/mapa_transacao_nativa.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/metodo_pagamento.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/resultado_transacao.dart';
import 'package:constel_pay/funcionalidades/pagamento/dominio/entidades/status_pagamento.dart';
import 'package:constel_pay/nucleo/erros/falha.dart';
import 'package:constel_pay/nucleo/erros/resultado.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Resultado<ResultadoTransacao> _converter(Object? resposta) =>
    MapaTransacaoNativa.deResposta(resposta,
        metodo: MetodoPagamento.credito, valorCentavos: 14960);

void main() {
  group('tipoDe', () {
    test('mapeia credito, debito e pix para os codigos da adquirente', () {
      expect(MapaTransacaoNativa.tipoDe(MetodoPagamento.credito), 110);
      expect(MapaTransacaoNativa.tipoDe(MetodoPagamento.debito), 120);
      expect(MapaTransacaoNativa.tipoDe(MetodoPagamento.pix), 230);
    });

    test('metodo sem cobranca nativa nao tem codigo', () {
      expect(MapaTransacaoNativa.tipoDe(MetodoPagamento.dinheiro), isNull);
      expect(MapaTransacaoNativa.tipoDe(MetodoPagamento.voucher), isNull);
    });
  });

  group('deResposta', () {
    test('aprovado traz os dados da transacao', () {
      final resultado = _converter(const {
        'status': 'aprovado',
        'valorCentavos': 14960,
        'parcelas': 1,
        'codigoAutorizacao': 'A1B2',
        'nsu': '998877',
        'bandeira': 'VISA',
        'finalCartao': '1234',
        'adquirente': 'Stone',
      });
      final transacao = (resultado as Sucesso<ResultadoTransacao>).valor;
      expect(transacao.status, StatusPagamento.aprovado);
      expect(transacao.metodo, MetodoPagamento.credito);
      expect(transacao.valorCentavos, 14960);
      expect(transacao.nsu, '998877');
      expect(transacao.finalCartao, '1234');
    });

    test('recusado e cancelado sao desfechos de negocio, nao falhas', () {
      for (final entrada in {
        'recusado': StatusPagamento.recusado,
        'cancelado': StatusPagamento.cancelado,
      }.entries) {
        final resultado = _converter({'status': entrada.key});
        expect((resultado as Sucesso<ResultadoTransacao>).valor.status,
            entrada.value);
      }
    });

    test('status ausente ou desconhecido vira indeterminado, nunca recusa', () {
      for (final resposta in <Object?>[
        const <String, Object?>{},
        const {'status': 'sei_la'},
        const {'status': 42},
      ]) {
        final resultado = _converter(resposta);
        expect((resultado as Erro<ResultadoTransacao>).falha,
            isA<FalhaPagamentoIndeterminado>());
      }
    });

    test('resposta que nao e mapa vira indeterminado', () {
      for (final resposta in <Object?>[null, 'aprovado', 7]) {
        expect((_converter(resposta) as Erro<ResultadoTransacao>).falha,
            isA<FalhaPagamentoIndeterminado>());
      }
    });

    test('campos ausentes caem no valor pedido pelo app, nao em zero', () {
      final resultado = _converter(const {'status': 'aprovado'});
      final transacao = (resultado as Sucesso<ResultadoTransacao>).valor;
      expect(transacao.valorCentavos, 14960);
      expect(transacao.parcelas, 1);
      expect(transacao.nsu, isEmpty);
    });

    test('mensagem do operador longa demais e truncada', () {
      final resultado = _converter({
        'status': 'recusado',
        'mensagemOperador': 'x' * 400,
      });
      final transacao = (resultado as Sucesso<ResultadoTransacao>).valor;
      expect(transacao.mensagemOperador.length, 160);
      expect(transacao.mensagemOperador.endsWith('…'), isTrue);
    });
  });

  group('falhaDeExcecao', () {
    test('canal ausente (build generica) vira FalhaTerminalPagamento', () {
      expect(MapaTransacaoNativa.falhaDeExcecao(MissingPluginException()),
          isA<FalhaTerminalPagamento>());
    });

    test('terminal indisponivel e ocupado sao seguros para repetir', () {
      for (final codigo in [
        'TERMINAL_INDISPONIVEL',
        'NAO_ATIVADO',
        'EM_ANDAMENTO'
      ]) {
        expect(
            MapaTransacaoNativa.falhaDeExcecao(PlatformException(code: codigo)),
            isA<FalhaTerminalPagamento>());
      }
    });

    test('rede e tempo esgotado usam as falhas ja existentes', () {
      expect(
          MapaTransacaoNativa.falhaDeExcecao(
              PlatformException(code: 'SEM_REDE')),
          isA<FalhaRede>());
      expect(
          MapaTransacaoNativa.falhaDeExcecao(
              PlatformException(code: 'TEMPO_ESGOTADO')),
          isA<FalhaTimeout>());
    });

    test('timeout e erro desconhecido viram indeterminado', () {
      expect(MapaTransacaoNativa.falhaDeExcecao(TimeoutException('x')),
          isA<FalhaPagamentoIndeterminado>());
      expect(
          MapaTransacaoNativa.falhaDeExcecao(
              PlatformException(code: 'QUALQUER_OUTRA')),
          isA<FalhaPagamentoIndeterminado>());
      expect(MapaTransacaoNativa.falhaDeExcecao(StateError('x')),
          isA<FalhaPagamentoIndeterminado>());
    });
  });
}
