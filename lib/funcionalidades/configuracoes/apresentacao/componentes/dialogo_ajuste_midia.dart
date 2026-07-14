import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../dominio/entidades/tema_personalizado.dart';
import '../../../propaganda/apresentacao/ajuste_tela.dart';
import '../../../propaganda/apresentacao/componentes/player_propaganda.dart';
import '../../../propaganda/dominio/entidades/midia_propaganda.dart';
import 'seletor_ajuste_midia.dart';

/// Resumo curto do enquadramento, exibido no card da midia.
String resumoEnquadramento(MidiaPropaganda midia) {
  final base = _resumoBase(midia);
  final rotacao = resolverQuartosDeVolta(midia.rotacaoGraus) * 90;
  return rotacao == 0 ? base : '$base · girada $rotacao°';
}

String _resumoBase(MidiaPropaganda midia) {
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
      var resultado = '$modo · $ancora · $zoom%';
      if (zoom < 100) {
        final fundo = fundoEfetivo(tipo: midia.tipo, fundo: midia.fundo);
        final rotuloFundo =
            fundo == FundoMidia.borrado ? 'borrado' : 'na cor do tema';
        resultado += ' · fundo $rotuloFundo';
      }
      return resultado;
    case AjusteMidia.esticar:
      return modo;
  }
}

class DialogoAjusteMidia extends StatefulWidget {
  const DialogoAjusteMidia({
    super.key,
    required this.midia,
    required this.corTema,
    required this.orientacao,
    required this.aoSalvar,
  });

  final MidiaPropaganda midia;

  /// Cor primaria do tema da loja: o preview pinta o mesmo fundo do totem.
  final Color corTema;

  /// Orientacao da tela do totem: o preview simula esta razao de aspecto.
  final OrientacaoTela orientacao;

  final void Function({
    required AjusteMidia ajuste,
    required FundoMidia fundo,
    required AncoraMidia ancora,
    required int zoomPercentual,
    required int rotacaoGraus,
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
  // Normalizado ja na entrada: estado local so conhece 0/90/180/270.
  late int _rotacao = resolverQuartosDeVolta(widget.midia.rotacaoGraus) * 90;

  bool get _mostraFundo =>
      modoDeixaSobra(_ajuste, _zoom) &&
      (widget.midia.tipo != TipoMidia.video || fundoBorradoLiberadoParaVideo);

  bool get _mostraCorte => _ajuste == AjusteMidia.preencher;

  /// O id nao muda, entao o player nao reinicia a midia a cada tecla: so
  /// re-renderiza com o enquadramento novo.
  MidiaPropaganda get _midiaPreview => widget.midia.copyWith(
      ajuste: _ajuste,
      fundo: _fundo,
      ancora: _ancora,
      zoomPercentual: _zoom,
      rotacaoGraus: _rotacao);

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
                          color: _ancora == ancora
                              ? widget.corTema.withValues(alpha: .18)
                              : null,
                          border: Border.all(
                            color: _ancora == ancora
                                ? widget.corTema
                                : widget.corTema.withValues(alpha: .45),
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
                  width: widget.orientacao == OrientacaoTela.horizontal
                      ? 300
                      : null,
                  height: widget.orientacao == OrientacaoTela.horizontal
                      ? null
                      : 220,
                  child: AspectRatio(
                    aspectRatio: widget.orientacao == OrientacaoTela.horizontal
                        ? 16 / 9
                        : 9 / 16,
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
              const SizedBox(height: 4),
              Row(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact),
                    onPressed: () =>
                        setState(() => _rotacao = (_rotacao + 90) % 360),
                    icon: const Icon(Icons.rotate_90_degrees_cw, size: 16),
                    label: const Text('Girar 90°',
                        style: TextStyle(fontSize: 11.5)),
                  ),
                  if (_rotacao != 0) ...[
                    const SizedBox(width: 4),
                    _rotulo('Girada: $_rotacao°'),
                  ],
                ],
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
                zoomPercentual: _zoom,
                rotacaoGraus: _rotacao);
            Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
