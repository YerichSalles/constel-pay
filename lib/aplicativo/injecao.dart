import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../funcionalidades/leitura_cartao/dados/fontes_dados/fonte_leitura_mock.dart';
import '../funcionalidades/leitura_cartao/dados/repositorios/repositorio_leitura_impl.dart';
import '../funcionalidades/leitura_cartao/dominio/casos_uso/caso_uso_ler_cartao.dart';
import '../funcionalidades/leitura_cartao/dominio/repositorios/repositorio_leitura.dart';
import '../funcionalidades/pagamento/dados/fontes_dados/fonte_pagamento_mock.dart';
import '../funcionalidades/pagamento/dados/repositorios/repositorio_pagamento_impl.dart';
import '../funcionalidades/pagamento/dominio/casos_uso/caso_uso_gerar_pix.dart';
import '../funcionalidades/pagamento/dominio/casos_uso/caso_uso_processar_pagamento.dart';
import '../funcionalidades/pagamento/dominio/casos_uso/caso_uso_verificar_pagamento.dart';
import '../funcionalidades/pagamento/dominio/repositorios/repositorio_pagamento.dart';
import '../funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import '../funcionalidades/configuracoes/dados/repositorios/repositorio_credencial_impl.dart';
import '../funcionalidades/configuracoes/dados/repositorios/repositorio_tema_impl.dart';
import '../funcionalidades/configuracoes/dominio/casos_uso/caso_uso_testar_conexao.dart';
import '../funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import '../funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import '../funcionalidades/configuracoes/dominio/repositorios/repositorio_credencial.dart';
import '../funcionalidades/configuracoes/dominio/repositorios/repositorio_tema.dart';
import '../funcionalidades/propaganda/dados/repositorios/repositorio_propaganda_impl.dart';
import '../funcionalidades/propaganda/dominio/repositorios/repositorio_propaganda.dart';
import '../nucleo/configuracao/cliente_api.dart';
import '../nucleo/constantes/constantes_app.dart';
import '../nucleo/dispositivo/info_aplicativo.dart';
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

final provedorArmazenamentoSeguro = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final provedorRepositorioCredencial = Provider<RepositorioCredencial>(
  (ref) => RepositorioCredencialImpl(ref.watch(provedorArmazenamentoSeguro)),
);

final provedorRepositorioPropaganda = Provider<RepositorioPropaganda>(
  (ref) => RepositorioPropagandaImpl(ref.watch(provedorSharedPreferences)),
);

// Cliente da API local (consumo do cartão) — usa a URL base do ambiente ativo.
final provedorClienteApi = Provider<ClienteApi>(
  (ref) => ClienteApi(
      repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao)),
);

// Cliente da API na nuvem (login) — usa a URL de nuvem do ambiente ativo.
final provedorClienteApiNuvem = Provider<ClienteApi>(
  (ref) => ClienteApi(
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    seletorBase: (configuracao) => configuracao.urlNuvemAtiva,
  ),
);

final provedorInfoAplicativo = Provider<InfoAplicativo>(
  (ref) => InfoAplicativoImpl(),
);

final provedorCasoUsoTestarConexao = Provider<CasoUsoTestarConexao>(
  (ref) => CasoUsoTestarConexao(
    clienteApi: ref.watch(provedorClienteApi),
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    preferencias: ref.watch(provedorSharedPreferences),
  ),
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
