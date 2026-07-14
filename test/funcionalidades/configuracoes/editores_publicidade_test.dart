import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/cartao_formato_publicidade.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/editor_carrossel.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/editor_letreiro.dart';
import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/editor_parceiro.dart';
import 'package:constel_pay/funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/publicidade_barra.dart';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget filho) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: filho)));

void main() {
  group('CartaoFormatoPublicidade', () {
    testWidgets(
        'mostra codigo, nome, descricao e complemento; sem check quando não selecionado',
        (tester) async {
      await tester.pumpWidget(_app(CartaoFormatoPublicidade(
        codigo: '1A',
        nome: 'Carrossel de banners',
        descricao:
            'Alterne automaticamente campanhas, eventos, parceiros e conteúdos institucionais.',
        complemento: 'Melhor opção para exibir várias artes no mesmo espaço.',
        miniatura: CartaoFormatoPublicidade.miniaturaCarrossel(),
        selecionado: false,
        aoTocar: () {},
      )));
      expect(find.text('1A'), findsOneWidget);
      expect(find.text('Carrossel de banners'), findsOneWidget);
      expect(
          find.text(
              'Alterne automaticamente campanhas, eventos, parceiros e conteúdos institucionais.'),
          findsOneWidget);
      expect(
          find.text('Melhor opção para exibir várias artes no mesmo espaço.'),
          findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('tocar chama callback e selecionado mostra check_circle',
        (tester) async {
      var tocado = false;
      await tester.pumpWidget(_app(CartaoFormatoPublicidade(
        codigo: '1B',
        nome: 'Letreiro de mensagens',
        descricao:
            'Exiba frases e avisos em movimento sem precisar criar artes.',
        complemento: 'Indicado para eventos, promoções e comunicados rápidos.',
        miniatura: CartaoFormatoPublicidade.miniaturaLetreiro(),
        selecionado: true,
        aoTocar: () => tocado = true,
      )));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      expect(tocado, isTrue);
    });

    testWidgets('Semantics expoe button:true e selected conforme o valor',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(CartaoFormatoPublicidade(
        codigo: '1C',
        nome: 'Espaço fixo de parceiro',
        descricao: 'Exiba uma única imagem, GIF ou vídeo continuamente.',
        complemento:
            'Indicado para publicidade de parceiros ou campanhas prioritárias.',
        miniatura: CartaoFormatoPublicidade.miniaturaParceiro(),
        selecionado: true,
        aoTocar: () {},
      )));
      final flags = tester
          .getSemantics(find.byType(CartaoFormatoPublicidade))
          .flagsCollection;
      expect(flags.isButton, isTrue);
      expect(flags.isSelected, Tristate.isTrue);
      handle.dispose();
    });

    testWidgets(
        '3 cards mostram codigos/nomes distintos; so o selecionado mostra check',
        (tester) async {
      String? tocado;
      await tester.pumpWidget(_app(Column(children: [
        CartaoFormatoPublicidade(
          codigo: '1A',
          nome: 'Carrossel de banners',
          descricao: 'x',
          complemento: 'y',
          miniatura: CartaoFormatoPublicidade.miniaturaCarrossel(),
          selecionado: true,
          aoTocar: () => tocado = '1A',
        ),
        CartaoFormatoPublicidade(
          codigo: '1B',
          nome: 'Letreiro de mensagens',
          descricao: 'x',
          complemento: 'y',
          miniatura: CartaoFormatoPublicidade.miniaturaLetreiro(),
          selecionado: false,
          aoTocar: () => tocado = '1B',
        ),
        CartaoFormatoPublicidade(
          codigo: '1C',
          nome: 'Espaço fixo de parceiro',
          descricao: 'x',
          complemento: 'y',
          miniatura: CartaoFormatoPublicidade.miniaturaParceiro(),
          selecionado: false,
          aoTocar: () => tocado = '1C',
        ),
      ])));
      expect(find.text('1A'), findsOneWidget);
      expect(find.text('1B'), findsOneWidget);
      expect(find.text('1C'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      await tester.tap(find.text('1C'));
      expect(tocado, '1C');
    });
  });

  group('EditorCarrossel', () {
    const banner1 = MidiaPropaganda(
        id: 'b1', tipo: TipoMidia.imagem, caminho: '/b/um.png', ordem: 1);
    const banner2 = MidiaPropaganda(
        id: 'b2',
        tipo: TipoMidia.imagem,
        caminho: '/b/dois.png',
        ordem: 2,
        ativo: false);

    Widget montar({
      PublicidadeBarra publicidade = const PublicidadeBarra(),
      ValueChanged<int>? aoDefinirIntervalo,
      ValueChanged<TransicaoCarrossel>? aoDefinirTransicao,
      VoidCallback? aoAdicionarBanners,
      ValueChanged<String>? aoAlternarBanner,
      void Function(String, int)? aoMoverBanner,
      ValueChanged<String>? aoRemoverBanner,
      ValueChanged<MidiaPropaganda>? aoAjustarBanner,
    }) =>
        _app(EditorCarrossel(
          publicidade: publicidade,
          aoDefinirIntervalo: aoDefinirIntervalo ?? (_) {},
          aoDefinirTransicao: aoDefinirTransicao ?? (_) {},
          aoAdicionarBanners: aoAdicionarBanners ?? () {},
          aoAlternarBanner: aoAlternarBanner ?? (_) {},
          aoMoverBanner: aoMoverBanner ?? (_, __) {},
          aoRemoverBanner: aoRemoverBanner ?? (_) {},
          aoAjustarBanner: aoAjustarBanner ?? (_) {},
        ));

    testWidgets('vazio mostra Nenhum conteúdo configurado.', (tester) async {
      await tester.pumpWidget(montar());
      expect(find.text('Nenhum conteúdo configurado.'), findsOneWidget);
    });

    testWidgets('titulo e descricao propria da secao sao exibidos',
        (tester) async {
      await tester.pumpWidget(montar());
      expect(find.text('Carrossel de banners'), findsOneWidget);
      expect(
          find.text(
              'Alterne automaticamente campanhas dentro da barra superior.'),
          findsOneWidget);
    });

    testWidgets('banner some/aparece conforme a lista recebida',
        (tester) async {
      await tester.pumpWidget(
          montar(publicidade: const PublicidadeBarra(banners: [banner1])));
      expect(find.text('Banner 1'), findsOneWidget);
      expect(find.text('Nenhum conteúdo configurado.'), findsNothing);

      await tester.pumpWidget(montar());
      expect(find.text('Banner 1'), findsNothing);
      expect(find.text('Nenhum conteúdo configurado.'), findsOneWidget);
    });

    testWidgets('dropdown Tempo entre banners dispara aoDefinirIntervalo',
        (tester) async {
      int? capturado;
      await tester.pumpWidget(montar(aoDefinirIntervalo: (v) => capturado = v));
      expect(find.text('Tempo entre banners'), findsOneWidget);
      await tester.tap(find.text('6 segundos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10 segundos').last);
      await tester.pumpAndSettle();
      expect(capturado, 10);
    });

    testWidgets('dropdown Transição dispara aoDefinirTransicao',
        (tester) async {
      TransicaoCarrossel? capturado;
      await tester.pumpWidget(montar(aoDefinirTransicao: (v) => capturado = v));
      expect(find.text('Transição'), findsOneWidget);
      await tester.tap(find.text('Suave'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deslizar').last);
      await tester.pumpAndSettle();
      expect(capturado, TransicaoCarrossel.deslizar);
    });

    testWidgets('dica de tamanho e aviso de 5 banners estao presentes',
        (tester) async {
      await tester.pumpWidget(montar(
          publicidade: const PublicidadeBarra(banners: [banner1, banner2])));
      expect(find.text('Recomendado: 384 × 192 px, proporção 2:1.'),
          findsOneWidget);
      expect(
          find.text(
              'Recomendamos até 5 banners ativos para manter uma rotação rápida.'),
          findsOneWidget);
    });

    testWidgets('+ Adicionar banner dispara aoAdicionarBanners',
        (tester) async {
      var chamado = false;
      await tester.pumpWidget(montar(aoAdicionarBanners: () => chamado = true));
      await tester.tap(find.text('+ Adicionar banner'));
      expect(chamado, isTrue);
    });

    testWidgets(
        'acoes do card (mover/ajustar/alternar/remover) chamam callbacks com o id certo',
        (tester) async {
      String? movidoId, alternado, removido;
      int? delta;
      MidiaPropaganda? ajustado;
      await tester.pumpWidget(montar(
        publicidade: const PublicidadeBarra(banners: [banner1]),
        aoMoverBanner: (id, d) {
          movidoId = id;
          delta = d;
        },
        aoAlternarBanner: (id) => alternado = id,
        aoRemoverBanner: (id) => removido = id,
        aoAjustarBanner: (m) => ajustado = m,
      ));
      await tester.tap(find.byIcon(Icons.arrow_downward));
      expect(movidoId, 'b1');
      expect(delta, 1);
      await tester.tap(find.byType(Switch));
      expect(alternado, 'b1');
      await tester.tap(find.text('Ajustar…'));
      expect(ajustado?.id, 'b1');
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(removido, 'b1');
    });

    testWidgets('acao Ajustar… possui Tooltip proprio', (tester) async {
      await tester.pumpWidget(
          montar(publicidade: const PublicidadeBarra(banners: [banner1])));
      expect(find.byTooltip('Ajustar enquadramento'), findsOneWidget);
    });
  });

  group('EditorLetreiro', () {
    const tema = TemaPersonalizado(
        corPrimaria: '#112233', corSecundaria: '#AABBCC', fonte: 'Poppins');

    Widget montar({
      PublicidadeBarra publicidade = const PublicidadeBarra(),
      ValueChanged<String>? aoAdicionarMensagem,
      void Function(String, String)? aoEditarMensagem,
      ValueChanged<String>? aoAlternarMensagem,
      void Function(String, int)? aoMoverMensagem,
      ValueChanged<String>? aoRemoverMensagem,
      ValueChanged<VelocidadeLetreiro>? aoDefinirVelocidade,
      ValueChanged<String>? aoDefinirSeparador,
      VoidCallback? aoAjustarAparencia,
    }) =>
        _app(EditorLetreiro(
          publicidade: publicidade,
          tema: tema,
          aoAdicionarMensagem: aoAdicionarMensagem ?? (_) {},
          aoEditarMensagem: aoEditarMensagem ?? (_, __) {},
          aoAlternarMensagem: aoAlternarMensagem ?? (_) {},
          aoMoverMensagem: aoMoverMensagem ?? (_, __) {},
          aoRemoverMensagem: aoRemoverMensagem ?? (_) {},
          aoDefinirVelocidade: aoDefinirVelocidade ?? (_) {},
          aoDefinirSeparador: aoDefinirSeparador ?? (_) {},
          aoAjustarAparencia: aoAjustarAparencia ?? () {},
        ));

    testWidgets(
        'titulo, descricao e vazio mostram Nenhum conteúdo configurado.',
        (tester) async {
      await tester.pumpWidget(montar());
      expect(find.text('Letreiro de mensagens'), findsOneWidget);
      expect(
          find.text('Crie avisos e divulgações sem precisar produzir imagens.'),
          findsOneWidget);
      expect(find.text('Nenhum conteúdo configurado.'), findsOneWidget);
    });

    testWidgets('adicionar mensagem via dialogo com contador nativo N/100',
        (tester) async {
      String? capturado;
      await tester
          .pumpWidget(montar(aoAdicionarMensagem: (t) => capturado = t));
      await tester.tap(find.text('+ Adicionar mensagem'));
      await tester.pumpAndSettle();
      expect(find.text('Mensagem'), findsOneWidget);
      expect(find.text('0/100'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Promoção hoje!');
      await tester.pump();
      expect(find.text('14/100'), findsOneWidget);
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(capturado, 'Promoção hoje!');
    });

    testWidgets('editar mensagem reutiliza o mesmo dialogo preenchido',
        (tester) async {
      String? idEditado, textoEditado;
      const msg = MensagemLetreiro(id: 'm1', texto: 'Original', ordem: 1);
      await tester.pumpWidget(montar(
        publicidade: const PublicidadeBarra(mensagens: [msg]),
        aoEditarMensagem: (id, t) {
          idEditado = id;
          textoEditado = t;
        },
      ));
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Original'), findsWidgets); // card + campo preenchido
      await tester.enterText(find.byType(TextFormField), 'Editada');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(idEditado, 'm1');
      expect(textoEditado, 'Editada');
    });

    testWidgets('resumo de Estilo visual mostra fonte e cores herdadas do tema',
        (tester) async {
      await tester.pumpWidget(montar());
      expect(find.text('Estilo visual'), findsOneWidget);
      expect(find.text('Fonte e cores herdadas da aba Aparência.'),
          findsOneWidget);
      expect(find.text('Fonte: Poppins'), findsOneWidget);
      expect(find.text('Cor principal: #112233'), findsOneWidget);
      expect(find.text('Cor secundária: #AABBCC'), findsOneWidget);
    });

    testWidgets('Ajustar aparência dispara aoAjustarAparencia', (tester) async {
      var chamado = false;
      await tester.pumpWidget(montar(aoAjustarAparencia: () => chamado = true));
      await tester.tap(find.text('Ajustar aparência'));
      expect(chamado, isTrue);
    });

    testWidgets('dropdowns Velocidade e Separador disparam callbacks',
        (tester) async {
      VelocidadeLetreiro? velocidade;
      String? separador;
      await tester.pumpWidget(montar(
        aoDefinirVelocidade: (v) => velocidade = v,
        aoDefinirSeparador: (s) => separador = s,
      ));
      expect(find.text('Velocidade'), findsOneWidget);
      expect(find.text('Separador'), findsOneWidget);
      await tester.tap(find.text('Normal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rápida').last);
      await tester.pumpAndSettle();
      expect(velocidade, VelocidadeLetreiro.rapida);

      await tester.tap(find.text('•'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('★').last);
      await tester.pumpAndSettle();
      expect(separador, '★');
    });

    testWidgets(
        'acoes do card (mover/alternar/remover) chamam callbacks com o id certo',
        (tester) async {
      String? movidoId, alternado, removido;
      int? delta;
      const msg = MensagemLetreiro(id: 'm1', texto: 'Ola', ordem: 1);
      await tester.pumpWidget(montar(
        publicidade: const PublicidadeBarra(mensagens: [msg]),
        aoMoverMensagem: (id, d) {
          movidoId = id;
          delta = d;
        },
        aoAlternarMensagem: (id) => alternado = id,
        aoRemoverMensagem: (id) => removido = id,
      ));
      await tester.tap(find.byIcon(Icons.arrow_upward));
      expect(movidoId, 'm1');
      expect(delta, -1);
      await tester.tap(find.byType(Switch));
      expect(alternado, 'm1');
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(removido, 'm1');
    });
  });

  group('EditorParceiro', () {
    testWidgets(
        'sem midia mostra Nenhum conteúdo configurado. e CTA Alterar mídia',
        (tester) async {
      var chamado = false;
      await tester.pumpWidget(_app(EditorParceiro(
        publicidade: const PublicidadeBarra(),
        aoAlterarMidia: () => chamado = true,
        aoRemoverMidia: () {},
        aoAjustarMidia: () {},
      )));
      expect(find.text('Espaço fixo de parceiro'), findsOneWidget);
      expect(
          find.text(
              'Exiba uma única publicidade continuamente durante o atendimento.'),
          findsOneWidget);
      expect(find.text('Nenhum conteúdo configurado.'), findsOneWidget);
      expect(find.text('Alterar mídia'), findsOneWidget);
      expect(find.text('Remover mídia'), findsNothing);
      await tester.tap(find.text('Alterar mídia'));
      expect(chamado, isTrue);
    });

    testWidgets('com midia mostra previa e botoes Alterar/Ajustar/Remover',
        (tester) async {
      var alterar = false, remover = false, ajustar = false;
      const midia = MidiaPropaganda(
          id: 'p1',
          tipo: TipoMidia.imagem,
          caminho: '/p/parceiro.png',
          ordem: 0);
      await tester.pumpWidget(_app(EditorParceiro(
        publicidade: const PublicidadeBarra(midiaParceiro: midia),
        aoAlterarMidia: () => alterar = true,
        aoRemoverMidia: () => remover = true,
        aoAjustarMidia: () => ajustar = true,
      )));
      expect(find.text('Nenhum conteúdo configurado.'), findsNothing);
      expect(find.text('parceiro.png'), findsOneWidget);
      expect(find.text('Recomendado: 1040 × 128 px.'), findsOneWidget);
      await tester.tap(find.text('Alterar mídia'));
      expect(alterar, isTrue);
      await tester.tap(find.text('Ajustar…'));
      expect(ajustar, isTrue);
      await tester.tap(find.text('Remover mídia'));
      expect(remover, isTrue);
    });
  });
}
