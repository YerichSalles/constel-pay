import 'package:constel_pay/funcionalidades/propaganda/dados/repositorios/repositorio_propaganda_impl.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const midias = [
    MidiaPropaganda(
        id: 'a', tipo: TipoMidia.imagem, caminho: '/m/a.png', ordem: 2),
    MidiaPropaganda(
        id: 'b', tipo: TipoMidia.video, caminho: '/m/b.mp4', ordem: 1),
    MidiaPropaganda(
        id: 'c',
        tipo: TipoMidia.imagem,
        caminho: '/m/c.png',
        ordem: 3,
        ativo: false),
  ];

  test('devolve lista vazia quando nada foi salvo', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio =
        RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    expect(await repositorio.obterTodas(), isEmpty);
  });

  test('salva e recupera todas as midias', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio =
        RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    await repositorio.salvarTodas(midias);
    expect(await repositorio.obterTodas(), midias);
  });

  test('obterAtivasOrdenadas filtra inativas e ordena por ordem', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio =
        RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    await repositorio.salvarTodas(midias);
    final ativas = await repositorio.obterAtivasOrdenadas();
    expect(ativas.map((m) => m.id).toList(), ['b', 'a']);
  });
}
