import 'package:constel_pay/funcionalidades/propaganda/dados/repositorios/repositorio_publicidade_impl.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/publicidade_barra.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const banner = MidiaPropaganda(
    id: 'banner-1',
    tipo: TipoMidia.imagem,
    caminho: '/m/banner.png',
    ajuste: AjusteMidia.encaixar,
    fundo: FundoMidia.cor,
    ancora: AncoraMidia.topo,
    zoomPercentual: 140,
    ordem: 1,
  );

  const midiaParceiro = MidiaPropaganda(
    id: 'parceiro-1',
    tipo: TipoMidia.video,
    caminho: '/m/parceiro.mp4',
    ordem: 1,
  );

  const mensagem = MensagemLetreiro(
    id: 'msg-1',
    texto: 'Promoção especial hoje',
    ordem: 1,
  );

  const publicidadeCompleta = PublicidadeBarra(
    ativa: true,
    formato: FormatoPublicidade.letreiro,
    banners: [banner],
    intervaloSegundos: 10,
    transicao: TransicaoCarrossel.deslizar,
    mensagens: [mensagem],
    velocidade: VelocidadeLetreiro.rapida,
    separador: '★',
    midiaParceiro: midiaParceiro,
  );

  test('obter() sem chave salva devolve defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio =
        RepositorioPublicidadeImpl(await SharedPreferences.getInstance());
    expect(await repositorio.obter(), const PublicidadeBarra());
  });

  test('salva e recupera a publicidade completa (round-trip)', () async {
    SharedPreferences.setMockInitialValues({});
    final repositorio =
        RepositorioPublicidadeImpl(await SharedPreferences.getInstance());
    await repositorio.salvar(publicidadeCompleta);
    expect(await repositorio.obter(), publicidadeCompleta);
  });

  test('JSON corrompido devolve defaults sem lançar', () async {
    SharedPreferences.setMockInitialValues({
      'publicidade_barra': '{lixo',
    });
    final repositorio =
        RepositorioPublicidadeImpl(await SharedPreferences.getInstance());
    expect(await repositorio.obter(), const PublicidadeBarra());
  });

  test('enum desconhecido no JSON cai no unknownEnumValue', () async {
    SharedPreferences.setMockInitialValues({
      'publicidade_barra': '{"ativa":true,"formato":"holograma",'
          '"banners":[],"intervaloSegundos":6,"transicao":"levitacao",'
          '"mensagens":[],"velocidade":"supersonica","separador":"•"}',
    });
    final repositorio =
        RepositorioPublicidadeImpl(await SharedPreferences.getInstance());
    final publicidade = await repositorio.obter();
    expect(publicidade.formato, FormatoPublicidade.carrossel);
    expect(publicidade.transicao, TransicaoCarrossel.suave);
    expect(publicidade.velocidade, VelocidadeLetreiro.normal);
  });

  group('formatoTemConteudo / exibivel', () {
    test('carrossel com banner ativo tem conteúdo', () {
      const publicidade = PublicidadeBarra(
        ativa: true,
        formato: FormatoPublicidade.carrossel,
        banners: [banner],
      );
      expect(publicidade.formatoTemConteudo, isTrue);
      expect(publicidade.exibivel, isTrue);
    });

    test('carrossel sem banners não tem conteúdo', () {
      const publicidade = PublicidadeBarra(
        ativa: true,
        formato: FormatoPublicidade.carrossel,
      );
      expect(publicidade.formatoTemConteudo, isFalse);
      expect(publicidade.exibivel, isFalse);
    });

    test('letreiro com mensagem ativa tem conteúdo', () {
      const publicidade = PublicidadeBarra(
        ativa: true,
        formato: FormatoPublicidade.letreiro,
        mensagens: [mensagem],
      );
      expect(publicidade.formatoTemConteudo, isTrue);
      expect(publicidade.exibivel, isTrue);
    });

    test('parceiro com midia definida tem conteúdo', () {
      const publicidade = PublicidadeBarra(
        ativa: true,
        formato: FormatoPublicidade.parceiro,
        midiaParceiro: midiaParceiro,
      );
      expect(publicidade.formatoTemConteudo, isTrue);
      expect(publicidade.exibivel, isTrue);
    });

    test('parceiro sem midia não tem conteúdo', () {
      const publicidade = PublicidadeBarra(
        ativa: true,
        formato: FormatoPublicidade.parceiro,
      );
      expect(publicidade.formatoTemConteudo, isFalse);
      expect(publicidade.exibivel, isFalse);
    });

    test('mesmo com conteúdo, ativa=false não é exibível', () {
      const publicidade = PublicidadeBarra(
        ativa: false,
        formato: FormatoPublicidade.carrossel,
        banners: [banner],
      );
      expect(publicidade.formatoTemConteudo, isTrue);
      expect(publicidade.exibivel, isFalse);
    });
  });

  test('bannersAtivos filtra inativos e ordena por ordem', () {
    const publicidade = PublicidadeBarra(
      banners: [
        MidiaPropaganda(
            id: 'a', tipo: TipoMidia.imagem, caminho: '/a.png', ordem: 2),
        MidiaPropaganda(
            id: 'b', tipo: TipoMidia.imagem, caminho: '/b.png', ordem: 1),
        MidiaPropaganda(
            id: 'c',
            tipo: TipoMidia.imagem,
            caminho: '/c.png',
            ordem: 0,
            ativo: false),
      ],
    );
    expect(publicidade.bannersAtivos.map((b) => b.id).toList(), ['b', 'a']);
  });

  test('mensagensAtivas filtra inativas e ordena por ordem', () {
    const publicidade = PublicidadeBarra(
      mensagens: [
        MensagemLetreiro(id: 'a', texto: 'A', ordem: 2),
        MensagemLetreiro(id: 'b', texto: 'B', ordem: 1),
        MensagemLetreiro(id: 'c', texto: 'C', ordem: 0, ativo: false),
      ],
    );
    expect(publicidade.mensagensAtivas.map((m) => m.id).toList(), ['b', 'a']);
  });
}
