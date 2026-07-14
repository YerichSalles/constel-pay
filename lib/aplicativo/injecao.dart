import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../funcionalidades/autenticacao/dados/fontes_dados/fonte_autenticacao_nuvem.dart';
import '../funcionalidades/autenticacao/dados/interceptadores/interceptador_autenticacao_nuvem.dart';
import '../funcionalidades/autenticacao/dados/repositorios/repositorio_sessao_nuvem_impl.dart';
import '../funcionalidades/autenticacao/dominio/casos_uso/caso_uso_garantir_sessao.dart';
import '../funcionalidades/autenticacao/dominio/casos_uso/caso_uso_login_nuvem.dart';
import '../funcionalidades/autenticacao/dominio/entidades/sessao_nuvem.dart';
import '../funcionalidades/autenticacao/dominio/repositorios/repositorio_sessao_nuvem.dart';
import '../funcionalidades/leitura_cartao/dados/fontes_dados/fonte_consumo_atendimento.dart';
import '../funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import '../funcionalidades/leitura_cartao/dados/fontes_dados/fonte_recurso_item.dart';
import '../funcionalidades/leitura_cartao/dados/repositorios/repositorio_leitura_impl.dart';
import '../funcionalidades/leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart';
import '../funcionalidades/leitura_cartao/dominio/repositorios/repositorio_leitura.dart';
import '../funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import '../funcionalidades/pagamento/dados/repositorios/repositorio_pagamento_impl.dart';
import '../funcionalidades/pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart';
import '../funcionalidades/pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart';
import '../funcionalidades/pagamento/dominio/casos_uso/caso_uso_verificar_pagamento.dart';
import '../funcionalidades/pagamento/dominio/repositorios/repositorio_pagamento.dart';
import '../funcionalidades/encerramento/dados/fontes_dados/fonte_encerramento_atendimento.dart';
import '../funcionalidades/encerramento/dados/fontes_dados/fonte_fatura.dart';
import '../funcionalidades/encerramento/dados/repositorios/repositorio_configuracao_faturamento_impl.dart';
import '../funcionalidades/encerramento/dados/repositorios/repositorio_transacoes_pendentes_impl.dart';
import '../funcionalidades/encerramento/dominio/casos_uso/caso_uso_encerrar_atendimentos.dart';
import '../funcionalidades/encerramento/dominio/repositorios/repositorio_configuracao_faturamento.dart';
import '../funcionalidades/encerramento/dominio/repositorios/repositorio_transacoes_pendentes.dart';
import '../funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import '../funcionalidades/configuracoes/dados/repositorios/repositorio_credencial_impl.dart';
import '../funcionalidades/configuracoes/dados/repositorios/repositorio_tema_impl.dart';
import '../funcionalidades/configuracoes/dominio/casos_uso/caso_uso_testar_conexao.dart';
import '../funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import '../funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import '../funcionalidades/configuracoes/dominio/repositorios/repositorio_credencial.dart';
import '../funcionalidades/configuracoes/dominio/repositorios/repositorio_tema.dart';
import '../funcionalidades/propaganda/dados/repositorios/repositorio_propaganda_impl.dart';
import '../funcionalidades/propaganda/dados/repositorios/repositorio_publicidade_impl.dart';
import '../funcionalidades/propaganda/dominio/repositorios/repositorio_propaganda.dart';
import '../funcionalidades/propaganda/dominio/repositorios/repositorio_publicidade.dart';
import '../nucleo/configuracao/cliente_api.dart';
import '../nucleo/constantes/constantes_app.dart';
import '../nucleo/dispositivo/info_aplicativo.dart';
import '../nucleo/erros/resultado.dart';
import 'idioma/controlador_idioma.dart';
import 'tema/controlador_tema.dart';

final provedorSharedPreferences = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Sobrescrito no main.dart'),
);

final provedorAtrasoBot =
    Provider<Duration>((ref) => ConstantesApp.atrasoBotPadrao);

final provedorRepositorioConfiguracao = Provider<RepositorioConfiguracao>(
  (ref) => RepositorioConfiguracaoImpl(ref.watch(provedorSharedPreferences)),
);

final provedorRepositorioTema = Provider<RepositorioTema>(
  (ref) => RepositorioTemaImpl(ref.watch(provedorSharedPreferences)),
);

final provedorTema = StateNotifierProvider<ControladorTema, TemaPersonalizado>(
  (ref) => ControladorTema(ref.watch(provedorRepositorioTema)),
);

// Idioma do atendimento atual — sem persistência, volta a pt-BR a cada novo
// atendimento (reset nos mesmos pontos que disparam `novaOperacao()`).
final provedorIdioma = StateNotifierProvider<ControladorIdioma, Locale>(
  (ref) => ControladorIdioma(),
);

final provedorArmazenamentoSeguro = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final provedorRepositorioCredencial = Provider<RepositorioCredencial>(
  (ref) => RepositorioCredencialImpl(ref.watch(provedorArmazenamentoSeguro)),
);

final provedorRepositorioPropaganda = Provider<RepositorioPropaganda>(
  (ref) => RepositorioPropagandaImpl(ref.watch(provedorSharedPreferences)),
);

final provedorRepositorioPublicidade = Provider<RepositorioPublicidade>(
  (ref) => RepositorioPublicidadeImpl(ref.watch(provedorSharedPreferences)),
);

// Cliente da API local (consumo do cartão) — usa a URL base do ambiente ativo.
final provedorClienteApi = Provider<ClienteApi>(
  (ref) => ClienteApi(
      repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao)),
);

// Repositório da sessão de nuvem (token + dados do login) no secure storage.
final provedorRepositorioSessaoNuvem = Provider<RepositorioSessaoNuvem>(
  (ref) => RepositorioSessaoNuvemImpl(ref.watch(provedorArmazenamentoSeguro)),
);

// Cliente da API na nuvem para LOGIN — SEM o interceptor de autenticação.
// O login é isento de token e de retry; usar um Dio separado evita o
// deadlock de re-login no QueuedInterceptor (mesma fila de erro).
final provedorClienteApiNuvemLogin = Provider<ClienteApi>(
  (ref) => ClienteApi(
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    seletorBase: (configuracao) => configuracao.urlNuvemAtiva,
  ),
);

// Cliente da API na nuvem para REQUISIÇÕES AUTENTICADAS (envio de vendas) —
// usa a URL de nuvem do ambiente ativo, injeta o token da sessão e faz
// re-login automático no 401. O re-login roda no cliente de login separado
// (provedorClienteApiNuvemLogin), nunca neste mesmo Dio.
final provedorClienteApiNuvem = Provider((ref) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptadorAutenticacaoNuvem(
      dio: dio,
      caminhoLogin: ConstantesApp.caminhoLoginNuvem,
      tokenAtual: () async =>
          (await ref.read(provedorRepositorioSessaoNuvem).obter())?.token,
      renovarSessao: () async {
        final resultado = await ref.read(provedorCasoUsoLoginNuvem).executar();
        return resultado is Sucesso<SessaoNuvem>;
      },
    ),
  );
  return ClienteApi(
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    seletorBase: (configuracao) => configuracao.urlNuvemAtiva,
    dio: dio,
  );
});

final provedorFonteAutenticacaoNuvem = Provider<FonteAutenticacaoNuvem>(
  (ref) => FonteAutenticacaoNuvem(ref.watch(provedorClienteApiNuvemLogin)),
);

final provedorCasoUsoLoginNuvem = Provider<CasoUsoLoginNuvem>(
  (ref) => CasoUsoLoginNuvem(
    fonte: ref.watch(provedorFonteAutenticacaoNuvem),
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    repositorioCredencial: ref.watch(provedorRepositorioCredencial),
    repositorioSessao: ref.watch(provedorRepositorioSessaoNuvem),
    infoAplicativo: ref.watch(provedorInfoAplicativo),
  ),
);

final provedorCasoUsoGarantirSessao = Provider<CasoUsoGarantirSessao>(
  (ref) => CasoUsoGarantirSessao(
    repositorioSessao: ref.watch(provedorRepositorioSessaoNuvem),
    casoUsoLogin: ref.watch(provedorCasoUsoLoginNuvem),
  ),
);

final provedorInfoAplicativo = Provider<InfoAplicativo>(
  (ref) => InfoAplicativoImpl(),
);

final provedorCasoUsoTestarConexao = Provider<CasoUsoTestarConexao>(
  (ref) => CasoUsoTestarConexao(
    clienteLoja: ref.watch(provedorClienteApi),
    clienteNuvem: ref.watch(provedorClienteApiNuvemLogin),
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    preferencias: ref.watch(provedorSharedPreferences),
  ),
);

// ---------------------------------------------------------------------------
// API da LOJA (APL local, ex.: https://<host>:3001/api/) — consumo do cartão.
// Servidor distinto da nuvem: exige login próprio e guarda a sessão em chave
// separada, porque o JWT só vale no servidor que o emitiu.
// ---------------------------------------------------------------------------

final provedorRepositorioSessaoLoja = Provider<RepositorioSessaoNuvem>(
  (ref) => RepositorioSessaoNuvemImpl(ref.watch(provedorArmazenamentoSeguro),
      chave: 'sessao_loja'),
);

// Cliente da loja para LOGIN — sem interceptor (mesmo motivo do da nuvem).
final provedorClienteApiLojaLogin = Provider<ClienteApi>(
  (ref) => ClienteApi(
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    seletorBase: (configuracao) => configuracao.urlBaseAtiva,
  ),
);

final provedorFonteAutenticacaoLoja = Provider<FonteAutenticacaoNuvem>(
  (ref) => FonteAutenticacaoNuvem(ref.watch(provedorClienteApiLojaLogin)),
);

final provedorCasoUsoLoginLoja = Provider<CasoUsoLoginNuvem>(
  (ref) => CasoUsoLoginNuvem(
    fonte: ref.watch(provedorFonteAutenticacaoLoja),
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    repositorioCredencial: ref.watch(provedorRepositorioCredencial),
    repositorioSessao: ref.watch(provedorRepositorioSessaoLoja),
    infoAplicativo: ref.watch(provedorInfoAplicativo),
    seletorBase: (configuracao) => configuracao.urlBaseAtiva,
    urlAusenteMensagem: 'Configure a URL da API local nas configurações.',
  ),
);

// Cliente da loja para REQUISIÇÕES AUTENTICADAS (consumo): injeta o token da
// sessão da loja e faz re-login automático no 401.
final provedorClienteApiLoja = Provider<ClienteApi>((ref) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptadorAutenticacaoNuvem(
      dio: dio,
      caminhoLogin: ConstantesApp.caminhoLoginNuvem,
      tokenAtual: () async =>
          (await ref.read(provedorRepositorioSessaoLoja).obter())?.token,
      renovarSessao: () async {
        final resultado = await ref.read(provedorCasoUsoLoginLoja).executar();
        return resultado is Sucesso<SessaoNuvem>;
      },
    ),
  );
  return ClienteApi(
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    seletorBase: (configuracao) => configuracao.urlBaseAtiva,
    dio: dio,
  );
});

// Fonte real de consumo: sempre na API da loja (urlBaseAtiva), nunca na nuvem.
final provedorFonteConsumoAtendimento = Provider<FonteConsumoAtendimento>(
  (ref) => FonteConsumoAtendimento(ref.watch(provedorClienteApiLoja)),
);

// Foto do item: mesma API da loja, com cache em memória por item.
final provedorFonteRecursoItem = Provider<FonteRecursoItem>(
  (ref) => FonteRecursoItemApi(ref.watch(provedorClienteApiLoja)),
);

final provedorFonteLeituraMock = Provider<FonteLeituraMock>(
  (ref) => FonteLeituraMock(),
);

final provedorRepositorioLeitura = Provider<RepositorioLeitura>(
  (ref) => RepositorioLeituraImpl(ref.watch(provedorFonteLeituraMock)),
);

final provedorCasoUsoLerCartao = Provider<CasoUsoLerCartao>(
  (ref) => CasoUsoLerCartao(ref.watch(provedorRepositorioLeitura)),
);

final provedorFontePagamentoMock = Provider<FontePagamentoMock>(
  (ref) => FontePagamentoMock(),
);

final provedorRepositorioPagamento = Provider<RepositorioPagamento>(
  (ref) => RepositorioPagamentoImpl(ref.watch(provedorFontePagamentoMock)),
);

final provedorCasoUsoGerarPix = Provider<CasoUsoGerarPix>(
  (ref) => CasoUsoGerarPix(ref.watch(provedorRepositorioPagamento)),
);

final provedorCasoUsoProcessarPagamento = Provider<CasoUsoProcessarPagamento>(
  (ref) => CasoUsoProcessarPagamento(ref.watch(provedorRepositorioPagamento)),
);

final provedorCasoUsoVerificarPagamento = Provider<CasoUsoVerificarPagamento>(
  (ref) => CasoUsoVerificarPagamento(ref.watch(provedorRepositorioPagamento)),
);

// ---------------------------------------------------------------------------
// Encerramento financeiro da comanda: ação 10 e 30 na API da LOJA, fatura na
// API da NUVEM. O caso de uso é ÚNICO no app (Provider raiz) — a trava contra
// encerramentos simultâneos depende dessa instância compartilhada.
// ---------------------------------------------------------------------------

final provedorRepositorioTransacoesPendentes =
    Provider<RepositorioTransacoesPendentes>(
  (ref) =>
      RepositorioTransacoesPendentesImpl(ref.watch(provedorSharedPreferences)),
);

final provedorRepositorioConfiguracaoFaturamento =
    Provider<RepositorioConfiguracaoFaturamento>(
  (ref) => RepositorioConfiguracaoFaturamentoImpl(
      ref.watch(provedorSharedPreferences)),
);

final provedorFonteEncerramentoAtendimento =
    Provider<FonteEncerramentoAtendimento>(
  (ref) => FonteEncerramentoAtendimento(ref.watch(provedorClienteApiLoja)),
);

// Fatura sempre na nuvem (contrato observado no caixa: movimento/fatura em
// sirius), pelo cliente autenticado com re-login no 401.
final provedorFonteFatura = Provider<FonteFatura>(
  (ref) => FonteFatura(ref.watch(provedorClienteApiNuvem)),
);

final provedorCasoUsoEncerrarAtendimentos =
    Provider<CasoUsoEncerrarAtendimentos>(
  (ref) => CasoUsoEncerrarAtendimentos(
    fonteEncerramento: ref.watch(provedorFonteEncerramentoAtendimento),
    fonteFatura: ref.watch(provedorFonteFatura),
    repositorioPendentes: ref.watch(provedorRepositorioTransacoesPendentes),
    repositorioConfiguracao:
        ref.watch(provedorRepositorioConfiguracaoFaturamento),
    fonteConsumo: ref.watch(provedorFonteConsumoAtendimento),
  ),
);
