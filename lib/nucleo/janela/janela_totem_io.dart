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

/// Liga/desliga o "sempre no topo" da janela do totem no Windows. Diálogos
/// nativos do sistema (ex.: seletor de arquivos) não são topmost: com a
/// janela sempre no topo eles abrem ATRÁS do app, que fica bloqueado pelo
/// modal invisível. Suspender o topo enquanto o diálogo está aberto deixa
/// ele vir para a frente; ao religar, o foco volta para o app.
Future<void> definirSempreNoTopoWindows(bool ativo) async {
  await windowManager.setAlwaysOnTop(ativo);
  if (ativo) {
    await windowManager.focus();
  }
}
