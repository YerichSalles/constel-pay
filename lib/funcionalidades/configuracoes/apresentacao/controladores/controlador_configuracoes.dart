import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../aplicativo/injecao.dart';
import '../../../../nucleo/configuracao/ambiente.dart';
import '../../../../nucleo/formatadores/formatador_data.dart';
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
    @Default(true) bool carregando,
    @Default(false) bool salvando,
    @Default(false) bool testando,
    String? mensagem,
    @Default(false) bool mensagemErro,
  }) = _EstadoConfiguracoes;
}

class ControladorConfiguracoes extends StateNotifier<EstadoConfiguracoes> {
  ControladorConfiguracoes({
    required RepositorioConfiguracao repositorioConfiguracao,
    required RepositorioCredencial repositorioCredencial,
    required CasoUsoTestarConexao casoUsoTestarConexao,
  })  : _repositorioConfiguracao = repositorioConfiguracao,
        _repositorioCredencial = repositorioCredencial,
        _casoUsoTestarConexao = casoUsoTestarConexao,
        super(const EstadoConfiguracoes());

  final RepositorioConfiguracao _repositorioConfiguracao;
  final RepositorioCredencial _repositorioCredencial;
  final CasoUsoTestarConexao _casoUsoTestarConexao;

  Future<void> carregar() async {
    final configuracao = await _repositorioConfiguracao.obter();
    final credencial = await _repositorioCredencial.obter();
    state = state.copyWith(
      configuracao: configuracao,
      usuario: credencial?.usuario ?? '',
      senha: credencial?.senha ?? '',
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
  }) async {
    state = state.copyWith(salvando: true, mensagem: null);
    if (usuario.isNotEmpty || senha.isNotEmpty) {
      await _repositorioCredencial
          .salvar(Credencial(usuario: usuario, senha: senha));
    }
    final nova = state.configuracao.copyWith(
      ambiente: ambiente,
      urlBaseProducao: urlProducao.trim(),
      urlBaseHomologacao: urlHomologacao.trim(),
      urlNuvemProducao:
          urlNuvemProducao?.trim() ?? state.configuracao.urlNuvemProducao,
      urlNuvemHomologacao:
          urlNuvemHomologacao?.trim() ?? state.configuracao.urlNuvemHomologacao,
    );
    await _repositorioConfiguracao.salvar(nova);
    state = state.copyWith(
      configuracao: nova,
      usuario: usuario,
      senha: senha,
      salvando: false,
      mensagem: 'Comunicação salva.',
      mensagemErro: false,
    );
  }

  Future<void> testarConexao() async {
    state = state.copyWith(testando: true, mensagem: null);
    final resultado = await _casoUsoTestarConexao.executar();
    state = resultado.quando(
      sucesso: (momento) => state.copyWith(
        testando: false,
        mensagem: 'Conexão OK · ${FormatadorData.hora(momento)}',
        mensagemErro: false,
      ),
      erro: (falha) => state.copyWith(
        testando: false,
        mensagem: falha.mensagem,
        mensagemErro: true,
      ),
    );
  }

  void limparMensagem() => state = state.copyWith(mensagem: null);
}

final provedorConfiguracoes = StateNotifierProvider.autoDispose<
    ControladorConfiguracoes, EstadoConfiguracoes>((ref) {
  final controlador = ControladorConfiguracoes(
    repositorioConfiguracao: ref.watch(provedorRepositorioConfiguracao),
    repositorioCredencial: ref.watch(provedorRepositorioCredencial),
    casoUsoTestarConexao: ref.watch(provedorCasoUsoTestarConexao),
  );
  controlador.carregar();
  return controlador;
});
