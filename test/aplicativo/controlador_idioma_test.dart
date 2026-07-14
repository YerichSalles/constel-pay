import 'package:constel_pay/aplicativo/idioma/controlador_idioma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ControladorIdioma', () {
    test('estado inicial e pt-BR', () {
      final controlador = ControladorIdioma();
      expect(controlador.state, const Locale('pt', 'BR'));
    });

    test('selecionar troca o locale', () {
      final controlador = ControladorIdioma();
      controlador.selecionar(const Locale('en'));
      expect(controlador.state, const Locale('en'));
    });

    test('selecionar para espanhol', () {
      final controlador = ControladorIdioma();
      controlador.selecionar(const Locale('es'));
      expect(controlador.state, const Locale('es'));
    });

    test('resetar volta para pt-BR apos selecionar outro idioma', () {
      final controlador = ControladorIdioma();
      controlador.selecionar(const Locale('en'));
      controlador.resetar();
      expect(controlador.state, const Locale('pt', 'BR'));
    });

    test('resetar e um no-op seguro quando ja esta em pt-BR', () {
      final controlador = ControladorIdioma();
      controlador.resetar();
      expect(controlador.state, const Locale('pt', 'BR'));
    });
  });
}
