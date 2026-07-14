import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/carrossel_publicidade.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/conteudo_publicidade.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/letreiro_publicidade.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/publicidade_barra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _caminhoInexistente = 'D:/nao/existe/banner.png';

MidiaPropaganda _midia({int ordem = 1, bool ativo = true, String id = 'm1'}) =>
    MidiaPropaganda(
      id: id,
      tipo: TipoMidia.imagem,
      caminho: _caminhoInexistente,
      ordem: ordem,
      ativo: ativo,
    );

Widget _app(Widget filho, {double largura = 320, double altura = 60}) =>
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: largura, height: altura, child: filho),
        ),
      ),
    );

/// Predicado que reconhece as bolinhas de indicador do carrossel (Container
/// circular), sem depender de tipos internos privados.
bool _ehIndicador(Widget w) =>
    w is Container &&
    w.decoration is BoxDecoration &&
    (w.decoration! as BoxDecoration).shape == BoxShape.circle;

void main() {
  group('calcularCoresPublicidade (funcao pura)', () {
    test('primaria escura resulta em texto branco', () {
      const tema = TemaPersonalizado(
        corPrimaria: '#101010',
        corSecundaria: '#FFD166',
      );
      final cores = calcularCoresPublicidade(tema);
      expect(cores.texto, Colors.white);
    });

    test('primaria clara resulta em texto escuro (#1E1E1E)', () {
      const tema = TemaPersonalizado(
        corPrimaria: '#FAFAFA',
        corSecundaria: '#FFD166',
      );
      final cores = calcularCoresPublicidade(tema);
      expect(cores.texto, const Color(0xFF1E1E1E));
    });

    test('secundaria sem contraste suficiente: destaque cai na cor do texto',
        () {
      // Secundaria igual a primaria: contraste com o fundo (variacao da
      // propria primaria) fica bem abaixo do minimo de 3.0.
      const tema = TemaPersonalizado(
        corPrimaria: '#5E52D6',
        corSecundaria: '#5E52D6',
      );
      final cores = calcularCoresPublicidade(tema);
      expect(cores.destaque, cores.texto);
    });

    test('secundaria com contraste suficiente vira a cor de destaque', () {
      const tema = TemaPersonalizado(
        corPrimaria: '#101010',
        corSecundaria: '#FFD166',
      );
      final cores = calcularCoresPublicidade(tema);
      expect(cores.destaque, const Color(0xFFFFD166));
    });
  });

  group('ConteudoPublicidade — despacho', () {
    testWidgets('publicidade nao exibivel renderiza SizedBox.shrink',
        (tester) async {
      const publicidade = PublicidadeBarra(ativa: false);
      await tester.pumpWidget(_app(const ConteudoPublicidade(
        publicidade: publicidade,
        tema: TemaPersonalizado(),
        reproduzindo: false,
      )));

      expect(find.byType(LetreiroPublicidade), findsNothing);
      expect(find.byType(CarrosselPublicidade), findsNothing);
      expect(find.byType(BannerPublicidade), findsNothing);
      final vazio = tester.widget<SizedBox>(find.descendant(
        of: find.byType(ConteudoPublicidade),
        matching: find.byType(SizedBox),
      ));
      expect(vazio.width, 0);
      expect(vazio.height, 0);
    });

    testWidgets('formato carrossel despacha para CarrosselPublicidade',
        (tester) async {
      final publicidade = PublicidadeBarra(
        ativa: true,
        formato: FormatoPublicidade.carrossel,
        banners: [_midia()],
      );
      await tester.pumpWidget(_app(ConteudoPublicidade(
        publicidade: publicidade,
        tema: const TemaPersonalizado(),
        reproduzindo: false,
      )));
      await tester.pump();

      expect(find.byType(CarrosselPublicidade), findsOneWidget);
      expect(find.byType(LetreiroPublicidade), findsNothing);
    });

    testWidgets(
        'formato letreiro despacha para LetreiroPublicidade com as '
        'mensagens ativas', (tester) async {
      final publicidade = PublicidadeBarra(
        ativa: true,
        formato: FormatoPublicidade.letreiro,
        mensagens: const [
          MensagemLetreiro(id: '1', texto: 'Promoção hoje', ordem: 1),
          MensagemLetreiro(id: '2', texto: 'Inativa', ordem: 2, ativo: false),
        ],
      );
      await tester.pumpWidget(_app(ConteudoPublicidade(
        publicidade: publicidade,
        tema: const TemaPersonalizado(),
        reproduzindo: false,
      )));
      await tester.pump();

      expect(find.byType(LetreiroPublicidade), findsOneWidget);
      final letreiro =
          tester.widget<LetreiroPublicidade>(find.byType(LetreiroPublicidade));
      expect(letreiro.mensagens, ['Promoção hoje']);
      expect(letreiro.animar, isFalse);
    });

    testWidgets('formato parceiro renderiza a midia unica sem timer',
        (tester) async {
      final publicidade = PublicidadeBarra(
        ativa: true,
        formato: FormatoPublicidade.parceiro,
        midiaParceiro: _midia(id: 'parceiro'),
      );
      await tester.pumpWidget(_app(ConteudoPublicidade(
        publicidade: publicidade,
        tema: const TemaPersonalizado(),
        reproduzindo: false,
      )));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(BannerPublicidade), findsOneWidget);
      expect(find.byType(CarrosselPublicidade), findsNothing);
      expect(find.byType(LetreiroPublicidade), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('LetreiroPublicidade', () {
    testWidgets(
        'texto curto em area larga fica estatico, sem excecao com '
        'animar:false', (tester) async {
      await tester.pumpWidget(_app(
        const LetreiroPublicidade(
          mensagens: ['Oi'],
          separador: '•',
          velocidade: VelocidadeLetreiro.normal,
          corFundo: Color(0xFF202020),
          corTexto: Colors.white,
          corSeparador: Colors.white,
          fonte: 'Inter',
          animar: false,
        ),
        largura: 800,
      ));
      await tester.pump();

      expect(find.text('Oi'), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('monta com emojis sem lancar excecao', (tester) async {
      await tester.pumpWidget(_app(
        const LetreiroPublicidade(
          mensagens: ['🎉 Promoção 😊', 'Boa sorte 🍀'],
          separador: '★',
          velocidade: VelocidadeLetreiro.rapida,
          corFundo: Color(0xFF202020),
          corTexto: Colors.white,
          corSeparador: Colors.amber,
          fonte: 'Inter',
          animar: false,
        ),
        largura: 120,
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'separador usa corSeparador e mensagens usam corTexto no '
        'texto composto', (tester) async {
      await tester.pumpWidget(_app(
        const LetreiroPublicidade(
          mensagens: ['Primeira', 'Segunda'],
          separador: '•',
          velocidade: VelocidadeLetreiro.normal,
          corFundo: Color(0xFF202020),
          corTexto: Colors.white,
          corSeparador: Colors.amber,
          fonte: 'Inter',
          animar: false,
        ),
        largura: 800,
      ));
      await tester.pump();

      final richText = tester.widget<RichText>(find.descendant(
        of: find.byType(LetreiroPublicidade),
        matching: find.byType(RichText),
      ));
      final raiz = richText.text as TextSpan;

      final spansSeparador = <TextSpan>[];
      final spansMensagem = <TextSpan>[];
      raiz.visitChildren((span) {
        if (span is TextSpan && span.text != null) {
          if (span.text!.contains('•')) {
            spansSeparador.add(span);
          } else if (span.text == 'Primeira' || span.text == 'Segunda') {
            spansMensagem.add(span);
          }
        }
        return true;
      });

      expect(spansSeparador, isNotEmpty);
      for (final span in spansSeparador) {
        expect(span.style?.color, Colors.amber);
      }
      expect(spansMensagem, hasLength(2));
      for (final span in spansMensagem) {
        expect(span.style?.color, Colors.white);
      }
    });
  });

  group('CarrosselPublicidade', () {
    testWidgets('1 banner nao mostra indicadores', (tester) async {
      await tester.pumpWidget(_app(
        CarrosselPublicidade(
          banners: [_midia(id: 'b1')],
          intervaloSegundos: 6,
          transicao: TransicaoCarrossel.suave,
          corIndicadores: Colors.amber,
          reproduzindo: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byWidgetPredicate(_ehIndicador), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('3 banners mostram 3 indicadores', (tester) async {
      await tester.pumpWidget(_app(
        CarrosselPublicidade(
          banners: [
            _midia(id: 'b1', ordem: 1),
            _midia(id: 'b2', ordem: 2),
            _midia(id: 'b3', ordem: 3),
          ],
          intervaloSegundos: 6,
          transicao: TransicaoCarrossel.deslizar,
          corIndicadores: Colors.amber,
          reproduzindo: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byWidgetPredicate(_ehIndicador), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('semAnimacao nao lanca excecao ao trocar de indice',
        (tester) async {
      await tester.pumpWidget(_app(
        CarrosselPublicidade(
          banners: [_midia(id: 'b1', ordem: 1), _midia(id: 'b2', ordem: 2)],
          intervaloSegundos: 6,
          transicao: TransicaoCarrossel.semAnimacao,
          corIndicadores: Colors.amber,
          reproduzindo: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'semAnimacao usa AnimatedSwitcher com duration zero (troca '
        'instantanea, sem coexistencia)', (tester) async {
      await tester.pumpWidget(_app(
        CarrosselPublicidade(
          banners: [_midia(id: 'b1', ordem: 1), _midia(id: 'b2', ordem: 2)],
          intervaloSegundos: 6,
          transicao: TransicaoCarrossel.semAnimacao,
          corIndicadores: Colors.amber,
          reproduzindo: false,
        ),
      ));
      await tester.pump();

      final switcher =
          tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher));
      expect(switcher.duration, Duration.zero);
    });

    testWidgets('suave mantem AnimatedSwitcher com duration de 400ms',
        (tester) async {
      await tester.pumpWidget(_app(
        CarrosselPublicidade(
          banners: [_midia(id: 'b1', ordem: 1), _midia(id: 'b2', ordem: 2)],
          intervaloSegundos: 6,
          transicao: TransicaoCarrossel.suave,
          corIndicadores: Colors.amber,
          reproduzindo: false,
        ),
      ));
      await tester.pump();

      final switcher =
          tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher));
      expect(switcher.duration, const Duration(milliseconds: 400));
    });
  });
}
