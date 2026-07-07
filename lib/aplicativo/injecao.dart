import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../funcionalidades/configuracoes/dados/repositorios/repositorio_configuracao_impl.dart';
import '../funcionalidades/configuracoes/dados/repositorios/repositorio_credencial_impl.dart';
import '../funcionalidades/configuracoes/dados/repositorios/repositorio_tema_impl.dart';
import '../funcionalidades/configuracoes/dominio/entidades/tema_personalizado.dart';
import '../funcionalidades/configuracoes/dominio/repositorios/repositorio_configuracao.dart';
import '../funcionalidades/configuracoes/dominio/repositorios/repositorio_credencial.dart';
import '../funcionalidades/configuracoes/dominio/repositorios/repositorio_tema.dart';
import '../nucleo/constantes/constantes_app.dart';
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
