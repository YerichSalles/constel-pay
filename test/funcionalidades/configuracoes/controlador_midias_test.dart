import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_midias.dart';
import 'package:constel_pay/funcionalidades/propaganda/dados/repositorios/repositorio_propaganda_impl.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ControladorMidias controlador;
  late RepositorioPropagandaImpl repositorio;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repositorio =
        RepositorioPropagandaImpl(await SharedPreferences.getInstance());
    controlador = ControladorMidias(repositorio);
    await controlador.carregar();
  });

  test('adicionarArquivos infere tipo e ordem', () async {
    await controlador.adicionarArquivos(['/m/foto.png', '/m/video.mp4']);
    final midias = controlador.state.midias;
    expect(midias, hasLength(2));
    expect(midias[0].tipo, TipoMidia.imagem);
    expect(midias[1].tipo, TipoMidia.video);
    expect(midias[0].ordem, 1);
    expect(midias[1].ordem, 2);
    expect(await repositorio.obterTodas(), hasLength(2));
  });

  test('alternarAtivo inverte o flag e persiste', () async {
    await controlador.adicionarArquivos(['/m/foto.png']);
    final id = controlador.state.midias.single.id;
    await controlador.alternarAtivo(id);
    expect(controlador.state.midias.single.ativo, isFalse);
    expect((await repositorio.obterAtivasOrdenadas()), isEmpty);
  });

  test('mover troca a posicao com o vizinho', () async {
    await controlador.adicionarArquivos(['/m/a.png', '/m/b.png', '/m/c.png']);
    final idC = controlador.state.midias[2].id;
    await controlador.mover(idC, -1);
    expect(controlador.state.midias[1].id, idC);
    await controlador.mover(idC, -1);
    expect(controlador.state.midias[0].id, idC);
    await controlador.mover(idC, -1); // ja esta no topo: no-op
    expect(controlador.state.midias[0].id, idC);
  });

  test('remover exclui e definirDuracao atualiza', () async {
    await controlador.adicionarArquivos(['/m/a.png', '/m/b.png']);
    final idA = controlador.state.midias[0].id;
    await controlador.remover(idA);
    expect(controlador.state.midias, hasLength(1));
    final idB = controlador.state.midias.single.id;
    await controlador.definirDuracao(idB, 15);
    expect(controlador.state.midias.single.duracaoSegundos, 15);
  });

  test('gif entra como imagem animada, com ajuste automatico', () async {
    await controlador.adicionarArquivos(['/m/oferta.gif']);
    final midia = controlador.state.midias.single;
    expect(midia.tipo, TipoMidia.imagem);
    expect(midia.ajuste, AjusteMidia.automatico);
  });

  test('definirEnquadramento persiste modo, fundo, ancora e zoom', () async {
    await controlador.adicionarArquivos(['/m/a.png']);
    final id = controlador.state.midias.single.id;
    await controlador.definirEnquadramento(id,
        ajuste: AjusteMidia.preencher,
        fundo: FundoMidia.cor,
        ancora: AncoraMidia.baseDireita,
        zoomPercentual: 180,
        rotacaoGraus: 90);
    final midia = controlador.state.midias.single;
    expect(midia.ajuste, AjusteMidia.preencher);
    expect(midia.fundo, FundoMidia.cor);
    expect(midia.ancora, AncoraMidia.baseDireita);
    expect(midia.zoomPercentual, 180);
    expect(midia.rotacaoGraus, 90);
    final salva = (await repositorio.obterTodas()).single;
    expect(salva.ajuste, AjusteMidia.preencher);
    expect(salva.fundo, FundoMidia.cor);
    expect(salva.ancora, AncoraMidia.baseDireita);
    expect(salva.zoomPercentual, 180);
    expect(salva.rotacaoGraus, 90);
  });
}
