import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../nucleo/configuracao/ambiente.dart';
import '../../../../nucleo/erros/falha.dart';
import '../../../../nucleo/erros/resultado.dart';
import '../../../../nucleo/utils/registrador.dart';
import '../../../../nucleo/utils/url_base.dart';
import '../../../autenticacao/dominio/casos_uso/caso_uso_login_nuvem.dart';
import '../../../autenticacao/dominio/repositorios/repositorio_sessao_nuvem.dart';
import '../../dominio/casos_uso/caso_uso_testar_conexao.dart';
import '../../dominio/entidades/configuracao_terminal.dart';
import '../../dominio/entidades/credencial.dart';
import '../../dominio/repositorios/repositorio_configuracao.dart';
import '../../dominio/repositorios/repositorio_credencial.dart';

part 'controlador_configuracoes.freezed.dart';

/// Resultado conhecido da última verificação de cada API.
enum StatusConexao { desconhecido, verificando, conectado, erro }

@freezed
class EstadoConfiguracoes with _$EstadoConfiguracoes {
  const factory EstadoConfiguracoes({
    @Default(ConfiguracaoTerminal()) ConfiguracaoTerminal configuracao,
    @Default('') String usuario,
    @Default('') String senha,
    // Nome do estabelecimento da sessão de nuvem ativa; vazio sem login.
    @Default('') String nomeEstabelecimento,
    @Default(true) bool carregando,
    @Default(false) bool salvando,
    @Default(false) bool testandoLocal,
    @Default(false) bool testandoNuvem,
    @Default(StatusConexao.desconhecido) StatusConexao statusLocal,
    @Default(StatusConexao.desconhecido) StatusConexao statusNuvem,
    // Tempo de resposta do teste de comunicação, em milissegundos.
    int? latenciaLocalMs,
    int? latenciaNuvemMs,
    // Usuário autenticado no último teste da nuvem; vazio sem login.
    @Default('') String usuarioNuvem,
    DateTime? ultimaVerificacao,
    String? mensagem,
    @Default(false) bool mensagemErro,
  }) = _EstadoConfiguracoes;
}

class ControladorConfiguracoes extends StateNotifier<EstadoConfiguracoes> {
  ControladorConfiguracoes({
    required RepositorioConfiguracao repositorioConfiguracao,
    required RepositorioCredencial repositorioCredencial,
    required RepositorioSessaoNuvem repositorioSessaoNuvem,
    required RepositorioSessaoNuvem repositorioSessaoLoja,
    required CasoUsoTestarConexao casoUsoTestarConexao,
    required CasoUsoLoginNuvem casoUsoLoginNuvem,
    required CasoUsoLoginNuvem casoUsoLoginLoja,
  })  : _repositorioConfiguracao = repositorioConfiguracao,
        _repositorioCredencial = repositorioCredencial,
        _repositorioSessaoNuvem = repositorioSessaoNuvem,
        _repositorioSessaoLoja = repositorioSessaoLoja,
        _casoUsoTestarConexao = casoUsoTestarConexao,
        _casoUsoLoginNuvem = casoUsoLoginNuvem,
        _casoUsoLoginLoja = casoUsoLoginLoja,
        super(const EstadoConfiguracoes());

  final RepositorioConfiguracao _repositorioConfiguracao;
  final RepositorioCredencial _repositorioCredencial;
  final RepositorioSessaoNuvem _repositorioSessaoNuvem;
  final RepositorioSessaoNuvem _repositorioSessaoLoja;
  final CasoUsoTestarConexao _casoUsoTestarConexao;
  final CasoUsoLoginNuvem _casoUsoLoginNuvem;
  final CasoUsoLoginNuvem _casoUsoLoginLoja;

  Future<void> carregar() async {
    final configuracao = await _repositorioConfiguracao.obter();
    final credencial = await _repositorioCredencial.obter();
    final sessao = await _repositorioSessaoNuvem.obter();
    state = state.copyWith(
      configuracao: configuracao,
      usuario: credencial?.usuario ?? '',
      senha: credencial?.senha ?? '',
      nomeEstabelecimento: sessao?.estabelecimento.nome ?? '',
      usuarioNuvem: sessao?.usuario.nome ?? '',
      carregando: false,
    );
  }

  Future<void> salvarConfiguracao(ConfiguracaoTerminal nova) async {
    state = state.copyWith(salvando: true, mensagem: null);
    await _repositorioConfiguracao.salvar(nova);
    state = state.copyWith(
      configuracao: nova,
      salvando: false,
      mensagem: 'Configurações salvas.',
      mensagemErro: false,
    );
  }

  Future<void> salvarComunicacao({
    required String usuario,
    required String senha,
    required Ambiente ambiente,
    required String urlProducao,
    required String urlHomologacao,
    String? urlNuvemProducao,
    String? urlNuvemHomologacao,
    String? identificadorDispositivo,
    String? idDispositivo,
    bool? leituraPorCamera,
  }) async {
    state = state.copyWith(salvando: true, mensagem: null);
    if (usuario.isNotEmpty || senha.isNotEmpty) {
      await _repositorioCredencial
          .salvar(Credencial(usuario: usuario, senha: senha));
    }
    final anterior = state.configuracao;
    final nova = anterior.copyWith(
      ambiente: ambiente,
      identificadorDispositivo:
          identificadorDispositivo?.trim() ?? anterior.identificadorDispositivo,
      idDispositivo: idDispositivo?.trim() ?? anterior.idDispositivo,
      leituraPorCamera: leituraPorCamera ?? anterior.leituraPorCamera,
      urlBaseProducao: comBarraFinal(urlProducao.trim()),
      urlBaseHomologacao: comBarraFinal(urlHomologacao.trim()),
      urlNuvemProducao:
          comBarraFinal(urlNuvemProducao?.trim() ?? anterior.urlNuvemProducao),
      urlNuvemHomologacao: comBarraFinal(
          urlNuvemHomologacao?.trim() ?? anterior.urlNuvemHomologacao),
    );
    await _repositorioConfiguracao.salvar(nova);
    // Sessões e status só perdem a validade quando credencial, ambiente ou
    // URL mudam; salvar o identificador do terminal, por exemplo, não derruba
    // a verificação já feita.
    final conexaoMudou = usuario != state.usuario ||
        senha != state.senha ||
        nova.ambiente != anterior.ambiente ||
        nova.urlBaseProducao != anterior.urlBaseProducao ||
        nova.urlBaseHomologacao != anterior.urlBaseHomologacao ||
        nova.urlNuvemProducao != anterior.urlNuvemProducao ||
        nova.urlNuvemHomologacao != anterior.urlNuvemHomologacao;
    if (conexaoMudou) {
      await _repositorioSessaoNuvem.remover();
      await _repositorioSessaoLoja.remover();
    }
    state = state.copyWith(
      configuracao: nova,
      usuario: usuario,
      senha: senha,
      nomeEstabelecimento: conexaoMudou ? '' : state.nomeEstabelecimento,
      statusLocal:
          conexaoMudou ? StatusConexao.desconhecido : state.statusLocal,
      statusNuvem:
          conexaoMudou ? StatusConexao.desconhecido : state.statusNuvem,
      latenciaLocalMs: conexaoMudou ? null : state.latenciaLocalMs,
      latenciaNuvemMs: conexaoMudou ? null : state.latenciaNuvemMs,
      usuarioNuvem: conexaoMudou ? '' : state.usuarioNuvem,
      salvando: false,
      mensagem: 'Comunicação salva.',
      mensagemErro: false,
    );
  }

  /// Testa a API da loja: comunicação + login real com os dados já salvos.
  /// Cada servidor emite o próprio token; um login não vale pelo outro.
  Future<void> testarApiLocal() async {
    state = state.copyWith(
      testandoLocal: true,
      statusLocal: StatusConexao.verificando,
      mensagem: null,
    );
    final cronometro = Stopwatch()..start();
    final conexao = await _casoUsoTestarConexao.executarLoja();
    cronometro.stop();
    if (conexao case Erro(:final falha)) {
      return _falhou(falha, origem: 'API Local', local: true);
    }
    final login = await _casoUsoLoginLoja.executar();
    state = login.quando(
      sucesso: (sessao) => state.copyWith(
        testandoLocal: false,
        statusLocal: StatusConexao.conectado,
        latenciaLocalMs: cronometro.elapsedMilliseconds,
        ultimaVerificacao: DateTime.now(),
        nomeEstabelecimento: sessao.estabelecimento.nome,
        mensagem: 'API Local OK · ${sessao.usuario.nome}'
            ' · ${sessao.estabelecimento.nome}',
        mensagemErro: false,
      ),
      erro: (falha) {
        registrador.w('Teste da API Local: ${falha.mensagem}');
        return state.copyWith(
          testandoLocal: false,
          statusLocal: StatusConexao.erro,
          ultimaVerificacao: DateTime.now(),
          mensagem: 'API Local: ${falha.mensagem}',
          mensagemErro: true,
        );
      },
    );
  }

  /// Testa a API na nuvem: comunicação + login real.
  Future<void> testarApiNuvem() async {
    state = state.copyWith(
      testandoNuvem: true,
      statusNuvem: StatusConexao.verificando,
      mensagem: null,
    );
    final cronometro = Stopwatch()..start();
    final conexao = await _casoUsoTestarConexao.executarNuvem();
    cronometro.stop();
    if (conexao case Erro(:final falha)) {
      return _falhou(falha, origem: 'API Nuvem', local: false);
    }
    final login = await _casoUsoLoginNuvem.executar();
    state = login.quando(
      sucesso: (sessao) => state.copyWith(
        testandoNuvem: false,
        statusNuvem: StatusConexao.conectado,
        latenciaNuvemMs: cronometro.elapsedMilliseconds,
        ultimaVerificacao: DateTime.now(),
        nomeEstabelecimento: sessao.estabelecimento.nome,
        usuarioNuvem: sessao.usuario.nome,
        mensagem: 'API Nuvem OK · ${sessao.usuario.nome}'
            ' · ${sessao.estabelecimento.nome}',
        mensagemErro: false,
      ),
      erro: (falha) {
        registrador.w('Teste da API Nuvem: ${falha.mensagem}');
        return state.copyWith(
          testandoNuvem: false,
          statusNuvem: StatusConexao.erro,
          ultimaVerificacao: DateTime.now(),
          mensagem: 'API Nuvem: ${falha.mensagem}',
          mensagemErro: true,
        );
      },
    );
  }

  /// Testa as duas APIs em sequência, para o painel de status.
  Future<void> verificarTodas() async {
    await testarApiLocal();
    await testarApiNuvem();
  }

  void _falhou(Falha falha, {required String origem, required bool local}) {
    registrador.w('Teste da $origem: ${falha.mensagem}');
    state = state.copyWith(
      testandoLocal: local ? false : state.testandoLocal,
      testandoNuvem: local ? state.testandoNuvem : false,
      statusLocal: local ? StatusConexao.erro : state.statusLocal,
      statusNuvem: local ? state.statusNuvem : StatusConexao.erro,
      ultimaVerificacao: DateTime.now(),
      mensagem: falha.mensagem,
      mensagemErro: true,
    );
  }

  void limparMensagem() => state = state.copyWith(mensagem: null);
}

final provedorConfiguracoes = StateNotifierProvider.autoDispose<
    ControladorConfiguracoes, EstadoConfiguracoes>((ref) {
  final controlador = ControladorConfiguracoes(
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    repositorioCredencial: ref.watch(provedorRepositorioCredencial),
    repositorioSessaoNuvem: ref.watch(provedorRepositorioSessaoNuvem),
    repositorioSessaoLoja: ref.watch(provedorRepositorioSessaoLoja),
    casoUsoTestarConexao: ref.watch(provedorCasoUsoTestarConexao),
    casoUsoLoginNuvem: ref.watch(provedorCasoUsoLoginNuvem),
    casoUsoLoginLoja: ref.watch(provedorCasoUsoLoginLoja),
  );
  controlador.carregar();
  return controlador;
});
