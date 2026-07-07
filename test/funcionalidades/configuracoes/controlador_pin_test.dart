import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_pin.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/configuracao_terminal.dart';
import 'package:constel_pay/nucleo/utils/hasher_pin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ControladorPin> criarControlador({String pinHash = ''}) async {
    SharedPreferences.setMockInitialValues({});
    final repositorio =
        RepositorioConfiguracaoImpl(await SharedPreferences.getInstance());
    await repositorio.salvar(ConfiguracaoTerminal(pinHash: pinHash));
    final controlador = ControladorPin(repositorio);
    await controlador.iniciar();
    return controlador;
  }

  void digitarPin(ControladorPin controlador, String pin) {
    for (final digito in pin.split('')) {
      controlador.digitar(digito);
    }
  }

  test('sem pinHash inicia em modo criar', () async {
    final controlador = await criarControlador();
    expect(controlador.state.modo, ModoPin.criar);
  });

  test('criacao completa: criar -> confirmar -> concluido', () async {
    final controlador = await criarControlador();
    digitarPin(controlador, '1234');
    await controlador.confirmar();
    expect(controlador.state.modo, ModoPin.confirmar);
    expect(controlador.state.digitos, isEmpty);
    digitarPin(controlador, '1234');
    await controlador.confirmar();
    expect(controlador.state.concluido, isTrue);
  });

  test('confirmacao divergente volta para criar com erro', () async {
    final controlador = await criarControlador();
    digitarPin(controlador, '1234');
    await controlador.confirmar();
    digitarPin(controlador, '9999');
    await controlador.confirmar();
    expect(controlador.state.modo, ModoPin.criar);
    expect(controlador.state.erro, isNotNull);
    expect(controlador.state.concluido, isFalse);
  });

  test('pin curto em modo criar gera erro de validacao', () async {
    final controlador = await criarControlador();
    digitarPin(controlador, '12');
    await controlador.confirmar();
    expect(controlador.state.erro, isNotNull);
    expect(controlador.state.modo, ModoPin.criar);
  });

  test('verificar com pin correto conclui', () async {
    final controlador =
        await criarControlador(pinHash: HasherPin.gerar('4321'));
    expect(controlador.state.modo, ModoPin.verificar);
    digitarPin(controlador, '4321');
    await controlador.confirmar();
    expect(controlador.state.concluido, isTrue);
  });

  test('verificar com pin errado mostra erro e limpa digitos', () async {
    final controlador =
        await criarControlador(pinHash: HasherPin.gerar('4321'));
    digitarPin(controlador, '0000');
    await controlador.confirmar();
    expect(controlador.state.concluido, isFalse);
    expect(controlador.state.erro, 'PIN incorreto.');
    expect(controlador.state.digitos, isEmpty);
  });

  test('digitar respeita o limite de 6 digitos e apagar remove o ultimo',
      () async {
    final controlador = await criarControlador();
    digitarPin(controlador, '12345678');
    expect(controlador.state.digitos, '123456');
    controlador.apagar();
    expect(controlador.state.digitos, '12345');
  });
}
