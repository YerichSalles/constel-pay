import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'janela_totem_stub.dart' if (dart.library.io) 'janela_totem_io.dart';

/// Serviço único responsável pelo comportamento de janela/tela em modo totem
/// (autoatendimento). Concentra aqui toda a configuração específica de
/// plataforma, para não espalhar chamadas de janela pelo app.
///
/// - Windows: tela cheia sem barra de título nem botões, sempre no topo e sem
///   redimensionamento (via `window_manager`, em [configurarJanelaWindowsTotem]).
/// - Android: modo imersivo — esconde a barra de status e a de navegação, o
///   app ocupa a tela inteira.
/// - Demais plataformas (ex.: web): nenhuma ação.
abstract final class ServicoJanelaTotem {
  static bool get _ehWindows =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  static bool get _ehAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Aplica o modo totem. Deve ser chamado no início de `main()`, logo após
  /// `WidgetsFlutterBinding.ensureInitialized()`.
  static Future<void> iniciar() async {
    if (_ehWindows) {
      await configurarJanelaWindowsTotem();
    } else if (_ehAndroid) {
      await _configurarAndroid();
    }
  }

  /// Android: `immersiveSticky` oculta as barras do sistema e as reexibe só
  /// temporariamente quando o usuário desliza a partir da borda, voltando a
  /// escondê-las sozinho — adequado a um terminal de autoatendimento.
  static Future<void> _configurarAndroid() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
}
