import 'package:constel_pay/nucleo/utils/hasher_pin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HasherPin', () {
    test('gera hash deterministico de 64 caracteres hex', () {
      final hash = HasherPin.gerar('1234');
      expect(hash, hasLength(64));
      expect(hash, HasherPin.gerar('1234'));
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(hash), isTrue);
    });

    test('pins diferentes geram hashes diferentes', () {
      expect(HasherPin.gerar('1234'), isNot(HasherPin.gerar('4321')));
    });

    test('verificar compara pin com hash', () {
      final hash = HasherPin.gerar('123456');
      expect(HasherPin.verificar('123456', hash), isTrue);
      expect(HasherPin.verificar('000000', hash), isFalse);
    });
  });
}
