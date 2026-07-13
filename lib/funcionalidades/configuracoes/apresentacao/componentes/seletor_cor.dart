import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/tema_constel.dart';

class SeletorCor extends StatefulWidget {
  const SeletorCor({
    super.key,
    required this.rotulo,
    required this.valorHex,
    required this.aoMudar,
  });

  final String rotulo;
  final String valorHex;
  final void Function(String hex) aoMudar;

  static const List<String> amostras = [
    '#5E52D6',
    '#7367F0',
    '#FFD166',
    '#F7F7FB',
    '#2F2B3D',
    '#2E7D32',
    '#D32F2F',
    '#1565C0',
  ];

  @override
  State<SeletorCor> createState() => _SeletorCorState();
}

class _SeletorCorState extends State<SeletorCor> {
  late final TextEditingController _campo =
      TextEditingController(text: widget.valorHex);

  @override
  void didUpdateWidget(covariant SeletorCor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // So ressincroniza quando o valor mudou de fora (ex.: a faixa herdando a
    // cor principal). Se o texto ja bate, nao mexe: sobrescrever aqui no meio
    // da digitacao do proprio usuario neste campo atropelaria o cursor.
    if (widget.valorHex != _campo.text) {
      _campo.text = widget.valorHex;
    }
  }

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  void _selecionar(String hex) {
    _campo.text = hex;
    widget.aoMudar(hex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final corAtual = TemaConstel.corDeHex(_campo.text, CoresApp.primariaPadrao);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.rotulo,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: corAtual,
                shape: BoxShape.circle,
                border: Border.all(color: CoresApp.bordaCard, width: 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _campo,
                decoration: const InputDecoration(hintText: '#RRGGBB'),
                onChanged: (valor) {
                  widget.aoMudar(valor);
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: SeletorCor.amostras
              .map(
                (hex) => GestureDetector(
                  onTap: () => _selecionar(hex),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: TemaConstel.corDeHex(hex, Colors.grey),
                      shape: BoxShape.circle,
                      border: Border.all(color: CoresApp.bordaCard),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
