import 'package:flutter/material.dart';

import '../../../../aplicativo/tema/cores_app.dart';
import '../../../../aplicativo/tema/tema_constel.dart';
import '../../../../nucleo/utils/cor_hex.dart';
import 'dialogo_seletor_cor.dart';

/// Linha compacta de edição de uma cor do tema: rótulo, amostra, campo
/// hexadecimal e acesso ao seletor visual. Só propaga valores válidos;
/// hex sem `#` ou em minúsculas é normalizado para `#RRGGBB`.
class CampoCor extends StatefulWidget {
  const CampoCor({
    super.key,
    required this.rotulo,
    required this.valorHex,
    required this.aoMudar,
  });

  final String rotulo;
  final String valorHex;
  final void Function(String hex) aoMudar;

  @override
  State<CampoCor> createState() => _CampoCorState();
}

class _CampoCorState extends State<CampoCor> {
  late final TextEditingController _campo =
      TextEditingController(text: widget.valorHex);
  String? _ultimoEmitido;
  bool _invalido = false;

  @override
  void didUpdateWidget(covariant CampoCor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ressincroniza apenas quando o valor mudou de fora (ex.: a faixa
    // herdando a cor principal). Se veio da própria digitação neste campo,
    // sobrescrever o texto atropelaria o cursor do usuário.
    if (widget.valorHex != _campo.text && widget.valorHex != _ultimoEmitido) {
      _campo.text = widget.valorHex;
      _invalido = false;
    }
  }

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  void _aoDigitar(String valor) {
    final normalizado = normalizarCorHex(valor);
    setState(() => _invalido = valor.trim().isNotEmpty && normalizado == null);
    if (normalizado != null) {
      _ultimoEmitido = normalizado;
      widget.aoMudar(normalizado);
    }
  }

  void _formatarCampo() {
    final normalizado = normalizarCorHex(_campo.text);
    if (normalizado != null && normalizado != _campo.text) {
      _campo.text = normalizado;
    }
  }

  Future<void> _abrirSeletor() async {
    final anterior = widget.valorHex;
    final escolhido = await mostrarDialogoSeletorCor(
      context,
      corInicial: anterior,
      aoAlterar: (hex) {
        _ultimoEmitido = hex;
        widget.aoMudar(hex);
      },
    );
    final definitivo = escolhido ?? anterior;
    _campo.text = definitivo;
    _ultimoEmitido = definitivo;
    widget.aoMudar(definitivo);
    setState(() => _invalido = false);
  }

  @override
  Widget build(BuildContext context) {
    final corAtual = TemaConstel.corDeHex(_campo.text, CoresApp.primariaPadrao);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.rotulo,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Row(
          children: [
            InkWell(
              onTap: _abrirSeletor,
              customBorder: const CircleBorder(),
              child: Tooltip(
                message: 'Abrir seletor de cores',
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: corAtual,
                    shape: BoxShape.circle,
                    border: Border.all(color: CoresApp.bordaCard, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Focus(
                onFocusChange: (focado) {
                  if (!focado) _formatarCampo();
                },
                child: TextFormField(
                  controller: _campo,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '#RRGGBB',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    // Reforça que a cor é selecionável sem atrapalhar a
                    // edição direta do hexadecimal: o texto continua
                    // clicável para posicionar o cursor.
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.palette_outlined,
                          size: 18, color: CoresApp.textoSecundario),
                      tooltip: 'Escolher cor',
                      onPressed: _abrirSeletor,
                    ),
                    errorText: _invalido
                        ? 'Informe uma cor hexadecimal válida.'
                        : null,
                    errorStyle: const TextStyle(fontSize: 11),
                  ),
                  onChanged: _aoDigitar,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
