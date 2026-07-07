import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../compartilhado/widgets/detector_inatividade.dart';
import '../funcionalidades/chat/apresentacao/paginas/pagina_chat.dart';
import '../funcionalidades/configuracoes/apresentacao/paginas/pagina_configuracoes.dart';
import '../funcionalidades/configuracoes/apresentacao/paginas/pagina_pin.dart';
import '../funcionalidades/propaganda/apresentacao/paginas/pagina_propaganda.dart';
import '../funcionalidades/splash/apresentacao/paginas/pagina_splash.dart';

/// Terminal de autoatendimento: navegação deve ser instantânea, sem
/// transições de página que atrasem a resposta ao toque do operador.
Page<void> _pagina(Widget filho) => NoTransitionPage(child: filho);

GoRouter criarRoteador({required String localInicial}) => GoRouter(
      initialLocation: localInicial,
      routes: [
        GoRoute(path: '/', redirect: (_, __) => '/splash'),
        GoRoute(
          path: '/splash',
          pageBuilder: (_, __) => _pagina(const PaginaSplash()),
        ),
        GoRoute(
          path: '/propaganda',
          pageBuilder: (_, __) => _pagina(const PaginaPropaganda()),
        ),
        GoRoute(
          path: '/chat',
          pageBuilder: (_, __) =>
              _pagina(const DetectorInatividade(filho: PaginaChat())),
        ),
        GoRoute(
          path: '/pin',
          pageBuilder: (_, estado) => _pagina(
              PaginaPin(destino: estado.uri.queryParameters['destino'])),
        ),
        GoRoute(
          path: '/configuracoes',
          pageBuilder: (_, __) => _pagina(const PaginaConfiguracoes()),
        ),
      ],
    );
