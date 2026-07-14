import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/controladores/controlador_publicidade.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/publicidade_barra.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/repositorios/repositorio_publicidade.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepositorioPublicidadeFake implements RepositorioPublicidade {
  PublicidadeBarra _armazenado = const PublicidadeBarra();
  int chamadasSalvar = 0;

  @override
  Future<PublicidadeBarra> obter() async => _armazenado;

  @override
  Future<void> salvar(PublicidadeBarra publicidade) async {
    _armazenado = publicidade;
    chamadasSalvar++;
  }
}

void main() {
  late ControladorPublicidade controlador;
  late _RepositorioPublicidadeFake repositorio;

  setUp(() async {
    repositorio = _RepositorioPublicidadeFake();
    controlador = ControladorPublicidade(repositorio);
  });

  test('carregar popula salva e rascunho com o valor do repositorio', () async {
    repositorio._armazenado =
        const PublicidadeBarra(ativa: true, separador: '|');
    await controlador.carregar();
    expect(controlador.state.carregando, isFalse);
    expect(controlador.state.salva, repositorio._armazenado);
    expect(controlador.state.rascunho, repositorio._armazenado);
    expect(controlador.state.pendentes, isFalse);
  });

  group('edicoes alteram somente o rascunho', () {
    setUp(() async => controlador.carregar());

    test('alternarAtiva', () {
      controlador.alternarAtiva(true);
      expect(controlador.state.rascunho.ativa, isTrue);
      expect(controlador.state.salva.ativa, isFalse);
      expect(controlador.state.pendentes, isTrue);
    });

    test('definirIntervalo', () {
      controlador.definirIntervalo(10);
      expect(controlador.state.rascunho.intervaloSegundos, 10);
      expect(controlador.state.salva.intervaloSegundos, 6);
      expect(controlador.state.pendentes, isTrue);
    });

    test('definirTransicao', () {
      controlador.definirTransicao(TransicaoCarrossel.deslizar);
      expect(controlador.state.rascunho.transicao, TransicaoCarrossel.deslizar);
      expect(controlador.state.salva.transicao, TransicaoCarrossel.suave);
    });

    test('definirVelocidade', () {
      controlador.definirVelocidade(VelocidadeLetreiro.rapida);
      expect(controlador.state.rascunho.velocidade, VelocidadeLetreiro.rapida);
      expect(controlador.state.salva.velocidade, VelocidadeLetreiro.normal);
    });

    test('definirSeparador', () {
      controlador.definirSeparador('★');
      expect(controlador.state.rascunho.separador, '★');
      expect(controlador.state.salva.separador, '•');
    });
  });

  test(
      'selecionarFormato so muda o formato, preserva banners/mensagens/parceiro',
      () async {
    await controlador.carregar();
    controlador.adicionarBanners(['/b/1.png']);
    controlador.adicionarMensagem('Promocao');
    controlador.definirMidiaParceiro('/p/parceiro.png');

    controlador.selecionarFormato(FormatoPublicidade.letreiro);

    final rascunho = controlador.state.rascunho;
    expect(rascunho.formato, FormatoPublicidade.letreiro);
    expect(rascunho.banners, hasLength(1));
    expect(rascunho.mensagens, hasLength(1));
    expect(rascunho.midiaParceiro, isNotNull);
  });

  group('banners', () {
    setUp(() async => controlador.carregar());

    test(
        'adicionarBanners cria com uuid, tipo imagem, ordem sequencial e ativo',
        () {
      controlador.adicionarBanners(['/b/a.png', '/b/b.png']);
      final banners = controlador.state.rascunho.banners;
      expect(banners, hasLength(2));
      expect(banners[0].tipo, TipoMidia.imagem);
      expect(banners[0].ordem, 1);
      expect(banners[1].ordem, 2);
      expect(banners.every((b) => b.ativo), isTrue);
      expect(banners[0].id, isNot(equals(banners[1].id)));
    });

    test('alternarBannerAtivo inverte o flag', () {
      controlador.adicionarBanners(['/b/a.png']);
      final id = controlador.state.rascunho.banners.single.id;
      controlador.alternarBannerAtivo(id);
      expect(controlador.state.rascunho.banners.single.ativo, isFalse);
    });

    test('moverBanner troca a posicao com o vizinho e nao mexe em bordas', () {
      controlador.adicionarBanners(['/b/a.png', '/b/b.png', '/b/c.png']);
      final idC = controlador.state.rascunho.banners[2].id;
      controlador.moverBanner(idC, -1);
      expect(controlador.state.rascunho.banners[1].id, idC);
      controlador.moverBanner(idC, -1);
      expect(controlador.state.rascunho.banners[0].id, idC);
      controlador.moverBanner(idC, -1); // ja esta no topo: no-op
      expect(controlador.state.rascunho.banners[0].id, idC);
      final ordens =
          controlador.state.rascunho.banners.map((b) => b.ordem).toSet();
      expect(ordens, hasLength(3)); // ordens permanecem unicas
    });

    test('removerBanner exclui', () {
      controlador.adicionarBanners(['/b/a.png', '/b/b.png']);
      final idA = controlador.state.rascunho.banners[0].id;
      controlador.removerBanner(idA);
      expect(controlador.state.rascunho.banners, hasLength(1));
      expect(controlador.state.rascunho.banners.single.id, isNot(idA));
    });

    test('ajustarBanner atualiza somente ajuste/ancora/zoom', () {
      controlador.adicionarBanners(['/b/a.png']);
      final id = controlador.state.rascunho.banners.single.id;
      controlador.ajustarBanner(id,
          ajuste: AjusteMidia.preencher,
          ancora: AncoraMidia.baseDireita,
          zoomPercentual: 150);
      final banner = controlador.state.rascunho.banners.single;
      expect(banner.ajuste, AjusteMidia.preencher);
      expect(banner.ancora, AncoraMidia.baseDireita);
      expect(banner.zoomPercentual, 150);
      expect(banner.caminho, '/b/a.png');
      expect(banner.fundo, FundoMidia.borrado); // nao mexido
    });
  });

  group('mensagens', () {
    setUp(() async => controlador.carregar());

    test('adicionarMensagem cria com uuid, ordem sequencial e ativo, com trim',
        () {
      controlador.adicionarMensagem('  Promocao hoje  ');
      final mensagem = controlador.state.rascunho.mensagens.single;
      expect(mensagem.texto, 'Promocao hoje');
      expect(mensagem.ordem, 1);
      expect(mensagem.ativo, isTrue);
    });

    test('adicionarMensagem com texto vazio (so espacos) e ignorado', () {
      controlador.adicionarMensagem('   ');
      expect(controlador.state.rascunho.mensagens, isEmpty);
    });

    test('editarMensagem faz trim e ignora vazio (mantem original)', () {
      controlador.adicionarMensagem('Original');
      final id = controlador.state.rascunho.mensagens.single.id;
      controlador.editarMensagem(id, '  Editada  ');
      expect(controlador.state.rascunho.mensagens.single.texto, 'Editada');
      controlador.editarMensagem(id, '   ');
      expect(controlador.state.rascunho.mensagens.single.texto, 'Editada');
    });

    test('alternarMensagemAtiva inverte o flag', () {
      controlador.adicionarMensagem('Promocao');
      final id = controlador.state.rascunho.mensagens.single.id;
      controlador.alternarMensagemAtiva(id);
      expect(controlador.state.rascunho.mensagens.single.ativo, isFalse);
    });

    test('moverMensagem troca a posicao com o vizinho', () {
      controlador.adicionarMensagem('Um');
      controlador.adicionarMensagem('Dois');
      controlador.adicionarMensagem('Tres');
      final idTres = controlador.state.rascunho.mensagens[2].id;
      controlador.moverMensagem(idTres, -1);
      expect(controlador.state.rascunho.mensagens[1].id, idTres);
      controlador.moverMensagem(idTres, 1);
      expect(controlador.state.rascunho.mensagens[2].id, idTres);
      controlador.moverMensagem(idTres, 1); // ja esta no fim: no-op
      expect(controlador.state.rascunho.mensagens[2].id, idTres);
    });

    test('removerMensagem exclui', () {
      controlador.adicionarMensagem('Um');
      controlador.adicionarMensagem('Dois');
      final idUm = controlador.state.rascunho.mensagens[0].id;
      controlador.removerMensagem(idUm);
      expect(controlador.state.rascunho.mensagens, hasLength(1));
      expect(controlador.state.rascunho.mensagens.single.id, isNot(idUm));
    });
  });

  group('parceiro', () {
    setUp(() async => controlador.carregar());

    test('definirMidiaParceiro substitui (uma so)', () {
      controlador.definirMidiaParceiro('/p/a.png');
      final primeiro = controlador.state.rascunho.midiaParceiro;
      expect(primeiro, isNotNull);
      expect(primeiro!.tipo, TipoMidia.imagem);
      expect(primeiro.ordem, 0);
      controlador.definirMidiaParceiro('/p/b.png');
      final segundo = controlador.state.rascunho.midiaParceiro;
      expect(segundo!.caminho, '/p/b.png');
      expect(segundo.id, isNot(primeiro.id));
    });

    test('ajustarMidiaParceiro atualiza somente ajuste/ancora/zoom', () {
      controlador.definirMidiaParceiro('/p/a.png');
      controlador.ajustarMidiaParceiro(
          ajuste: AjusteMidia.encaixar,
          ancora: AncoraMidia.topo,
          zoomPercentual: 120);
      final midia = controlador.state.rascunho.midiaParceiro!;
      expect(midia.ajuste, AjusteMidia.encaixar);
      expect(midia.ancora, AncoraMidia.topo);
      expect(midia.zoomPercentual, 120);
      expect(midia.caminho, '/p/a.png');
    });

    test('removerMidiaParceiro limpa', () {
      controlador.definirMidiaParceiro('/p/a.png');
      controlador.removerMidiaParceiro();
      expect(controlador.state.rascunho.midiaParceiro, isNull);
    });
  });

  group('ciclo aplicar/descartar', () {
    setUp(() async => controlador.carregar());

    test('aplicar persiste o rascunho, zera pendentes e reflete em salva',
        () async {
      controlador.adicionarBanners(['/b/a.png']);
      controlador.definirIntervalo(15);
      final ok = await controlador.aplicar();
      expect(ok, isTrue);
      expect(repositorio.chamadasSalvar, 1);
      expect(controlador.state.salva, controlador.state.rascunho);
      expect(controlador.state.pendentes, isFalse);
      expect((await repositorio.obter()).intervaloSegundos, 15);
    });

    test(
        'aplicar com ativa=true e formato sem conteudo retorna false e nao persiste',
        () async {
      controlador.alternarAtiva(true); // formato padrao carrossel, sem banners
      final ok = await controlador.aplicar();
      expect(ok, isFalse);
      expect(repositorio.chamadasSalvar, 0);
      expect(controlador.state.salva.ativa, isFalse);
      expect(controlador.state.pendentes, isTrue);
    });

    test('aplicar com ativa=false persiste mesmo sem conteudo', () async {
      controlador.definirSeparador('|'); // ativa continua false
      final ok = await controlador.aplicar();
      expect(ok, isTrue);
      expect(repositorio.chamadasSalvar, 1);
    });

    test('descartar restaura o rascunho para o valor salvo', () async {
      controlador.adicionarBanners(['/b/a.png']);
      controlador.alternarAtiva(true);
      expect(controlador.state.pendentes, isTrue);
      controlador.descartar();
      expect(controlador.state.rascunho, controlador.state.salva);
      expect(controlador.state.pendentes, isFalse);
      expect(controlador.state.rascunho.banners, isEmpty);
    });
  });
}
