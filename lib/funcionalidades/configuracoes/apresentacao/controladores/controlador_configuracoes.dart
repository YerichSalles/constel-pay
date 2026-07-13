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
  }) async {
    state = state.copyWith(salvando: true, mensagem: null);
    if (usuario.isNotEmpty || senha.isNotEmpty) {
      await _repositorioCredencial
          .salvar(Credencial(usuario: usuario, senha: senha));
    }
    final nova = state.configuracao.copyWith(
      ambiente: ambiente,
      identificadorDispositivo: identificadorDispositivo?.trim() ??
          state.configuracao.identificadorDispositivo,
      idDispositivo: idDispositivo?.trim() ?? state.configuracao.idDispositivo,
      urlBaseProducao: comBarraFinal(urlProducao.trim()),
      urlBaseHomologacao: comBarraFinal(urlHomologacao.trim()),
      urlNuvemProducao: comBarraFinal(
          urlNuvemProducao?.trim() ?? state.configuracao.urlNuvemProducao),
      urlNuvemHomologacao: comBarraFinal(urlNuvemHomologacao?.trim() ??
          state.configuracao.urlNuvemHomologacao),
    );
    await _repositorioConfiguracao.salvar(nova);
    // Credencial, ambiente ou URL podem ter mudado: as sessões gravadas
    // ficariam apontando para o usuário/ambiente antigo até expirar.
    await _repositorioSessaoNuvem.remover();
    await _repositorioSessaoLoja.remover();
    state = state.copyWith(
      configuracao: nova,
      usuario: usuario,
      senha: senha,
      nomeEstabelecimento: '',
      salvando: false,
      mensagem: 'Comunicação salva.',
      mensagemErro: false,
    );
  }

  /// Testa a API da loja: comunicação + login real com os dados já salvos.
  /// Cada servidor emite o próprio token; um login não vale pelo outro.
  Future<void> testarApiLocal() async {
    state = state.copyWith(testandoLocal: true, mensagem: null);
    final conexao = await _casoUsoTestarConexao.executarLoja();
    if (conexao case Erro(:final falha)) {
      return _falhou(falha, origem: 'API Local', local: true);
    }
    final login = await _casoUsoLoginLoja.executar();
    state = login.quando(
      sucesso: (sessao) => state.copyWith(
        testandoLocal: false,
        nomeEstabelecimento: sessao.estabelecimento.nome,
        mensagem: 'API Local OK · ${sessao.usuario.nome}'
            ' · ${sessao.estabelecimento.nome}',
        mensagemErro: false,
      ),
      erro: (falha) {
        registrador.w('Teste da API Local: ${falha.mensagem}');
        return state.copyWith(
          testandoLocal: false,
          mensagem: 'API Local: ${falha.mensagem}',
          mensagemErro: true,
        );
      },
    );
  }

  /// Testa a API na nuvem: comunicação + login real.
  Future<void> testarApiNuvem() async {
    state = state.copyWith(testandoNuvem: true, mensagem: null);
    final conexao = await _casoUsoTestarConexao.executarNuvem();
    if (conexao case Erro(:final falha)) {
      return _falhou(falha, origem: 'API Nuvem', local: false);
    }
    final login = await _casoUsoLoginNuvem.executar();
    state = login.quando(
      sucesso: (sessao) => state.copyWith(
        testandoNuvem: false,
        nomeEstabelecimento: sessao.estabelecimento.nome,
        mensagem: 'API Nuvem OK · ${sessao.usuario.nome}'
            ' · ${sessao.estabelecimento.nome}',
        mensagemErro: false,
      ),
      erro: (falha) {
        registrador.w('Teste da API Nuvem: ${falha.mensagem}');
        return state.copyWith(
          testandoNuvem: false,
          mensagem: 'API Nuvem: ${falha.mensagem}',
          mensagemErro: true,
        );
      },
    );
  }

  void _falhou(Falha falha, {required String origem, required bool local}) {
    registrador.w('Teste da $origem: ${falha.mensagem}');
    state = state.copyWith(
      testandoLocal: local ? false : state.testandoLocal,
      testandoNuvem: local ? state.testandoNuvem : false,
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
