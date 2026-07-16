import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_pin.dart';
import 'package:constel_pay/nucleo/constantes/constantes_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void digitarPin(ControladorPin controlador, String pin) {
    for (final digito in pin.split('')) {
      controlador.digitar(digito);
    }
  }

  test('PIN correto conclui', () {
    final controlador = ControladorPin();
    digitarPin(controlador, ConstantesApp.pinAcesso);
    controlador.confirmar();
    expect(controlador.state.concluido, isTrue);
    expect(controlador.state.erro, isNull);
  });

  test('PIN errado mostra erro e limpa digitos', () {
    final controlador = ControladorPin();
    digitarPin(controlador, '000000');
    controlador.confirmar();
    expect(controlador.state.concluido, isFalse);
    expect(controlador.state.erro, 'PIN incorreto.');
    expect(controlador.state.digitos, isEmpty);
  });

  test('digitar respeita o tamanho do PIN e apagar remove o ultimo', () {
    final controlador = ControladorPin();
    digitarPin(controlador, '12345678');
    expect(controlador.state.digitos.length, ConstantesApp.pinAcesso.length,
        reason: 'nao aceita mais digitos que o tamanho do PIN');
    controlador.apagar();
    expect(
        controlador.state.digitos.length, ConstantesApp.pinAcesso.length - 1);
  });
}
