import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../nucleo/utils/cor_hex.dart';

/// Cores rápidas oferecidas dentro do seletor. São as mesmas amostras que
/// antes se repetiam abaixo de cada campo da aba Aparência.
const List<String> coresRapidas = [
  '#5E52D6',
  '#7367F0',
  '#FFD166',
  '#F7F7FB',
  '#2F2B3D',
  '#2E7D32',
  '#D32F2F',
  '#1565C0',
];

/// Abre o seletor visual de cores. Devolve o hexadecimal confirmado ou null
/// no cancelamento. [aoAlterar] é chamado a cada ajuste para a
/// pré-visualização refletir a cor em tempo real; quem chama decide o que
/// fazer quando o diálogo é cancelado (normalmente restaurar o valor
/// anterior).
Future<String?> mostrarDialogoSeletorCor(
  BuildContext context, {
  required String corInicial,
  void Function(String hex)? aoAlterar,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) =>
        _DialogoSeletorCor(corInicial: corInicial, aoAlterar: aoAlterar),
  );
}

class _DialogoSeletorCor extends StatefulWidget {
  const _DialogoSeletorCor({required this.corInicial, this.aoAlterar});

  final String corInicial;
  final void Function(String hex)? aoAlterar;

  @override
  State<_DialogoSeletorCor> createState() => _DialogoSeletorCorState();
}

class _DialogoSeletorCorState extends State<_DialogoSeletorCor> {
  late HSLColor _cor = HSLColor.fromColor(
      TemaConstel.corDeHex(widget.corInicial, CoresApp.primariaPadrao));
  late final TextEditingController _hex =
      TextEditingController(text: TemaConstel.hexDeCor(_cor.toColor()));

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  String get _hexAtual => TemaConstel.hexDeCor(_cor.toColor());

  void _definir(HSLColor cor, {bool sincronizarCampo = true}) {
    setState(() => _cor = cor);
    if (sincronizarCampo) _hex.text = _hexAtual;
    widget.aoAlterar?.call(_hexAtual);
  }

  Widget _controle(String rotulo, double valor, double maximo,
      ValueChanged<double> aoMudar) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(rotulo,
              style: const TextStyle(
                  fontSize: 12, color: CoresApp.textoSecundario)),
        ),
        Expanded(
          child: Slider(value: valor, max: maximo, onChanged: aoMudar),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Escolher cor',
          style: TextStyle(fontWeight: FontWeight.w800)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _cor.toColor(),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: CoresApp.bordaCard, width: 2),
              ),
            ),
            const SizedBox(height: 12),
            _controle('Matiz', _cor.hue, 360, (v) => _definir(_cor.withHue(v))),
            _controle('Saturação', _cor.saturation, 1,
                (v) => _definir(_cor.withSaturation(v))),
            _controle('Luminosidade', _cor.lightness, 1,
                (v) => _definir(_cor.withLightness(v))),
            const SizedBox(height: 8),
            const Text('Hexadecimal',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _hex,
              decoration: const InputDecoration(
                isDense: true,
                hintText: '#RRGGBB',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (valor) {
                final normalizado = normalizarCorHex(valor);
                if (normalizado == null) return;
                _definir(
                  HSLColor.fromColor(
                      TemaConstel.corDeHex(normalizado, _cor.toColor())),
                  sincronizarCampo: false,
                );
              },
            ),
            const SizedBox(height: 14),
            const Text('Cores rápidas',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final hex in coresRapidas)
                  InkWell(
                    key: Key('cor_rapida_$hex'),
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _definir(HSLColor.fromColor(
                        TemaConstel.corDeHex(hex, Colors.grey))),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: TemaConstel.corDeHex(hex, Colors.grey),
                        shape: BoxShape.circle,
                        border: Border.all(color: CoresApp.bordaCard),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_hexAtual),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
