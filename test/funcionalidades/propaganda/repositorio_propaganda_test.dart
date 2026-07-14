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

  test('o ajuste escolhido sobrevive ao round-trip', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio =
        RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.video,
          caminho: '/m/a.mp4',
          ordem: 1,
          ajuste: AjusteMidia.encaixar),
    ]);
    expect(
        (await repositorio.obterTodas()).single.ajuste, AjusteMidia.encaixar);
  });

  test('midia nova nasce com ajuste automatico', () {
    const midia = MidiaPropaganda(
        id: 'a', tipo: TipoMidia.imagem, caminho: '/m/a.png', ordem: 1);
    expect(midia.ajuste, AjusteMidia.automatico);
  });

  test('playlist gravada antes do campo ajuste continua carregando', () async {
    // Se `ajuste` virar um campo obrigatorio do ModeloMidia, o fromJson lanca
    // aqui, o catch do repositorio engole o erro e devolve lista vazia: a
    // playlist da loja sumiria sem aviso nenhum na atualizacao.
    SharedPreferences.setMockInitialValues({
      'midias_propaganda': '[{"id":"a","tipo":"imagem","caminho":"/m/a.png",'
          '"duracaoSegundos":8,"ordem":1,"ativo":true}]',
    });
    final repositorio =
        RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    final midias = await repositorio.obterTodas();
    expect(midias, hasLength(1),
        reason: 'a playlist antiga nao pode ser perdida');
    expect(midias.single.ajuste, AjusteMidia.automatico);
    expect(midias.single.fundo, FundoMidia.borrado);
    expect(midias.single.ancora, AncoraMidia.centro);
    expect(midias.single.zoomPercentual, 100);
    expect(midias.single.rotacaoGraus, 0);
  });

  test('o enquadramento escolhido sobrevive ao round-trip', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio =
        RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: '/m/a.png',
          ordem: 1,
          fundo: FundoMidia.cor,
          ancora: AncoraMidia.topo,
          zoomPercentual: 140),
    ]);
    final midia = (await repositorio.obterTodas()).single;
    expect(midia.fundo, FundoMidia.cor);
    expect(midia.ancora, AncoraMidia.topo);
    expect(midia.zoomPercentual, 140);
  });

  test('a rotacao escolhida sobrevive ao round-trip', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio =
        RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    await repositorio.salvarTodas(const [
      MidiaPropaganda(
          id: 'a',
          tipo: TipoMidia.imagem,
          caminho: '/m/a.png',
          ordem: 1,
          rotacaoGraus: 90),
    ]);
    expect((await repositorio.obterTodas()).single.rotacaoGraus, 90);
  });

  test('midia nova nasce com fundo borrado, ancora central e zoom 100', () {
    const midia = MidiaPropaganda(
        id: 'a', tipo: TipoMidia.imagem, caminho: '/m/a.png', ordem: 1);
    expect(midia.fundo, FundoMidia.borrado);
    expect(midia.ancora, AncoraMidia.centro);
    expect(midia.zoomPercentual, 100);
    expect(midia.rotacaoGraus, 0);
  });
}
