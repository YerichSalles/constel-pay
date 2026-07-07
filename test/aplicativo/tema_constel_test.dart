import 'package:constel_pay/aplicativo/tema/cores_app.dart';
import 'package:constel_pay/aplicativo/tema/tema_constel.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('TemaConstel.corDeHex', () {
    test('converte hex valido com #', () {
      expect(TemaConstel.corDeHex('#5E52D6', Colors.black),
          const Color(0xFF5E52D6));
    });
    test('converte hex valido sem #', () {
      expect(TemaConstel.corDeHex('FFD166', Colors.black),
          const Color(0xFFFFD166));
    });
    test('devolve padrao para hex invalido', () {
      expect(TemaConstel.corDeHex('xyz', CoresApp.primariaPadrao),
          CoresApp.primariaPadrao);
      expect(TemaConstel.corDeHex('', CoresApp.primariaPadrao),
          CoresApp.primariaPadrao);
    });
  });

  test('hexDeCor devolve o hex em maiusculas com #', () {
    expect(TemaConstel.hexDeCor(const Color(0xFF5E52D6)), '#5E52D6');
  });

  testWidgets('criar aplica as cores personalizadas',
      (WidgetTester tester) async {
    final tema = TemaConstel.criar(
        const TemaPersonalizado(corPrimaria: '#FF0000', corFundo: '#00FF00'));
    expect(tema.colorScheme.primary, const Color(0xFFFF0000));
    expect(tema.scaffoldBackgroundColor, const Color(0xFF00FF00));
    expect(tema.useMaterial3, isTrue);
  });

  testWidgets('criar usa os padroes Constel quando tema vazio',
      (WidgetTester tester) async {
    final tema = TemaConstel.criar(const TemaPersonalizado());
    expect(tema.colorScheme.primary, CoresApp.primariaPadrao);
    expect(tema.scaffoldBackgroundColor, CoresApp.fundoPadrao);
  });
}
