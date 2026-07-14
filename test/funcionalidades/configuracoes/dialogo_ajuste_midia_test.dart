import 'package:constel_pay/funcionalidades/configuracoes/apresentacao/componentes/dialogo_ajuste_midia.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/ajuste_tela.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/player_propaganda.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/midia_propaganda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef EnquadramentoSalvo = ({
  AjusteMidia ajuste,
  FundoMidia fundo,
  AncoraMidia ancora,
  int zoomPercentual,
});

void main() {
  const midiaImagem = MidiaPropaganda(
      id: 'a', tipo: TipoMidia.imagem, caminho: '/m/inexistente.png', ordem: 1);
  const midiaVideo = MidiaPropaganda(
      id: 'v', tipo: TipoMidia.video, caminho: '/m/inexistente.mp4', ordem: 1);

  Future<void> abrir(
    WidgetTester tester,
    MidiaPropaganda midia, {
    void Function(EnquadramentoSalvo salvo)? aoSalvar,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => DialogoAjusteMidia(
                  midia: midia,
                  corTema: const Color(0xFF5E52D6),
                  aoSalvar: ({
                    required AjusteMidia ajuste,
                    required FundoMidia fundo,
                    required AncoraMidia ancora,
                    required int zoomPercentual,
                  }) =>
                      aoSalvar?.call((
                    ajuste: ajuste,
                    fundo: fundo,
                    ancora: ancora,
                    zoomPercentual: zoomPercentual,
                  )),
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  /// A midia inexistente agenda o temporizador de 1s do player; drena antes
  /// do fim do teste.
  Future<void> drenar(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 2));

  Future<void> escolherModo(WidgetTester tester, String rotulo) async {
    await tester.tap(find.byType(DropdownButton<AjusteMidia>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(rotulo).last);
    await tester.pumpAndSettle();
  }

  testWidgets('preview usa o mesmo player da tela real', (tester) async {
    await abrir(tester, midiaImagem);
    expect(find.byType(PlayerPropaganda), findsOneWidget);
    await drenar(tester);
  });

  testWidgets('cancelar fecha sem salvar', (tester) async {
    EnquadramentoSalvo? salvo;
    await abrir(tester, midiaImagem, aoSalvar: (s) => salvo = s);
    await escolherModo(tester, 'Preencher (corta)');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(salvo, isNull);
    expect(find.byType(DialogoAjusteMidia), findsNothing);
    await drenar(tester);
  });

  testWidgets('salvar devolve o enquadramento editado', (tester) async {
    EnquadramentoSalvo? salvo;
    await abrir(tester, midiaImagem, aoSalvar: (s) => salvo = s);
    await escolherModo(tester, 'Preencher (corta)');
    await tester.tap(find.byKey(const ValueKey('ancora-topo')));
    await tester.pump();
    // O slider fica dentro de um SingleChildScrollView; garante que esta
    // visivel antes de arrastar, senao o gesto erra o alvo.
    await tester.ensureVisible(find.byType(Slider));
    await tester.pumpAndSettle();
    // Arrasta a partir do polegar (valor minimo -> ponta esquerda da trilha)
    // ate a ponta direita: zoom maximo, deterministico.
    final slider = find.byType(Slider);
    final borda = tester.getTopLeft(slider);
    final centroY = tester.getCenter(slider).dy;
    final gesto = await tester.startGesture(Offset(borda.dx + 24, centroY));
    await gesto.moveBy(const Offset(600, 0));
    await gesto.up();
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(salvo, isNotNull);
    expect(salvo!.ajuste, AjusteMidia.preencher);
    expect(salvo!.ancora, AncoraMidia.topo);
    expect(salvo!.zoomPercentual, zoomMaximo);
    expect(find.byType(DialogoAjusteMidia), findsNothing);
    await drenar(tester);
  });

  testWidgets(
      'controles de corte so aparecem no preencher; fundo so onde '
      'ha sobra', (tester) async {
    await abrir(tester, midiaImagem);
    // automatico: fundo sim, corte nao.
    expect(find.byType(SegmentedButton<FundoMidia>), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
    expect(find.byKey(const ValueKey('ancora-topo')), findsNothing);

    await escolherModo(tester, 'Preencher (corta)');
    expect(find.byType(SegmentedButton<FundoMidia>), findsNothing);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byKey(const ValueKey('ancora-topo')), findsOneWidget);
    await drenar(tester);
  });

  testWidgets('video nao oferece fundo enquanto o gate nao libera',
      (tester) async {
    await abrir(tester, midiaVideo);
    expect(find.byType(SegmentedButton<FundoMidia>), findsNothing);
    await drenar(tester);
  });

  test('toda ancora tem rotulo em pt-BR', () {
    for (final ancora in AncoraMidia.values) {
      expect(DialogoAjusteMidia.rotulosAncora[ancora], isNotNull,
          reason: 'sem rotulo para $ancora');
    }
  });

  test('resumo do enquadramento por modo', () {
    expect(resumoEnquadramento(midiaImagem), 'Automático · fundo borrado');
    expect(resumoEnquadramento(midiaImagem.copyWith(fundo: FundoMidia.cor)),
        'Automático · fundo na cor do tema');
    expect(resumoEnquadramento(midiaVideo), 'Automático · fundo na cor do tema',
        reason: 'video segue o gate: o resumo nao pode prometer blur');
    expect(
        resumoEnquadramento(midiaImagem.copyWith(
            ajuste: AjusteMidia.preencher,
            ancora: AncoraMidia.topo,
            zoomPercentual: 140)),
        'Preencher (corta) · topo · 140%');
    expect(
        resumoEnquadramento(midiaImagem.copyWith(ajuste: AjusteMidia.esticar)),
        'Esticar (distorce)');
  });
}
