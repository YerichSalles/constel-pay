import 'package:window_manager/window_manager.dart';

/// Configura a janela nativa do Windows para operação em totem, via
/// `window_manager`. Só é efetivamente chamada no Windows (o dispatch por
/// plataforma fica em [ServicoJanelaTotem]); em outros alvos io (ex.: Android)
/// o plugin não é chamado.
///
/// Windows: a janela abre em tela cheia, sem barra de título nem botões de
/// minimizar/maximizar/fechar, sempre acima das demais e sem redimensionamento.
/// O `waitUntilReadyToShow` mantém a janela oculta até a configuração terminar,
/// evitando o "flash" de aparecer primeiro em tamanho normal.
Future<void> configurarJanelaWindowsTotem() async {
  await windowManager.ensureInitialized();

  const opcoes = WindowOptions(
    fullScreen: true,
    // Sem barra de título (e, no Windows, sem os botões que moram nela).
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );

  await windowManager.waitUntilReadyToShow(opcoes, () async {
    await windowManager.setResizable(false);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setFullScreen(true);
    await windowManager.show();
    await windowManager.focus();
  });
}
