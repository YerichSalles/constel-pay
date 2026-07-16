import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Captura leituras de leitores de código de barras que operam como teclado
/// (keyboard wedge) — a maioria dos leitores de totem e manuais, USB ou
/// Bluetooth HID, em Android e Windows.
///
/// Distingue o leitor de digitação humana pela cadência: o leitor envia os
/// caracteres em rajada (poucos milissegundos entre teclas) e termina com
/// Enter. Teclas de uma pessoa chegam com intervalos maiores e reiniciam o
/// buffer, então o operador nunca dispara uma leitura sem querer.
///
/// O widget não desenha nada além do [filho]; apenas escuta o teclado enquanto
/// [ativo]. Quando o foco está num campo de texto (ex.: o fallback de digitação
/// manual), ignora os eventos para não duplicar a leitura.
class CapturaLeitorCodigo extends StatefulWidget {
  const CapturaLeitorCodigo({
    super.key,
    required this.aoLer,
    required this.filho,
    this.ativo = true,
    this.intervaloMaximo = const Duration(milliseconds: 100),
    this.tamanhoMinimo = 3,
  });

  /// Chamado com o código completo quando uma leitura válida é reconhecida.
  final ValueChanged<String> aoLer;
  final Widget filho;

  /// Quando falso, ignora o teclado (ex.: fora da fase de leitura).
  final bool ativo;

  /// Intervalo máximo entre teclas para tratá-las como a mesma rajada do
  /// leitor. Acima disso, o buffer reinicia.
  final Duration intervaloMaximo;

  /// Mínimo de caracteres para aceitar como código (evita ruído/Enter solto).
  final int tamanhoMinimo;

  @override
  State<CapturaLeitorCodigo> createState() => _CapturaLeitorCodigoState();
}

class _CapturaLeitorCodigoState extends State<CapturaLeitorCodigo> {
  final FocusNode _foco = FocusNode(debugLabel: 'captura_leitor_codigo');
  final StringBuffer _buffer = StringBuffer();
  DateTime? _ultimaTecla;

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  /// Evita interferir quando o operador está usando um campo de texto (o
  /// fallback manual): nesse caso o próprio campo trata a digitação.
  bool _campoDeTextoFocado() {
    final contexto = FocusManager.instance.primaryFocus?.context;
    if (contexto == null) return false;
    return contexto.widget is EditableText ||
        contexto.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  void _reiniciar() {
    _buffer.clear();
    _ultimaTecla = null;
  }

  KeyEventResult _aoTeclar(FocusNode node, KeyEvent evento) {
    if (!widget.ativo || evento is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (_campoDeTextoFocado()) return KeyEventResult.ignored;

    final tecla = evento.logicalKey;
    if (tecla == LogicalKeyboardKey.enter ||
        tecla == LogicalKeyboardKey.numpadEnter) {
      final codigo = _buffer.toString().trim();
      _reiniciar();
      if (codigo.length >= widget.tamanhoMinimo) {
        widget.aoLer(codigo);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // Só caracteres imprimíveis compõem o código; ignora teclas de controle.
    final caractere = evento.character;
    if (caractere == null ||
        caractere.isEmpty ||
        caractere.codeUnitAt(0) < 0x20) {
      return KeyEventResult.ignored;
    }

    final agora = DateTime.now();
    final anterior = _ultimaTecla;
    if (anterior != null &&
        agora.difference(anterior) > widget.intervaloMaximo) {
      _buffer.clear();
    }
    _buffer.write(caractere);
    _ultimaTecla = agora;
    // Não consome o evento: a UI continua respondendo normalmente às teclas.
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _foco,
      autofocus: true,
      onKeyEvent: _aoTeclar,
      child: widget.filho,
    );
  }
}
