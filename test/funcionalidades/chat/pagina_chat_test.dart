import 'package:constel_pay/aplicativo/injecao.dart';
import 'package:constel_pay/funcionalidades/chat/apresentacao/paginas/pagina_chat.dart';
import 'package:constel_pay/funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import 'package:constel_pay/funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import 'package:constel_pay/funcionalidades/propaganda/apresentacao/componentes/publicidade_barra_superior.dart';
import 'package:constel_pay/funcionalidades/propaganda/dados/repositorios/repositorio_publicidade_impl.dart';
import 'package:constel_pay/funcionalidades/propaganda/dominio/entidades/publicidade_barra.dart';
import 'package:constel_pay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _publicidadeLetreiroExibivel = PublicidadeBarra(
  ativa: true,
  formato: FormatoPublicidade.letreiro,
  mensagens: [
    MensagemLetreiro(id: 'm1', texto: 'Promoção especial hoje', ordem: 1),
  ],
);

void main() {
  testWidgets(
      'fluxo completo no chat: leitura -> pix -> sucesso -> comprovante',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final roteador = GoRouter(
      initialLocation: '/chat',
      routes: [
        GoRoute(path: '/chat', builder: (_, __) => const PaginaChat()),
        GoRoute(
            path: '/splash',
            builder: (_, __) => const Scaffold(body: Text('SPLASH'))),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provedorSharedPreferences.overrideWithValue(preferencias),
          provedorAtrasoBot.overrideWithValue(Duration.zero),
          provedorFonteLeituraMock
              .overrideWithValue(FonteLeituraMock(atraso: Duration.zero)),
          provedorFontePagamentoMock
              .overrideWithValue(FontePagamentoMock(atraso: Duration.zero)),
        ],
        child: MaterialApp.router(
          routerConfig: roteador,
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    // boas-vindas + scanner
    expect(find.textContaining('cartão de consumo'), findsWidgets);
    expect(find.textContaining('Simular leitura'), findsOneWidget);

    // leitura do primeiro cartao
    await tester.tap(find.textContaining('Simular leitura'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.textContaining('Comanda 01'), findsWidgets);

    // ir para pagamento: a taxa de serviço da API já vem embutida, sem escolha
    await tester.tap(find.textContaining('Continuar para pagamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.textContaining('de serviço'), findsWidgets);
    expect(find.text('Sem taxa'), findsNothing);
    expect(find.text('Pix'), findsOneWidget);

    // escolher pix
    await tester.tap(find.text('Pix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.text('Já fiz o pagamento'), findsOneWidget);

    // confirmar pagamento
    await tester.tap(find.text('Já fiz o pagamento'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('aprovado'), findsWidgets);

    // encerrar
    await tester.ensureVisible(find.text('Encerrar'));
    await tester.tap(find.text('Encerrar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.text('Comprovante de pagamento'), findsOneWidget);
    expect(find.text('Novo pagamento'), findsOneWidget);
  });

  testWidgets('desistir da inclusao adicional preserva a comanda e avanca',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final roteador = GoRouter(
      initialLocation: '/chat',
      routes: [
        GoRoute(path: '/chat', builder: (_, __) => const PaginaChat()),
        GoRoute(
            path: '/splash',
            builder: (_, __) => const Scaffold(body: Text('SPLASH'))),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provedorSharedPreferences.overrideWithValue(preferencias),
          provedorAtrasoBot.overrideWithValue(Duration.zero),
          provedorFonteLeituraMock
              .overrideWithValue(FonteLeituraMock(atraso: Duration.zero)),
          provedorFontePagamentoMock
              .overrideWithValue(FontePagamentoMock(atraso: Duration.zero)),
        ],
        child: MaterialApp.router(
          routerConfig: roteador,
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    // primeira leitura: sem ação de desistência disponível
    expect(find.text('Continuar com os cartões já adicionados'), findsNothing);
    await tester.tap(find.textContaining('Simular leitura'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.text('Adicionar outro cartão'), findsOneWidget);

    // entra na inclusão adicional e desiste
    await tester.tap(find.text('Adicionar outro cartão'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    await tester
        .ensureVisible(find.text('Continuar com os cartões já adicionados'));
    await tester.tap(find.text('Continuar com os cartões já adicionados'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    // comanda preservada e fluxo na escolha de método
    // A ListView acumulou conteúdo suficiente para que "Comanda 01" e "Pix"
    // não caibam simultaneamente na cacheExtent padrão — cada verificação
    // rola até o trecho correspondente antes de checar.
    final rolagem = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.textContaining('Comanda 01'), -300,
        scrollable: rolagem);
    expect(find.textContaining('Comanda 01'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Pix'), 300, scrollable: rolagem);
    expect(find.text('Pix'), findsOneWidget);
  });

  testWidgets(
      'sem publicidade salva/exibivel, o slot de publicidade nao aparece '
      'na barra (nao reserva espaco)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    final roteador = GoRouter(
      initialLocation: '/chat',
      routes: [
        GoRoute(path: '/chat', builder: (_, __) => const PaginaChat()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provedorSharedPreferences.overrideWithValue(preferencias),
          provedorAtrasoBot.overrideWithValue(Duration.zero),
          provedorFonteLeituraMock
              .overrideWithValue(FonteLeituraMock(atraso: Duration.zero)),
          provedorFontePagamentoMock
              .overrideWithValue(FontePagamentoMock(atraso: Duration.zero)),
        ],
        child: MaterialApp.router(
          routerConfig: roteador,
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    expect(find.byType(PublicidadeBarraSuperior), findsNothing);
  });

  testWidgets(
      'com publicidade salva e exibivel, o slot de publicidade aparece '
      'na barra', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = await SharedPreferences.getInstance();
    await RepositorioPublicidadeImpl(preferencias)
        .salvar(_publicidadeLetreiroExibivel);
    final roteador = GoRouter(
      initialLocation: '/chat',
      routes: [
        GoRoute(path: '/chat', builder: (_, __) => const PaginaChat()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provedorSharedPreferences.overrideWithValue(preferencias),
          provedorAtrasoBot.overrideWithValue(Duration.zero),
          provedorFonteLeituraMock
              .overrideWithValue(FonteLeituraMock(atraso: Duration.zero)),
          provedorFontePagamentoMock
              .overrideWithValue(FontePagamentoMock(atraso: Duration.zero)),
        ],
        child: MaterialApp.router(
          routerConfig: roteador,
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    expect(find.byType(PublicidadeBarraSuperior), findsOneWidget);
  });
}
