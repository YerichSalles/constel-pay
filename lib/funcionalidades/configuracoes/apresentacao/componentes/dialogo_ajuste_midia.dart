import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../propaganda/apresentacao/ajuste_tela.dart';
import '../../../propaganda/apresentacao/componentes/player_propaganda.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';
import 'seletor_ajuste_midia.dart';

/// Resumo curto do enquadramento, exibido no card da midia.
String resumoEnquadramento(MidiaPropaganda midia) {
  final modo = SeletorAjusteMidia.rotulos[midia.ajuste] ?? '';
  switch (midia.ajuste) {
    case AjusteMidia.automatico:
    case AjusteMidia.encaixar:
      final fundo = fundoEfetivo(tipo: midia.tipo, fundo: midia.fundo);
      final rotuloFundo =
          fundo == FundoMidia.borrado ? 'borrado' : 'na cor do tema';
      return '$modo · fundo $rotuloFundo';
    case AjusteMidia.preencher:
      final ancora =
          DialogoAjusteMidia.rotulosAncora[midia.ancora]!.toLowerCase();
      final zoom = midia.zoomPercentual.clamp(zoomMinimo, zoomMaximo);
      return '$modo · $ancora · $zoom%';
    case AjusteMidia.esticar:
      return modo;
  }
}

class DialogoAjusteMidia extends StatefulWidget {
  const DialogoAjusteMidia({
    super.key,
    required this.midia,
    required this.corTema,
    required this.aoSalvar,
  });

  final MidiaPropaganda midia;

  /// Cor primaria do tema da loja: o preview pinta o mesmo fundo do totem.
  final Color corTema;

  final void Function({
    required AjusteMidia ajuste,
    required FundoMidia fundo,
    required AncoraMidia ancora,
    required int zoomPercentual,
  }) aoSalvar;

  static const Map<AncoraMidia, String> rotulosAncora = {
    AncoraMidia.topoEsquerda: 'Topo à esquerda',
    AncoraMidia.topo: 'Topo',
    AncoraMidia.topoDireita: 'Topo à direita',
    AncoraMidia.esquerda: 'Esquerda',
    AncoraMidia.centro: 'Centro',
    AncoraMidia.direita: 'Direita',
    AncoraMidia.baseEsquerda: 'Base à esquerda',
    AncoraMidia.base: 'Base',
    AncoraMidia.baseDireita: 'Base à direita',
  };

  @override
  State<DialogoAjusteMidia> createState() => _DialogoAjusteMidiaState();
}

class _DialogoAjusteMidiaState extends State<DialogoAjusteMidia> {
  late AjusteMidia _ajuste = widget.midia.ajuste;
  late FundoMidia _fundo = widget.midia.fundo;
  late AncoraMidia _ancora = widget.midia.ancora;
  late int _zoom = widget.midia.zoomPercentual.clamp(zoomMinimo, zoomMaximo);

  bool get _mostraFundo =>
      modoDeixaSobra(_ajuste) &&
      (widget.midia.tipo != TipoMidia.video || fundoBorradoLiberadoParaVideo);

  bool get _mostraCorte => _ajuste == AjusteMidia.preencher;

  /// O id nao muda, entao o player nao reinicia a midia a cada tecla: so
  /// re-renderiza com o enquadramento novo.
  MidiaPropaganda get _midiaPreview => widget.midia.copyWith(
      ajuste: _ajuste, fundo: _fundo, ancora: _ancora, zoomPercentual: _zoom);

  Widget _rotulo(String texto) => Text(texto,
      style: const TextStyle(fontSize: 11.5, color: CoresApp.textoSecundario));

  Widget _gradeAncoras() {
    const linhas = [
      [AncoraMidia.topoEsquerda, AncoraMidia.topo, AncoraMidia.topoDireita],
      [AncoraMidia.esquerda, AncoraMidia.centro, AncoraMidia.direita],
      [AncoraMidia.baseEsquerda, AncoraMidia.base, AncoraMidia.baseDireita],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final linha in linhas)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final ancora in linha)
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Tooltip(
                    message: DialogoAjusteMidia.rotulosAncora[ancora]!,
                    child: InkWell(
                      key: ValueKey('ancora-${ancora.name}'),
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _ancora = ancora),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _ancora == ancora ? CoresApp.lilasClaro : null,
                          border: Border.all(
                            color: _ancora == ancora
                                ? CoresApp.primariaPadrao
                                : CoresApp.bordaCard,
                            width: _ancora == ancora ? 2 : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Ajustar mídia',
          style: TextStyle(fontWeight: FontWeight.w800)),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: 220,
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      // Mesmo player da tela real: o que aparece aqui e o que
                      // o totem vai pintar.
                      child: PlayerPropaganda(
                        midia: _midiaPreview,
                        corFundo: widget.corTema,
                        aoTerminar: () {},
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SeletorAjusteMidia(
                valor: _ajuste,
                aoMudar: (ajuste) => setState(() => _ajuste = ajuste),
              ),
              if (_mostraFundo) ...[
                const SizedBox(height: 10),
                _rotulo('Fundo da sobra'),
                const SizedBox(height: 6),
                SegmentedButton<FundoMidia>(
                  segments: const [
                    ButtonSegment(
                        value: FundoMidia.borrado, label: Text('Borrado')),
                    ButtonSegment(
                        value: FundoMidia.cor, label: Text('Cor do tema')),
                  ],
                  selected: {_fundo},
                  onSelectionChanged: (selecao) =>
                      setState(() => _fundo = selecao.single),
                ),
              ],
              if (_mostraCorte) ...[
                const SizedBox(height: 10),
                _rotulo('Corte a partir de'),
                const SizedBox(height: 6),
                Center(child: _gradeAncoras()),
                const SizedBox(height: 10),
                _rotulo('Zoom: $_zoom%'),
                Slider(
                  value: _zoom.toDouble(),
                  min: zoomMinimo.toDouble(),
                  max: zoomMaximo.toDouble(),
                  divisions: (zoomMaximo - zoomMinimo) ~/ 5,
                  label: '$_zoom%',
                  onChanged: (valor) => setState(() => _zoom = valor.round()),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            widget.aoSalvar(
                ajuste: _ajuste,
                fundo: _fundo,
                ancora: _ancora,
                zoomPercentual: _zoom);
            Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
