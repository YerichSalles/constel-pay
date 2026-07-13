import 'package:constel_pay/funcionalidades/propaganda/apresentacao/ajuste_tela.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('automatico nunca corta: contain incondicional', () {
    // Antes, midia com razao proxima da tela levava cover e perdia ate 25%
    // da peca. Agora nao existe razao que produza corte no automatico.
    expect(resolverBoxFit(AjusteMidia.automatico), BoxFit.contain);
  });

  test('modos explicitos seguem valendo', () {
    expect(resolverBoxFit(AjusteMidia.preencher), BoxFit.cover);
    expect(resolverBoxFit(AjusteMidia.encaixar), BoxFit.contain);
    expect(resolverBoxFit(AjusteMidia.esticar), BoxFit.fill);
  });

  test('cada ancora mapeia para o Alignment correspondente', () {
    const esperados = {
      AncoraMidia.topoEsquerda: Alignment.topLeft,
      AncoraMidia.topo: Alignment.topCenter,
      AncoraMidia.topoDireita: Alignment.topRight,
      AncoraMidia.esquerda: Alignment.centerLeft,
      AncoraMidia.centro: Alignment.center,
      AncoraMidia.direita: Alignment.centerRight,
      AncoraMidia.baseEsquerda: Alignment.bottomLeft,
      AncoraMidia.base: Alignment.bottomCenter,
      AncoraMidia.baseDireita: Alignment.bottomRight,
    };
    expect(esperados, hasLength(AncoraMidia.values.length),
        reason: 'toda ancora nova precisa entrar neste mapa');
    for (final entrada in esperados.entries) {
      expect(resolverAlinhamento(entrada.key), entrada.value,
          reason: '${entrada.key}');
    }
  });

  test('zoom converte percentual em escala', () {
    expect(resolverEscala(100), 1.0);
    expect(resolverEscala(150), 1.5);
    expect(resolverEscala(300), 3.0);
  });

  test('zoom fora da faixa e corrigido, nao estoura', () {
    expect(resolverEscala(40), 1.0);
    expect(resolverEscala(999), 3.0);
    expect(resolverEscala(-5), 1.0);
  });

  test('so automatico e encaixar deixam sobra', () {
    expect(modoDeixaSobra(AjusteMidia.automatico), isTrue);
    expect(modoDeixaSobra(AjusteMidia.encaixar), isTrue);
    expect(modoDeixaSobra(AjusteMidia.preencher), isFalse);
    expect(modoDeixaSobra(AjusteMidia.esticar), isFalse);
  });

  test('video cai para cor enquanto o gate do fundo borrado nao libera', () {
    // Flipar fundoBorradoLiberadoParaVideo exige a medicao de 60fps em
    // profile build (spec, secao Performance). Ao flipar, atualize junto.
    expect(fundoBorradoLiberadoParaVideo, isFalse);
    expect(fundoEfetivo(tipo: TipoMidia.video, fundo: FundoMidia.borrado),
        FundoMidia.cor);
    expect(fundoEfetivo(tipo: TipoMidia.video, fundo: FundoMidia.cor),
        FundoMidia.cor);
    expect(fundoEfetivo(tipo: TipoMidia.imagem, fundo: FundoMidia.borrado),
        FundoMidia.borrado);
  });
}
